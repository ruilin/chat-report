import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/report.dart';
import '../services/analytics.dart';
import '../theme.dart';
import '../widgets/charts.dart';
import '../widgets/share_card.dart';

/// 报告页 —— 整个产品为这一页服务。
/// 原则：每个数字可追溯（本地统计 + 金句附时间）；深读为付费模块（MVP 先全量展示）。
class ReportScreen extends StatelessWidget {
  final RelationshipReport report;

  /// 首页「示例报告」入口打开：顶部标注示例并引导去分析自己的聊天，不提供分享
  final bool isSample;

  const ReportScreen({super.key, required this.report, this.isSample = false});

  Widget _sampleBanner(BuildContext context, L l) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: UColors.roseSoft,
        border: Border.all(color: UColors.roseBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.sampleBanner,
              style: const TextStyle(
                  fontSize: 12.5, height: 1.5, color: UColors.ink2)),
          const SizedBox(height: 10),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: UColors.rose,
              shape: const StadiumBorder(),
              visualDensity: VisualDensity.compact,
            ),
            onPressed: () {
              Analytics.sampleCtaClick();
              Navigator.of(context).pop('import');
            },
            child: Text(l.sampleCta,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final m = report.metrics;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            UAvatar(m.you, isYou: true, size: 30),
            Transform.translate(
              // 头像叠压：朝阅读方向的反向偏移，RTL 下镜像
              offset: Offset(
                  Directionality.of(context) == TextDirection.rtl ? 10 : -10,
                  0),
              child: UAvatar(m.partner, isYou: false, size: 30),
            ),
            const SizedBox(width: 2),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.reportYouAnd(m.partner),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                Text(l.reportMessages(m.totalMessages),
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: UColors.muted,
                      fontFeatures: [FontFeature.tabularFigures()],
                    )),
              ],
            ),
          ],
        ),
        actions: [
          if (!isSample)
            IconButton(
              icon: const Icon(Icons.ios_share, size: 20),
              onPressed: () => showShareSheet(context, report),
            ),
        ],
      ),
      body: ListView(
        // 显式 padding 会让 ListView 不再自动避让系统栏，底部要自己加上导航栏高度
        padding: EdgeInsets.fromLTRB(
            20, 8, 20, 32 + MediaQuery.paddingOf(context).bottom),
        children: [
          if (isSample) ...[
            _sampleBanner(context, l),
            const SizedBox(height: 14),
          ],
          _warmthCard(l),
          const SizedBox(height: 14),
          _balanceCard(l),
          const SizedBox(height: 14),
          _curveCard(l),
          const SizedBox(height: 14),
          if (report.topics.isNotEmpty) ...[
            _topicsCard(l),
            const SizedBox(height: 14),
          ],
          _personalityCard(l),
          const SizedBox(height: 14),
          _deepReadingCard(l),
        ],
      ),
    );
  }

  Widget _warmthCard(L l) {
    return UCard(
      color: UColors.roseSoft,
      borderColor: UColors.roseBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ULabel(l.sectionWarmth, color: const Color(0xFFC87A8A)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${report.warmth}°',
                  style: UType.num.copyWith(fontSize: 46, height: 1)),
            ],
          ),
          if (report.warmthReason.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(report.warmthReason,
                style:
                    const TextStyle(fontSize: 12, color: UColors.ink2)),
          ],
        ],
      ),
    );
  }

  Widget _balanceCard(L l) {
    final m = report.metrics;
    String fmtDur(Duration d) {
      if (d.inSeconds < 60) return '${d.inSeconds}s';
      if (d.inMinutes < 60) {
        return '${d.inMinutes}m ${d.inSeconds % 60}s';
      }
      return '${d.inHours}h ${d.inMinutes % 60}m';
    }

    return UCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ULabel(l.sectionBalance),
          Row(
            children: [
              _legendDot(UColors.rose, l.labelYou),
              const SizedBox(width: 14),
              _legendDot(UColors.blue, m.partner),
            ],
          ),
          const SizedBox(height: 10),
          Text(l.labelMessagesSent,
              style: const TextStyle(fontSize: 11, color: UColors.ink2)),
          const SizedBox(height: 4),
          SplitBar(leftShare: m.shareOf(m.you)),
          const SizedBox(height: 12),
          Text(l.labelWhoTextsFirst,
              style: const TextStyle(fontSize: 11, color: UColors.ink2)),
          const SizedBox(height: 4),
          SplitBar(leftShare: m.startShareOf(m.you)),
          const SizedBox(height: 14),
          // 标签可能换行（长名字、西/葡/意等较长译文），两块等高、数值底对齐
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _replyTile(l.labelYourReplyTime,
                    fmtDur(m.medianReply[m.you]!), UColors.roseSoft,
                    const Color(0xFFB06A79)),
                const SizedBox(width: 10),
                _replyTile(
                    l.labelTheirReplyTime(m.partner.toUpperCase()),
                    fmtDur(m.medianReply[m.partner]!),
                    UColors.blueSoft,
                    const Color(0xFF4E82A6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color c, String label) => Row(children: [
        Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
                color: c, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(fontSize: 11, color: UColors.ink2)),
      ]);

  Widget _replyTile(String label, String value, Color bg, Color labelColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                // 真机字体下通常 1–2 行；留第 3 行给很长的联系人名
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .8,
                    color: labelColor)),
            const SizedBox(height: 2),
            Text(value, style: UType.num.copyWith(fontSize: 17)),
          ],
        ),
      ),
    );
  }

  Widget _curveCard(L l) {
    return UCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ULabel(l.sectionEmotionCurve),
          EmotionCurve(points: report.emotionCurve),
        ],
      ),
    );
  }

  Widget _topicsCard(L l) {
    return UCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ULabel(l.sectionTopics),
          TopicBars(topics: report.topics),
        ],
      ),
    );
  }

  Widget _personalityCard(L l) {
    final m = report.metrics;
    Widget row(String name, bool isYou, List<String> tags) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UAvatar(name, isYou: isYou, size: 26),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final t in tags)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: UColors.line),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(t,
                            style: const TextStyle(
                                fontSize: 11.5, color: UColors.ink2)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );

    return UCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ULabel(l.sectionPersonalities),
          row(m.you, true, report.personalityYou),
          row(m.partner, false, report.personalityPartner),
        ],
      ),
    );
  }

  Widget _deepReadingCard(L l) {
    return UCard(
      borderColor: const Color(0xFFEAD9B8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ULabel(l.sectionFullReading, color: UColors.gold),
          Text(report.deepReading,
              style: const TextStyle(
                  fontSize: 13.5, height: 1.7, color: UColors.ink)),
          if (report.milestones.isNotEmpty) ...[
            const SizedBox(height: 18),
            ULabel(l.sectionMilestones, color: UColors.gold),
            for (final ms in report.milestones)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(ms.date,
                            style: UType.num.copyWith(
                                fontSize: 11, color: UColors.muted)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(ms.title,
                              style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    if (ms.quote.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text('“${ms.quote}”',
                            style: UType.serifItalic.copyWith(
                                fontSize: 12.5, color: UColors.ink2)),
                      ),
                  ],
                ),
              ),
          ],
          if (report.advice.isNotEmpty) ...[
            const SizedBox(height: 8),
            ULabel(l.sectionAdvice, color: UColors.gold),
            for (final a in report.advice)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('—  ',
                        style: TextStyle(color: UColors.gold)),
                    Expanded(
                        child: Text(a,
                            style: const TextStyle(
                                fontSize: 12.5,
                                height: 1.6,
                                color: UColors.ink2))),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
