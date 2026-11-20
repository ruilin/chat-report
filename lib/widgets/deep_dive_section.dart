import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/locale_utils.dart';
import '../models/deep_dive.dart';
import '../models/metrics.dart';
import '../models/report.dart';
import '../services/analytics.dart';
import '../services/deep_dive_jobs.dart';
import '../services/purchases.dart';
import '../theme.dart';

const _red = Color(0xFFC0392B);
const _green = Color(0xFF3E9B6E);

/// 报告页底部的付费区：未解锁时是付费墙，解锁后是专题分析的完整内容。
/// 示例报告只展示有哪些内容，不提供购买。
class DeepDiveSection extends StatefulWidget {
  final RelationshipReport report;
  final bool isSample;

  const DeepDiveSection(
      {super.key, required this.report, this.isSample = false});

  @override
  State<DeepDiveSection> createState() => _DeepDiveSectionState();
}

class _DeepDiveSectionState extends State<DeepDiveSection> {
  final _purchases = Purchases.instance;
  bool _productLoaded = false;

  /// 专题分析还在写
  bool _generating = false;

  RelationshipReport get _report => widget.report;
  bool get _locked => !Purchases.isUnlocked(_report);

  @override
  void initState() {
    super.initState();
    if (widget.isSample) return;
    _watch(DeepDiveJobs.running(_report.id));
    final dive = _report.deepDive;
    if (!_locked) return;
    _purchases.addListener(_onPurchaseChange);
    _purchases.loadProduct().whenComplete(() {
      if (mounted) setState(() => _productLoaded = true);
    });
    Analytics.paywallView(
        itemCount: dive == null
            ? 0
            : dive.conflicts.length +
                dive.horsemen.length +
                dive.redFlags.length +
                dive.greenFlags.length +
                dive.turningPoints.length);
  }

  void _onPurchaseChange() {
    if (mounted) setState(() {});
  }

  /// 等后台的专题分析写完，写完就地刷新
  void _watch(Future<DeepDive?>? job) {
    if (job == null) return;
    _generating = true;
    job.then((dive) {
      // 从「我的报告」打开的是另一个对象，这里也要补上
      if (dive != null) _report.deepDive = dive;
    }).whenComplete(() {
      if (mounted) setState(() => _generating = false);
    });
  }

  void _retry() => setState(() => _watch(DeepDiveJobs.retry(_report)));

