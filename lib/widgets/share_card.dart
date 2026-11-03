import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_localizations.dart';
import '../models/report.dart';
import '../services/analytics.dart';
import '../theme.dart';

/// 分享卡片（设计稿 Step 4）：固定深色 —— 在浅色的 IG Story 流里跳出来；
/// 人名强制缩写为首字母，无豁免开关（隐私即品牌）。
class ShareCard extends StatelessWidget {
  final RelationshipReport report;
  const ShareCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final m = report.metrics;
    final youI = m.you.isEmpty ? 'U' : m.you.characters.first.toUpperCase();
    final partnerI =
        m.partner.isEmpty ? 'T' : m.partner.characters.first.toUpperCase();

    final span = m.months.length;
    final spanLabel = span >= 24
        ? l.shareCardYears((span / 12).round())
        : span >= 2
            ? l.shareCardMonths(span)
            : l.shareCardOurChat;

    MonthMood? peak;
    for (final p in report.emotionCurve) {
      if (peak == null || p.sentiment > peak.sentiment) peak = p;
    }

    Widget stat(String emoji, String bold, String rest) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFFB899A8),
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                    children: [
                      TextSpan(
                          text: bold,
                          style: const TextStyle(
                              color: Color(0xFFF6EDF2),
                              fontWeight: FontWeight.w700)),
                      TextSpan(text: ' $rest'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );

    return Container(
      width: 320,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2B1E2E), Color(0xFF3A2438), Color(0xFF4A2937)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.shareCardBrand,
              style: UType.label
                  .copyWith(fontSize: 9, color: const Color(0xFFB899A8))),
          const SizedBox(height: 8),
          Text('$youI & $partnerI · $spanLabel',
              style: UType.serifItalic
                  .copyWith(fontSize: 18, color: const Color(0xFFF6EDF2))),
          const SizedBox(height: 10),
          Text('${report.warmth}°',
              style: const TextStyle(
                fontSize: 62,
                height: 1,
                fontWeight: FontWeight.w800,
                color: Color(0xFFF2A0B0),
                fontFeatures: [FontFeature.tabularFigures()],
              )),
          const SizedBox(height: 4),
          Text(l.shareCardWarmth,
              style: UType.label
                  .copyWith(fontSize: 9, color: const Color(0xFFB899A8))),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
              border: Border(
                  top: BorderSide(color: Color(0x2EF6EDF2), width: 1)),
            ),
            child: Column(
              children: [
                stat('💬', '${m.totalMessages}',
                    l.shareCardMessages(m.lateNightCount)),
                stat('⚡', '${(m.startShareOf(m.you) * 100).round()}%',
                    l.shareCardStarted(youI)),
                if (peak != null)
                  stat('🌙', peak.label, l.shareCardWarmestMonth),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(l.shareCardWatermark,
              style: UType.label
                  .copyWith(fontSize: 8.5, color: const Color(0xFF8A6E80))),
        ],
      ),
    );
  }
}

/// 分享预览弹层：展示卡片 → 截图导出 PNG → 系统分享面板。
Future<void> showShareSheet(BuildContext context, RelationshipReport report) {
  final boundaryKey = GlobalKey();
  var sharing = false;
  Analytics.shareSheetOpen();

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: UColors.screen,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(L.of(ctx).shareTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(L.of(ctx).shareSubtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 11.5, color: UColors.muted)),
              const SizedBox(height: 16),
              Center(
                child: RepaintBoundary(
                  key: boundaryKey,
                  child: ShareCard(report: report),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: UColors.rose,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const StadiumBorder(),
                ),
                onPressed: sharing
                    ? null
                    : () async {
                        setState(() => sharing = true);
                        try {
                          final status = await _captureAndShare(
                              boundaryKey, L.of(ctx).shareText);
                          Analytics.shareResult(status.name);
                        } catch (e) {
                          Analytics.shareResult('error');
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                                content:
                                    Text(L.of(ctx).shareFailed('$e')),
                                behavior: SnackBarBehavior.floating));
                          }
                        } finally {
                          if (ctx.mounted) setState(() => sharing = false);
                        }
                      },
                icon: sharing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.ios_share, size: 18),
                label: Text(sharing
                        ? L.of(ctx).sharePreparing
                        : L.of(ctx).shareAction,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// 返回系统分享面板的结果（success / dismissed / unavailable）
Future<ShareResultStatus> _captureAndShare(
    GlobalKey boundaryKey, String shareText) async {
  final boundary = boundaryKey.currentContext?.findRenderObject()
      as RenderRepaintBoundary?;
  if (boundary == null) throw Exception('card not ready');

  // 3x 像素密度 → 卡片宽 320 输出约 960px，够 IG Story 用
  final image = await boundary.toImage(pixelRatio: 3);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  if (bytes == null) throw Exception('encode failed');

  final dir = await getTemporaryDirectory();
  final file = File(
      '${dir.path}/chat_report_${DateTime.now().millisecondsSinceEpoch}.png');
  await file.writeAsBytes(bytes.buffer.asUint8List());

  final result = await SharePlus.instance.share(ShareParams(
    files: [XFile(file.path, mimeType: 'image/png')],
    text: shareText,
  ));
  return result.status;
}
