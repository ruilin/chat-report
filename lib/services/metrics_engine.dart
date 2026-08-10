import '../models/chat_data.dart';
import '../models/metrics.dart';

/// 纯本地统计引擎。量化指标一律在这里算好，LLM 只负责解读数字。
class MetricsEngine {
  static const _newConversationGap = Duration(hours: 3);
  static const _maxReplyGap = Duration(hours: 12);

  ChatMetrics compute(ChatData data, {required String you}) {
    final msgs = data.messages;
    final partner = data.participants.firstWhere((p) => p != you,
        orElse: () => 'Them');

    final count = <String, int>{};
    final starts = <String, int>{};
    final replyDeltas = <String, List<Duration>>{};
    final lengthSum = <String, int>{};
    var lateNight = 0;
    var longestSilence = Duration.zero;

    for (var i = 0; i < msgs.length; i++) {
      final m = msgs[i];
      count[m.sender] = (count[m.sender] ?? 0) + 1;
      lengthSum[m.sender] = (lengthSum[m.sender] ?? 0) + m.text.length;
      if (m.time.hour >= 22 || m.time.hour < 4) lateNight++;

      if (i == 0) {
        starts[m.sender] = (starts[m.sender] ?? 0) + 1;
        continue;
      }
      final gap = m.time.difference(msgs[i - 1].time);
      if (gap > longestSilence) longestSilence = gap;
      if (gap >= _newConversationGap) {
        starts[m.sender] = (starts[m.sender] ?? 0) + 1;
      } else if (m.sender != msgs[i - 1].sender && gap <= _maxReplyGap) {
        (replyDeltas[m.sender] ??= []).add(gap);
      }
    }

    Duration median(List<Duration> xs) {
      if (xs.isEmpty) return Duration.zero;
      final sorted = [...xs]..sort();
      return sorted[sorted.length ~/ 2];
    }

    // 月度分桶（供情绪曲线的 x 轴对齐）
    final monthCount = <String, int>{};
    for (final m in msgs) {
      final key = '${m.time.year}-${m.time.month}';
      monthCount[key] = (monthCount[key] ?? 0) + 1;
    }
    final months = monthCount.entries.map((e) {
      final parts = e.key.split('-');
      return MonthBucket(int.parse(parts[0]), int.parse(parts[1]), e.value);
    }).toList()
      ..sort((a, b) => (a.year * 12 + a.month) - (b.year * 12 + b.month));

    return ChatMetrics(
      you: you,
      partner: partner,
      totalMessages: msgs.length,
      messageCount: count,
      conversationStarts: starts,
      medianReply: {
        for (final s in [you, partner]) s: median(replyDeltas[s] ?? []),
      },
      avgLength: {
        for (final s in [you, partner])
          s: (count[s] ?? 0) == 0 ? 0 : (lengthSum[s] ?? 0) / count[s]!,
      },
      lateNightCount: lateNight,
      longestSilenceDays: longestSilence.inDays,
      months: months,
    );
  }
}
