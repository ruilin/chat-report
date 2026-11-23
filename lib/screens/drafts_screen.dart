import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_localizations.dart';
import '../l10n/locale_utils.dart';
import '../models/draft.dart';
import '../models/report.dart';
import '../services/analytics.dart';
import '../services/draft_client.dart';
import '../services/purchases.dart';
import '../services/report_store.dart';
import '../services/zai_client.dart';
import '../theme.dart';
import '../widgets/unlock_panel.dart';
import 'consent_dialog.dart';

/// 写给 TA 的话：AI 起草，用户修改后自己发出去。App 不替用户发任何消息。
class DraftsScreen extends StatefulWidget {
  final RelationshipReport report;

  /// 测试时注入假的客户端和存储
  final DraftClient? client;
  final ReportStore? store;

  const DraftsScreen({super.key, required this.report, this.client, this.store});

  @override
  State<DraftsScreen> createState() => _DraftsScreenState();
}

class _DraftsScreenState extends State<DraftsScreen> {
  final _purchases = Purchases.instance;
  late final DraftClient _client = widget.client ?? DraftClient();
  late final ReportStore _store = widget.store ?? ReportStore();
  final _texts = <DraftKind, TextEditingController>{};
  final _errors = <DraftKind, String>{};

  /// 正在写的那一种，同一时间只写一条
  DraftKind? _writing;

  /// 模型判断这段聊天不适合起草消息
  bool _unsafe = false;

  RelationshipReport get _report => widget.report;

  @override
  void initState() {
    super.initState();
    Analytics.draftsOpen();
    _purchases.addListener(_onPurchaseChange);
    for (final d in _report.drafts) {
      _texts[d.kind] = TextEditingController(text: d.text);
    }
  }

  void _onPurchaseChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _purchases.removeListener(_onPurchaseChange);
    for (final c in _texts.values) {
      c.dispose();
    }
    if (widget.client == null) _client.dispose();
    super.dispose();
  }

  Future<void> _write(DraftKind kind) async {
    if (_writing != null) return;
    final l = L.of(context);
    final language = promptLanguageOf(context);
    if (!await ensureAiConsent(context)) return;

    final controller =
        _texts.putIfAbsent(kind, () => TextEditingController());
    final previous = controller.text.trim();
    setState(() {
      _writing = kind;
      _errors.remove(kind);
      controller.text = '';
    });

    try {
      final draft = await _client.write(
        report: _report,
        kind: kind,
        language: language,
        previous: previous.isEmpty ? null : previous,
        onText: (text) {
          if (mounted) controller.text = text;
        },
      );
      Analytics.draftGenerate(kind.name, draft == null ? 'refused' : 'ok');
      if (draft != null) {
        _report.drafts
          ..removeWhere((d) => d.kind == kind)
          ..add(MessageDraft(kind: kind, text: draft));
        await _save();
      }
      if (!mounted) return;
      setState(() {
        _writing = null;
        if (draft == null) {
          _unsafe = true;
          controller.text = previous;
        } else {
          controller.text = draft;
        }
      });
    } catch (e) {
      // ignore: avoid_print
      print('[drafts] write failed: $e');
      Analytics.draftGenerate(kind.name, 'error');
      if (!mounted) return;
      setState(() {
        _writing = null;
        // 写失败了，上一版草稿还给用户
        controller.text = previous;
        _errors[kind] =
            e is ZaiException ? e.localize(l) : l.errorServiceUnavailable;
      });
    }
  }

  Future<void> _save() async {
    try {
      await _store.save(_report);
    } catch (e) {
      // 存不下只是下次打开看不到这条草稿
      // ignore: avoid_print
      print('[drafts] save failed: $e');
    }
  }

  Future<void> _copy(DraftKind kind) async {
    final text = _texts[kind]!.text.trim();
    if (text.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    final copied = L.of(context).draftCopied;
    await Clipboard.setData(ClipboardData(text: text));
    Analytics.draftAction(kind.name, 'copy');
    messenger.showSnackBar(SnackBar(
        content: Text(copied), behavior: SnackBarBehavior.floating));
  }

  /// 调起系统分享，由用户自己选应用和联系人
  Future<void> _send(DraftKind kind) async {
    final text = _texts[kind]!.text.trim();
    if (text.isEmpty) return;
    Analytics.draftAction(kind.name, 'send');
    await SharePlus.instance.share(ShareParams(text: text));
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final partner = _report.metrics.partner;
    final allowed = DraftClient.allowed(_report);
    final anyLocked =
        DraftKind.values.any((k) => !DraftClient.isOpen(_report, k));

    return Scaffold(
      appBar: AppBar(title: Text(l.draftsEntryTitle(partner))),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                children: [
                  if (!allowed)
                    _note(l.draftExNote)
                  else if (_unsafe)
                    _note(l.draftUnsafe)
                  else ...[
                    Text(l.draftNote,
                        style: const TextStyle(
                            fontSize: 12, color: UColors.muted)),
                    const SizedBox(height: 12),
                    for (final kind in DraftKind.values) ...[
                      _card(l, kind),
                      const SizedBox(height: 12),
                    ],
                  ],
                ],
              ),
            ),
            if (allowed && !_unsafe && anyLocked)
              UnlockPanel(
                  report: _report, title: l.unlockTitle, body: l.draftLocked),
          ],
        ),
      ),
    );
  }

  Widget _note(String text) => UCard(
        child: Text(text,
            style: const TextStyle(
                fontSize: 13.5, height: 1.6, color: UColors.ink)),
      );

  Widget _card(L l, DraftKind kind) {
    final (title, hint) = switch (kind) {
      DraftKind.appreciate => (l.draftAppreciate, l.draftAppreciateHint),
      DraftKind.repair => (l.draftRepair, l.draftRepairHint),
      DraftKind.ask => (l.draftAsk, l.draftAskHint),
    };
    final open = DraftClient.isOpen(_report, kind);
    final writing = _writing == kind;
    final controller = _texts[kind];
    final hasText = controller != null && controller.text.trim().isNotEmpty;

    return UCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
              ),
              if (!open)
                const Icon(Icons.lock_outline, size: 16, color: UColors.gold),
            ],
          ),
          Text(hint,
              style: const TextStyle(fontSize: 12, color: UColors.muted)),
          if (open && (hasText || writing)) ...[
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              readOnly: writing,
              minLines: 2,
              maxLines: 8,
              style: const TextStyle(fontSize: 14, height: 1.55),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: writing ? l.draftWriting : null,
                hintStyle: const TextStyle(color: UColors.faint),
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: UColors.line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: UColors.line),
                ),
              ),
            ),
          ],
          if (_errors[kind] case final error?)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(error,
                  style: const TextStyle(fontSize: 12, color: UColors.rose)),
            ),
          if (open) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (hasText && !writing) ...[
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: UColors.rose,
                      shape: const StadiumBorder(),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () => _send(kind),
                    icon: const Icon(Icons.send, size: 15),
                    label: Text(l.draftSend),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: const StadiumBorder(),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () => _copy(kind),
                    child: Text(l.draftCopy),
                  ),
                ],
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: UColors.rose,
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: _writing == null ? () => _write(kind) : null,
                  child: Text(writing
                      ? l.draftWriting
                      : hasText
                          ? l.draftAgain
                          : l.draftWrite),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
