import 'dart:async';
import 'dart:convert';

import '../models/chat_data.dart';
import '../models/metrics.dart';
import '../models/report.dart';
import 'zai_client.dart';

/// 分析进度回调：stage 供 UI 展示阶段文案，fraction ∈ [0,1]。
typedef ProgressCallback = void Function(String stage, double fraction);

/// 两段式 LLM 管线：
///   Stage 1  按月分块 → glm-4.5-flash 并行产出结构化 JSON
///   Stage 2  月度 JSON + 本地统计 → glm-4.6 汇总成叙事报告
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
                await _analyzeChunk(entry.key, entry.value, language);
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
    final report =
        await _aggregate(metrics, relationship, monthResults, language);
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
      String month, String text, String language) {
    return _client.completeJson(
      model: ZaiClient.flashModel,
      maxTokens: 1024,
      system: 'You analyze a month of chat messages between two people. '
          'Reply with STRICT JSON only, no prose, in this shape: '
          '{"sentiment": 1-10, "topics": ["..."], '
          '"notable_quotes": [{"quote": "...", "who": "...", "day": "..."}], '
          '"events": ["short event description"], "summary": "one sentence"}. '
          'Write every human-readable value (topics, events, summary) in $language. '
          'Topics are short nouns (e.g. "Food", "Work", "Travel"). '
          'Keep notable_quotes verbatim in their original language. '
          'At most 3 quotes and 2 events.',
      user: 'Month $month:\n$text',
    );
  }

  Future<RelationshipReport> _aggregate(
    ChatMetrics metrics,
    Relationship relationship,
    Map<String, Map<String, dynamic>> months,
    String language,
  ) async {
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
      'monthly': months,
      'top_topics': [for (final t in topTopics.take(8)) t.key],
    });

    final json = await _withRetry(() => _client.completeJson(
      model: ZaiClient.proModel,
      maxTokens: 3000,
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
          'Write ALL human-readable output — warmth_reason, month_notes, personality tags, '
          'deep_reading, milestone titles, advice — in $language. '
          'Keep quotes verbatim in their original language. '
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
    );
  }

  /// 429 指数退避重试；其他异常直接抛出。
  Future<T> _withRetry<T>(Future<T> Function() task) async {
    for (var attempt = 1; ; attempt++) {
      try {
        return await task();
      } on ZaiException catch (e) {
        if (!e.isRateLimited || attempt >= _maxAttempts) rethrow;
        // ignore: avoid_print
        print('[pipeline] rate limited, retrying in ${3 * attempt}s');
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
