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
import 'package:chat_report/services/deep_dive_jobs.dart';
import 'package:chat_report/services/metrics_engine.dart';
import 'package:chat_report/services/purchases.dart';
import 'package:chat_report/services/quote_verifier.dart';
import 'package:chat_report/services/report_store.dart';
import 'package:chat_report/services/zai_client.dart';
import 'package:chat_report/widgets/deep_dive_section.dart';
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
  horsemen: [
    HorsemanItem(
        date: '2026-04',
        title: 'Shutting the door',
        detail: 'Ends the talk.',
        quote: 'you said you would come',
        kind: Horseman.stonewalling,
        byYou: false),
  ],
  attachmentYou: AttachmentRead(style: 'Leans anxious', detail: 'Checks in.'),
  attachmentLoop: 'One chases, one retreats.',
  loveYou: LoveLanguageRead(
      primary: LoveLanguage.time, detail: 'Wants to meet.', quote: 'see you soon'),
  turningPoints: [
    TurningPoint(
        date: '2026-05',
        title: 'Back on track',
        detail: 'Warmer replies.',
        quote: 'i missed you',
        rising: true),
  ],
);

RelationshipReport reportWithDive(
    {bool unlocked = false, String? id, DeepDive? dive = sampleDive}) {
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
    deepDive: dive,
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
  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 500));

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    dir = await Directory.systemTemp.createTemp('reports');
    store = ReportStore(dir: () async => dir);
    DeepDiveJobs.reset();
    DeepDiveJobs.store = store;
    gateway = FakeStore();
    purchases = Purchases(gateway, store);
  });

  tearDown(() async {
    await gateway.controller.close();
    await dir.delete(recursive: true);
  });

  group('psychology modules', () {
    test('keeps verified horsemen and readable love languages only', () {
      final dive = AnalysisPipeline.parseDeepDive({
        'four_horsemen': [
          {'kind': 'contempt', 'who': 'partner', 'date': '2026-03', 'title': 'Brushing off', 'detail': 'd', 'quote': 'fine whatever'},
          {'kind': 'criticism', 'who': 'you', 'title': 'Invented', 'quote': 'you never listen'},
          {'kind': 'sarcasm', 'who': 'you', 'title': 'Unknown kind', 'quote': 'fine whatever'},
          {'kind': 'stonewalling', 'who': 'Mia', 'title': 'Bad who', 'quote': 'fine whatever'},
        ],
        'love_languages': {
          'you': {'primary': 'time', 'detail': 'Wants to meet.', 'quote': 'see you soon'},
          'partner': {'primary': 'words', 'detail': 'd', 'quote': 'an invented quote'},
        },
      }, QuoteVerifier(chat()));
      expect(dive.horsemen, hasLength(1));
      expect(dive.horsemen.single.kind, Horseman.contempt);
      expect(dive.horsemen.single.byYou, isFalse);
      expect(dive.loveYou?.primary, LoveLanguage.time);
      expect(dive.loveYou?.quote, 'see you soon');
      // 原话对不上就去掉原话，判断留着
      expect(dive.lovePartner?.primary, LoveLanguage.words);
      expect(dive.lovePartner?.quote, '');
      expect(dive.isEmpty, isFalse);
    });

    test('who said a quote comes from the chat, not from the model', () {
      final verifier = QuoteVerifier(chat());
      expect(verifier.senderOf('fine whatever'), 'Mia');
      expect(verifier.senderOf('"You said you would come"'), 'Alex');
      // 没出现过，或两个人都说过，就不猜
      expect(verifier.senderOf('never written'), isNull);
      expect(verifier.senderOf('you'), isNull);

      final dive = AnalysisPipeline.parseDeepDive({
        'four_horsemen': [
          // 模型说是用户说的，其实是 Mia
          {'kind': 'contempt', 'who': 'you', 'title': 'Brushing off', 'quote': 'fine whatever'},
        ],
        'green_flags': [
          {'title': 'Reaching out', 'quote': 'I missed you'},
        ],
        'turning_points': [
          {'title': 'Warmer', 'direction': 'up', 'quote': 'see you soon'},
        ],
      }, verifier, you: 'Alex');
      expect(dive.horsemen.single.byYou, isFalse);
      expect(dive.horsemen.single.saidBy, 'partner');
      expect(dive.greenFlags.single.saidBy, 'you');
      expect(dive.turningPoints.single.saidBy, 'partner');

      // 存取后还在；旧报告没有这个字段也能读
      final again = DeepDive.fromJson(
          jsonDecode(jsonEncode(dive.toJson())) as Map<String, dynamic>);
      expect(again.greenFlags.single.saidBy, 'you');
      expect(again.horsemen.single.saidBy, 'partner');
      expect(EvidenceItem.fromJson({'title': 't', 'quote': 'q'}).saidBy, isNull);
      expect(const EvidenceItem(date: '', title: 't', detail: '', quote: 'q')
          .toJson()
          .containsKey('said_by'), isFalse);
    });

    test('a red flag that repeats a horsemen quote is dropped', () {
      final dive = AnalysisPipeline.parseDeepDive({
        'four_horsemen': [
          {'kind': 'contempt', 'who': 'partner', 'title': 'Brushing off', 'quote': 'fine whatever'},
        ],
        'red_flags': [
          {'title': 'Same line again', 'quote': 'Fine whatever'},
          {'title': 'Something else', 'quote': 'you said you would come'},
        ],
      }, QuoteVerifier(chat()));
      expect(dive.horsemen, hasLength(1));
      expect(dive.redFlags.single.title, 'Something else');
    });

    test('unknown love language means no reading', () {
      final dive = AnalysisPipeline.parseDeepDive({
        'love_languages': {
          'you': {'primary': 'Quality time'},
        },
      }, QuoteVerifier(chat()));
      expect(dive.loveYou, isNull);
      expect(dive.isEmpty, isTrue);
    });

    test('old reports without the new modules still load', () {
      final old = DeepDive.fromJson({'red_flags': [], 'attachment_loop': 'x'});
      expect(old.horsemen, isEmpty);
      expect(old.loveYou, isNull);
    });
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
      final report = await AnalysisPipeline(client).run(
        data: data,
        metrics: MetricsEngine().compute(data, you: 'Alex'),
        relationship: Relationship.partner,
      );
      // 专题分析在报告返回后才写完
      await DeepDiveJobs.running(report.id);
      return report;
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

    test('milestones record who said the quote', () async {
      final r = await run((system) {
        if (system.contains('premium section')) return ok({});
        if (system.contains('a month of chat')) return ok(month);
        return ok({
          'warmth': 70,
          'deep_reading': 'free reading',
          'milestones': [
            {'date': '2026-03', 'title': 'A', 'quote': 'see you soon'},
            {'date': '2026-03', 'title': 'B', 'quote': 'you said you would come'},
            {'date': '2026-03', 'title': 'C', 'quote': 'not in the chat'},
          ],
        });
      });
      expect([for (final m in r.milestones) m.saidBy], ['partner', 'you', null]);
      final loaded = RelationshipReport.fromJson(
          jsonDecode(jsonEncode(r.toJson())) as Map<String, dynamic>);
      expect([for (final m in loaded.milestones) m.saidBy], ['partner', 'you', null]);
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
      final report = await AnalysisPipeline(client).run(
        data: data,
        metrics: MetricsEngine().compute(data, you: 'Alex'),
        relationship: Relationship.partner,
      );
      await DeepDiveJobs.running(report.id);
      expect(inputs.single, isNot(contains('signals')));
    });

    test('the free report comes back first, the deep dive is saved later',
        () async {
      final gate = Completer<void>();
      final data = chat();
      final client = ZaiClient(MockClient((req) async {
        final body = jsonDecode(req.body) as Map<String, dynamic>;
        final system = (body['messages'] as List).first['content'] as String;
        if (system.contains('premium section')) {
          await gate.future;
          return ok({
            'red_flags': [
              {'title': 'Real', 'quote': 'fine whatever'},
            ],
          });
        }
        return ok(system.contains('a month of chat') ? month : free);
      }));
      final report = await AnalysisPipeline(client).run(
        data: data,
        metrics: MetricsEngine().compute(data, you: 'Alex'),
        relationship: Relationship.partner,
      );
      // 报告已经能看，专题分析还在写
      expect(report.deepReading, 'free reading');
      expect(report.deepDive, isNull);
      final job = DeepDiveJobs.running(report.id);
      expect(job, isNotNull);
      await store.save(report);
      // 这期间用户付了款，写回专题分析时不能把解锁状态盖掉
      await store.markUnlocked(report.id);

      gate.complete();
      await job;
      expect(report.deepDive!.redFlags.single.title, 'Real');
      expect(DeepDiveJobs.running(report.id), isNull);
      expect(DeepDiveJobs.canRetry(report.id), isFalse);
      final saved = (await store.list()).single;
      expect(saved.deepDive!.redFlags.single.title, 'Real');
      expect(saved.deepDiveUnlocked, isTrue);
    });

    test('a failed deep dive can be retried while the app stays open',
        () async {
      var fail = true;
      final data = chat();
      final client = ZaiClient(MockClient((req) async {
        final body = jsonDecode(req.body) as Map<String, dynamic>;
        final system = (body['messages'] as List).first['content'] as String;
        if (system.contains('premium section')) {
          if (fail) return http.Response('boom', 500);
          return ok({
            'red_flags': [
              {'title': 'Real', 'quote': 'fine whatever'},
            ],
          });
        }
        return ok(system.contains('a month of chat') ? month : free);
      }));
      final report = await AnalysisPipeline(client).run(
        data: data,
        metrics: MetricsEngine().compute(data, you: 'Alex'),
        relationship: Relationship.partner,
      );
      await DeepDiveJobs.running(report.id);
      expect(report.deepDive, isNull);
      expect(DeepDiveJobs.canRetry(report.id), isTrue);

      fail = false;
      await DeepDiveJobs.retry(report);
      expect(report.deepDive!.redFlags.single.title, 'Real');
      expect(DeepDiveJobs.canRetry(report.id), isFalse);
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
    final report = await AnalysisPipeline(client).run(
      data: data,
      metrics: MetricsEngine().compute(data, you: 'Alex'),
      relationship: Relationship.partner,
    );
    await DeepDiveJobs.running(report.id);
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
      Purchases.paywallEnabled = true;
    });

    tearDown(() => Purchases.paywallEnabled = false);

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
      final sample = buildSampleReport();
      expect(find.text(sample.deepReading), findsOneWidget);
      // 建议和教练都在这一个价格里，但建议的内容要解锁后才能看
      expect(find.text(sample.advice.first), findsNothing);
      expect(find.text(en.sectionAdvice), findsOneWidget);
      expect(
          find.descendant(
              of: find.byType(DeepDiveSection),
              matching: find.text(en.coachTitle)),
          findsOneWidget);
    });

    testWidgets('locked: one real finding is shown for free', (tester) async {
      await show(tester, reportWithDive());
      expect(find.text(en.previewLabel), findsOneWidget);
      expect(find.textContaining(en.horsemanStonewalling), findsOneWidget);
      expect(find.text('Shutting the door'), findsOneWidget);
      expect(find.text('“you said you would come”'), findsOneWidget);
      // 替代做法和其余条目仍然要解锁
      expect(find.text(en.antidoteStonewalling), findsNothing);
      expect(find.textContaining('fine whatever'), findsNothing);
    });

    testWidgets('locked: without horsemen the preview falls back, or is absent',
        (tester) async {
      await show(
          tester,
          reportWithDive(
              dive: const DeepDive(redFlags: [
            EvidenceItem(
                date: '2026-04',
                title: 'Silent treatment',
                detail: 'd',
                quote: 'fine whatever'),
            EvidenceItem(
                date: '2026-04',
                title: 'Second flag',
                detail: 'd',
                quote: 'see you soon'),
          ])));
      expect(find.text(en.previewLabel), findsOneWidget);
      expect(find.text('Silent treatment'), findsOneWidget);
      expect(find.text('Second flag'), findsNothing);

      await show(
          tester,
          reportWithDive(
              dive: const DeepDive(
                  attachmentYou: AttachmentRead(style: 'secure', detail: 'd'))));
      expect(find.text(en.previewLabel), findsNothing);
      expect(find.text(en.deepDiveOneTime), findsOneWidget);
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
      expect(find.text(buildSampleReport().advice.first), findsOneWidget);
      // 心理学模块：类型和爱的语言按界面语言显示，并给出替代做法
      expect(find.text(en.horsemanStonewalling), findsOneWidget);
      expect(find.text(en.antidoteStonewalling), findsOneWidget);
      expect(find.text(en.horsemanContempt), findsNothing);
      expect(find.text(en.loveTime), findsOneWidget);
      expect(find.text('“see you soon”'), findsOneWidget);
    });

    testWidgets('paywall off: everyone sees the content, nothing to buy',
        (tester) async {
      Purchases.paywallEnabled = false;
      await show(tester, reportWithDive());
      expect(find.text('Silent treatment'), findsOneWidget);
      expect(find.text('“fine whatever”'), findsOneWidget);
      expect(find.text(en.deepDiveBuy(r'\$2.99')), findsNothing);
      expect(find.text(en.deepDiveOneTime), findsNothing);
      expect(find.byIcon(Icons.lock_outline), findsNothing);
      expect(find.text(buildSampleReport().advice.first), findsOneWidget);
    });

    testWidgets('paywall off: sample shows no locks', (tester) async {
      Purchases.paywallEnabled = false;
      await show(tester, buildSampleReport(), isSample: true);
      expect(find.text(en.sampleDeepDiveHint), findsOneWidget);
      expect(find.text(en.samplePaidHint), findsNothing);
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

    testWidgets('no deep dive: says so and only sells what is there',
        (tester) async {
      await show(tester, reportWithDive(dive: null));
      // 少了内容要告诉用户
      expect(find.text(en.deepDiveMissing), findsOneWidget);
      expect(find.text(en.previewLabel), findsNothing);
      expect(find.text(en.sectionRedFlags), findsNothing);
      expect(find.text(en.sectionAdvice), findsOneWidget);
      expect(
          find.descendant(
              of: find.byType(DeepDiveSection),
              matching: find.text(en.coachTitle)),
          findsOneWidget);
      expect(find.text(en.deepDiveBuy(r'$2.99')), findsOneWidget);
    });

    testWidgets('no deep dive, already unlocked: nothing left to buy',
        (tester) async {
      Purchases.paywallEnabled = false;
      await show(tester, reportWithDive(dive: null));
      expect(find.text(en.deepDiveMissing), findsOneWidget);
      expect(find.text(en.deepDiveOneTime), findsNothing);
      // 不是这次打开期间生成的报告，没有原文可以重试
      expect(find.text(en.errorRetry), findsNothing);
    });

    testWidgets('deep dive still being written: says so, then fills in',
        (tester) async {
      Purchases.paywallEnabled = false;
      final gate = Completer<DeepDive?>();
      final r = reportWithDive(dive: null);
      // 任务要在真实的事件循环里跑，否则假时钟下等不到它结束
      await tester.runAsync(() async {
        DeepDiveJobs.start(r, () => gate.future);
      });
      tester.view.physicalSize = const Size(390, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      // 有转圈动画，不能等到静止
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        home: ReportScreen(report: r),
      ));
      await tester.pump();
      expect(find.text(en.deepDiveGenerating), findsOneWidget);
      expect(find.text(en.deepDiveMissing), findsNothing);
      // 免费报告已经能看
      expect(find.text(buildSampleReport().deepReading), findsOneWidget);

      await tester.runAsync(() async {
        final job = DeepDiveJobs.running(r.id);
        gate.complete(sampleDive);
        await job;
      });
      await tester.pumpAndSettle();
      expect(find.text(en.deepDiveGenerating), findsNothing);
      expect(find.text('Silent treatment'), findsOneWidget);
    });

    testWidgets('failed deep dive offers a retry that fills it in',
        (tester) async {
      Purchases.paywallEnabled = false;
      var calls = 0;
      final r = reportWithDive(dive: null);
      await tester.runAsync(() => DeepDiveJobs.start(
          r, () async => ++calls == 1 ? null : sampleDive));
      await show(tester, r);
      expect(find.text(en.deepDiveMissing), findsOneWidget);

      await tester.tap(find.text(en.errorRetry));
      await tester.pump();
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pumpAndSettle();
      expect(calls, 2);
      expect(find.text('Silent treatment'), findsOneWidget);
      expect(find.text(en.errorRetry), findsNothing);
    });

    testWidgets('sample shows all the paid content and cannot be bought',
        (tester) async {
      final sample = buildSampleReport();
      await show(tester, sample, isSample: true);
      // 付费墙开着时要说明这部分是付费的
      expect(find.text(en.samplePaidHint), findsOneWidget);
      expect(find.text(en.horsemanCriticism), findsOneWidget);
      expect(find.text(en.antidoteStonewalling), findsOneWidget);
      expect(find.text(en.loveWords), findsOneWidget);
      expect(find.text(en.attachmentAvoidant), findsOneWidget);
      expect(find.text(sample.advice.first), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsNothing);
      expect(find.textContaining(r'$'), findsNothing);
      expect(gateway.buys, 0);
    });

    testWidgets('sample fits narrow screens in every language',
        (tester) async {
      for (final locale in L.supportedLocales) {
        tester.view.physicalSize = const Size(320, 6000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(MaterialApp(
          key: ValueKey(locale),
          locale: locale,
          localizationsDelegates: L.localizationsDelegates,
          supportedLocales: L.supportedLocales,
          home: ReportScreen(
              report: buildSampleReport(lang: sampleLangOf(locale)),
              isSample: true),
        ));
        await tester.pumpAndSettle();
        final error = tester.takeException();
        expect(error, isNull,
            reason: '$locale ${error is FlutterError ? error.toStringDeep() : ''}');
      }
    });

    test('sample deep dive is written for every sample language', () {
      final en = buildSampleReport().deepDive!;
      for (final locale in L.supportedLocales) {
        final lang = sampleLangOf(locale);
        final dive = buildSampleReport(lang: lang).deepDive!;
        expect(dive.horsemen, hasLength(2), reason: lang);
        if (lang != 'en') {
          expect(dive.conflictSummary, isNot(en.conflictSummary), reason: lang);
          expect(dive.loveYou!.detail, isNot(en.loveYou!.detail), reason: lang);
        }
      }
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
      // 建议同时解锁，不用离开页面
      expect(find.text(r.advice.first), findsOneWidget);
    });

    testWidgets('unlocked content fits narrow screens in every language',
        (tester) async {
      for (final locale in L.supportedLocales) {
        tester.view.physicalSize = const Size(320, 4000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(MaterialApp(
          key: ValueKey(locale),
          locale: locale,
          localizationsDelegates: L.localizationsDelegates,
          supportedLocales: L.supportedLocales,
          home: ReportScreen(report: reportWithDive(unlocked: true)),
        ));
        await tester.pumpAndSettle();
        final error = tester.takeException();
        expect(error, isNull,
            reason: '$locale ${error is FlutterError ? error.toStringDeep() : ''}');
      }
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
