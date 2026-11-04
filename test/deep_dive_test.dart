import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chat_report/l10n/app_localizations.dart';
import 'package:chat_report/main.dart';
import 'package:chat_report/models/chat_data.dart';
import 'package:chat_report/models/deep_dive.dart';
import 'package:chat_report/models/report.dart';
import 'package:chat_report/sample/sample_report.dart';
import 'package:chat_report/screens/report_screen.dart';
import 'package:chat_report/services/analysis_pipeline.dart';
import 'package:chat_report/services/metrics_engine.dart';
import 'package:chat_report/services/purchases.dart';
import 'package:chat_report/services/quote_verifier.dart';
import 'package:chat_report/services/report_store.dart';
import 'package:chat_report/services/zai_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 按 z.ai 的 SSE 格式返回一段文字
http.Response streamedText(String text) => http.Response.bytes(
    utf8.encode('data: ${jsonEncode({
          'choices': [
            {
              'delta': {'content': text}
            }
          ]
        })}\n\ndata: [DONE]\n\n'),
    200);

class FakeStore implements StoreGateway {
  final controller = StreamController<List<PurchaseDetails>>.broadcast();
  final finished = <PurchaseDetails>[];
  ProductDetails? available = ProductDetails(
      id: Purchases.productId,
      title: 'Deep dive',
      description: '',
      price: r'$2.99',
      rawPrice: 2.99,
      currencyCode: 'USD');
  int buys = 0;
  int restores = 0;

  @override
  Stream<List<PurchaseDetails>> get purchases => controller.stream;
  @override
  Future<ProductDetails?> product(String id) async => available;
  @override
  Future<bool> buy(ProductDetails product) async {
    buys++;
    return true;
  }

  @override
  Future<void> restore() async => restores++;
  @override
  Future<void> finish(PurchaseDetails details) async => finished.add(details);
}

PurchaseDetails purchase(PurchaseStatus status,
    {String id = 'order-1', String? errorMessage}) {
  final d = PurchaseDetails(
    purchaseID: id,
    productID: Purchases.productId,
    verificationData: PurchaseVerificationData(
        localVerificationData: '', serverVerificationData: id, source: 'test'),
    transactionDate: '0',
    status: status,
  );
  if (errorMessage != null) {
    d.error = IAPError(source: 'test', code: 'x', message: errorMessage);
  }
  return d;
}

const sampleDive = DeepDive(
  conflictSummary: 'They tend to argue about plans.',
  conflicts: [
    EvidenceItem(
        date: '2026-03',
        title: 'The cancelled trip',
        detail: 'A plan fell through.',
        quote: 'you said you would come'),
  ],
  redFlags: [
    EvidenceItem(
        date: '2026-04',
        title: 'Silent treatment',
        detail: 'Long gaps after fights.',
        quote: 'fine whatever'),
  ],
  attachmentYou: AttachmentRead(style: 'Leans anxious', detail: 'Checks in.'),
  attachmentLoop: 'One chases, one retreats.',
  turningPoints: [
    TurningPoint(
        date: '2026-05',
        title: 'Back on track',
        detail: 'Warmer replies.',
        quote: 'i missed you',
        rising: true),
  ],
);

RelationshipReport reportWithDive({bool unlocked = false, String? id}) {
  final s = buildSampleReport();
  return RelationshipReport(
    id: id,
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
    deepDive: sampleDive,
    deepDiveUnlocked: unlocked,
  );
}

ChatData chat() {
  final start = DateTime(2026, 3, 1, 10);
  const lines = [
    ('Alex', 'you said you would come'),
    ('Mia', 'fine whatever'),
    ('Alex', 'I missed   you'),
    ('Mia', 'see you soon'),
  ];
  return ChatData(
    participants: const ['Alex', 'Mia'],
    messages: [
      for (var i = 0; i < 40; i++)
        ChatMessage(
          time: start.add(Duration(days: i * 2, minutes: i)),
          sender: lines[i % 4].$1,
          text: lines[i % 4].$2,
        ),
    ],
  );
}

