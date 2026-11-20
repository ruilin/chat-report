// 把商店截图要用的界面直接渲染成图片，不需要模拟器或手机。
//
// 每种语言出一组 1080×2340 的原图（和 tool/capture_shots.py 的产物同名同尺寸），
// 再交给 tool/gen_store_assets.py 加标题、裁成 Play 要求的比例。
//
// 用法（一次一种语言，字体按语言加载）：
//   flutter test tool/render_store_shots.dart \
//     --dart-define=OUT=/绝对路径/raw --dart-define=LOCALE=en
//   LOCALE 取 en / zh / zh_Hant / es / pt / fr / de / it / tr / ar / hi / id
//
// 测试环境没有系统字体，这里从 Flutter SDK 和 macOS 里加载：
// 拉丁文用 Roboto，中文、阿拉伯文、印地文各用一套系统字体，表情用 Apple Color Emoji。
import 'dart:io';
import 'dart:ui' as ui;

import 'package:chat_report/l10n/app_localizations.dart';
import 'package:chat_report/models/coach.dart';
import 'package:chat_report/models/report.dart';
import 'package:chat_report/sample/sample_report.dart';
import 'package:chat_report/screens/coach_screen.dart';
import 'package:chat_report/screens/home_screen.dart';
import 'package:chat_report/screens/report_screen.dart';
import 'package:chat_report/services/coach_client.dart';
import 'package:chat_report/services/zai_client.dart';
import 'package:chat_report/theme.dart';
import 'package:chat_report/widgets/charts.dart';
import 'package:chat_report/widgets/share_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

const outDir = String.fromEnvironment('OUT');
const localeTag = String.fromEnvironment('LOCALE', defaultValue: 'en');

// 和主力测试机一致：1080×2340，密度 450
const pixelRatio = 2.8125;
const screen = Size(1080 / pixelRatio, 2340 / pixelRatio);
const statusBar = 30.0;