  @override
  void dispose() {
    _purchases.removeListener(_onPurchaseChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final adviceCount = _report.advice.length;
    // 示例报告是虚构数据，付费内容全部展示，让用户知道花钱能看到什么
    if (widget.isSample && _report.deepDive != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              Purchases.paywallEnabled
                  ? l.samplePaidHint
                  : l.sampleDeepDiveHint,
              style: const TextStyle(fontSize: 12, color: UColors.muted)),
          const SizedBox(height: 10),
          _Unlocked(report: _report, dive: _report.deepDive!, l: l),
        ],
      );
    }
    if (widget.isSample) {
      return _Paywall(
          l: l,
          showDive: true,
          adviceCount: adviceCount,
          footer: _sampleFooter(l));
    }
    final dive = _report.deepDive;
    if (dive == null && _generating) return _Generating(l: l);
    // 没生成出来要说清楚，否则用户不知道少了内容。
    // 这次打开期间还能重试；聊天原文不留，App 重启后只能重新分析
    final missing = dive == null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.deepDiveMissing,
                  style: const TextStyle(fontSize: 12, color: UColors.muted)),
              if (DeepDiveJobs.canRetry(_report.id))
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: UColors.rose,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: _retry,
                  child: Text(l.errorRetry),
                ),
            ],
          )
        : null;
    if (_locked) {
      // 专题分析没生成时，付费仍然能解锁教练和建议，但不能再列专题分析
      return _Paywall(
          l: l,
          dive: dive,
          showDive: dive != null,
          preview: dive == null ? null : _preview(l, dive),
          adviceCount: adviceCount,
          footer: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (missing != null) ...[missing, const SizedBox(height: 10)],
              _buyFooter(l),
            ],
          ));
    }
    if (dive == null) return missing!;
    return _Unlocked(report: _report, dive: dive, l: l);
  }

  /// 没解锁时免费露出一条真实发现，让用户付费前先看到内容质量
  Widget? _preview(L l, DeepDive dive) {
    final m = _report.metrics;
    if (dive.horsemen.firstOrNull case final h?) {
      return _Preview(
          l: l,
          section: '${l.sectionFourHorsemen} · ${_horsemanName(l, h.kind)}',
          child: _Evidence(h,
              leading: UAvatar(h.byYou ? m.you : m.partner,
                  isYou: h.byYou, size: 18)));
    }
    final candidates = <(String, EvidenceItem)>[
      for (final e in dive.redFlags.take(1)) (l.sectionRedFlags, e),
      for (final e in dive.greenFlags.take(1)) (l.sectionGreenFlags, e),
      for (final e in dive.conflicts.take(1)) (l.sectionConflict, e),
      for (final e in dive.turningPoints.take(1)) (l.sectionTurningPoints, e),
    ];
    if (candidates.isEmpty) return null;
    final (section, item) = candidates.first;
    return _Preview(l: l, section: section, child: _Evidence(item));
  }

  Widget _sampleFooter(L l) => Text(l.sampleDeepDiveHint,
      style: const TextStyle(fontSize: 12, color: UColors.muted));

  Widget _buyFooter(L l) {
    final state = _purchases.state;
    final price = _purchases.price;
    final canPay = _purchases.credits > 0 || price != null;
    final busy = state == PurchaseState.buying;
    final String? notice = switch (state) {
      PurchaseState.pending => l.deepDivePending,
      PurchaseState.failed => l.deepDiveFailed,
      _ => _productLoaded && !canPay ? l.deepDiveUnavailable : null,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (notice != null) ...[
          Text(notice,
              style: const TextStyle(fontSize: 12, color: UColors.ink2)),
          const SizedBox(height: 10),
        ],
        if (!_productLoaded && !canPay)
          const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: UColors.gold),
            ),
          )
        else if (canPay)
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: UColors.rose,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: const StadiumBorder(),
            ),
            onPressed: busy || state == PurchaseState.pending
                ? null
                : _purchases.credits > 0
                    ? () => _purchases.useCredit(_report)
                    : () => _purchases.buy(_report.id),
            child: busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    _purchases.credits > 0
                        ? l.deepDiveUseCredit
                        : l.deepDiveBuy(price!),
                    style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        if (canPay) ...[
          const SizedBox(height: 8),
          Text(l.deepDiveOneTime,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: UColors.muted)),
        ],
      ],
    );
  }
}

/// 只列有什么、有多少，不露内容
class _Paywall extends StatelessWidget {
  final L l;
  final DeepDive? dive;
  final bool showDive;
  final Widget? preview;
  final int adviceCount;
  final Widget footer;

  const _Paywall(
      {required this.l,
      this.dive,
      required this.showDive,
      this.preview,
      required this.adviceCount,
      required this.footer});

  @override
  Widget build(BuildContext context) {
    // 付费墙关着时只有示例报告走到这里：建议就显示在上面，不用再列
    final paywall = Purchases.paywallEnabled;
    Widget row(String title, int? count) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(
                  paywall
                      ? Icons.lock_outline
                      : Icons.auto_awesome,
                  size: 16,
                  color: UColors.gold),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 13.5, color: UColors.ink)),
              ),
              if (count != null && count > 0)
                Text('$count',
                    style: UType.num
                        .copyWith(fontSize: 13, color: UColors.gold)),
            ],
          ),
        );

    return UCard(
      color: const Color(0xFFFFFBF2),
      borderColor: const Color(0xFFEAD9B8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ULabel(paywall ? l.unlockTitle : l.deepDiveTitle,
              color: UColors.gold),
          Text(paywall ? l.unlockSubtitle : l.deepDiveSubtitle,
              style: const TextStyle(
                  fontSize: 13, height: 1.5, color: UColors.ink2)),
          const SizedBox(height: 10),
          ?preview,
          if (showDive) ...[
            row(l.sectionConflict, dive?.conflicts.length),
            row(l.sectionFourHorsemen, dive?.horsemen.length),
            row(l.sectionRedFlags, dive?.redFlags.length),
            row(l.sectionGreenFlags, dive?.greenFlags.length),
            row(l.sectionAttachment, null),
            row(l.sectionLoveLanguages, null),
            row(l.sectionTurningPoints, dive?.turningPoints.length),
          ],
          if (paywall) ...[
            if (adviceCount > 0) row(l.sectionAdvice, adviceCount),
            row(l.coachTitle, null),
          ],
          const SizedBox(height: 12),
          footer,
        ],
      ),
    );
  }
}

