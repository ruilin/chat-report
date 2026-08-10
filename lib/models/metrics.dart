/// 本地统计结果 —— 全部由代码计算，不经 LLM（报告里的数字必须可追溯）。
class ChatMetrics {
  final String you;
  final String partner;

  final int totalMessages;
  final Map<String, int> messageCount; // sender -> count
  final Map<String, int> conversationStarts; // 谁先开启对话（>3h 间隔算新对话）
  final Map<String, Duration> medianReply; // sender -> 回复延迟中位数
  final Map<String, double> avgLength; // sender -> 平均字符数
  final int lateNightCount; // 22:00–04:00 消息数
  final int longestSilenceDays;
  final List<MonthBucket> months;

  ChatMetrics({
    required this.you,
    required this.partner,
    required this.totalMessages,
    required this.messageCount,
    required this.conversationStarts,
    required this.medianReply,
    required this.avgLength,
    required this.lateNightCount,
    required this.longestSilenceDays,
    required this.months,
  });

  double shareOf(String sender) =>
      totalMessages == 0 ? 0 : (messageCount[sender] ?? 0) / totalMessages;

  double startShareOf(String sender) {
    final total =
        conversationStarts.values.fold<int>(0, (a, b) => a + b);
    return total == 0 ? 0 : (conversationStarts[sender] ?? 0) / total;
  }

  Map<String, dynamic> toPromptJson() => {
        'total_messages': totalMessages,
        'messages_by_sender': messageCount,
        'conversation_starts': conversationStarts,
        'median_reply_seconds': medianReply
            .map((k, v) => MapEntry(k, v.inSeconds)),
        'avg_message_chars':
            avgLength.map((k, v) => MapEntry(k, v.toStringAsFixed(1))),
        'late_night_messages_22_04': lateNightCount,
        'longest_silence_days': longestSilenceDays,
      };
}

class MonthBucket {
  final int year;
  final int month;
  final int count;
  MonthBucket(this.year, this.month, this.count);

  String get label => '$year-${month.toString().padLeft(2, '0')}';
}