/// ARB 后缀 → (Locale, 原图目录名)。目录名沿用 capture_shots.py 的 Android 语言标签
const locales = <String, (Locale, String)>{
  'en': (Locale('en'), 'en'),
  'zh': (Locale('zh'), 'zh-Hans'),
  'zh_Hant': (Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'), 'zh-Hant'),
  'es': (Locale('es'), 'es'),
  'pt': (Locale('pt'), 'pt-BR'),
  'fr': (Locale('fr'), 'fr'),
  'de': (Locale('de'), 'de'),
  'it': (Locale('it'), 'it'),
  'tr': (Locale('tr'), 'tr'),
  'ar': (Locale('ar'), 'ar'),
  'hi': (Locale('hi'), 'hi'),
  'id': (Locale('id'), 'id'),
};

Future<void> loadFont(String family, List<String> paths) async {
  final loader = FontLoader(family);
  var found = false;
  for (final path in paths) {
    final file = File(path);
    if (!file.existsSync()) continue;
    found = true;
    loader.addFont(
        Future.value(ByteData.view(file.readAsBytesSync().buffer)));
  }
  if (!found) fail('缺字体：$family ← $paths');
  await loader.load();
}

/// 这种语言的正文字体。没有系统字体可回退，所以整套界面都用它
List<String> scriptFont(String tag) => switch (tag) {
      'zh' || 'zh_Hant' => ['/System/Library/Fonts/Hiragino Sans GB.ttc'],
      'ar' => ['/System/Library/Fonts/SFArabic.ttf'],
      'hi' => ['/System/Library/Fonts/Kohinoor.ttc'],
      _ => const [],
    };

Future<void> loadFonts(String tag) async {
  final sdk = File(Platform.resolvedExecutable).parent.parent.parent.parent.path;
  final material = '$sdk/artifacts/material_fonts';
  final roboto = [
    for (final w in ['Regular', 'Medium', 'Bold', 'Black', 'Light', 'Italic'])
      '$material/Roboto-$w.ttf',
  ];
  final script = scriptFont(tag);
  final primary = script.isEmpty ? roboto : script;
  await loadFont('Primary', primary);
  // 没指定字体的文字（比如图表里自己画的标签）默认落到测试字体上，换成正文字体
  await loadFont('FlutterTest', primary);
  await loadFont('Roboto', roboto);
  await loadFont('MaterialIcons', ['$material/MaterialIcons-Regular.otf']);
  await loadFont('Palatino', [
    '/System/Library/Fonts/Supplemental/Georgia Italic.ttf',
    '/System/Library/Fonts/Supplemental/Georgia Bold Italic.ttf',
  ]);
  // serifItalic 的回退链是 Georgia → serif：分别放正文字体和表情
  await loadFont('Georgia', primary);
  await loadFont('serif', ['/System/Library/Fonts/Apple Color Emoji.ttc']);
  await loadFont('Emoji', ['/System/Library/Fonts/Apple Color Emoji.ttc']);
  // 「⋮」「→」这类符号正文字体里没有
  await loadFont('Symbols', ['/Library/Fonts/Arial Unicode.ttf']);
}

ThemeData shotTheme() {
  final base = buildTheme();
  TextTheme withFonts(TextTheme t) => t.apply(
      fontFamily: 'Primary',
      fontFamilyFallback: const ['Roboto', 'Emoji', 'Symbols']);
  return base.copyWith(
    textTheme: withFonts(base.textTheme),
    primaryTextTheme: withFonts(base.primaryTextTheme),
  );
}

/// 示例数据，但按真实报告展示：有分享按钮和教练入口，没有示例横幅
RelationshipReport sampleAsReal(String lang, L l) {
  final r = buildSampleReport(lang: lang);
  final dive = r.deepDive!;
  // 教练页放一轮问答，内容取自示例报告本身
  r.coachMessages.addAll([
    CoachMessage(fromUser: true, text: l.coachSuggest1),
    CoachMessage(
        fromUser: false, text: '${dive.conflictSummary}\n\n${r.advice[1]}'),
  ]);
  return r;
}

void main() {
  final entry = locales[localeTag];
  if (entry == null) fail('不认识的 LOCALE：$localeTag');
  final (locale, dirName) = entry;

  testWidgets('render $localeTag', (tester) async {
    if (outDir.isEmpty) fail('要传 --dart-define=OUT=输出目录');
    await tester.runAsync(() => loadFonts(localeTag));
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({'ai_consent_v1': true});

    final l = await L.delegate.load(locale);
    final lang = sampleLangOf(locale);
    final report = sampleAsReal(lang, l);
    final boundary = GlobalKey();
    final out = Directory('$outDir/$dirName')..createSync(recursive: true);

    tester.view.physicalSize = screen * pixelRatio;
    tester.view.devicePixelRatio = pixelRatio;
    tester.view.padding = const FakeViewPadding(top: statusBar * pixelRatio);
    addTearDown(tester.view.reset);

    Future<void> show(Widget home) async {
      await tester.pumpWidget(RepaintBoundary(
        key: boundary,
        child: MaterialApp(
          key: UniqueKey(),
          debugShowCheckedModeBanner: false,
          locale: locale,
          localizationsDelegates: L.localizationsDelegates,
          supportedLocales: L.supportedLocales,
          theme: shotTheme(),
          builder: (context, child) => Stack(children: [
            child!,
            const _StatusBar(),
          ]),
          home: home,
        ),
      ));
      await tester.pumpAndSettle();
    }

    Future<void> shoot(String name) async {
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final render = boundary.currentContext!.findRenderObject()
            as RenderRepaintBoundary;
        final image = await render.toImage(pixelRatio: pixelRatio);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        File('${out.path}/$name.png')
            .writeAsBytesSync(bytes!.buffer.asUint8List());
      });
    }

    /// 把某张卡片滚到顶栏下方，上面留一点间距
    Future<void> scrollTo(Finder inside) async {
      final card =
          find.ancestor(of: inside, matching: find.byType(UCard)).first;
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      final position = tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position;
      position.jumpTo(
          (position.pixels - 12).clamp(0.0, position.maxScrollExtent));
      await tester.pumpAndSettle();
    }

    // 1 首页，2 导入引导
    await show(const HomeScreen());
    await shoot('1_home');
    await tester.tap(find.text(l.homeImportTitle));
    await tester.pumpAndSettle();
    await shoot('2_guide');

    // 3-5 报告，7-8 专题分析
    await show(ReportScreen(report: report));
    await shoot('3_report_top');
    await scrollTo(find.byType(EmotionCurve));
    await shoot('4_report_mid');
    await scrollTo(find.text(report.deepReading));
    await shoot('5_report_deep');
    await scrollTo(find.text(l.fourHorsemenIntro));
    await shoot('7_horsemen');
    await scrollTo(find.text(l.loveLanguagesNote));
    // 依恋类型和爱的语言放进同一屏
    final position = tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position;
    position.jumpTo((position.pixels - 250).clamp(0.0, position.maxScrollExtent));
    await shoot('8_love');

    // 6 分享
    position.jumpTo(0);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.ios_share));
    await tester.pumpAndSettle();
    expect(find.byType(ShareCard), findsOneWidget);
    await shoot('6_share');

    // 9 AI 教练。不会真的发请求
    final offline = CoachClient(ZaiClient(
        MockClient((_) async => http.Response('offline', 503))));
    await show(CoachScreen(report: report, client: offline));
    await shoot('9_coach');
  });
}

/// 仿系统状态栏：时间和信号、电量图标
class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF3A2B3D);
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: statusBar,
      child: IgnorePointer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            textDirection: TextDirection.ltr,
            children: const [
              Text('12:00',
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: color,
                      decoration: TextDecoration.none)),
              Spacer(),
              Icon(Icons.wifi, size: 15, color: color),
              SizedBox(width: 4),
              Icon(Icons.signal_cellular_4_bar, size: 15, color: color),
              SizedBox(width: 4),
              Icon(Icons.battery_full, size: 15, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
