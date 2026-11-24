import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_localizations.dart';
import '../l10n/locale_utils.dart';
import '../models/deep_dive.dart';
import '../models/report.dart';
import '../services/analytics.dart';
import '../services/purchases.dart';
import '../services/review_prompt.dart';
import '../theme.dart';

/// 卡片内容：默认的关系温度，或解锁后可选的爱的语言
enum ShareCardStyle { warmth, love }

/// 分享卡片：上面是和图标一致的艳粉，往下过渡到深紫 —— 顶部认得出品牌，
/// 占满屏幕时又不刺眼。人名强制缩写为首字母，无豁免开关（隐私即品牌）。
class ShareCard extends StatelessWidget {
  final RelationshipReport report;
  final ShareCardStyle style;

  /// 9:16 竖版，发状态或快拍时能占满屏幕
  final bool tall;

  const ShareCard({
    super.key,
    required this.report,
    this.style = ShareCardStyle.warmth,
    this.tall = false,
  });

  static const width = 320.0;
  static const tallHeight = width * 16 / 9;

  /// 爱的语言是付费内容，解锁了才能做成卡片
  static bool canShareLove(RelationshipReport report) {
    final dive = report.deepDive;
    return Purchases.isUnlocked(report) &&
        dive != null &&
        (dive.loveYou != null || dive.lovePartner != null);
  }

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

    const white = Colors.white;
    const soft = Color(0xE0FFFFFF); // 次要文字
    const faint = Color(0xBFFFFFFF); // 小标

