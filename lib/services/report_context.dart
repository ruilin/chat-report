import 'dart:convert';

import '../models/report.dart';
import 'purchases.dart';

/// 给 AI 教练和消息起草用的报告内容。只有报告，没有聊天原文。
String reportContextJson(RelationshipReport report) {
  final m = report.metrics;
  final dive = report.deepDive;
  return jsonEncode({
    'relationship': report.relationship,
    'user_name': m.you,
    'other_person': m.partner,
    'stats': m.toPromptJson(),
    'warmth': report.warmth,
    'warmth_reason': report.warmthReason,
    'topics': [for (final t in report.topics) t.topic],
    'personality_user': report.personalityYou,
    'personality_other': report.personalityPartner,
    'reading': report.deepReading,
    'milestones': [for (final s in report.milestones) s.toJson()],
    // 没解锁的付费内容不给模型，否则追问就绕过了付费
    if (Purchases.isUnlocked(report)) 'advice': report.advice,
    if (Purchases.isUnlocked(report) && dive != null)
      'deep_dive': dive.toJson(),
  });
}
