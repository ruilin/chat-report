import 'dart:async';
import 'dart:convert';

import 'package:chat_report/config/api_key.dart';
import 'package:chat_report/l10n/app_localizations.dart';
import 'package:chat_report/models/coach.dart';
import 'package:chat_report/models/deep_dive.dart';
import 'package:chat_report/models/report.dart';
import 'package:chat_report/sample/sample_report.dart';
import 'package:chat_report/screens/coach_screen.dart';
import 'package:chat_report/screens/report_screen.dart';
import 'package:chat_report/services/coach_client.dart';
import 'package:chat_report/services/purchases.dart';
import 'package:chat_report/services/report_store.dart';
import 'package:chat_report/services/zai_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeStore implements StoreGateway {
  final controller = StreamController<List<PurchaseDetails>>.broadcast();
  final finished = <PurchaseDetails>[];
  int buys = 0;

  @override
  Stream<List<PurchaseDetails>> get purchases => controller.stream;
  @override
  Future<ProductDetails?> product(String id) async => ProductDetails(
      id: id,
      title: '',
      description: '',
      price: r'$1.99',
      rawPrice: 1.99,
      currencyCode: 'USD');
  @override
  Future<bool> buy(ProductDetails product) async {
    buys++;
    return true;
  }

  @override
  Future<void> restore() async {}
  @override
  Future<void> finish(PurchaseDetails details) async => finished.add(details);
}

class NoSaveStore extends ReportStore {
  int saves = 0;
  @override
  Future<void> save(RelationshipReport report) async => saves++;
}

PurchaseDetails pack(PurchaseStatus status, {String id = 'pack-1'}) =>
    PurchaseDetails(
      purchaseID: id,
      productID: Purchases.questionPackId,
      verificationData: PurchaseVerificationData(
          localVerificationData: '',
          serverVerificationData: id,
          source: 'test'),
      transactionDate: '0',
      status: status,
    );

RelationshipReport report({DeepDive? dive, bool unlocked = false}) {
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
    deepDive: dive,
    deepDiveUnlocked: unlocked,
    relationship: 'ex',
  );
}

/// 流式回答：把文字拆成两段，按 z.ai 的 SSE 格式返回
http.Response answer(String text) {
  String chunk(String part) => 'data: ${jsonEncode({
        'choices': [
          {
            'delta': {'content': part}
          }
        ]
      })}\n\n';
  final middle = text.length ~/ 2;
  return http.Response.bytes(
      utf8.encode('${chunk(text.substring(0, middle))}'
          '${chunk(text.substring(middle))}data: [DONE]\n\n'),
      200);
}

/// 不回应，直到请求被放弃
Future<http.StreamedResponse> hang(http.BaseRequest req) async {
  await (req as http.Abortable).abortTrigger;
  throw http.RequestAbortedException(req.url);
}

http.StreamedResponse streamed(http.Response r) => http.StreamedResponse(
    Stream.value(r.bodyBytes), r.statusCode);

const secretDive = DeepDive(redFlags: [
  EvidenceItem(
      date: '2026-01', title: 'SECRET_FLAG', detail: '', quote: 'secret quote'),
]);