    final youTag = report.personalityYou.firstOrNull;
    final partnerTag = report.personalityPartner.firstOrNull;
    Widget tag(String initial, String text) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0x33FFFFFF),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text('$initial · $text',
              style:
                  const TextStyle(fontSize: 11.5, height: 1.2, color: white)),
        );

    Widget stat(String emoji, String bold, String rest) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 8),
              Expanded(
                // Text.rich 会继承主题字体和系统字号设置，RichText 不会
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: soft,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                    children: [
                      TextSpan(
                          text: bold,
                          style: const TextStyle(
                              color: white, fontWeight: FontWeight.w700)),
                      TextSpan(text: ' $rest'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );

    Widget loveRow(String initial, LoveLanguage v) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0x80FFFFFF)),
                ),
                child: Text(initial,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: white)),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(loveLanguageLabel(l, v),
                    style: const TextStyle(
                        fontSize: 22,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        color: white)),
              ),
            ],
          ),
        );

    final bigLabel = UType.label.copyWith(fontSize: 11, color: white);

    final header = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l.shareCardBrand,
            style: UType.label.copyWith(fontSize: 9, color: faint)),
        const SizedBox(height: 8),
        Text('$youI & $partnerI · $spanLabel',
            textAlign: TextAlign.center,
            style: UType.serifItalic.copyWith(fontSize: 18, color: white)),
      ],
    );

    // 性格标签比数字更让看到的人好奇自己是什么类型
    final tags = youTag == null && partnerTag == null
        ? null
        : Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              if (youTag != null) tag(youI, youTag),
              if (youTag != null && partnerTag != null)
                const Text('×', style: TextStyle(fontSize: 12, color: faint)),
              if (partnerTag != null) tag(partnerI, partnerTag),
            ],
          );

    final dive = report.deepDive;
    final showLove = style == ShareCardStyle.love && dive != null;
    final middle = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLove) ...[
          Text(l.sectionLoveLanguages.toUpperCase(),
              textAlign: TextAlign.center, style: bigLabel),
          const SizedBox(height: 12),
          if (dive.loveYou case final v?) loveRow(youI, v.primary),
          if (dive.lovePartner case final v?) loveRow(partnerI, v.primary),
          const SizedBox(height: 8),
          Text('${report.warmth}° · ${l.sectionWarmth}',
              style: const TextStyle(fontSize: 12, color: soft)),
        ] else ...[
          // 一划而过时只有这个数字会被看到，所以尽量大。
          // 字体宽的时候整体缩小，不让「°」掉到下一行
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('${report.warmth}°',
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  fontSize: tall ? 128 : 104,
                  height: 1,
                  letterSpacing: -2,
                  fontWeight: FontWeight.w900,
                  color: white,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  shadows: const [
                    Shadow(
                        color: Color(0x402B1E2E),
                        blurRadius: 18,
                        offset: Offset(0, 4)),
                  ],
                )),
          ),
          const SizedBox(height: 6),
          Text(l.shareCardWarmth,
              textAlign: TextAlign.center, style: bigLabel),
        ],
        if (tags != null) ...[const SizedBox(height: 14), tags],
        if (!showLove) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0x572B1E2E),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                stat('💬', '${m.totalMessages}',
                    l.shareCardMessages(m.lateNightCount)),
                stat('⚡', '${(m.startShareOf(m.you) * 100).round()}%',
                    l.shareCardStarted(youI)),
              ],
            ),
          ),
        ],
      ],
    );

    // 白色名片：图标和名字让人记住是哪个 App。
    // 图片被转发后文字里的链接会丢，二维码跟着图走
    final footer = Container(
      padding: const EdgeInsets.fromLTRB(10, 9, 9, 9),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const AppIconMark(size: 38),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.appTitle,
                    style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        color: UColors.ink)),
                const SizedBox(height: 2),
                Text(l.shareCardScan,
                    style: const TextStyle(
                        fontSize: 10.5, height: 1.25, color: UColors.muted)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          QrImageView(
            data: playStoreQrLink,
            size: 46,
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );

    const padding = EdgeInsets.fromLTRB(20, 26, 20, 18);
    return Container(
      width: width,
      height: tall ? tallHeight : null,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(-.35, -1),
          end: Alignment(.35, 1),
          stops: [0, .45, 1],
          colors: [Color(0xFFE0277C), Color(0xFFA3155C), Color(0xFF4A2040)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // 图标里的走势线和心，淡淡地垫在右侧当底纹。
          // 这是图标的一部分，从右往左读的语言里也不换边
          Positioned(
            right: -96,
            top: tall ? 150 : 96,
            child: const CustomPaint(
              size: Size(330, 198),
              painter: _LogoPainter(
                view: Rect.fromLTWH(240, 250, 600, 360),
                color: Color(0x14FFFFFF),
              ),
            ),
          ),
          Padding(
            padding: padding,
            child: tall
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      header,
                      // 文字长的语言可能放不下，整体缩小而不是溢出
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SizedBox(
                              width: width - padding.horizontal,
                              child: middle),
                        ),
                      ),
                      footer,
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      header,
                      const SizedBox(height: 14),
                      middle,
                      const SizedBox(height: 14),
                      footer,
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// App 图标，画出来而不是用图片：导出分享图时不用等图片加载。
/// 样子要和 tool/gen_icon.py 生成的图标保持一致。
class AppIconMark extends StatelessWidget {
  final double size;
  const AppIconMark({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF03486), Color(0xFFC40662)],
        ),
        borderRadius: BorderRadius.circular(size * .235),
      ),
      child: CustomPaint(
        size: Size.square(size),
        painter: const _LogoPainter(
          view: Rect.fromLTWH(0, 0, 1024, 1024),
          color: UColors.rose,
          bubble: Colors.white,
        ),
      ),
    );
  }
}

