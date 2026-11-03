import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chat_report/l10n/app_localizations.dart';
import 'package:chat_report/main.dart';
import 'package:chat_report/sample/sample_report.dart';
import 'package:chat_report/screens/report_screen.dart';

void main() {
  test('every UI language has its own sample copy', () {
    final en = buildSampleReport(lang: 'en');
    for (final locale in L.supportedLocales) {
      final lang = sampleLangOf(locale);
      // 只有英文界面才该用英文示例，其余语言缺文案会静默回退，这里要拦住
      expect(lang == 'en', locale.languageCode == 'en',
          reason: '$locale → $lang');
      final r = buildSampleReport(lang: lang);
      expect(r.deepReading, isNotEmpty, reason: lang);
      if (lang != 'en') {
        // 没有回退到英文
        expect(r.deepReading, isNot(en.deepReading), reason: lang);
        expect(r.advice.first, isNot(en.advice.first), reason: lang);
        expect(r.topics.first.topic, isNot(en.topics.first.topic),
            reason: lang);
      }
    }
  });

  test('sample language follows UI locale', () {
    expect(sampleLangOf(const Locale('en', 'US')), 'en');
    expect(sampleLangOf(const Locale('zh', 'CN')), 'zh');
    expect(sampleLangOf(const Locale('zh', 'TW')), 'zh-Hant');
    expect(sampleLangOf(const Locale('es', 'MX')), 'es');
    expect(sampleLangOf(const Locale('ja')), 'en');
  });

  testWidgets('home sample link opens a marked report that leads to import',
      (tester) async {
    await tester.pumpWidget(const ChatReportApp());
    final l = await L.delegate.load(const Locale('en'));

    await tester.tap(find.text(l.homeSampleTitle));
    await tester.pumpAndSettle();
    expect(find.byType(ReportScreen), findsOneWidget);
    expect(find.text(l.sampleBanner), findsOneWidget);
    // 示例报告不提供分享
    expect(find.byIcon(Icons.ios_share), findsNothing);

    await tester.tap(find.text(l.sampleCta));
    await tester.pumpAndSettle();
    expect(find.byType(ReportScreen), findsNothing);
    expect(find.text(l.guideTitle), findsOneWidget);
  });
}
