import 'package:flutter_test/flutter_test.dart';
import 'package:chat_report/services/metrics_engine.dart';
import 'package:chat_report/services/whatsapp_parser.dart';

String _lines(String Function(int i, String who, String text) fmt) {
  final buf = StringBuffer();
  for (var i = 0; i < 20; i++) {
    final who = i.isEven ? 'Uli' : 'Sam';
    buf.writeln(fmt(i, who, 'message number $i'));
  }
  return buf.toString();
}

void main() {
  final parser = WhatsAppParser();

  test('parses Android day-first format', () {
    final raw =
        _lines((i, who, t) => '2${(i % 8) + 1}/03/24, 21:${10 + i} - $who: $t');
    final data = parser.parse(raw);
    expect(data.messages.length, 20);
    expect(data.participants, containsAll(['Uli', 'Sam']));
    expect(data.messages.first.time.month, 3);
    expect(data.messages.first.time.day, greaterThan(12)); // day-first 判定
  });

  test('parses iOS bracketed format with AM/PM', () {
    final raw = _lines(
        (i, who, t) => '[03/21/24, 9:${10 + i}:05 PM] $who: $t');
    final data = parser.parse(raw);
    expect(data.messages.length, 20);
    expect(data.messages.first.time.hour, 21); // PM 转换
    expect(data.messages.first.time.month, 3); // month-first 判定（21>12）
  });

  test('multi-line messages are merged, system lines dropped', () {
    final base = _lines((i, who, t) => '21/03/24, 10:${10 + i} - $who: $t');
    final raw = 'Messages and calls are end-to-end encrypted.\n'
        '$base'
        'continued on a second line without header\n';
    final data = parser.parse(raw);
    expect(data.messages.last.text, contains('second line'));
    expect(
        data.messages.any((m) => m.text.contains('end-to-end')), isFalse);
  });

  test('media placeholders flagged, not counted as text', () {
    final base = _lines((i, who, t) => '21/03/24, 10:${10 + i} - $who: $t');
    final raw = '$base'
        '21/03/24, 10:59 - Sam: <Media omitted>\n';
    final data = parser.parse(raw);
    expect(data.messages.last.isMedia, isTrue);
    expect(data.messages.last.text, isEmpty);
  });

  test('metrics engine computes balance and reply medians', () {
    final raw = _lines((i, who, t) => '21/03/24, ${10 + i}:00 - $who: $t');
    final data = parser.parse(raw);
    final metrics = MetricsEngine().compute(data, you: 'Uli');
    expect(metrics.totalMessages, 20);
    expect(metrics.shareOf('Uli'), closeTo(.5, .01));
    expect(metrics.medianReply['Sam']!.inMinutes, 60);
    expect(metrics.months.single.count, 20);
  });

  test('rejects unparseable text', () {
    expect(() => parser.parse('hello\nworld\n'),
        throwsA(isA<ParseException>()));
  });
}
