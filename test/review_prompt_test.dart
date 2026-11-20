import 'package:chat_report/l10n/app_localizations.dart';
import 'package:chat_report/sample/sample_report.dart';
import 'package:chat_report/screens/report_screen.dart';
import 'package:chat_report/services/review_prompt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late int requests;
  late bool available;
  final defaultRequest = ReviewPrompt.request;
  final defaultReadTime = ReviewPrompt.minReadTime;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    requests = 0;
    available = true;
    ReviewPrompt.request = () async {
      if (!available) return false;
      requests++;
      return true;
    };
  });

  tearDown(() {
    ReviewPrompt.request = defaultRequest;
    ReviewPrompt.minReadTime = defaultReadTime;
  });

  test('asks once, then waits a month before asking again', () async {
    await ReviewPrompt.maybeAsk('share');
    await ReviewPrompt.maybeAsk('share');
    expect(requests, 1);

    final prefs = await SharedPreferences.getInstance();
    final longAgo = DateTime.now()
        .subtract(ReviewPrompt.minGap + const Duration(days: 1))
        .millisecondsSinceEpoch;
    await prefs.setInt('review_asked_at', longAgo);
    await ReviewPrompt.maybeAsk('report_read');
    expect(requests, 2);

    // 问过两次就不再问
    await prefs.setInt('review_asked_at', longAgo);
    await ReviewPrompt.maybeAsk('share');
    expect(requests, 2);
  });

  test('an unavailable store does not use up an ask', () async {
    available = false;
    await ReviewPrompt.maybeAsk('share');
    available = true;
    await ReviewPrompt.maybeAsk('share');
    expect(requests, 1);
  });

  test('a failing request never throws', () async {
    ReviewPrompt.request = () async => throw StateError('no store');
    await ReviewPrompt.maybeAsk('share');
  });

  group('leaving a report', () {
    Future<void> openAndLeave(WidgetTester tester, {bool isSample = false}) async {
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        home: ReportScreen(report: buildSampleReport(), isSample: isSample),
      ));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    }

    testWidgets('after reading long enough, asks for a review', (tester) async {
      ReviewPrompt.minReadTime = Duration.zero;
      await openAndLeave(tester);
      expect(requests, 1);
    });

    testWidgets('a quick look does not ask', (tester) async {
      await openAndLeave(tester);
      expect(requests, 0);
    });

    testWidgets('the sample report never asks', (tester) async {
      ReviewPrompt.minReadTime = Duration.zero;
      await openAndLeave(tester, isSample: true);
      expect(requests, 0);
    });
  });
}
