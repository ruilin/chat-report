import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/deep_dive.dart';
import '../models/report.dart';
import '../services/analytics.dart';
import '../services/purchases.dart';
import '../theme.dart';

const _red = Color(0xFFC0392B);
const _green = Color(0xFF3E9B6E);

/// 报告页底部的付费专题分析：未解锁时是付费墙，解锁后是完整内容。
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

  RelationshipReport get _report => widget.report;
  bool get _locked => !Purchases.isDeepDiveOpen(_report);

  @override
  void initState() {
    super.initState();
    final dive = _report.deepDive;
    if (widget.isSample || dive == null || !_locked) return;
    _purchases.addListener(_onPurchaseChange);
    _purchases.loadProduct().whenComplete(() {
      if (mounted) setState(() => _productLoaded = true);
    });
    Analytics.paywallView(
        itemCount: dive.conflicts.length +
            dive.redFlags.length +
            dive.greenFlags.length +
            dive.turningPoints.length);
  }

  void _onPurchaseChange() {
    if (!mounted) return;
    setState(() {
      if (_purchases.lastUnlockedId == _report.id) {
        _report.deepDiveUnlocked = true;
      }
    });
  }

  @override
  void dispose() {
    _purchases.removeListener(_onPurchaseChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    if (widget.isSample) return _Paywall(l: l, footer: _sampleFooter(l));
    final dive = _report.deepDive;
    // 没生成出来要说清楚，否则用户不知道少了内容。聊天原文不留，只能重新分析
    if (dive == null) {
      return Text(l.deepDiveMissing,
          style: const TextStyle(fontSize: 12, color: UColors.muted));
    }
    if (_locked) {
      return _Paywall(l: l, dive: dive, footer: _buyFooter(l));
    }
    return _Unlocked(report: _report, dive: dive, l: l);
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
  final Widget footer;

  const _Paywall({required this.l, this.dive, required this.footer});

  @override
  Widget build(BuildContext context) {
    Widget row(String title, int? count) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(
                  Purchases.deepDivePaywallEnabled
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
          ULabel(l.deepDiveTitle, color: UColors.gold),
          Text(l.deepDiveSubtitle,
              style: const TextStyle(
                  fontSize: 13, height: 1.5, color: UColors.ink2)),
          const SizedBox(height: 10),
          row(l.sectionConflict, dive?.conflicts.length),
          row(l.sectionRedFlags, dive?.redFlags.length),
          row(l.sectionGreenFlags, dive?.greenFlags.length),
          row(l.sectionAttachment, null),
          row(l.sectionTurningPoints, dive?.turningPoints.length),
          const SizedBox(height: 12),
          footer,
        ],
      ),
    );
  }
}

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

  const _Evidence(this.item, {this.icon, this.iconColor});

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
              if (icon != null) ...[
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
