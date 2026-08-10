import '../l10n/app_localizations.dart';
import '../models/chat_data.dart';

/// WhatsApp 导出 txt 解析器。
///
/// 支持的行格式（时间戳 locale 差异是这个产品最大的解析风险，
/// 新格式一律加进 _headerPatterns 并补测试）：
///   iOS:     [21/03/24, 9:41:05 PM] Sam: message text
///   Android: 21/03/24, 21:41 - Sam: message text
///   Android(US): 3/21/24, 9:41 PM - Sam: message text
class WhatsAppParser {
  // iOS: [date, time] Name: text
  static final _iosHeader = RegExp(
      r'^‎?\[(?<date>[\d./-]{6,10}),?\s+(?<time>[\d:]{4,8})(?:\s*(?<ampm>[APap]\.?[Mm]\.?))?\]\s(?<rest>.*)$');
  // Android: date, time - Name: text
  static final _androidHeader = RegExp(
      r'^‎?(?<date>[\d./-]{6,10}),?\s+(?<time>[\d:]{4,8})(?:\s*(?<ampm>[APap]\.?[Mm]\.?))?\s[-–]\s(?<rest>.*)$');

  static final _mediaMarkers = RegExp(
      r'<Media omitted>|image omitted|video omitted|audio omitted|sticker omitted|GIF omitted|document omitted',
      caseSensitive: false);

  static final _systemMarkers = RegExp(
      r'end-to-end encrypted|created group|added you|changed the subject|security code|Disappearing messages|blocked this contact',
      caseSensitive: false);

  /// 解析整份导出文本。消息数不足时抛 [ParseException]。
  ChatData parse(String raw) {
    final lines = raw.split(RegExp(r'\r?\n'));
    final entries = <({String date, String time, String? ampm, String rest})>[];
    final buffer = StringBuffer();

    ({String date, String time, String? ampm, String rest})? matchHeader(
        String line) {
      final m = _iosHeader.firstMatch(line) ?? _androidHeader.firstMatch(line);
      if (m == null) return null;
      return (
        date: m.namedGroup('date')!,
        time: m.namedGroup('time')!,
        ampm: m.namedGroup('ampm'),
        rest: m.namedGroup('rest')!,
      );
    }

    for (final line in lines) {
      final h = matchHeader(line);
      if (h != null) {
        entries.add(h);
        buffer.clear();
      } else if (entries.isNotEmpty && line.trim().isNotEmpty) {
        // 多行消息：拼接到上一条
        final last = entries.removeLast();
        entries.add((
          date: last.date,
          time: last.time,
          ampm: last.ampm,
          rest: '${last.rest}\n${line.trim()}',
        ));
      }
    }

    if (entries.length < 10) {
      throw ParseException(ParseErrorKind.unrecognized, entries.length);
    }

    final dayFirst = _detectDayFirst(entries.map((e) => e.date));

    final messages = <ChatMessage>[];
    final senders = <String, int>{};

    for (final e in entries) {
      final time = _parseDateTime(e.date, e.time, e.ampm, dayFirst);
      if (time == null) continue;

      final colon = e.rest.indexOf(': ');
      if (colon <= 0) continue; // 无发送者 → 系统消息
      final sender = e.rest.substring(0, colon).trim();
      final text = e.rest.substring(colon + 2).trim();
      if (sender.length > 40) continue;
      if (_systemMarkers.hasMatch(text)) continue;

      final isMedia = _mediaMarkers.hasMatch(text);
      messages.add(ChatMessage(
          time: time, sender: sender, text: isMedia ? '' : text, isMedia: isMedia));
      senders[sender] = (senders[sender] ?? 0) + 1;
    }

    if (messages.length < 10) {
      throw ParseException(ParseErrorKind.tooFew, messages.length);
    }

    // 参与者按消息量排序，只保留前 2（群聊场景 MVP 不支持）
    final participants = senders.keys.toList()
      ..sort((a, b) => senders[b]!.compareTo(senders[a]!));

    messages.sort((a, b) => a.time.compareTo(b.time));
    return ChatData(
        messages: messages, participants: participants.take(2).toList());
  }

  /// 日/月顺序探测：任一日期首段 > 12 则确定 day-first；
  /// 全部无法判定时默认 day-first（非美地区占多数）。
  bool _detectDayFirst(Iterable<String> dates) {
    for (final d in dates) {
      final parts = d.split(RegExp(r'[./-]'));
      if (parts.length < 3) continue;
      final a = int.tryParse(parts[0]) ?? 0;
      final b = int.tryParse(parts[1]) ?? 0;
      if (a > 12) return true;
      if (b > 12) return false;
    }
    return true;
  }

  DateTime? _parseDateTime(
      String date, String time, String? ampm, bool dayFirst) {
    final d = date.split(RegExp(r'[./-]')).map(int.tryParse).toList();
    final t = time.split(':').map(int.tryParse).toList();
    if (d.length < 3 || t.length < 2) return null;
    if (d.contains(null) || t.contains(null)) return null;

    int day = dayFirst ? d[0]! : d[1]!;
    int month = dayFirst ? d[1]! : d[0]!;
    int year = d[2]!;
    if (year < 100) year += 2000;
    // 有些 locale 是 yyyy/mm/dd
    if (d[0]! > 1000) {
      year = d[0]!;
      month = d[1]!;
      day = d[2]!;
    }

    int hour = t[0]!;
    final minute = t[1]!;
    final second = t.length > 2 ? (t[2] ?? 0) : 0;
    if (ampm != null) {
      final pm = ampm.toLowerCase().startsWith('p');
      if (pm && hour != 12) hour += 12;
      if (!pm && hour == 12) hour = 0;
    }

    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    return DateTime(year, month, day, hour, minute, second);
  }
}

enum ParseErrorKind { unrecognized, tooFew }

class ParseException implements Exception {
  final ParseErrorKind kind;
  final int count;
  ParseException(this.kind, this.count);

  /// 本地化文案（UI 层调用；toString 保留技术描述供日志用）
  String localize(L l) => switch (kind) {
        ParseErrorKind.unrecognized => l.parseUnrecognized(count),
        ParseErrorKind.tooFew => l.parseTooFew(count),
      };

  @override
  String toString() => 'ParseException(${kind.name}, $count)';
}