void main() {
  late Directory dir;
  late ReportStore store;
  late FakeStore gateway;
  late Purchases purchases;

  // 购买流程里有真实的磁盘读写，多个测试文件同时跑时 50ms 偶尔不够
  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 250));

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    dir = await Directory.systemTemp.createTemp('reports');
    store = ReportStore(dir: () async => dir);
    gateway = FakeStore();
    purchases = Purchases(gateway, store);
  });

  tearDown(() async {
    await gateway.controller.close();
    await dir.delete(recursive: true);
  });

  group('quote verification', () {
    test('accepts exact quotes, rejects invented ones', () {
      final v = QuoteVerifier(chat());
      expect(v.contains('fine whatever'), isTrue);
      expect(v.contains('“FINE whatever”'), isTrue, reason: '大小写和引号不算改写');
      expect(v.contains('i missed you'), isTrue, reason: '空白差异不算改写');
      expect(v.contains('fine, whatever'), isFalse);
      expect(v.contains('I never loved you'), isFalse);
      expect(v.contains(''), isFalse);
    });

    test('items with invented quotes are dropped, real ones kept', () {
      final dive = AnalysisPipeline.parseDeepDive({
        'conflict': {'summary': 'Plans.', 'moments': []},
        'red_flags': [
          {'date': '2026-03', 'title': 'Real', 'quote': 'fine whatever'},
          {'date': '2026-03', 'title': 'Made up', 'quote': 'I hate you'},
          {'date': 'March', 'title': 'Bad date', 'quote': 'see you soon'},
        ],
        'green_flags': 'not a list',
        'attachment': {
          'you': {'style': 'Leans anxious', 'detail': 'x'},
          'partner': {'style': ''},
          'loop': 'y',
        },
        'turning_points': [
          {
            'date': '2026-04',
            'direction': 'down',
            'title': 'Cooling',
            'quote': 'fine whatever'
          },
        ],
      }, QuoteVerifier(chat()));

      expect(dive.redFlags.map((e) => e.title), ['Real', 'Bad date']);
      expect(dive.redFlags.last.date, '');
      expect(dive.greenFlags, isEmpty);
      expect(dive.attachmentYou?.style, 'Leans anxious');
      expect(dive.attachmentPartner, isNull);
      expect(dive.turningPoints.single.rising, isFalse);
    });

    test('all quotes invented and no attachment means nothing to sell', () {
      final dive = AnalysisPipeline.parseDeepDive({
        'red_flags': [
          {'title': 'Made up', 'quote': 'never said this'},
        ],
      }, QuoteVerifier(chat()));
      expect(dive.isEmpty, isTrue);
    });
  });

  group('pipeline', () {
    Future<RelationshipReport> run(
        http.Response Function(String system) answer) async {
      final data = chat();
      final client = ZaiClient(MockClient((req) async {
        final body = jsonDecode(req.body) as Map<String, dynamic>;
        final system =
            (body['messages'] as List).first['content'] as String;
        return answer(system);
      }));
      return AnalysisPipeline(client).run(
        data: data,
        metrics: MetricsEngine().compute(data, you: 'Alex'),
        relationship: Relationship.partner,
      );
    }

    http.Response ok(Map<String, dynamic> content) =>
        streamedText(jsonEncode(content));

    final month = {
      'sentiment': 6,
      'topics': ['Plans'],
      'summary': 's',
      'signals': [
        {'kind': 'red', 'label': 'l', 'quote': 'fine whatever'},
      ],
    };
    final free = {'warmth': 70, 'deep_reading': 'free reading'};

    test('deep dive failure does not lose the free report', () async {
      final report = await run((system) {
        if (system.contains('premium section')) {
          return http.Response('boom', 500);
        }
        return ok(system.contains('a month of chat') ? month : free);
      });
      expect(report.deepReading, 'free reading');
      expect(report.deepDive, isNull);
    });

    test('deep dive is attached with verified quotes only', () async {
      final prompts = <String>[];
      final report = await run((system) {
        prompts.add(system);
        if (system.contains('premium section')) {
          return ok({
            'red_flags': [
              {'title': 'Real', 'quote': 'fine whatever'},
              {'title': 'Fake', 'quote': 'made up words'},
            ],
          });
        }
        return ok(system.contains('a month of chat') ? month : free);
      });
      expect(report.deepDive!.redFlags.map((e) => e.title), ['Real']);
      expect(report.deepDiveUnlocked, isFalse);
    });

    test('broken JSON from the report step is retried, not fatal', () async {
      var reportCalls = 0;
      final r = await run((system) {
        if (system.contains('premium section')) return ok({});
        if (system.contains('a month of chat')) return ok(month);
        reportCalls++;
        return reportCalls == 1 ? streamedText('{"warmth": 50,, }') : ok(free);
      });
      expect(reportCalls, 2);
      expect(r.deepReading, isNotEmpty);
    });

    test('every step carries the language rules', () async {
      final systems = <String>[];
      await run((system) {
        systems.add(system);
        if (system.contains('premium section')) return ok({});
        return ok(system.contains('a month of chat') ? month : free);
      });
      expect(systems.length, greaterThanOrEqualTo(3));
      for (final s in systems) {
        expect(s, contains('never translate or transliterate'));
        expect(s, contains('including topic labels'));
        // 名字要写明，模型才不会自己音译
        expect(s, contains('"Alex"'));
      }
      // 报告写给用户本人看，每一步都不能用用户的名字
      for (final s in systems) {
        expect(s, contains('as "you" in the second person'));
      }
    });

    test('free report prompt does not receive premium signals', () async {
      final inputs = <String>[];
      final data = chat();
      final client = ZaiClient(MockClient((req) async {
        final body = jsonDecode(req.body) as Map<String, dynamic>;
        final msgs = body['messages'] as List;
        final system = msgs.first['content'] as String;
        if (system.contains('warm, evidence-based')) {
          inputs.add(msgs.last['content'] as String);
        }
        if (system.contains('premium section')) return ok({});
        return ok(system.contains('a month of chat') ? month : free);
      }));
      await AnalysisPipeline(client).run(
        data: data,
        metrics: MetricsEngine().compute(data, you: 'Alex'),
        relationship: Relationship.partner,
      );
      expect(inputs.single, isNot(contains('signals')));
    });
  });

  test('every report step uses the free model', () async {
    final models = <String>{};
    final data = chat();
    final client = ZaiClient(MockClient((req) async {
      final body = jsonDecode(req.body) as Map<String, dynamic>;
      models.add(body['model'] as String);
      return streamedText('{"sentiment": 5, "warmth": 50}');
    }));
    await AnalysisPipeline(client).run(
      data: data,
      metrics: MetricsEngine().compute(data, you: 'Alex'),
      relationship: Relationship.partner,
    );
    expect(models, {'glm-4.5-flash'});
  });

  group('report store', () {
    test('report survives a save and load, including the deep dive', () async {
      final r = reportWithDive();
      await store.save(r);
      final loaded = (await store.list()).single;
      expect(jsonEncode(loaded.toJson()), jsonEncode(r.toJson()));
      expect(loaded.deepDive!.turningPoints.single, isA<TurningPoint>());
      expect(await store.count(), 1);
    });

    test('newest first; corrupt files are skipped', () async {
      final older = reportWithDive(id: '100');
      await store.save(older);
      await Future<void>.delayed(const Duration(milliseconds: 5));
      final newer = reportWithDive(id: '200');
      await store.save(newer);
      await File('${dir.path}/300.json').writeAsString('{not json');
      expect((await store.list()).map((r) => r.id), ['200', '100']);
    });

    test('delete and unlock; unknown ids are safe', () async {
      final r = reportWithDive();
      await store.save(r);
      expect(await store.markUnlocked(r.id), isTrue);
      expect((await store.list()).single.deepDiveUnlocked, isTrue);
      expect(await store.markUnlocked('999'), isFalse);
      await store.delete(r.id);
      expect(await store.list(), isEmpty);
      expect(() => store.delete('../evil'), throwsArgumentError);
    });
  });

  group('purchases', () {
    Future<RelationshipReport> saved() async {
      final r = reportWithDive();
      await store.save(r);
      return r;
    }

    Future<bool> unlockedOnDisk(String id) async =>
        (await store.list()).firstWhere((r) => r.id == id).deepDiveUnlocked;

    test('successful purchase unlocks that report and consumes', () async {
      final r = await saved();
      await purchases.start();
      await purchases.buy(r.id);
      expect(gateway.buys, 1);
      expect(purchases.state, PurchaseState.buying);

      gateway.controller.add([purchase(PurchaseStatus.purchased)]);
      await settle();

      expect(await unlockedOnDisk(r.id), isTrue);
      expect(purchases.lastUnlockedId, r.id);
      expect(purchases.state, PurchaseState.idle);
      expect(gateway.finished, hasLength(1));
    });

    test('a replayed purchase is consumed but not granted twice', () async {
      final r = await saved();
      await purchases.start();
      await purchases.buy(r.id);
      gateway.controller.add([purchase(PurchaseStatus.purchased)]);
      await settle();
      gateway.controller.add([purchase(PurchaseStatus.restored)]);
      await settle();
      expect(purchases.credits, 0);
      expect(gateway.finished, hasLength(2));
    });

    test('purchase survives an app restart before delivery', () async {
      final r = await saved();
      await purchases.start();
      await purchases.buy(r.id);
      final after = Purchases(gateway, store);
      await after.start();
      gateway.controller.add([purchase(PurchaseStatus.restored)]);
      await settle();
      expect(await unlockedOnDisk(r.id), isTrue);
    });

    test('paid but report deleted becomes a credit, usable once', () async {
      final r = await saved();
      await purchases.start();
      await purchases.buy(r.id);
      await store.delete(r.id);
      gateway.controller.add([purchase(PurchaseStatus.purchased)]);
      await settle();
      expect(purchases.credits, 1);
      expect(gateway.finished, hasLength(1));

      final other = await saved();
      await purchases.useCredit(other);
      expect(other.deepDiveUnlocked, isTrue);
      expect(await unlockedOnDisk(other.id), isTrue);
      expect(purchases.credits, 0);
      final third = await saved();
      await purchases.useCredit(third);
      expect(third.deepDiveUnlocked, isFalse);
    });

    test('credits persist across restarts', () async {
      await purchases.start();
      gateway.controller.add([purchase(PurchaseStatus.purchased)]);
      await settle();
      final after = Purchases(gateway, store);
      await after.start();
      expect(after.credits, 1);
    });

    test('cancel unlocks nothing and allows buying again', () async {
      final r = await saved();
      await purchases.start();
      await purchases.buy(r.id);
      gateway.controller.add([purchase(PurchaseStatus.canceled)]);
      await settle();
      expect(await unlockedOnDisk(r.id), isFalse);
      expect(purchases.state, PurchaseState.idle);
      await purchases.buy(r.id);
      expect(gateway.buys, 2);
    });

    test('pending blocks new purchases, then delivers to the right report',
        () async {
      final a = await saved();
      await Future<void>.delayed(const Duration(milliseconds: 2));
      final b = await saved();
      await purchases.start();
      await purchases.buy(a.id);
      gateway.controller.add([purchase(PurchaseStatus.pending)]);
      await settle();
      expect(purchases.state, PurchaseState.pending);
      expect(await unlockedOnDisk(a.id), isFalse);

      await purchases.buy(b.id);
      expect(gateway.buys, 1, reason: '还有一笔待付款，不能再发起');

      final after = Purchases(gateway, store);
      await after.start();
      expect(after.state, PurchaseState.pending, reason: '重启后仍知道在等付款');

      gateway.controller.add([purchase(PurchaseStatus.purchased)]);
      await settle();
      expect(await unlockedOnDisk(a.id), isTrue);
      expect(await unlockedOnDisk(b.id), isFalse);
    });

    test('error reports failure; already-owned asks the store to replay',
        () async {
      final r = await saved();
      await purchases.start();
      final baseline = gateway.restores;
      await purchases.buy(r.id);
      gateway.controller.add([
        purchase(PurchaseStatus.error,
            errorMessage: 'BillingResponse.itemAlreadyOwned')
      ]);
      await settle();
      expect(gateway.restores, baseline + 1);

      gateway.controller.add([purchase(PurchaseStatus.restored)]);
      await settle();
      expect(await unlockedOnDisk(r.id), isTrue, reason: '归属没有丢');

      await purchases.buy(r.id);
      gateway.controller.add([
        purchase(PurchaseStatus.error,
            id: 'order-2', errorMessage: 'BillingResponse.error')
      ]);
      await settle();
      expect(purchases.state, PurchaseState.failed);
    });

    test('product unavailable fails without charging', () async {
      gateway.available = null;
      final r = await saved();
      await purchases.start();
      await purchases.buy(r.id);
      expect(gateway.buys, 0);
      expect(purchases.state, PurchaseState.failed);
    });

    test('other products are ignored', () async {
      await purchases.start();
      final other = PurchaseDetails(
        purchaseID: 'x',
        productID: 'something_else',
        verificationData: PurchaseVerificationData(
            localVerificationData: '',
            serverVerificationData: '',
            source: 'test'),
        transactionDate: '0',
        status: PurchaseStatus.purchased,
      );
      gateway.controller.add([other]);
      await settle();
      expect(purchases.credits, 0);
      expect(gateway.finished, isEmpty);
    });
  });

  group('report screen', () {
    late L en;

    setUp(() async {
      en = await L.delegate.load(const Locale('en'));
      Purchases.instance = purchases;
      Purchases.deepDivePaywallEnabled = true;
    });

    tearDown(() => Purchases.deepDivePaywallEnabled = false);

    Future<void> show(WidgetTester tester, RelationshipReport report,
        {bool isSample = false, Locale locale = const Locale('en')}) async {
      tester.view.physicalSize = const Size(390, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        locale: locale,
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        home: ReportScreen(report: report, isSample: isSample),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('locked: shows price and counts, hides the content',
        (tester) async {
      await show(tester, reportWithDive());
      expect(find.text(en.deepDiveBuy(r'$2.99')), findsOneWidget);
      expect(find.text(en.deepDiveOneTime), findsOneWidget);
      expect(find.text(en.sectionRedFlags), findsOneWidget);
      expect(find.textContaining('Silent treatment'), findsNothing);
      expect(find.textContaining('fine whatever'), findsNothing);
      expect(find.textContaining('Leans anxious'), findsNothing);
      // 免费内容照常展示
      expect(find.text(buildSampleReport().deepReading), findsOneWidget);
    });

    testWidgets('unlocked: shows content with evidence, no paywall',
        (tester) async {
      await show(tester, reportWithDive(unlocked: true));
      expect(find.text('Silent treatment'), findsOneWidget);
      expect(find.text('“fine whatever”'), findsOneWidget);
      expect(find.text('Leans anxious'), findsOneWidget);
      expect(find.text(en.deepDiveNoGreenFlags), findsOneWidget);
      expect(find.text(en.deepDiveOneTime), findsNothing);
      expect(find.text(en.deepDiveDisclaimer), findsOneWidget);
    });

    testWidgets('paywall off: everyone sees the content, nothing to buy',
        (tester) async {
      Purchases.deepDivePaywallEnabled = false;
      await show(tester, reportWithDive());
      expect(find.text('Silent treatment'), findsOneWidget);
      expect(find.text('“fine whatever”'), findsOneWidget);
      expect(find.text(en.deepDiveBuy(r'\$2.99')), findsNothing);
      expect(find.text(en.deepDiveOneTime), findsNothing);
      expect(find.byIcon(Icons.lock_outline), findsNothing);
    });

    testWidgets('paywall off: sample shows no locks', (tester) async {
      Purchases.deepDivePaywallEnabled = false;
      await show(tester, buildSampleReport(), isSample: true);
      expect(find.text(en.sampleDeepDiveHint), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsNothing);
    });

    testWidgets('attachment labels follow the app language', (tester) async {
      await show(
          tester,
          RelationshipReport(
              metrics: reportWithDive().metrics,
              warmth: 50,
              warmthReason: '',
              emotionCurve: const [],
              topics: const [],
              personalityYou: const [],
              personalityPartner: const [],
              deepReading: '',
              milestones: const [],
              advice: const [],
              deepDiveUnlocked: true,
              deepDive: const DeepDive(
                  attachmentYou: AttachmentRead(style: 'Secure', detail: 'd'),
                  attachmentPartner:
                      AttachmentRead(style: 'an old label', detail: 'd'))));
      expect(find.text(en.attachmentSecure), findsOneWidget);
      expect(find.text('an old label'), findsOneWidget);
    });

    testWidgets('no deep dive means no paywall', (tester) async {
      await show(tester, buildSampleReport());
      expect(find.text(en.deepDiveTitle.toUpperCase()), findsNothing);
      // 少了内容要告诉用户
      expect(find.text(en.deepDiveMissing), findsOneWidget);
    });

    testWidgets('sample shows what is inside but cannot be bought',
        (tester) async {
      await show(tester, buildSampleReport(), isSample: true);
      expect(find.text(en.sampleDeepDiveHint), findsOneWidget);
      expect(find.textContaining(r'$'), findsNothing);
      expect(gateway.buys, 0);
    });

    testWidgets('store unavailable says so instead of a dead button',
        (tester) async {
      gateway.available = null;
      await show(tester, reportWithDive());
      expect(find.text(en.deepDiveUnavailable), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('buying unlocks the open report in place', (tester) async {
      final r = reportWithDive();
      await tester.runAsync(() async {
        await store.save(r);
        await purchases.start();
      });
      await show(tester, r);
      final buy = find.text(en.deepDiveBuy(r'$2.99'));
      await tester.ensureVisible(buy);
      await tester.pump();
      await tester.tap(buy);
      await tester.runAsync(settle);
      await tester.pump();
      expect(gateway.buys, 1);

      await tester.runAsync(() async {
        gateway.controller.add([purchase(PurchaseStatus.purchased)]);
        await settle();
      });
      await tester.pump();
      expect(find.text('Silent treatment'), findsOneWidget);
      expect(find.text(en.deepDiveOneTime), findsNothing);
    });

    testWidgets('paywall fits narrow screens in every language',
        (tester) async {
      for (final locale in L.supportedLocales) {
        tester.view.physicalSize = const Size(320, 3000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(MaterialApp(
          key: ValueKey(locale),
          locale: locale,
          localizationsDelegates: L.localizationsDelegates,
          supportedLocales: L.supportedLocales,
          home: ReportScreen(report: reportWithDive()),
        ));
        await tester.pumpAndSettle();
        final error = tester.takeException();
        expect(error, isNull,
            reason: '$locale ${error is FlutterError ? error.toStringDeep() : ''}');
      }
    });
  });

  testWidgets('home does not overflow on small screens in any language',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    for (final locale in L.supportedLocales) {
      tester.platformDispatcher.localesTestValue = [locale];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      await tester.pumpWidget(ChatReportApp(key: ValueKey(locale)));
      await tester.pump();
      expect(tester.takeException(), isNull, reason: '$locale');
    }
  });
}
