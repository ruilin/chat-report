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
    // 第一个 Scrollable 是整页的纵向滚动，顶部的快速跳转条排在它后面
    final position =
        tester.state<ScrollableState>(find.byType(Scrollable).first).position;
    position.jumpTo(position.maxScrollExtent);
    await tester.pumpAndSettle();
    final lastCard = tester.getRect(find.byType(UCard).last);
    expect(lastCard.bottom, lessThanOrEqualTo(800 - navBar));
  });

  testWidgets('quick jump chips scroll down to the deep dive',
      (tester) async {
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final l = await L.delegate.load(const Locale('en'));
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: L.localizationsDelegates,
      supportedLocales: L.supportedLocales,
      home: ReportScreen(report: buildSampleReport()),
    ));
    await tester.pumpAndSettle();
    final position =
        tester.state<ScrollableState>(find.byType(Scrollable).first).position;
    expect(position.pixels, 0);
    // 专题分析一开始在屏幕外
    expect(tester.getTopLeft(find.text(l.horsemanCriticism)).dy,
        greaterThan(800));

    // 测试字体更宽，按钮可能排到屏幕右侧之外，先横向滚出来
    final chip = find.widgetWithText(ActionChip, l.deepDiveTitle);
    await tester.ensureVisible(chip);
    await tester.pumpAndSettle();
    await tester.tap(chip);
    await tester.pumpAndSettle();
    expect(position.pixels, greaterThan(800));
    expect(tester.getTopLeft(find.text(l.horsemanCriticism)).dy,
        lessThan(800));
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