/// 图标的图案：对话气泡（可选）+ 走势线 + 线尽头的一颗心。
/// 坐标沿用 tool/gen_icon.py 的 1024 画布，[view] 是其中要画出来的那一块。
class _LogoPainter extends CustomPainter {
  final Rect view;
  final Color color;
  final Color? bubble;
  const _LogoPainter({required this.view, required this.color, this.bubble});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / view.width);
    canvas.translate(-view.left, -view.top);

    if (bubble case final fill?) {
      final shape = Path()
        ..addRRect(RRect.fromLTRBR(
            162, 222, 862, 690, const Radius.circular(160)))
        // 左下的小尾巴
        ..moveTo(250, 650)
        ..cubicTo(250, 732, 247.6, 780, 238, 810)
        ..cubicTo(304, 756, 352, 708, 370, 682)
        ..close();
      canvas.drawPath(shape, Paint()..color = fill);
    }

    // 底纹是半透明的：线和心先合成一个形状再画，重叠处才不会更深
    final line = Path()
      ..moveTo(286, 524)
      ..lineTo(390, 426)
      ..lineTo(490, 562)
      ..lineTo(594, 472);
    final heart = Path()
      ..moveTo(0, .93)
      ..cubicTo(-.16, .80, -1, .30, -1, -.38)
      ..cubicTo(-1, -.72, -.78, -.95, -.5, -.95)
      ..cubicTo(-.26, -.95, -.07, -.80, 0, -.60)
      ..cubicTo(.07, -.80, .26, -.95, .5, -.95)
      ..cubicTo(.78, -.95, 1, -.72, 1, -.38)
      ..cubicTo(1, .30, .16, .80, 0, .93)
      ..close();
    final place = Matrix4.identity()
      ..translateByDouble(700, 388, 0, 1)
      ..rotateZ(.14)
      ..scaleByDouble(100, 100, 1, 1);

    canvas.saveLayer(null, Paint()..color = color.withValues(alpha: color.a));
    final solid = Paint()..color = color.withValues(alpha: 1);
    canvas.drawPath(
        line,
        Paint()
          ..color = solid.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 50
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);
    canvas.drawPath(heart.transform(place.storage), solid);
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LogoPainter old) =>
      old.view != view || old.color != color || old.bubble != bubble;
}

/// 分享预览弹层：展示卡片 → 截图导出 PNG → 系统分享面板。
Future<void> showShareSheet(BuildContext context, RelationshipReport report) {
  final boundaryKey = GlobalKey();
  var sharing = false;
  var style = ShareCardStyle.warmth;
  var tall = false;
  final canLove = ShareCard.canShareLove(report);
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
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: [
                  if (canLove)
                    for (final (value, label) in [
                      (ShareCardStyle.warmth, L.of(ctx).sectionWarmth),
                      (ShareCardStyle.love, L.of(ctx).sectionLoveLanguages),
                    ])
                      ChoiceChip(
                        label: Text(label,
                            style: const TextStyle(fontSize: 12)),
                        selected: style == value,
                        showCheckmark: false,
                        selectedColor: UColors.roseSoft,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: UColors.line),
                        shape: const StadiumBorder(),
                        visualDensity: VisualDensity.compact,
                        onSelected: (_) => setState(() => style = value),
                      ),
                  FilterChip(
                    label: Text(L.of(ctx).shareFormatTall,
                        style: const TextStyle(fontSize: 12)),
                    selected: tall,
                    selectedColor: UColors.roseSoft,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: UColors.line),
                    shape: const StadiumBorder(),
                    visualDensity: VisualDensity.compact,
                    onSelected: (v) => setState(() => tall = v),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // 竖版比小屏幕还高：预览缩小显示，导出的图片仍是原始尺寸
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: RepaintBoundary(
                    key: boundaryKey,
                    child: ShareCard(report: report, style: style, tall: tall),
                  ),
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
                              boundaryKey, shareMessage(L.of(ctx)));
                          Analytics.shareResult(status.name,
                              card: style.name, tall: tall);
                          // 愿意分享说明对报告满意，这时请他评分最合适
                          if (status == ShareResultStatus.success) {
                            ReviewPrompt.maybeAsk('share');
                          }
                        } catch (e) {
                          Analytics.shareResult('error',
                              card: style.name, tall: tall);
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
/// 分享出去的文字带上下载链接，否则看到卡片的人找不到 App。
/// referrer 让 Play 和 Firebase 能统计分享带来的安装
const playStoreShareLink = 'https://play.google.com/store/apps/details'
    '?id=com.ruilin.chatreport&referrer=utm_source%3Dshare_card';

/// 卡片上的二维码，来源单独标记，和文字链接分开统计
const playStoreQrLink = 'https://play.google.com/store/apps/details'
    '?id=com.ruilin.chatreport&referrer=utm_source%3Dshare_qr';

String shareMessage(L l) => '${l.shareText}\n$playStoreShareLink';

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
