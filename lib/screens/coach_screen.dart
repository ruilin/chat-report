import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/locale_utils.dart';
import '../models/coach.dart';
import '../models/report.dart';
import '../services/analytics.dart';
import '../services/coach_client.dart';
import '../services/purchases.dart';
import '../services/report_store.dart';
import '../services/zai_client.dart';
import '../theme.dart';
import 'consent_dialog.dart';

/// AI 教练：围绕一份报告追问。对话随报告存在本机。
class CoachScreen extends StatefulWidget {
  final RelationshipReport report;

  /// 测试时注入假的客户端和存储
  final CoachClient? client;
  final ReportStore? store;

  const CoachScreen({super.key, required this.report, this.client, this.store});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  final _purchases = Purchases.instance;
  final _input = TextEditingController();
  final _scroll = ScrollController();
  late final CoachClient _client = widget.client ?? CoachClient();
  late final ReportStore _store = widget.store ?? ReportStore();
  bool _sending = false;
  bool _productLoaded = false;
  String? _error;

  /// 正在写出的回答
  String _partial = '';

  /// 等了一阵还没有字，告诉用户没卡死
  bool _slow = false;
  Timer? _slowTimer;
  static const _slowAfter = Duration(seconds: 8);

  List<CoachMessage> get _messages => widget.report.coachMessages;
  bool get _locked => !Purchases.isUnlocked(widget.report);
  bool get _outOfQuestions => _locked && _purchases.freeQuestionsLeft <= 0;

  @override
  void initState() {
    super.initState();
    Analytics.coachOpen();
    if (!_locked) return;
    _purchases.addListener(_onPurchaseChange);
    _purchases.loadBalances();
    _purchases.loadProduct().whenComplete(() {
      if (mounted) setState(() => _productLoaded = true);
    });
  }

