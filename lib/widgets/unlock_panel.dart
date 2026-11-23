import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/report.dart';
import '../services/purchases.dart';
import '../theme.dart';

/// 页面底部的解锁面板：说明为什么要解锁，再给购买按钮。
/// AI 教练的免费次数用完、想写更多草稿时都用它。
class UnlockPanel extends StatefulWidget {
  final RelationshipReport report;
  final String title;
  final String body;

  const UnlockPanel(
      {super.key,
      required this.report,
      required this.title,
      required this.body});

  @override
  State<UnlockPanel> createState() => _UnlockPanelState();
}

class _UnlockPanelState extends State<UnlockPanel> {
  final _purchases = Purchases.instance;
  bool _productLoaded = false;

  @override
  void initState() {
    super.initState();
    _purchases.addListener(_onChange);
    _purchases.loadBalances();
    _purchases.loadProduct().whenComplete(() {
      if (mounted) setState(() => _productLoaded = true);
    });
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _purchases.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final state = _purchases.state;
    final price = _purchases.price;
    final hasCredit = _purchases.credits > 0;
    final canPay = hasCredit || price != null;
    final busy = state == PurchaseState.buying;
    final String? notice = switch (state) {
      PurchaseState.pending => l.deepDivePending,
      PurchaseState.failed => l.deepDiveFailed,
      _ => _productLoaded && !canPay ? l.deepDiveUnavailable : null,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFBF2),
        border: Border(top: BorderSide(color: Color(0xFFEAD9B8))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text(widget.body,
              style: const TextStyle(fontSize: 12.5, color: UColors.ink2)),
          if (notice != null) ...[
            const SizedBox(height: 8),
            Text(notice,
                style: const TextStyle(fontSize: 12, color: UColors.ink2)),
          ],
          if (canPay) ...[
            const SizedBox(height: 10),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: UColors.rose,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: const StadiumBorder(),
              ),
              onPressed: busy || state == PurchaseState.pending
                  ? null
                  : hasCredit
                      ? () => _purchases.useCredit(widget.report)
                      : () => _purchases.buy(widget.report.id),
              child: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      hasCredit ? l.deepDiveUseCredit : l.deepDiveBuy(price!),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 6),
            Text(l.deepDiveOneTime,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: UColors.muted)),
          ],
        ],
      ),
    );
  }
}
