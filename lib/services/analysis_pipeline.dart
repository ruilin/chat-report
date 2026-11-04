import 'dart:async';
import 'dart:convert';

import '../models/chat_data.dart';
import '../models/deep_dive.dart';
import '../models/metrics.dart';
import '../models/report.dart';
import 'analytics.dart';
import 'quote_verifier.dart';
import 'zai_client.dart';

/// 分析进度回调：stage 供 UI 展示阶段文案，fraction ∈ [0,1]。
typedef ProgressCallback = void Function(String stage, double fraction);

/// 两段式 LLM 管线：
///   Stage 1  按月分块 → [ZaiClient.flashModel] 并行产出结构化 JSON
///   Stage 2  月度 JSON + 本地统计 → [ZaiClient.reportModel] 汇总成叙事报告和专题分析
class AnalysisPipeline {
  final ZaiClient _client;
  static const _maxChunkChars = 12000;
  // flash 免费档并发配额很低，2 路已实测会偶发 429，靠退避重试兜底
  static const _concurrency = 2;
  static const _maxAttempts = 4;

  AnalysisPipeline([ZaiClient? client]) : _client = client ?? ZaiClient();

  Future<RelationshipReport> run({
    required ChatData data,
    required ChatMetrics metrics,
    required Relationship relationship,
    /// 报告正文的输出语言（跟随 App 界面语言），如 "English" / "Simplified Chinese"
    String language = 'English',
    ProgressCallback? onProgress,
  }) async {
    onProgress?.call('Reading ${metrics.totalMessages} messages', .05);

    final chunks = _chunkByMonth(data);
    onProgress?.call('Reading between the lines', .1);

    final monthResults = <String, Map<String, dynamic>>{};
    var done = 0;
    Object? lastError;

    // 有限并发跑分块分析。429 限流指数退避重试；其他错误重试一次；
    // 最终仍失败则跳过该月（留下日志与错误）。
    final queue = chunks.entries.toList();
    Future<void> worker() async {
      while (queue.isNotEmpty) {
        final entry = queue.removeAt(0);
        for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
          try {
            monthResults[entry.key] =
                await _analyzeChunk(entry.key, entry.value, language, metrics);
            break;
          } catch (e) {
            lastError = e;
            // ignore: avoid_print
            print('[pipeline] chunk ${entry.key} attempt $attempt failed: $e');
            final rateLimited = e is ZaiException && e.isRateLimited;
            if (!rateLimited && attempt >= 2) break; // 非限流只重试一次
            if (attempt < _maxAttempts) {
              await Future.delayed(Duration(seconds: 3 * attempt));
            }
          }
        }
        done++;
        onProgress?.call(
            'Reading between the lines', .1 + .6 * done / chunks.length);
      }
    }

    await Future.wait(List.generate(
        _concurrency.clamp(1, chunks.length), (_) => worker()));

    if (monthResults.isEmpty) {
      // 保留最后一次错误的类型与状态码，界面文案和埋点都靠它区分原因
      final last = lastError;
      throw ZaiException('所有月份分析都失败了。$last',
          statusCode: last is ZaiException ? last.statusCode : null,
          kind: last is ZaiException ? last.kind : ZaiErrorKind.http);
    }