  void _onPurchaseChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _slowTimer?.cancel();
    _purchases.removeListener(_onPurchaseChange);
    _input.dispose();
    _scroll.dispose();
    if (widget.client == null) _client.dispose();
    super.dispose();
  }

  Future<void> _send(String raw) async {
    final question = raw.trim();
    if (question.isEmpty || _sending || _outOfQuestions) return;
    final language = promptLanguageOf(context);
    final l = L.of(context);
    if (!await ensureAiConsent(context)) return;

    final history = List<CoachMessage>.of(_messages);
    _input.clear();
    setState(() {
      _messages.add(CoachMessage(fromUser: true, text: question));
      _sending = true;
      _error = null;
      _partial = '';
      _slow = false;
    });
    _scrollToEnd();
    _slowTimer = Timer(_slowAfter, () {
      if (mounted && _partial.isEmpty) setState(() => _slow = true);
    });

    try {
      final answer = await _client.ask(
        report: widget.report,
        history: history,
        question: question,
        language: language,
        onText: _onText,
      );
      // 回答成功才扣次数
      if (_locked) await _purchases.spendFreeQuestion();
      Analytics.coachAnswer(ok: true, left: _purchases.freeQuestionsLeft);
      // 回答跟着报告存，离开了页面也要留下
      _messages.add(CoachMessage(fromUser: false, text: answer));
      if (mounted) {
        setState(() {
          _partial = '';
          _sending = false;
        });
        _scrollToEnd();
      }
      await _save();
    } catch (e) {
      // ignore: avoid_print
      print('[coach] ask failed: $e');
      Analytics.coachAnswer(ok: false, left: _purchases.freeQuestionsLeft);
      // 先撤掉问题：离开页面后请求被中断时，也不能留下没有回答的问题
      _messages.removeLast();
      if (!mounted) return;
      // 退回到发送前，问题放回输入框，用户可以直接重发。
      // 错误写在输入框上方：SnackBar 会盖住发送按钮，挡住重发
      setState(() {
        _partial = '';
        _sending = false;
        _error = e is ZaiException ? e.localize(l) : l.errorServiceUnavailable;
      });
      _input.text = question;
    } finally {
      _slowTimer?.cancel();
    }
  }

  void _onText(String text) {
    if (!mounted) return;
    setState(() => _partial = text);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  Future<void> _save() async {
    try {
      await _store.save(widget.report);
    } catch (e) {
      // 存不下只是下次看不到这段对话，不打断当前使用
      // ignore: avoid_print
      print('[coach] save failed: $e');
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut);
      }
    });
  }

  Future<void> _reportAnswer() async {
    final l = L.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final reasons = {
      'offensive': l.coachReportOffensive,
      'harmful': l.coachReportHarmful,
      'wrong': l.coachReportWrong,
    };
    final reason = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: UColors.screen,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l.coachReportTitle,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            for (final e in reasons.entries)
              ListTile(
                title: Text(e.value),
                onTap: () => Navigator.pop(ctx, e.key),
              ),
          ],
        ),
      ),
    );
    if (reason == null) return;
    Analytics.coachAnswerReported(reason);
    messenger.showSnackBar(SnackBar(
      content: Text(l.coachReportThanks),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.coachTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                children: [
                  PrivacyNote(l.coachDisclaimer),
                  const SizedBox(height: 14),
                  if (_messages.isEmpty) _suggestions(l),
                  for (final m in _messages) _bubble(m, l),
                  if (_sending)
                    _partial.isEmpty
                        ? _Typing(slowText: _slow ? l.coachSlow : null)
                        : _bubble(
                            CoachMessage(fromUser: false, text: _partial), l,
                            done: false),
                ],
              ),
            ),
            _outOfQuestions ? _paywall(l) : _composer(l),
          ],
        ),
      ),
    );
  }

  Widget _suggestions(L l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final q in [l.coachSuggest1, l.coachSuggest2, l.coachSuggest3])
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ActionChip(
              label: Text(q,
                  style: const TextStyle(fontSize: 12.5, color: UColors.ink2)),
              backgroundColor: Colors.white,
              side: const BorderSide(color: UColors.line),
              shape: const StadiumBorder(),
              onPressed: _outOfQuestions || _sending ? null : () => _send(q),
            ),
          ),
      ],
    );
  }

  Widget _bubble(CoachMessage m, L l, {bool done = true}) {
    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: m.fromUser ? UColors.rose : Colors.white,
        border: m.fromUser ? null : Border.all(color: UColors.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(m.text,
          style: TextStyle(
              fontSize: 13.5,
              height: 1.55,
              color: m.fromUser ? Colors.white : UColors.ink)),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment:
            m.fromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * .82),
            child: bubble,
          ),
          if (!m.fromUser && done)
            IconButton(
              tooltip: l.coachReportTitle,
              visualDensity: VisualDensity.compact,
              iconSize: 16,
              color: UColors.faint,
              icon: const Icon(Icons.outlined_flag),
              onPressed: _reportAnswer,
            ),
        ],
      ),
    );
  }

  Widget _composer(L l) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 8, 8),
      decoration: const BoxDecoration(
        color: UColors.screen,
        border: Border(top: BorderSide(color: UColors.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_error case final error?)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(error,
                  style: const TextStyle(fontSize: 12, color: UColors.rose)),
            ),
          if (_locked)
            Text(l.coachLeft(_purchases.freeQuestionsLeft),
                style: const TextStyle(fontSize: 11, color: UColors.muted)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _input,
                  minLines: 1,
                  maxLines: 4,
                  maxLength: 500,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: l.coachHint,
                    hintStyle: const TextStyle(color: UColors.faint),
                    border: InputBorder.none,
                    counterText: '',
                  ),
                ),
              ),
              IconButton(
                tooltip: l.coachSend,
                icon: const Icon(Icons.send, color: UColors.rose),
                onPressed: _sending ? null : () => _send(_input.text),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paywall(L l) {
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
          Text(l.coachOutTitle,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text(l.coachOutBody,
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

class _Typing extends StatelessWidget {
  final String? slowText;

  const _Typing({this.slowText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child:
                CircularProgressIndicator(strokeWidth: 2, color: UColors.rose),
          ),
          if (slowText case final text?) ...[
            const SizedBox(width: 10),
            Expanded(
              child: Text(text,
                  style: const TextStyle(fontSize: 12, color: UColors.muted)),
            ),
          ],
        ],
      ),
    );
  }
}
