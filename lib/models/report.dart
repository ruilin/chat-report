import 'coach.dart';
import 'deep_dive.dart';
import 'metrics.dart';

/// 报告页渲染所需的全部内容。
/// 数字类字段来自 [ChatMetrics]（本地统计），叙事类字段来自 LLM。
class RelationshipReport {
  /// 本机唯一标识，也是存储文件名
  final String id;
  final DateTime createdAt;
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

  /// 付费专题分析。生成失败或内容不足时为 null，此时不展示付费入口
  final DeepDive? deepDive;
  bool deepDiveUnlocked;

  /// 关系类型的稳定标识（Relationship.promptName），AI 教练据此调整语气
  final String relationship;

  /// 和 AI 教练的对话
  final List<CoachMessage> coachMessages;

  RelationshipReport({
    String? id,
    DateTime? createdAt,
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
    this.deepDive,
    this.deepDiveUnlocked = false,
    this.relationship = '',
    List<CoachMessage>? coachMessages,
  })  : coachMessages = coachMessages ?? [],
        createdAt = createdAt ?? DateTime.now(),
        id = id ?? (createdAt ?? DateTime.now()).microsecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
        'id': id,
        'created_at': createdAt.toIso8601String(),
        'metrics': metrics.toJson(),
        'warmth': warmth,
        'warmth_reason': warmthReason,
        'emotion_curve': [for (final m in emotionCurve) m.toJson()],
        'topics': [for (final t in topics) t.toJson()],
        'personality_you': personalityYou,
        'personality_partner': personalityPartner,
        'deep_reading': deepReading,
        'milestones': [for (final m in milestones) m.toJson()],
        'advice': advice,
        'deep_dive': deepDive?.toJson(),
        'deep_dive_unlocked': deepDiveUnlocked,
        'relationship': relationship,
        'coach_messages': [for (final m in coachMessages) m.toJson()],
      };

  factory RelationshipReport.fromJson(Map<String, dynamic> j) {
    List<String> strings(dynamic v) => [for (final s in v as List) s as String];
    final dive = j['deep_dive'];
    return RelationshipReport(
      id: j['id'] as String,
      createdAt: DateTime.parse(j['created_at'] as String),
      metrics: ChatMetrics.fromJson(j['metrics'] as Map<String, dynamic>),
      warmth: j['warmth'] as int,
      warmthReason: j['warmth_reason'] as String,
      emotionCurve: [
        for (final m in j['emotion_curve'] as List)
          MonthMood.fromJson(m as Map<String, dynamic>),
      ],
      topics: [
        for (final t in j['topics'] as List)
          TopicShare.fromJson(t as Map<String, dynamic>),
      ],
      personalityYou: strings(j['personality_you']),
      personalityPartner: strings(j['personality_partner']),
      deepReading: j['deep_reading'] as String,
      milestones: [
        for (final m in j['milestones'] as List)
          Milestone.fromJson(m as Map<String, dynamic>),
      ],
      advice: strings(j['advice']),
      deepDive:
          dive == null ? null : DeepDive.fromJson(dive as Map<String, dynamic>),
      deepDiveUnlocked: j['deep_dive_unlocked'] as bool? ?? false,
      relationship: j['relationship'] as String? ?? '',
      coachMessages: [
        for (final m in (j['coach_messages'] as List? ?? const []))
          CoachMessage.fromJson(m as Map<String, dynamic>),
      ],
    );
  }
}

class MonthMood {
  final String label; // e.g. 2026-04
  final double sentiment; // 1–10
  final String? note; // 峰/谷事件注释
  MonthMood(this.label, this.sentiment, {this.note});

  Map<String, dynamic> toJson() =>
      {'label': label, 'sentiment': sentiment, 'note': note};

  factory MonthMood.fromJson(Map<String, dynamic> j) => MonthMood(
      j['label'] as String, (j['sentiment'] as num).toDouble(),
      note: j['note'] as String?);
}

class TopicShare {
  final String topic;
  final int weight;
  TopicShare(this.topic, this.weight);

  Map<String, dynamic> toJson() => {'topic': topic, 'weight': weight};

  factory TopicShare.fromJson(Map<String, dynamic> j) =>
      TopicShare(j['topic'] as String, j['weight'] as int);
}

class Milestone {
  final String date;
  final String title;
  final String quote;
  Milestone(this.date, this.title, this.quote);

  Map<String, dynamic> toJson() =>
      {'date': date, 'title': title, 'quote': quote};

  factory Milestone.fromJson(Map<String, dynamic> j) => Milestone(
      j['date'] as String, j['title'] as String, j['quote'] as String);
}
