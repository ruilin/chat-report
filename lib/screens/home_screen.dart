import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../debug/mock_report.dart';
import '../l10n/app_localizations.dart';
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
    final action = await showImportGuideSheet(context);
    if (action == 'pick') await _importFile();
  }

  Future<void> _importFile() async {
    const group = XTypeGroup(label: 'Chat export', extensions: ['txt']);
    final file = await openFile(acceptedTypeGroups: [group]);
    if (file == null) return;
    final raw = await file.readAsString();
    await _parseAndGo(raw);
  }

  Future<void> _pasteText() async {
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
    if (raw != null && raw.trim().isNotEmpty) await _parseAndGo(raw);
  }

  Future<void> _parseAndGo(String raw) async {
    setState(() => _busy = true);
    try {
      final data = WhatsAppParser().parse(raw);
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => SetupScreen(data: data)));
    } on ParseException catch (e) {
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
                // debug 彩蛋：长按 logo 打开 mock 报告，调 UI 不用跑 LLM
                onLongPress: kDebugMode
                    ? () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            ReportScreen(
                                report: buildMockReport(
                                    lang: _mockLangOf(context)))))
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

/// debug mock 报告的语言键，与 promptLanguageOf 同源
String _mockLangOf(BuildContext context) {
  final loc = Localizations.localeOf(context);
  if (loc.languageCode != 'zh') return 'en';
  return (loc.scriptCode == 'Hant' ||
          const {'TW', 'HK', 'MO'}.contains(loc.countryCode))
      ? 'zh-Hant'
      : 'zh';
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: UCard(
        color: primary ? UColors.roseSoft : null,
        borderColor: primary ? UColors.rose : null,
        child: Column(
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
                padding: const EdgeInsets.only(top: 10),
                decoration: const BoxDecoration(
                  border: Border(
                      top: BorderSide(color: UColors.roseBorder, width: 1)),
                ),
                child: Text(hint!,
                    style: const TextStyle(
                        fontSize: 10.5,
                        height: 1.7,
                        color: Color(0xFFB06A79))),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
