import 'metrics.dart';

/// 报告页渲染所需的全部内容。
/// 数字类字段来自 [ChatMetrics]（本地统计），叙事类字段来自 LLM。
class RelationshipReport {
  final ChatMetrics metrics;
  final int warmth; // 0–100
  final String warmthReason;
  final List<MonthMood> emotionCurve;
  final List<TopicShare> topics;
  final List<String> personalityYou;
  final List<String> personalityPartner;
  final String deepReading;
  final List<Milestone> milestones;
  final List<String> advice;

  RelationshipReport({
    required this.metrics,
    required this.warmth,
    required this.warmthReason,
    required this.emotionCurve,
    required this.topics,
    required this.personalityYou,
    required this.personalityPartner,
    required this.deepReading,
    required this.milestones,
    required this.advice,
  });
}

class MonthMood {
  final String label; // e.g. 2026-04
  final double sentiment; // 1–10
  final String? note; // 峰/谷事件注释
  MonthMood(this.label, this.sentiment, {this.note});
}

class TopicShare {
  final String topic;
  final int weight;
  TopicShare(this.topic, this.weight);
}

class Milestone {
  final String date;
  final String title;
  final String quote;
  Milestone(this.date, this.title, this.quote);
}