/// 免费报告已经能看，专题分析还在后台写
class _Generating extends StatelessWidget {
  final L l;

  const _Generating({required this.l});

  @override
  Widget build(BuildContext context) {
    return UCard(
      color: const Color(0xFFFFFBF2),
      borderColor: const Color(0xFFEAD9B8),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child:
                CircularProgressIndicator(strokeWidth: 2, color: UColors.gold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.deepDiveTitle,
                    style: const TextStyle(
                        fontSize: 13.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(l.deepDiveGenerating,
                    style:
                        const TextStyle(fontSize: 12, color: UColors.ink2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 付费墙里免费露出的一条发现
class _Preview extends StatelessWidget {
  final L l;
  final String section;
  final Widget child;

  const _Preview({required this.l, required this.section, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEAD9B8)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.previewLabel,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: UColors.gold)),
          const SizedBox(height: 2),
          Text(section,
              style: const TextStyle(fontSize: 11.5, color: UColors.muted)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

String _horsemanName(L l, Horseman h) => switch (h) {
      Horseman.criticism => l.horsemanCriticism,
      Horseman.contempt => l.horsemanContempt,
      Horseman.defensiveness => l.horsemanDefensiveness,
      Horseman.stonewalling => l.horsemanStonewalling,
    };

class _Unlocked extends StatelessWidget {
  final RelationshipReport report;
  final DeepDive dive;
  final L l;

  const _Unlocked({required this.report, required this.dive, required this.l});

  @override
  Widget build(BuildContext context) {
    final m = report.metrics;
    final sections = <Widget>[
      if (dive.conflictSummary.isNotEmpty || dive.conflicts.isNotEmpty)
        _card(l.sectionConflict, [
          if (dive.conflictSummary.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(dive.conflictSummary,
                  style: const TextStyle(
                      fontSize: 13.5, height: 1.7, color: UColors.ink)),
            ),
          for (final e in dive.conflicts) _Evidence(e),
        ]),
      _horsemenCard(m),
      _card(l.sectionRedFlags, [
        if (dive.redFlags.isEmpty) _none(l.deepDiveNoRedFlags),
        for (final e in dive.redFlags)
          _Evidence(e, icon: Icons.flag, iconColor: _red),
      ]),
      _card(l.sectionGreenFlags, [
        if (dive.greenFlags.isEmpty) _none(l.deepDiveNoGreenFlags),
        for (final e in dive.greenFlags)
          _Evidence(e, icon: Icons.flag, iconColor: _green),
      ]),
      if (dive.attachmentYou != null || dive.attachmentPartner != null)
        _card(l.sectionAttachment, [
          if (dive.attachmentYou case final a?) _attachment(m.you, true, a),
          if (dive.attachmentPartner case final a?)
            _attachment(m.partner, false, a),
          if (dive.attachmentLoop.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(l.attachmentLoopLabel,
                style: const TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text(dive.attachmentLoop,
                style: const TextStyle(
                    fontSize: 12.5, height: 1.6, color: UColors.ink2)),
          ],
        ]),
      if (dive.loveYou != null || dive.lovePartner != null)
        _card(l.sectionLoveLanguages, [
          if (dive.loveYou case final v?) _love(m.you, true, v),
          if (dive.lovePartner case final v?) _love(m.partner, false, v),
          Text(l.loveLanguagesNote,
              style: const TextStyle(fontSize: 11, color: UColors.muted)),
        ]),
      if (dive.turningPoints.isNotEmpty)
        _card(l.sectionTurningPoints, [
          for (final t in dive.turningPoints)
            _Evidence(t,
                icon: t.rising ? Icons.trending_up : Icons.trending_down,
                iconColor: t.rising ? _green : _red),
        ]),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final s in sections) ...[s, const SizedBox(height: 14)],
        Text(l.deepDiveDisclaimer,
            style: const TextStyle(fontSize: 11, color: UColors.muted)),
      ],
    );
  }

  Widget _none(String text) => Text(text,
      style: const TextStyle(fontSize: 12.5, color: UColors.muted));

  Widget _card(String title, List<Widget> children) => UCard(
        borderColor: const Color(0xFFEAD9B8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ULabel(title, color: UColors.gold),
            ...children,
          ],
        ),
      );

  /// 按四种类型分组，每组后面给出戈特曼建议的替代做法
  Widget _horsemenCard(ChatMetrics m) {
    String antidote(Horseman h) => switch (h) {
          Horseman.criticism => l.antidoteCriticism,
          Horseman.contempt => l.antidoteContempt,
          Horseman.defensiveness => l.antidoteDefensiveness,
          Horseman.stonewalling => l.antidoteStonewalling,
        };
    return _card(l.sectionFourHorsemen, [
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(l.fourHorsemenIntro,
            style: const TextStyle(
                fontSize: 12.5, height: 1.6, color: UColors.ink2)),
      ),
      if (dive.horsemen.isEmpty) _none(l.fourHorsemenNone),
      for (final kind in Horseman.values)
        if (dive.horsemen.where((h) => h.kind == kind).toList()
            case final found when found.isNotEmpty) ...[
          Text(_horsemanName(l, kind),
              style: const TextStyle(
                  fontSize: 13.5, fontWeight: FontWeight.w700, color: _red)),
          const SizedBox(height: 6),
          for (final h in found)
            _Evidence(h,
                leading: UAvatar(h.byYou ? m.you : m.partner,
                    isYou: h.byYou, size: 18)),
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(antidote(kind),
                style: const TextStyle(
                    fontSize: 12, height: 1.5, color: _green)),
          ),
        ],
    ]);
  }

  Widget _love(String name, bool isYou, LoveLanguageRead v) {
    final label = loveLanguageLabel(l, v.primary);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UAvatar(name, isYou: isYou, size: 26),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
                if (v.detail.isNotEmpty)
                  Text(v.detail,
                      style: const TextStyle(
                          fontSize: 12.5, height: 1.6, color: UColors.ink2)),
                if (v.quote.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text('“${v.quote}”',
                        style: UType.serifItalic
                            .copyWith(fontSize: 12.5, color: UColors.ink2)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 模型只给固定的英文值，由 App 按界面语言显示。其他写法（如旧报告）原样显示
  String _attachmentLabel(String style) =>
      switch (style.trim().toLowerCase()) {
        'anxious' => l.attachmentAnxious,
        'avoidant' => l.attachmentAvoidant,
        'secure' => l.attachmentSecure,
        'mixed' => l.attachmentMixed,
        _ => style,
      };

  Widget _attachment(String name, bool isYou, AttachmentRead a) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UAvatar(name, isYou: isYou, size: 26),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_attachmentLabel(a.style),
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700)),
                  if (a.detail.isNotEmpty)
                    Text(a.detail,
                        style: const TextStyle(
                            fontSize: 12.5,
                            height: 1.6,
                            color: UColors.ink2)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _Evidence extends StatelessWidget {
  final EvidenceItem item;
  final IconData? icon;
  final Color? iconColor;

  /// 代替图标放在标题前，比如说这句话的人的头像
  final Widget? leading;

  const _Evidence(this.item, {this.icon, this.iconColor, this.leading});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 6),
              ] else if (icon != null) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(icon, size: 15, color: iconColor),
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(item.title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
              ),
              if (item.date.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(item.date,
                    style: UType.num
                        .copyWith(fontSize: 11, color: UColors.muted)),
              ],
            ],
          ),
          if (item.detail.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(item.detail,
                  style: const TextStyle(
                      fontSize: 12.5, height: 1.6, color: UColors.ink2)),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text('“${item.quote}”',
                style: UType.serifItalic
                    .copyWith(fontSize: 12.5, color: UColors.ink2)),
          ),
        ],
      ),
    );
  }
}
