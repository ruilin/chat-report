import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chat_report/l10n/app_localizations.dart';
import 'package:chat_report/l10n/locale_utils.dart';
import 'package:chat_report/models/chat_data.dart';

void main() {
  test('all three locales are supported', () {
    final tags = L.supportedLocales.map((l) => l.toLanguageTag()).toSet();
    expect(tags, containsAll(['en', 'zh', 'zh-Hant']));
  });

  test('every locale resolves its own strings (no English leakage)', () async {
    final en = await L.delegate.load(const Locale('en'));
    final zh = await L.delegate.load(const Locale('zh'));
    final hant = await L.delegate
        .load(const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'));

    // 简体与繁体必须各自不同，且都不等于英文（否则说明回退到了模板）
    expect(zh.setupTitle, isNot(en.setupTitle));
    expect(hant.setupTitle, isNot(en.setupTitle));
    expect(hant.homeImportTitle, isNot(zh.homeImportTitle),
        reason: '繁体应使用「匯入」而非简体「导入」');

    // 带占位符的条目
    expect(zh.reportYouAnd('Mia'), contains('Mia'));
    expect(hant.setupMessageCount(12, 'Mar–Jul'), contains('12'));
  });

  test('traditional Chinese uses Taiwan/HK vocabulary, not converted glyphs',
      () async {
    final hant = await L.delegate
        .load(const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'));
    // 抽查几个最容易被简转繁工具做错的词
    expect(hant.homeImportTitle, contains('匯入'));
    expect(hant.reportMessages(3), contains('則'));
    expect(hant.analyzingPrivacy, contains('伺服器'));
    expect(hant.guideStep4Detail, contains('檔案'));
  });

  test('relationship labels localize', () async {
    final zh = await L.delegate.load(const Locale('zh'));
    final hant = await L.delegate
        .load(const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'));
    expect(Relationship.partner.label(zh), contains('伴侣'));
    expect(Relationship.partner.label(hant), contains('伴侶'));
    // promptName 是喂给 LLM 的稳定标识，不能随语言变
    expect(Relationship.partner.promptName, 'partner');
  });

  testWidgets('prompt language follows UI locale', (tester) async {
    Future<String> langFor(Locale locale) async {
      late String result;
      await tester.pumpWidget(Localizations(
        locale: locale,
        delegates: L.localizationsDelegates,
        child: Builder(builder: (context) {
          result = promptLanguageOf(context);
          return const SizedBox();
        }),
      ));
      await tester.pumpAndSettle();
      return result;
    }

    expect(await langFor(const Locale('en')), 'English');
    expect(await langFor(const Locale('zh')), 'Simplified Chinese');
    expect(
        await langFor(const Locale.fromSubtags(
            languageCode: 'zh', scriptCode: 'Hant')),
        'Traditional Chinese');
    expect(await langFor(const Locale('zh', 'TW')), 'Traditional Chinese');
    expect(await langFor(const Locale('zh', 'HK')), 'Traditional Chinese');
  });
}
