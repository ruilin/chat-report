// 端到端冒烟测试：合成 5 个月的对话 → 解析 → 统计 → 真实调用 z.ai 两段管线。
// 运行：dart run tool/pipeline_smoke.dart（会产生少量真实 API 花费）
import 'dart:io';

import 'package:chat_report/models/chat_data.dart';
import 'package:chat_report/services/analysis_pipeline.dart';
import 'package:chat_report/services/metrics_engine.dart';
import 'package:chat_report/services/whatsapp_parser.dart';

void main() async {
  final buf = StringBuffer();
  final topics = [
    ['did you try that ramen place yet', 'we should cook together this weekend'],
    ['my boss is driving me crazy again', 'you deserve better at that job'],
    ['imagine us in Lisbon next spring', 'I found cheap flights!!'],
    ['lol this meme is so us', '😂😂 send more'],
    ['do you ever think about where this is going', 'yeah… I do, a lot'],
  ];
  for (var month = 3; month <= 7; month++) {
    for (var day = 2; day <= 26; day += 3) {
      final pair = topics[(month + day) % topics.length];
      buf.writeln('$day/0$month/26, 21:1${day % 10} - Uli: ${pair[0]}');
      buf.writeln('$day/0$month/26, 21:3${day % 10} - Sam: ${pair[1]}');
    }
  }
  // 4 月制造一段冷淡期（只留 2 天）
  final raw = buf
      .toString()
      .split('\n')
      .where((l) => !(l.contains('/04/26') && !l.startsWith('2/') && !l.startsWith('5/')))
      .join('\n');

  final data = WhatsAppParser().parse(raw);
  stdout.writeln('parsed: ${data.messages.length} messages, '
      'participants=${data.participants}');

  final metrics = MetricsEngine().compute(data, you: 'Uli');
  stdout.writeln('metrics: share(Uli)=${metrics.shareOf('Uli')} '
      'starts=${metrics.conversationStarts} months=${metrics.months.length}');

  final pipeline = AnalysisPipeline();
  final report = await pipeline.run(
    data: data,
    metrics: metrics,
    relationship: Relationship.partner,
    onProgress: (stage, f) =>
        stdout.writeln('  [${(f * 100).round().toString().padLeft(3)}%] $stage'),
  );
  pipeline.dispose();

  stdout
    ..writeln('--- REPORT ---')
    ..writeln('warmth: ${report.warmth} (${report.warmthReason})')
    ..writeln('curve: ${report.emotionCurve.map((m) => '${m.label}:${m.sentiment}${m.note != null ? '*' : ''}').join(' ')}')
    ..writeln('topics: ${report.topics.map((t) => t.topic).join(', ')}')
    ..writeln('you: ${report.personalityYou.join(' / ')}')
    ..writeln('partner: ${report.personalityPartner.join(' / ')}')
    ..writeln('milestones: ${report.milestones.length}, advice: ${report.advice.length}')
    ..writeln('deep reading: ${report.deepReading.length} chars');
  exit(0);
}
