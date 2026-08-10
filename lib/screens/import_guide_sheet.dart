import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../theme.dart';

/// 导入引导弹层：分步教用户从 WhatsApp 导出聊天记录，
/// 提供「Open WhatsApp」跳转与「选择已导出文件」两个动作。
///
/// 返回值：'pick' = 用户点了选择文件；null = 关闭。
Future<String?> showImportGuideSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: UColors.screen,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => const _ImportGuideSheet(),
  );
}

class _ImportGuideSheet extends StatelessWidget {
  const _ImportGuideSheet();

  static List<({String emoji, String title, String detail})> _steps(L l) => [
        (emoji: '📱', title: l.guideStep1Title, detail: l.guideStep1Detail),
        (emoji: '⋮', title: l.guideStep2Title, detail: l.guideStep2Detail),
        (emoji: '🚫', title: l.guideStep3Title, detail: l.guideStep3Detail),
        (emoji: '📂', title: l.guideStep4Title, detail: l.guideStep4Detail),
      ];

  Future<void> _openWhatsApp(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final failedMsg = L.of(context).guideOpenFailed;
    // 依次尝试 App scheme → 官网（未安装时兜底）
    final ok = await launchUrl(
      Uri.parse('whatsapp://'),
      mode: LaunchMode.externalApplication,
    ).catchError((_) => false);
    if (!ok) {
      final web = await launchUrl(
        Uri.parse('https://wa.me/'),
        mode: LaunchMode.externalApplication,
      ).catchError((_) => false);
      if (!web) {
        messenger.showSnackBar(SnackBar(
          content: Text(failedMsg),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 22,
          right: 22,
          top: 18,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: UColors.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(l.guideTitle,
                style: const TextStyle(
                    fontSize: 19, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(l.guideSubtitle,
                style: const TextStyle(fontSize: 12.5, color: UColors.muted)),
            const SizedBox(height: 18),
            for (final (i, s) in _steps(l).indexed) _StepRow(i: i, step: s),
            const SizedBox(height: 6),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF25D366), // WhatsApp 品牌绿
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: const StadiumBorder(),
              ),
              onPressed: () => _openWhatsApp(context),
              icon: const Icon(Icons.chat, size: 18),
              label: Text(l.guideOpenWhatsApp,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: UColors.rose,
                side: const BorderSide(color: UColors.rose, width: 1.4),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: const StadiumBorder(),
              ),
              onPressed: () => Navigator.pop(context, 'pick'),
              child: Text(l.guidePickFile,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),
            Center(child: PrivacyNote(l.guidePrivacy)),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final int i;
  final ({String emoji, String title, String detail}) step;
  const _StepRow({required this.i, required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: UColors.rose,
              shape: BoxShape.circle,
            ),
            child: Text('${i + 1}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${step.emoji}  ${step.title}',
                    style: const TextStyle(
                        fontSize: 13.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(step.detail,
                    style: const TextStyle(
                        fontSize: 11.5, color: UColors.muted, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