    onProgress?.call('Writing your report', .75);
    final report = await _aggregate(
        metrics, relationship, monthResults, language,
        deepDive: () async {
      onProgress?.call('Writing your report', .88);
      return _deepDive(data, metrics, relationship, monthResults, language);
    });
    onProgress?.call('Done', 1);
    return report;
  }

  /// 按自然月分块；超长月份截断（保头保尾，中段抽稀在 V1.1 做）。
  Map<String, String> _chunkByMonth(ChatData data) {
    final byMonth = <String, StringBuffer>{};
    for (final m in data.messages) {
      if (m.isMedia) continue;
      final key =
          '${m.time.year}-${m.time.month.toString().padLeft(2, '0')}';
      final buf = byMonth.putIfAbsent(key, StringBuffer.new);
      if (buf.length > _maxChunkChars) continue;
      buf.writeln(
          '${m.time.day} ${m.time.hour}:${m.time.minute.toString().padLeft(2, '0')} ${m.sender}: ${m.text}');
    }
    return {
      for (final e in byMonth.entries)
        if (e.value.isNotEmpty) e.key: e.value.toString(),
    };
  }

  Future<Map<String, dynamic>> _analyzeChunk(
      String month, String text, String language, ChatMetrics metrics) {
    return _client.completeJson(
      model: ZaiClient.flashModel,
      maxTokens: 2400,
      system: 'You analyze a month of chat messages between two people. '
          'Reply with STRICT JSON only, no prose, in this shape: '
          '{"sentiment": 1-10, "topics": ["..."], '
          '"notable_quotes": [{"quote": "...", "who": "...", "day": "..."}], '
          '"events": ["short event description"], "summary": "one sentence", '
          '"conflict_moments": [{"about": "what the disagreement was about", "who_reached_out_first": "...", "quote": "..."}], '
          '"signals": [{"kind": "red or green", "label": "short description", "quote": "..."}]}. '
          'conflict_moments and signals are empty arrays when nothing fits; never stretch to fill them. '
          'A red signal is a concerning pattern such as contempt, stonewalling, guilt-tripping or controlling behavior; '
          'a green signal is a healthy one such as repair attempts, curiosity or support. '
          'Every quote is the text of one message copied exactly, without sender or time. '
          'Topics are short nouns (e.g. "Food", "Work", "Travel"). '
          'At most 3 quotes, 2 events, 2 conflict_moments and 3 signals. '
          '${_languageRules(language, metrics)}',
      user: 'Month $month:\n$text',
    );
  }

  Future<RelationshipReport> _aggregate(
    ChatMetrics metrics,
    Relationship relationship,
    Map<String, Map<String, dynamic>> months,
    String language, {
    required Future<DeepDive?> Function() deepDive,
  }) async {
    // 话题权重本地聚合（数字不交给模型算）
    final topicCount = <String, int>{};
    for (final m in months.values) {
      for (final t in (m['topics'] as List? ?? [])) {
        final key = t.toString();
        topicCount[key] = (topicCount[key] ?? 0) + 1;
      }
    }
    final topTopics = topicCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final input = jsonEncode({
      'relationship': relationship.promptName,
      'you': metrics.you,
      'partner': metrics.partner,
      'stats': metrics.toPromptJson(),
      // 争吵和信号只给专题分析用，免费报告的输入保持不变
      'monthly': {
        for (final e in months.entries)
          e.key: {
            for (final f in e.value.entries)
              if (f.key != 'conflict_moments' && f.key != 'signals')
                f.key: f.value,
          },
      },
      'top_topics': [for (final t in topTopics.take(8)) t.key],
    });

    final json = await _withRetry(() => _client.completeJson(
      model: ZaiClient.reportModel,
      maxTokens: 5000,
      system:
          'You are Chat Report, an app that writes warm, evidence-based readings of a '
          'two-person chat history. You receive locally-computed stats (treat every '
          'number as ground truth — never invent numbers) and per-month analysis JSON. '
          'Reply with STRICT JSON only: '
          '{"warmth": 0-100, "warmth_reason": "one sentence", '
          '"month_notes": {"YYYY-MM": "short note"} (only the single peak month and the single lowest month), '
          '"personality_you": ["3 short playful tags"], '
          '"personality_partner": ["3 short playful tags"], '
          '"deep_reading": "300-400 word reading of the relationship: rhythm, turning points, what each person values. Warm but honest, grounded in the data.", '
          '"milestones": [{"date": "YYYY-MM", "title": "...", "quote": "verbatim quote"}] (3-5 items), '
          '"advice": ["3 specific suggestions"]}. '
          'Use hedged language ("signs of", "tends to") — never diagnose. '
          'If relationship is "ex", stay reflective and never encourage re-contact. '
          '${_languageRules(language, metrics)} ${_addressRules(metrics)} '
          'JSON keys stay in English.',
      user: input,
    ));

    final curve = _buildCurve(metrics, months, json['month_notes']);

    List<String> strList(dynamic v, {int max = 3}) => [
          for (final s in (v as List? ?? [])) s.toString()
        ].take(max).toList();

    return RelationshipReport(
      metrics: metrics,
      warmth: (json['warmth'] as num?)?.round().clamp(0, 100) ?? 50,
      warmthReason: json['warmth_reason']?.toString() ?? '',
      emotionCurve: curve,
      topics: [
        for (final t in topTopics.take(5)) TopicShare(t.key, t.value),
      ],
      personalityYou: strList(json['personality_you']),
      personalityPartner: strList(json['personality_partner']),
      deepReading: json['deep_reading']?.toString() ?? '',
      milestones: [
        for (final m in (json['milestones'] as List? ?? []))
          if (m is Map)
            Milestone(m['date']?.toString() ?? '', m['title']?.toString() ?? '',
                m['quote']?.toString() ?? ''),
      ].take(5).toList(),
      advice: strList(json['advice']),
      deepDive: await deepDive(),
      relationship: relationship.promptName,
    );
  }

  /// 专题分析和免费报告一起生成：付款后立刻能看，也不用为了付费后再分析
  /// 而把聊天原文留在手机上。失败只影响付费入口，不影响免费报告。
  Future<DeepDive?> _deepDive(
    ChatData data,
    ChatMetrics metrics,
    Relationship relationship,
    Map<String, Map<String, dynamic>> months,
    String language,
  ) async {
    try {
      final json = await _withRetry(() => _client.completeJson(
            model: ZaiClient.reportModel,
            maxTokens: 5000,
            system:
                'You write the premium section of Chat Report, a reading of a two-person chat history. '
                'You receive locally-computed stats (ground truth, never invent numbers) and per-month '
                'analysis JSON. Reply with STRICT JSON only: '
                '{"conflict": {"summary": "2-3 sentences: what they tend to fight about, who usually reaches out first, how it tends to end", '
                '"moments": [{"date": "YYYY-MM", "title": "...", "detail": "one sentence", "quote": "..."}] (0-3 items)}, '
                '"red_flags": [{"date": "YYYY-MM", "title": "...", "detail": "one sentence", "quote": "..."}] (0-4 items), '
                '"green_flags": [same shape] (0-4 items), '
                '"attachment": {"you": {"style": "exactly one of anxious, avoidant, secure, mixed", "detail": "1-2 sentences"}, '
                '"partner": {"style": "...", "detail": "..."}, "loop": "1-2 sentences on the pattern they get stuck in together"}, '
                '"turning_points": [{"date": "YYYY-MM", "direction": "up or down", "title": "...", "detail": "one sentence", "quote": "..."}] (0-4 items)}. '
                'Every quote must be copied character for character from a quote field in the input; '
                'anything else will be discarded. Leave a list empty rather than stretching: '
                'do not invent red flags to seem insightful, and do not pad green flags. '
                'Use hedged language ("signs of", "tends to"). Attachment styles are tendencies seen in these '
                'messages, never a diagnosis; never diagnose anyone. '
                'If relationship is "ex", stay reflective and never encourage re-contact. '
                'If relationship is "friend" or "family", read it as that kind of bond, not a romance. '
                'If the chat shows threats, violence, coercion or self-harm, say so gently and suggest talking to '
                'someone they trust or a local support service, without drawing conclusions. '
                '${_languageRules(language, metrics)} ${_addressRules(metrics)} '
                'JSON keys, the direction value and the style value stay in English.',
            user: jsonEncode({
              'relationship': relationship.promptName,
              'you': metrics.you,
              'partner': metrics.partner,
              'stats': metrics.toPromptJson(),
              'monthly': months,
            }),
          ));
      final dive = parseDeepDive(json, QuoteVerifier(data));
      return dive.isEmpty ? null : dive;
    } catch (e) {
      // ignore: avoid_print
      print('[pipeline] deep dive failed: $e');
      Analytics.deepDiveFail(e is ZaiException ? e.kind.name : 'other');
      return null;
    }
  }

  /// 把模型输出转成 [DeepDive]。引用对不上聊天记录的条目直接丢弃
  static DeepDive parseDeepDive(
      Map<String, dynamic> json, QuoteVerifier verifier) {
    final month = RegExp(r'^\d{4}-\d{2}$');

    Map<String, String>? verified(dynamic v) {
      if (v is! Map) return null;
      final title = v['title']?.toString().trim() ?? '';
      final quote = v['quote']?.toString().trim() ?? '';
      if (title.isEmpty || !verifier.contains(quote)) return null;
      final date = v['date']?.toString().trim() ?? '';
      return {
        'date': month.hasMatch(date) ? date : '',
        'title': title,
        'detail': v['detail']?.toString().trim() ?? '',
        'quote': quote,
      };
    }

    List<EvidenceItem> items(dynamic list, {int max = 4}) => [
          for (final v in (list is List ? list : const []))
            if (verified(v) case final m?)
              EvidenceItem(
                  date: m['date']!,
                  title: m['title']!,
                  detail: m['detail']!,
                  quote: m['quote']!),
        ].take(max).toList();

    final conflict = json['conflict'];
    final attachment = json['attachment'];
    return DeepDive(
      conflictSummary:
          conflict is Map ? conflict['summary']?.toString().trim() ?? '' : '',
      conflicts: items(conflict is Map ? conflict['moments'] : null, max: 3),
      redFlags: items(json['red_flags']),
      greenFlags: items(json['green_flags']),
      attachmentYou: attachment is Map
          ? AttachmentRead.maybeFromJson(attachment['you'])
          : null,
      attachmentPartner: attachment is Map
          ? AttachmentRead.maybeFromJson(attachment['partner'])
          : null,
      attachmentLoop:
          attachment is Map ? attachment['loop']?.toString().trim() ?? '' : '',
      turningPoints: [
        for (final v
            in (json['turning_points'] is List
                ? json['turning_points'] as List
                : const []))
          if (verified(v) case final m?)
            TurningPoint(
                date: m['date']!,
                title: m['title']!,
                detail: m['detail']!,
                quote: m['quote']!,
                rising: (v as Map)['direction']?.toString() != 'down'),
      ].take(4).toList(),
    );
  }

  /// 所有报告提示词共用的语言要求
  static String _languageRules(String language, ChatMetrics metrics) =>
      'Language rules: write every human-readable value in $language only'
      '${language == 'Traditional Chinese' ? ', using Traditional characters throughout' : ''}. '
      'Translate whatever comes from the chat or the input, whatever language it is in, including topic labels. '
      'Never mix in words from another language or script. '
      'The two people are named ${jsonEncode(metrics.you)} and ${jsonEncode(metrics.partner)}: '
      'write these names character for character in their original script, even inside $language text; '
      'never translate or transliterate them. '
      'Never quote messages inside other text: paraphrase them in $language. '
      'Only quote fields hold original wording, copied verbatim in their original language.';

  /// 报告是写给用户本人看的，用第二人称
  static String _addressRules(ChatMetrics metrics) =>
      'Speak directly to ${jsonEncode(metrics.you)} as "you" in the second person and never use their name; '
      'refer to the other person as ${jsonEncode(metrics.partner)}.';

  /// 429 指数退避多试几次；没回应或 JSON 损坏只再试一次；其他异常直接抛出。
  Future<T> _withRetry<T>(Future<T> Function() task) async {
    for (var attempt = 1; ; attempt++) {
      try {
        return await task();
      } on ZaiException catch (e) {
        final retryable = e.isRateLimited || e.isTimedOut || e.isBadResponse;
        final limit = e.isRateLimited ? _maxAttempts : 2;
        if (!retryable || attempt >= limit) rethrow;
        // ignore: avoid_print
        print('[pipeline] ${e.kind.name}, retrying in ${3 * attempt}s');
        await Future.delayed(Duration(seconds: 3 * attempt));
      }
    }
  }

  List<MonthMood> _buildCurve(
    ChatMetrics metrics,
    Map<String, Map<String, dynamic>> months,
    dynamic notes,
  ) {
    final noteMap = notes is Map ? notes : const {};
    final curve = <MonthMood>[];
    for (final b in metrics.months) {
      final key = '${b.year}-${b.month.toString().padLeft(2, '0')}';
      final m = months[key];
      if (m == null) continue;
      final s = (m['sentiment'] as num?)?.toDouble() ?? 5;
      curve.add(MonthMood(key, s.clamp(1, 10),
          note: noteMap[key]?.toString()));
    }
    return curve;
  }

  void dispose() => _client.dispose();
}