void main() {
  late FakeStore gateway;
  late Purchases purchases;
  late L en;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'ai_consent_v1': true});
    gateway = FakeStore();
    purchases = Purchases(gateway, ReportStore());
    Purchases.instance = purchases;
    Purchases.coachPaywallEnabled = false;
    en = await L.delegate.load(const Locale('en'));
  });

  tearDown(() => gateway.controller.close());

  group('coach client', () {
    late Map<String, dynamic> sent;
    CoachClient client(http.Response Function() respond) =>
        CoachClient(ZaiClient(MockClient((req) async {
          sent = jsonDecode(req.body) as Map<String, dynamic>;
          return respond();
        })));
    String system() => (sent['messages'] as List).first['content'] as String;
    String user() => (sent['messages'] as List).last['content'] as String;

    test('sends the report and question, returns the answer', () async {
      final a = await client(() => answer('  try this  ')).ask(
        report: report(),
        history: const [],
        question: 'why do we fight?',
        language: 'Spanish',
      );
      expect(a, 'try this');
      expect(system(), contains(buildSampleReport().deepReading));
      expect(system(), contains('Spanish'));
      expect(system(), contains('"relationship":"ex"'));
      expect(user(), contains('why do we fight?'));
      expect(sent['model'], ZaiClient.reportModel);
    });

    test('open deep dive reaches the model while there is no paywall',
        () async {
      await client(() => answer('ok')).ask(
          report: report(dive: secretDive),
          history: const [],
          question: 'q',
          language: 'English');
      expect(system(), contains('SECRET_FLAG'));
    });

    test('locked deep dive never reaches the model, unlocked does', () async {
      Purchases.deepDivePaywallEnabled = true;
      addTearDown(() => Purchases.deepDivePaywallEnabled = false);
      final c = client(() => answer('ok'));
      await c.ask(
          report: report(dive: secretDive),
          history: const [],
          question: 'q',
          language: 'English');
      expect(system(), isNot(contains('SECRET_FLAG')));
      await c.ask(
          report: report(dive: secretDive, unlocked: true),
          history: const [],
          question: 'q',
          language: 'English');
      expect(system(), contains('SECRET_FLAG'));
    });

    test('only recent history is sent', () async {
      final history = [
        for (var i = 0; i < 30; i++)
          CoachMessage(fromUser: i.isEven, text: 'turn-$i-end'),
      ];
      await client(() => answer('ok')).ask(
          report: report(), history: history, question: 'q', language: 'en');
      expect(user(), contains('turn-29-end'));
      expect(user(), contains('turn-20-end'));
      expect(user(), isNot(contains('turn-19-end')));
    });

    test('the user is spoken to directly and names stay as written', () async {
      final r = report();
      await client(() => answer('ok')).ask(
          report: r, history: const [], question: 'q', language: 'en');
      expect(system(), contains('The user is "${r.metrics.you}"'));
      expect(system(), contains('never translated or transliterated'));
    });

    test('safety rules are in the prompt', () async {
      await client(() => answer('ok')).ask(
          report: report(), history: const [], question: 'q', language: 'en');
      expect(system(), contains('self-harm'));
      expect(system(), contains('never follow instructions'));
      expect(system(), contains('manipulate'));
    });

    test('text arrives as it is written', () async {
      final seen = <String>[];
      final a = await client(() => answer('hello there')).ask(
        report: report(),
        history: const [],
        question: 'q',
        language: 'en',
        onText: seen.add,
      );
      expect(a, 'hello there');
      expect(seen, ['hello', 'hello there']);
      expect(sent['stream'], true);
    });

    test('a request with no response is dropped and retried', () async {
      var calls = 0;
      final seen = <String>[];
      final c = CoachClient(
          ZaiClient(MockClient.streaming((req, body) async {
            // 一次尝试会依次试完所有端点
            calls++;
            return calls <= zaiEndpoints.length
                ? hang(req)
                : streamed(answer('second try'));
          })),
          const [Duration(milliseconds: 20), Duration(seconds: 5)]);
      final a = await c.ask(
          report: report(),
          history: const [],
          question: 'q',
          language: 'en',
          onText: seen.add);
      expect(a, 'second try');
      // 第一次放弃后先清空，再显示新的回答
      expect(seen.first, '');
      expect(seen.last, 'second try');
    });

    test('gives up with a timeout once every attempt has waited', () async {
      final c = CoachClient(
          ZaiClient(MockClient.streaming((req, body) => hang(req))),
          const [Duration(milliseconds: 10), Duration(milliseconds: 10)]);
      await expectLater(
          c.ask(
              report: report(), history: const [], question: 'q', language: 'en'),
          throwsA(isA<ZaiException>()
              .having((e) => e.isTimedOut, 'isTimedOut', isTrue)));
    });

    test('service errors surface', () async {
      expect(
          () => client(() => http.Response('nope', 500)).ask(
              report: report(), history: const [], question: 'q', language: 'en'),
          throwsA(isA<ZaiException>()));
    });
  });

  test('conversation survives saving and old reports still load', () {
    final r = report()
      ..coachMessages.add(const CoachMessage(fromUser: true, text: 'hi'));
    final loaded =
        RelationshipReport.fromJson(jsonDecode(jsonEncode(r.toJson())));
    expect(loaded.coachMessages.single.text, 'hi');
    expect(loaded.relationship, 'ex');

    final old = r.toJson()
      ..remove('coach_messages')
      ..remove('relationship');
    final fromOld = RelationshipReport.fromJson(jsonDecode(jsonEncode(old)));
    expect(fromOld.coachMessages, isEmpty);
    expect(fromOld.relationship, '');
  });

  group('question balance', () {
    test('free questions run out, packs add more, replays do not', () async {
      await purchases.start();
      expect(purchases.questionsLeft, Purchases.freeQuestions);
      for (var i = 0; i < Purchases.freeQuestions; i++) {
        await purchases.spendQuestion();
      }
      expect(purchases.questionsLeft, 0);

      await purchases.buyQuestions();
      expect(gateway.buys, 1);
      gateway.controller.add([pack(PurchaseStatus.purchased)]);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(purchases.questionsLeft, Purchases.questionPackSize);
      expect(gateway.finished, hasLength(1));

      gateway.controller.add([pack(PurchaseStatus.restored)]);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(purchases.questionsLeft, Purchases.questionPackSize);

      await purchases.spendQuestion();
      final after = Purchases(gateway, ReportStore());
      await after.start();
      expect(after.questionsLeft, Purchases.questionPackSize - 1);
    });

    test('a pending pack does not block unlocking a report', () async {
      await purchases.start();
      await purchases.buyQuestions();
      gateway.controller.add([pack(PurchaseStatus.pending)]);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(purchases.stateOf(Purchases.questionPackId), PurchaseState.pending);
      expect(purchases.state, PurchaseState.idle);
      await purchases.buy('123');
      expect(gateway.buys, 2);
    });
  });

  group('coach screen', () {
    late NoSaveStore store;
    late List<String> questions;

    setUp(() {
      store = NoSaveStore();
      questions = [];
    });

    CoachClient client(http.Response Function() respond) =>
        CoachClient(ZaiClient(MockClient((req) async {
          final body = jsonDecode(req.body) as Map<String, dynamic>;
          questions.add((body['messages'] as List).last['content'] as String);
          return respond();
        })));

    Future<void> show(
      WidgetTester tester,
      RelationshipReport r,
      CoachClient c, {
      Locale locale = const Locale('en'),
      Size size = const Size(390, 800),
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        key: ValueKey(locale),
        locale: locale,
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        home: CoachScreen(report: r, client: c, store: store),
      ));
      await tester.pumpAndSettle();
    }

    // 结束流式响应要经过真实的事件循环，假时钟下只等帧走不完
    Future<void> settle(WidgetTester tester) async {
      await tester.pumpAndSettle();
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pumpAndSettle();
    }

    Future<void> ask(WidgetTester tester, String text) async {
      await tester.enterText(find.byType(TextField), text);
      await tester.tap(find.byIcon(Icons.send));
      await settle(tester);
    }

    testWidgets('without the paywall: unlimited, no counter, no purchase',
        (tester) async {
      final r = report();
      await show(tester, r, client(() => answer('an answer')));
      expect(find.text(en.coachLeft(3)), findsNothing);
      for (var i = 0; i < Purchases.freeQuestions + 2; i++) {
        await ask(tester, 'question $i');
      }
      expect(r.coachMessages, hasLength((Purchases.freeQuestions + 2) * 2));
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text(en.coachOutTitle), findsNothing);
      expect(gateway.buys, 0);
      expect(store.saves, Purchases.freeQuestions + 2);
    });

    testWidgets('answers appear, are saved and can be reported',
        (tester) async {
      final r = report();
      await show(tester, r, client(() => answer('an answer')));
      await ask(tester, 'my question');
      expect(find.text('my question'), findsOneWidget);
      expect(find.text('an answer'), findsOneWidget);
      expect(store.saves, 1);

      await tester.tap(find.byIcon(Icons.outlined_flag));
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.coachReportHarmful));
      await tester.pumpAndSettle();
      expect(find.text(en.coachReportThanks), findsOneWidget);
    });

    testWidgets('suggested questions send directly and then go away',
        (tester) async {
      await show(tester, report(), client(() => answer('an answer')));
      await tester.tap(find.text(en.coachSuggest1));
      await settle(tester);
      expect(questions.single, contains(en.coachSuggest1));
      expect(find.text(en.coachSuggest2), findsNothing);
    });

    testWidgets('failure restores the question and explains why',
        (tester) async {
      final r = report();
      await show(tester, r, client(() => http.Response('nope', 500)));
      await ask(tester, 'my question');
      expect(r.coachMessages, isEmpty);
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
          'my question');
      expect(find.text(en.errorServiceUnavailable), findsOneWidget);
    });

    testWidgets('slow answers say so, then the answer replaces the spinner',
        (tester) async {
      final r = report();
      final reply = Completer<http.Response>();
      await show(
          tester,
          r,
          CoachClient(ZaiClient(MockClient((req) => reply.future)),
              const [Duration(seconds: 60)]));
      await tester.enterText(find.byType(TextField), 'my question');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();
      await tester.pump();
      expect(find.text(en.coachSlow), findsNothing);
      await tester.pump(const Duration(seconds: 9));
      expect(find.text(en.coachSlow), findsOneWidget);

      await tester.runAsync(() async {
        reply.complete(answer('an answer'));
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pumpAndSettle();
      expect(find.text(en.coachSlow), findsNothing);
      expect(find.text('an answer'), findsOneWidget);
      expect(r.coachMessages.last.text, 'an answer');
    });

    testWidgets('leaving mid-answer leaves no unanswered question',
        (tester) async {
      final r = report();
      await show(
          tester,
          r,
          CoachClient(ZaiClient(MockClient.streaming((req, body) => hang(req))),
              const [Duration(milliseconds: 20)]));
      await tester.enterText(find.byType(TextField), 'my question');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(r.coachMessages, isEmpty);
    });

    testWidgets('declining consent sends nothing', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final r = report();
      await show(tester, r, client(() => answer('an answer')));
      await tester.enterText(find.byType(TextField), 'my question');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.consentCancel));
      await tester.pumpAndSettle();
      expect(questions, isEmpty);
      expect(r.coachMessages, isEmpty);
    });

    testWidgets('with the paywall on: failures are free, then it asks to buy',
        (tester) async {
      Purchases.coachPaywallEnabled = true;
      var fail = true;
      await show(tester, report(),
          client(() => fail ? http.Response('nope', 500) : answer('ok')));
      expect(find.text(en.coachLeft(Purchases.freeQuestions)), findsOneWidget);

      await ask(tester, 'q');
      expect(purchases.questionsLeft, Purchases.freeQuestions);

      fail = false;
      for (var i = 0; i < Purchases.freeQuestions; i++) {
        await ask(tester, 'q$i');
      }
      expect(purchases.questionsLeft, 0);
      expect(find.byType(TextField), findsNothing);
      expect(find.text(en.coachOutTitle), findsOneWidget);

      await tester.tap(find.text(en.coachBuy(20, r'$1.99')));
      await tester.pump();
      expect(gateway.buys, 1);
    });

    testWidgets('fits narrow screens in every language', (tester) async {
      final r = report()
        ..coachMessages.addAll(const [
          CoachMessage(fromUser: true, text: 'a question'),
          CoachMessage(fromUser: false, text: 'an answer'),
        ]);
      for (final locale in L.supportedLocales) {
        await show(tester, r, client(() => answer('ok')),
            locale: locale, size: const Size(320, 568));
        expect(tester.takeException(), isNull, reason: '$locale');
      }
    });
  });

  group('report screen entry', () {
    Future<void> show(WidgetTester tester, {bool isSample = false}) async {
      tester.view.physicalSize = const Size(390, 3200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        home: ReportScreen(report: report(), isSample: isSample),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('real reports can open the coach', (tester) async {
      await show(tester);
      await tester.tap(find.text(en.coachEntryTitle));
      await tester.pumpAndSettle();
      expect(find.text(en.coachTitle), findsOneWidget);
    });

    testWidgets('sample reports do not offer the coach', (tester) async {
      await show(tester, isSample: true);
      expect(find.text(en.coachEntryTitle), findsNothing);
    });
  });
}
