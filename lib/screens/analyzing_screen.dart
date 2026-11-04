import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/locale_utils.dart';
import '../models/chat_data.dart';
import '../services/analysis_pipeline.dart';
import '../services/analytics.dart';
import '../services/zai_client.dart';
import '../services/metrics_engine.dart';
import '../services/report_store.dart';
import '../theme.dart';
import 'report_screen.dart';

/// 分析页：真实管线进度 + 轮换的衬线斜体文案，把等待变成期待。
class AnalyzingScreen extends StatefulWidget {
  final ChatData data;
  final String you;
  final Relationship relationship;

  const AnalyzingScreen({
    super.key,
    required this.data,
    required this.you,
    required this.relationship,
  });

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen> {
  final _pipeline = AnalysisPipeline();
  double _fraction = 0;
  int _quipIndex = 0;
  Timer? _quipTimer;
  ZaiException? _error;
  Object? _rawError;
  final _stopwatch = Stopwatch();
  bool _finished = false;

  String get _rel => widget.relationship.name;
  int get _elapsedSec => _stopwatch.elapsed.inSeconds;

  @override
  void initState() {
    super.initState();
    _quipTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) setState(() => _quipIndex = (_quipIndex + 1) % 4);
    });
    // 依赖 Localizations，须等首帧后再读取
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    _stopwatch.start();
    Analytics.analysisStart(
        relationship: _rel, messageCount: widget.data.messages.length);
    try {
      final metrics =
          MetricsEngine().compute(widget.data, you: widget.you);
      final report = await _pipeline.run(
        data: widget.data,
        metrics: metrics,
        relationship: widget.relationship,
        language: promptLanguageOf(context),
        onProgress: (stage, fraction) {
          if (mounted) setState(() => _fraction = fraction);
        },
      );
      _finished = true;
      Analytics.analysisSuccess(
        relationship: _rel,
        messageCount: widget.data.messages.length,
        durationSec: _elapsedSec,
      );
      try {
        await ReportStore().save(report);
      } catch (e) {
        // 存不下也不影响这次查看；付款到账时会转成额度
        // ignore: avoid_print
        print('[analyze] save failed: $e');
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          settings: const RouteSettings(name: 'report'),
          builder: (_) => ReportScreen(report: report)));
    } catch (e) {
      // ignore: avoid_print
      print('[analyze] failed: $e');
      _finished = true;
      Analytics.analysisFail(
        relationship: _rel,
        errorKind: e is ZaiException ? e.kind.name : 'other',
        statusCode: e is ZaiException ? e.statusCode : null,
        durationSec: _elapsedSec,
      );
      if (mounted) {
        setState(() {
          _error = e is ZaiException ? e : null;
          _rawError = e;
        });
      }
    }
  }

  @override
  void dispose() {
    if (!_finished && _stopwatch.isRunning) {
      Analytics.analysisCancel(relationship: _rel, elapsedSec: _elapsedSec);
    }
    _quipTimer?.cancel();
    _pipeline.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final quips = [l.quip1, l.quip2, l.quip3, l.quip4];
    final pct = (_fraction * 100).round();
    final stages = <(String, bool)>[
      (l.stageReading(widget.data.messages.length), _fraction > .05),
      (l.stageCounting, _fraction > .08),
      (l.stageBetweenLines, _fraction > .7),
      (l.stageWriting, _fraction >= 1),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _rawError != null
              ? _ErrorView(
                  // 非接口错误（如模型输出无法解析）同样不是网络问题
                  message: _error?.localize(l) ?? l.errorServiceUnavailable,
                  onBack: () => Navigator.of(context).pop())
              : Column(
                  children: [
                    const Spacer(flex: 2),
                    SizedBox(
                      width: 130,
                      height: 130,
                      child: Stack(
                        fit: StackFit.expand,
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: _fraction.clamp(.02, 1),
                            strokeWidth: 8,
                            strokeCap: StrokeCap.round,
                            color: UColors.rose,
                            backgroundColor: UColors.grid,
                          ),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('$pct%',
                                    style: UType.num
                                        .copyWith(fontSize: 26)),
                                Text(l.analyzing,
                                    style: UType.label
                                        .copyWith(fontSize: 8)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Text(
                        quips[_quipIndex],
                        key: ValueKey(_quipIndex),
                        style: UType.serifItalic.copyWith(fontSize: 17),
                      ),
                    ),
                    const SizedBox(height: 26),
                    Builder(builder: (context) {
                      final current = stages.indexWhere((s) => !s.$2);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < stages.length; i++)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  if (stages[i].$2)
                                    const Icon(Icons.check,
                                        size: 15, color: UColors.blue)
                                  else if (i == current)
                                    const SizedBox(
                                      width: 15,
                                      height: 15,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: UColors.rose,
                                      ),
                                    )
                                  else
                                    const Icon(Icons.circle_outlined,
                                        size: 13, color: UColors.faint),
                                  const SizedBox(width: 10),
                                  Text(stages[i].$1,
                                      style: TextStyle(
                                          fontSize: 12.5,
                                          color: stages[i].$2
                                              ? UColors.ink2
                                              : UColors.muted)),
                                ],
                              ),
                            ),
                        ],
                      );
                    }),
                    const Spacer(flex: 3),
                    PrivacyNote(l.analyzingPrivacy),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onBack;
  const _ErrorView({required this.message, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('😕', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(L.of(context).errorTitle,
              style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(message,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: UColors.muted)),
          const SizedBox(height: 18),
          OutlinedButton(
              onPressed: onBack, child: Text(L.of(context).errorRetry)),
        ],
      ),
    );
  }
}
