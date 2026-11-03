import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../sample/sample_report.dart';
import '../services/analytics.dart';
import '../services/whatsapp_parser.dart';
import '../theme.dart';
import 'import_guide_sheet.dart';
import 'report_screen.dart';
import 'setup_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _busy = false;

  /// 主入口：先弹分步引导（含跳转 WhatsApp），用户拿到文件后再选取。
  Future<void> _startImport() async {
    Analytics.importGuideOpen();
    final action = await showImportGuideSheet(context);
    if (action == 'pick') await _importFile();
  }

  Future<void> _importFile() async {
    const group = XTypeGroup(label: 'Chat export', extensions: ['txt']);
    final file = await openFile(acceptedTypeGroups: [group]);
    Analytics.importFilePick(file == null ? 'cancelled' : 'picked');
    if (file == null) return;
    final raw = await file.readAsString();
    await _parseAndGo(raw, source: 'file');
  }

  /// 示例报告：导出聊天记录门槛高，先让新用户看到成品。
  /// 报告页底部按钮返回 'import' 时直接进入导入引导。
  Future<void> _openSample() async {
    Analytics.sampleReportOpen();
    final action = await Navigator.of(context).push<String>(MaterialPageRoute(
      settings: const RouteSettings(name: 'report_sample'),
      builder: (_) => ReportScreen(
        report: buildSampleReport(
            lang: sampleLangOf(Localizations.localeOf(context))),
        isSample: true,
      ),
    ));
    if (action == 'import' && mounted) await _startImport();
  }

  Future<void> _pasteText() async {
    Analytics.pasteSheetOpen();
    final l = L.of(context);
    final controller = TextEditingController();
    final raw = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: UColors.screen,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.pasteSheetTitle,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(l.pasteSheetSubtitle,
                  style: const TextStyle(fontSize: 12, color: UColors.muted)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 8,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: l.pasteSheetHint,
                  hintStyle:
                      const TextStyle(color: UColors.faint, fontSize: 13),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: UColors.line),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: UColors.rose,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const StadiumBorder(),
                ),
                onPressed: () => Navigator.pop(ctx, controller.text),
                child: Text(l.pasteSheetAction),
              ),
            ],
          ),
        ),
      ),
    );
    if (raw != null && raw.trim().isNotEmpty) {
      await _parseAndGo(raw, source: 'paste');
    }
  }

  /// [source]: file / paste，仅用于埋点区分入口
  Future<void> _parseAndGo(String raw, {required String source}) async {
    setState(() => _busy = true);
    try {
      final data = WhatsAppParser().parse(raw);
      Analytics.chatParseSuccess(
        source: source,
        messageCount: data.messages.length,
        participantCount: data.participants.length,
        daySpan: data.lastDate.difference(data.firstDate).inDays,
      );
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(
          settings: const RouteSettings(name: 'setup'),
          builder: (_) => SetupScreen(data: data)));
    } on ParseException catch (e) {
      Analytics.chatParseFail(source: source, reason: e.kind.name);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.localize(L.of(context))),
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                // debug 彩蛋：长按 logo 打开不带「示例」标记的示例报告，
                // 用于目检报告页和采集商店截图（tool/capture_shots.sh）
                onLongPress: kDebugMode
                    ? () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ReportScreen(
                            report: buildSampleReport(
                                lang: sampleLangOf(
                                    Localizations.localeOf(context))))))
                    : null,
                child: Text(l.appTitle,
                    style: UType.serifItalic.copyWith(fontSize: 30)),
              ),
              Text(l.tagline,
                  style: const TextStyle(fontSize: 14, color: UColors.muted)),
              const SizedBox(height: 26),
              _EntryCard(
                primary: true,
                emoji: '💬',
                title: l.homeImportTitle,
                subtitle: l.homeImportSubtitle,
                hint: l.homeImportHint,
                onTap: _busy ? null : _startImport,
              ),
              const SizedBox(height: 14),
              _EntryCard(
                emoji: '📋',
                title: l.homePasteTitle,
                subtitle: l.homePasteSubtitle,
                onTap: _busy ? null : _pasteText,
              ),
              const SizedBox(height: 10),
              _SampleLink(
                title: l.homeSampleTitle,
                subtitle: l.homeSampleSubtitle,
                onTap: _busy ? null : _openSample,
              ),
              const Spacer(),
              if (_busy)
                const Center(
                    child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(color: UColors.rose),
                )),
              PrivacyNote(l.homePrivacy),
            ],
          ),
        ),
      ),
    );
  }
}

/// 首页入口统一的按压反馈：按下时轻微缩小，松手回弹。
/// 水波纹由各入口自己的 InkWell 画（卡片的不透明底色会盖住外层 InkWell）。
class _PressScale extends StatefulWidget {
  /// 把 onHighlightChanged 交给内部 InkWell，按下/松开时驱动缩放
  final Widget Function(ValueChanged<bool> onHighlightChanged) builder;

  const _PressScale({required this.builder});

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? .97 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: widget.builder((v) {
        if (v != _pressed) setState(() => _pressed = v);
      }),
    );
  }
}

/// 品牌色的浅水波纹
final _splash = UColors.rose.withValues(alpha: .12);
final _highlight = UColors.rose.withValues(alpha: .06);

/// 首页第三入口：先看示例报告。比两张入口卡轻一档，不抢主路径
class _SampleLink extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SampleLink(
      {required this.title, required this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return _PressScale(
      builder: (onHighlightChanged) => InkWell(
        onTap: onTap,
        onHighlightChanged: onHighlightChanged,
        borderRadius: BorderRadius.circular(12),
        splashColor: _splash,
        highlightColor: _highlight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          child: Row(
            children: [
              const Text('👀', style: TextStyle(fontSize: 17)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: UColors.rose)),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 11.5, color: UColors.muted)),
                  ],
                ),
              ),
              // chevron_right 随 RTL 自动镜像
              const Icon(Icons.chevron_right, size: 20, color: UColors.rose),
            ],
          ),
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final bool primary;
  final String emoji;
  final String title;
  final String subtitle;
  final String? hint;
  final VoidCallback? onTap;

  const _EntryCard({
    this.primary = false,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.hint,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _PressScale(
      builder: (onHighlightChanged) => UCard(
        color: primary ? UColors.roseSoft : null,
        borderColor: primary ? UColors.rose : null,
        padding: EdgeInsets.zero,
        // 透明 Material 放在卡片底色之上，水波纹才不会被底色盖住
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            onHighlightChanged: onHighlightChanged,
            borderRadius: BorderRadius.circular(16),
            splashColor: _splash,
            highlightColor: _highlight,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _content(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: primary ? UColors.rose : UColors.grid,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 19)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14.5)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 11.5, color: UColors.muted)),
                ],
              ),
            ),
          ],
        ),
        if (hint != null) ...[
          const SizedBox(height: 12),
          Container(
            // 分隔线横贯整张卡片，而不是只有提示文字那么宽
            width: double.infinity,
            padding: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
              border:
                  Border(top: BorderSide(color: UColors.roseBorder, width: 1)),
            ),
            child: Text(hint!,
                style: const TextStyle(
                    fontSize: 10.5, height: 1.7, color: Color(0xFFB06A79))),
          ),
        ],
      ],
    );
  }
}
