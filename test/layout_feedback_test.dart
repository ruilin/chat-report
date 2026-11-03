import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chat_report/l10n/app_localizations.dart';
import 'package:chat_report/main.dart';
import 'package:chat_report/sample/sample_report.dart';
import 'package:chat_report/screens/report_screen.dart';
import 'package:chat_report/theme.dart';

void main() {
  testWidgets('report bottom stays above the system navigation bar',
      (tester) async {
    const navBar = 48.0;
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(bottom: navBar);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: L.localizationsDelegates,
      supportedLocales: L.supportedLocales,
      home: ReportScreen(report: buildSampleReport()),
    ));
    await tester.pumpAndSettle();

    // 滚到底，最后一张卡片的下沿必须在导航栏之上
    final list = find.descendant(
        of: find.byType(ListView), matching: find.byType(Scrollable));
    final position = tester.state<ScrollableState>(list.first).position;
    // ListView 懒布局，maxScrollExtent 会随后续子项布局而变大，跳到不再变为止
    do {
      position.jumpTo(position.maxScrollExtent);
      await tester.pumpAndSettle();
    } while (position.pixels < position.maxScrollExtent);
    final lastCard = tester.getRect(find.byType(UCard).last);
    expect(lastCard.bottom, lessThanOrEqualTo(800 - navBar));
  });

  testWidgets('home entry cards shrink while pressed and spring back',
      (tester) async {
    await tester.pumpWidget(const ChatReportApp());
    final l = await L.delegate.load(const Locale('en'));
    final title = find.text(l.homePasteTitle);
    double scale() => tester
        .widget<AnimatedScale>(
            find.ancestor(of: title, matching: find.byType(AnimatedScale)))
        .scale;

    expect(scale(), 1);
    final gesture = await tester.startGesture(tester.getCenter(title));
    await tester.pump(const Duration(milliseconds: 200));
    expect(scale(), lessThan(1));

    await gesture.up();
    await tester.pump(const Duration(milliseconds: 200));
    expect(scale(), 1);
  });
}
