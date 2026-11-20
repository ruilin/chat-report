import 'package:chat_report/l10n/app_localizations.dart';
import 'package:chat_report/widgets/share_card.dart';
import 'package:chat_report/models/report.dart';
import 'package:chat_report/sample/sample_report.dart';
import 'package:chat_report/services/purchases.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

RelationshipReport withLove({bool unlocked = true}) {
  final s = buildSampleReport();
  return RelationshipReport(
    metrics: s.metrics,
    warmth: s.warmth,
    warmthReason: s.warmthReason,
    emotionCurve: s.emotionCurve,
    topics: s.topics,
    personalityYou: s.personalityYou,
    personalityPartner: s.personalityPartner,
    deepReading: s.deepReading,
    milestones: s.milestones,
    advice: s.advice,
    deepDive: s.deepDive,
    deepDiveUnlocked: unlocked,
  );
}

void main() {
  tearDown(() => Purchases.paywallEnabled = false);

  testWidgets('love language and tall cards fit in every language',
      (tester) async {
    for (final locale in L.supportedLocales) {
      final l = await L.delegate.load(locale);
      for (final style in ShareCardStyle.values) {
        for (final tall in [false, true]) {
          await tester.pumpWidget(MaterialApp(
            key: ValueKey('$locale $style $tall'),
            locale: locale,
            localizationsDelegates: L.localizationsDelegates,
            supportedLocales: L.supportedLocales,
            home: Scaffold(
                body: SingleChildScrollView(
                    child: Center(
                        child: ShareCard(
                            report: withLove(), style: style, tall: tall)))),
          ));
          await tester.pumpAndSettle();
          final why = '$locale $style tall=$tall';
          expect(tester.takeException(), isNull, reason: why);
          final size = tester.getSize(find.byType(ShareCard));
          expect(size.width, ShareCard.width, reason: why);
          if (tall) expect(size.height, ShareCard.tallHeight, reason: why);
          expect(find.byType(QrImageView), findsOneWidget, reason: why);
          expect(find.text(l.loveWords),
              style == ShareCardStyle.love ? findsOneWidget : findsNothing,
              reason: why);
        }
      }
    }
  });

  test('love languages can only be shared from an unlocked report', () {
    Purchases.paywallEnabled = true;
    expect(ShareCard.canShareLove(withLove(unlocked: false)), isFalse);
    expect(ShareCard.canShareLove(withLove()), isTrue);
    Purchases.paywallEnabled = false;
    expect(ShareCard.canShareLove(withLove(unlocked: false)), isTrue);
  });

  testWidgets('share sheet offers styles and still fits a small screen',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final l = await L.delegate.load(const Locale('en'));
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: L.localizationsDelegates,
      supportedLocales: L.supportedLocales,
      home: Builder(
          builder: (context) => Scaffold(
              body: TextButton(
                  onPressed: () => showShareSheet(context, withLove()),
                  child: const Text('open')))),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text(l.loveWords), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, l.sectionLoveLanguages));
    await tester.pumpAndSettle();
    expect(find.text(l.loveWords), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, l.shareFormatTall));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    // 导出尺寸不受预览缩小影响
    expect(tester.getSize(find.byType(ShareCard)).height, ShareCard.tallHeight);
  });

  testWidgets('share card carries a QR code to the app in every language',
      (tester) async {
    for (final locale in L.supportedLocales) {
      await tester.pumpWidget(MaterialApp(
        key: ValueKey(locale),
        locale: locale,
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        home: Scaffold(
            body: Center(child: ShareCard(report: buildSampleReport()))),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$locale');
      expect(find.byType(QrImageView), findsOneWidget, reason: '$locale');
      // 两人各带一个性格标签
      final sample = buildSampleReport();
      expect(find.textContaining(sample.personalityYou.first), findsOneWidget);
      expect(
          find.textContaining(sample.personalityPartner.first), findsOneWidget);
      final l = await L.delegate.load(locale);
      expect(find.text(l.shareCardScan), findsOneWidget, reason: '$locale');
    }
    final link = Uri.parse(playStoreQrLink);
    expect(link.queryParameters['id'], 'com.ruilin.chatreport');
    expect(link.queryParameters['referrer'], 'utm_source=share_qr');
  });

  test('shared text links to the app in every language', () async {
    for (final locale in L.supportedLocales) {
      final l = await L.delegate.load(locale);
      final message = shareMessage(l);
      expect(message, startsWith(l.shareText), reason: '$locale');
      expect(message, endsWith(playStoreShareLink), reason: '$locale');
    }
    final link = Uri.parse(playStoreShareLink);
    expect(link.queryParameters['id'], 'com.ruilin.chatreport');
    expect(link.queryParameters['referrer'], 'utm_source=share_card');
  });
}
