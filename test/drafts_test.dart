import 'dart:async';
import 'dart:convert';

import 'package:chat_report/l10n/app_localizations.dart';
import 'package:chat_report/models/deep_dive.dart';
import 'package:chat_report/models/draft.dart';
import 'package:chat_report/models/report.dart';
import 'package:chat_report/sample/sample_report.dart';
import 'package:chat_report/screens/drafts_screen.dart';
import 'package:chat_report/screens/report_screen.dart';
import 'package:chat_report/services/draft_client.dart';
import 'package:chat_report/services/purchases.dart';
import 'package:chat_report/services/report_store.dart';
import 'package:chat_report/services/zai_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeStore implements StoreGateway {
  final controller = StreamController<List<PurchaseDetails>>.broadcast();
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
  Future<void> finish(PurchaseDetails details) async {}
}

class NoSaveStore extends ReportStore {
  int saves = 0;
  @override
  Future<void> save(RelationshipReport report) async => saves++;
}

/// 按 z.ai 的 SSE 格式分两段返回文字
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

/// 写完欣赏类草稿后那次单独的核对请求
bool isCheck(http.Request req) =>
    ((jsonDecode(req.body)['messages'] as List).first['content'] as String)
        .startsWith('You check one chat message');

/// 核对的回答。[deedBy] 是那件事实际谁做的，[credits] 是消息里算在谁头上
Map<String, dynamic> verdict(String deedBy, {String credits = 'other'}) => {
      'deed': 'knowing what they need',
      'deed_done_by': deedBy,
      'message_credits': credits,
    };

/// 模型按约定返回的 JSON
http.Response draft(String message, {bool concern = false}) => answer(jsonEncode({
      'concern': concern,
      'event': 'the trip',
      'done_by': 'other',
      'message': message,
    }));

const secretDive = DeepDive(redFlags: [
  EvidenceItem(
      date: '2026-01', title: 'SECRET_FLAG', detail: '', quote: 'secret quote'),
]);

RelationshipReport report(
    {bool unlocked = false, String relationship = 'partner'}) {
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
    deepDive: secretDive,
    deepDiveUnlocked: unlocked,
    relationship: relationship,
  );
}

void main() {
  late FakeStore gateway;
  late L en;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'ai_consent_v1': true});
    gateway = FakeStore();
    Purchases.instance = Purchases(gateway, ReportStore());
    Purchases.paywallEnabled = true;
    en = await L.delegate.load(const Locale('en'));
  });

  tearDown(() {
    Purchases.paywallEnabled = false;
    return gateway.controller.close();
  });

  group('draft client', () {
    late List<Map<String, dynamic>> sent;

    /// 核对请求单独记，回答「谢的是谁做的事」
    late List<Map<String, dynamic>> checks;
    DraftClient client(http.Response Function() respond,
        {String Function()? doneBy}) {
      sent = [];
      checks = [];
      return DraftClient(ZaiClient(MockClient((req) async {
        final body = jsonDecode(req.body) as Map<String, dynamic>;
        if (isCheck(req)) {
          checks.add(body);
          // 默认：事是对方做的，消息也算在对方头上
          return answer(jsonEncode(verdict(doneBy?.call() ?? 'other')));
        }
        sent.add(body);
        return respond();
      })));
    }

    String system() => (sent.last['messages'] as List).first['content'] as String;
    String user() => (sent.last['messages'] as List).last['content'] as String;

    test('each purpose carries its own evidence-based shape', () async {
      final c = client(() => draft('a draft'));
      final r = report(unlocked: true);
      await c.write(report: r, kind: DraftKind.appreciate, language: 'English');
      expect(system(), contains('Praise them and their action'));
      await c.write(report: r, kind: DraftKind.repair, language: 'English');
      expect(system(), contains('owns only what is in user_did'));
      expect(system(), contains('never promise to stop or fix, anything in other_did'));
      expect(system(), contains('Never invent a fault'));
      expect(system(), contains('Do not ask for forgiveness'));
      expect(system(), contains('"owns": "user, other or nothing"'));
      await c.write(report: r, kind: DraftKind.ask, language: 'English');
      expect(system(), contains('one feeling, about one specific situation'));
      expect(system(), contains('not an apology and not a promise'));
      expect(system(), contains('no question starting with "why"'));
      expect(system(), contains('"asks_other_to"'));
    });

    test('conflict drafts are told who wrote what, from the chat itself',
        () async {
      final s = buildSampleReport();
      final r = RelationshipReport(
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
        deepDiveUnlocked: true,
        deepDive: const DeepDive(conflicts: [
          EvidenceItem(
              date: '2026-02',
              title: 'Late again',
              detail: '',
              quote: 'third time this month',
              saidBy: 'you'),
          EvidenceItem(
              date: '2026-02',
              title: 'Shut down',
              detail: '',
              quote: 'not talking tonight',
              saidBy: 'partner'),
          EvidenceItem(
              date: '2026-02', title: 'Unknown', detail: '', quote: 'whose line'),
        ]),
      );
      final c = client(() => draft('a draft'));
      await c.write(report: r, kind: DraftKind.repair, language: 'English');
      expect(system(), contains('- the user wrote: ["third time this month"]'));
      expect(system(), contains(' wrote: ["not talking tonight"]'));
      expect(system(), contains('when the user wrote the complaint'));
      // 查不到说话人的不列进去
      expect(system(), isNot(contains('["whose line"]')));
      // 欣赏不谈吵架
      await c.write(report: r, kind: DraftKind.appreciate, language: 'English');
      expect(system(), isNot(contains('Who wrote what in their disagreements')));
    });

    test('safety and voice rules are always in the prompt', () async {
      final c = client(() => draft('a draft'));
      final text = await c.write(
          report: report(), kind: DraftKind.appreciate, language: 'Spanish');
      expect(text, 'a draft');
      expect(system(), contains('Never guilt, pressure, test, threaten'));
      expect(system(), contains('in the first person'));
      expect(system(), contains('Never mention the report, the app, AI'));
      expect(system(), contains('When concern is true, message must be ""'));
      expect(system(), contains('only thank the other person for things'));
      // 草稿跟聊天的语言走，用报告里的原话当样本
      expect(system(), contains(jsonEncode(buildSampleReport().milestones.first.quote)));
      expect(system(), contains('Write the message in the same language as these samples'));
      expect(sent.last['model'], ZaiClient.reportModel);
    });

    test('locked reports keep paid findings away from the model', () async {
      final c = client(() => draft('a draft'));
      await c.write(
          report: report(), kind: DraftKind.appreciate, language: 'English');
      expect(system(), isNot(contains('SECRET_FLAG')));
      await c.write(
          report: report(unlocked: true),
          kind: DraftKind.repair,
          language: 'English');
      expect(system(), contains('SECRET_FLAG'));
    });

    test('paid purposes need an unlocked report', () async {
      final c = client(() => draft('a draft'));
      expect(DraftClient.isOpen(report(), DraftKind.appreciate), isTrue);
      expect(DraftClient.isOpen(report(), DraftKind.repair), isFalse);
      expect(DraftClient.isOpen(report(unlocked: true), DraftKind.ask), isTrue);
      await expectLater(
          c.write(report: report(), kind: DraftKind.ask, language: 'English'),
          throwsStateError);
      expect(sent, isEmpty);
    });

    test('no drafts for an ex, and nothing is sent', () async {
      final c = client(() => draft('a draft'));
      final text = await c.write(
          report: report(unlocked: true, relationship: 'ex'),
          kind: DraftKind.appreciate,
          language: 'English');
      expect(text, isNull);
      expect(sent, isEmpty);
    });

    test('without quotes the draft falls back to the app language', () async {
      final s = buildSampleReport();
      final noQuotes = RelationshipReport(
          metrics: s.metrics,
          warmth: s.warmth,
          warmthReason: s.warmthReason,
          emotionCurve: s.emotionCurve,
          topics: s.topics,
          personalityYou: s.personalityYou,
          personalityPartner: s.personalityPartner,
          deepReading: s.deepReading,
          milestones: const [],
          advice: s.advice);
      await client(() => draft('x')).write(
          report: noQuotes, kind: DraftKind.appreciate, language: 'Spanish');
      expect(system(), contains('Write the message in Spanish.'));
    });

    test('only the message is shown while it is being written', () async {
      final seen = <String>[];
      final text = await client(() => draft('Thanks for "that" trip.')).write(
          report: report(),
          kind: DraftKind.appreciate,
          language: 'English',
          onText: seen.add);
      expect(text, 'Thanks for "that" trip.');
      expect(seen, isNotEmpty);
      for (final shown in seen) {
        expect(shown, isNot(contains('concern')));
        expect('Thanks for "that" trip.', startsWith(shown));
      }
    });

    test('appreciation about the user\'s own action is written again', () async {
      var calls = 0;
      final c = client(() => answer(jsonEncode({
            'concern': false,
            'done_by': ++calls == 1 ? 'user' : 'other',
            'message': calls == 1 ? 'I booked the trip.' : 'Thanks for coming.',
          })));
      final text = await c.write(
          report: report(), kind: DraftKind.appreciate, language: 'English');
      expect(calls, 2);
      expect(text, 'Thanks for coming.');
      // 模型自己都说是用户做的那一版，不用再发请求核对
      expect(checks, hasLength(1));
    });

    test('appreciation is checked once more for who really did it', () async {
      // 写的时候模型说是对方做的，单独再问才发现谢反了
      var calls = 0;
      var asked = 0;
      final c = client(
          () => draft(++calls == 1
              ? 'I love how you notice what I need.'
              : 'It meant a lot when you said I always know what you need.'),
          doneBy: () => ++asked == 1 ? 'user' : 'other');
      final text = await c.write(
          report: report(), kind: DraftKind.appreciate, language: 'English');
      expect(calls, 2);
      expect(text, startsWith('It meant a lot'));
      expect(checks, hasLength(2));
      final check = (checks.first['messages'] as List);
      expect(check.first['content'], contains('the deed is the user\'s'));
      expect(check.first['content'], contains('message_credits'));
      expect(check.last['content'], 'Message: "I love how you notice what I need."');
      expect(user(), contains('it thanked them for something the user did'));
      // 被拦下后让模型换一件事写，别在同一句话上打转
      expect(user(), contains('"knowing what they need"'));
      expect(user(), contains('build the message on a different moment'));

      // 锁着的报告，核对时也看不到付费内容
      expect(check.first['content'], isNot(contains('SECRET_FLAG')));

      // 另外两类不多发这次请求
      await c.write(
          report: report(unlocked: true), kind: DraftKind.repair, language: 'English');
      expect(checks, hasLength(2));
    });

    test('thanking them for saying so is fine, even when the user did the deed',
        () async {
      // 「谢谢你说我总是知道你要什么」：事是用户做的，消息里也说是用户做的
      final c = DraftClient(ZaiClient(MockClient((req) async => isCheck(req)
          ? answer(jsonEncode(verdict('user', credits: 'user')))
          : draft('It meant a lot when you said I always know what you need.'))));
      expect(
          await c.write(
              report: report(), kind: DraftKind.appreciate, language: 'English'),
          startsWith('It meant a lot'));

      // 核对说不清是谁做的，不因此拦下
      final unclear = DraftClient(ZaiClient(MockClient((req) async => isCheck(req)
          ? answer(jsonEncode(verdict('unclear')))
          : draft('Thanks for coming.'))));
      expect(
          await unclear.write(
              report: report(), kind: DraftKind.appreciate, language: 'English'),
          'Thanks for coming.');
    });

    test('a check that keeps saying it is wrong ends in an error, not a draft',
        () async {
      final c = client(() => draft('I love how you notice what I need.'),
          doneBy: () => 'user');
      await expectLater(
          c.write(report: report(), kind: DraftKind.appreciate, language: 'English'),
          throwsA(isA<ZaiException>()));
      expect(sent, hasLength(3));
      expect(checks, hasLength(3));
    });

    test('a check that cannot connect is asked again without rewriting',
        () async {
      var writes = 0;
      var asks = 0;
      final c = DraftClient(ZaiClient(MockClient((req) async {
        if (!isCheck(req)) {
          writes++;
          return draft('Thanks for coming.');
        }
        return ++asks == 1
            ? http.Response('{"error":{"code":"1302"}}', 429)
            : answer(jsonEncode(verdict('other')));
      })), const [Duration(seconds: 1), Duration(seconds: 1)]);
      final seen = <String>[];
      final text = await c.write(
          report: report(),
          kind: DraftKind.appreciate,
          language: 'English',
          onText: seen.add);
      expect(text, 'Thanks for coming.');
      expect(writes, 1);
      expect(asks, 2);
      // 已经显示出来的字不清掉
      expect(seen, isNot(contains('')));
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('an unclear safety answer counts as a concern', () async {
      final r = await client(() => answer(jsonEncode({'message': 'hi there'})))
          .write(report: report(), kind: DraftKind.appreciate, language: 'English');
      expect(r, isNull);
    });

    test('a refusal becomes null and never reaches the screen', () async {
      final seen = <String>[];
      final text = await client(() => draft('', concern: true)).write(
          report: report(),
          kind: DraftKind.appreciate,
          language: 'English',
          onText: seen.add);
      expect(text, isNull);
      expect(seen, isEmpty);
    });

    test('wrapping quotes are removed and rewrites see the old draft', () async {
      final c = client(() => draft('"Thanks for booking the trip."'));
      final text = await c.write(
          report: report(),
          kind: DraftKind.appreciate,
          language: 'English',
          previous: 'an older draft');
      expect(text, 'Thanks for booking the trip.');
      expect(user(), contains('"an older draft"'));
      expect(user(), contains('Never reuse a sentence'));
      // 换一条一开始不调随机度：调高了模型会编细节
      expect(sent.last.containsKey('temperature'), isFalse);
      await c.write(
          report: report(), kind: DraftKind.appreciate, language: 'English');
      expect(user(), 'Write the message.');
      expect(sent.last.containsKey('temperature'), isFalse);
    });

    test('a rewrite that repeats the old draft is written again', () async {
      const old = 'Thanks for bringing me lunch, you always know what I need.';
      var calls = 0;
      final c = client(() => draft(switch (++calls) {
            1 => 'Thanks for bringing me lunch, you really know what I need.',
            2 => 'Picking me up in the rain last week meant a lot to me.',
            _ => 'You stayed up to rehearse my interview with me. So kind.',
          }));
      final text = await c.write(
          report: report(),
          kind: DraftKind.appreciate,
          language: 'English',
          previous: old);
      expect(calls, 2);
      expect(text, 'Picking me up in the rain last week meant a lot to me.');
      // 写得和上一版太像，重写时才调高随机度
      expect(sent.first.containsKey('temperature'), isFalse);
      expect(sent.last['temperature'], .9);

      // 下一次换一条，会告诉模型前面写过哪件事
      await c.write(
          report: report(),
          kind: DraftKind.appreciate,
          language: 'English',
          previous: text);
      expect(user(), contains('Earlier drafts were about: ["the trip"]'));
    });

    test('a rewrite that never changes fails instead of showing the same text',
        () async {
      const old = '记得你上次提醒我别吃泡面，还给我带饭，真的很贴心。';
      final c = client(() => draft(old));
      await expectLater(
          c.write(
              report: report(),
              kind: DraftKind.appreciate,
              language: 'Simplified Chinese',
              previous: old),
          throwsA(isA<ZaiException>()));
      expect(sent, hasLength(3));
    });

    test('similar drafts are told apart from different ones', () {
      const a = 'I feel frustrated when calls get missed without notice, '
          'and I would like us to set up a quick text system.';
      expect(
          DraftClient.similarity(a, a.replaceFirst('frustrated', 'worried')),
          greaterThan(.8));
      expect(
          DraftClient.similarity(
              a, 'Could we pick one evening a week that is just for us?'),
          lessThan(.2));
      const zh = '记得你上次提醒我别吃泡面，还给我带饭，真的很贴心。';
      expect(DraftClient.similarity(zh, zh), 1);
      expect(DraftClient.similarity(zh, zh.replaceFirst('贴心', '暖心')),
          greaterThan(.8));
      expect(DraftClient.similarity(zh, '那天下大雨你跑来地铁口接我，我一直记着。'),
          lessThan(.3));
    });

    test('an apology is not accepted as a request', () async {
      Future<String?> ask(List<Map<String, dynamic>> replies) {
        var i = 0;
        return client(() => answer(jsonEncode(replies[i++]))).write(
            report: report(unlocked: true),
            kind: DraftKind.ask,
            language: 'English');
      }

      Map<String, dynamic> reply(String message, {bool apologises = false}) => {
            'concern': false,
            'event': 'late replies',
            'asks_other_to': 'be patient',
            'message': message,
            'apologises': apologises,
          };

      // 模型自己说是道歉
      expect(
          await ask([
            reply('I will reply sooner from now on.', apologises: true),
            reply('Could you bear with me on busy days?'),
          ]),
          'Could you bear with me on busy days?');
      expect(sent, hasLength(2));
      // 重来时告诉模型上一次错在哪
      expect((sent.first['messages'] as List).last['content'],
          'Write the message.');
      expect(user(), contains('Your last attempt could not be used: it apologised'));
      // 模型没承认，但话里在道歉
      expect(
          await ask([
            reply('我感到抱歉关于之前迟到的事情，我以后会提前告知你。'),
            reply('忙的时候我先回一句在忙，你能先别多想吗？'),
          ]),
          '忙的时候我先回一句在忙，你能先别多想吗？');
      expect(sent, hasLength(2));
    });

    test('repair that owns the other person\'s behaviour is written again',
        () async {
      var calls = 0;
      final c = client(() => answer(jsonEncode({
            'concern': false,
            'event': 'missed calls',
            'user_did': 'spoke sharply',
            'other_did': 'missed calls without notice',
            'message': ++calls == 1
                ? 'I will let you know when plans change.'
                : 'I snapped at you about the calls, and I want to do that better.',
            'owns': calls == 1 ? 'other' : 'user',
          })));
      final text = await c.write(
          report: report(unlocked: true),
          kind: DraftKind.repair,
          language: 'English');
      expect(calls, 2);
      expect(text, startsWith('I snapped at you'));
    });

    test('a draft that copies what the user already sent is written again',
        () async {
      final s = buildSampleReport();
      final r = RelationshipReport(
        metrics: s.metrics,
        warmth: s.warmth,
        warmthReason: s.warmthReason,
        emotionCurve: s.emotionCurve,
        topics: s.topics,
        personalityYou: s.personalityYou,
        personalityPartner: s.personalityPartner,
        deepReading: s.deepReading,
        milestones: [
          Milestone('2026-02', 'Sorry', '昨晚那句话我说重了，对不起', saidBy: 'you'),
          Milestone('2026-03', 'Night', '晚安', saidBy: 'you'),
          Milestone('2026-01', 'Rain', '别等了，我去地铁口接你', saidBy: 'partner'),
        ],
        advice: s.advice,
      );
      var calls = 0;
      final c = client(() => draft(switch (++calls) {
            1 => '昨晚那句话我说重了，对不起。以后我一定先发消息。',
            _ => '那天下大雨你跑来接我，我一直记着。晚安。',
          }));
      final text = await c.write(
          report: r, kind: DraftKind.appreciate, language: 'Simplified Chinese');
      expect(calls, 2);
      // 很短的原话（晚安）撞上不算照抄
      expect(text, startsWith('那天下大雨你跑来接我'));
      expect(user(), contains('it copied a message the user already sent'));
    });

    test('appreciation built on the user\'s own line is written again',
        () async {
      final s = buildSampleReport();
      final r = RelationshipReport(
        metrics: s.metrics,
        warmth: s.warmth,
        warmthReason: s.warmthReason,
        emotionCurve: s.emotionCurve,
        topics: s.topics,
        personalityYou: s.personalityYou,
        personalityPartner: s.personalityPartner,
        deepReading: s.deepReading,
        milestones: [
          Milestone('2026-03', 'Memory',
              'I remember everything you tell me, even the boring parts',
              saidBy: 'you'),
          Milestone('2026-01', 'No rush', 'Let\'s talk about it this weekend, no rush',
              saidBy: 'partner'),
        ],
        advice: s.advice,
      );
      var calls = 0;
      final c = client(() => answer(jsonEncode({
            'concern': false,
            'event': 'remembering details',
            // 模型自己说是对方做的，但这句话在聊天里是用户说的
            'based_on': ++calls == 1
                ? 'I remember everything you tell me, even the boring parts.'
                : 'Let\'s talk about it this weekend, no rush',
            'done_by': 'other',
            'message': calls == 1
                ? 'I love how you remember the little things I tell you.'
                : 'Thank you for never rushing me on the big talks.',
          })));
      final text = await c.write(
          report: r, kind: DraftKind.appreciate, language: 'English');
      expect(calls, 2);
      expect(text, 'Thank you for never rushing me on the big talks.');
      expect(system(), contains('never thank '));
      expect(system(),
          contains('wrote: ["Let\'s talk about it this weekend, no rush"]'));
    });

    test('details the report does not give are written out again', () async {
      Map<String, dynamic> reply(String message, String added) => {
            'concern': false,
            'event': 'the rain',
            'done_by': 'other',
            'message': message,
            'added': added,
          };
      var calls = 0;
      final c = client(() => answer(jsonEncode(switch (++calls) {
            1 => reply('You got soaked coming to get me.', 'that they got soaked'),
            _ => reply('You came to get me in the rain.', 'None.'),
          })));
      final text = await c.write(
          report: report(), kind: DraftKind.appreciate, language: 'English');
      expect(calls, 2);
      expect(text, 'You came to get me in the rain.');
      expect(user(), contains('it added something the report does not say'));
      expect(user(), contains('that they got soaked'));
      expect(system(), contains('Use only what the report states'));

      // 模型这项自查不准，三次都说加了东西时，最后一版照常给用户，不报错
      final stubborn = client(() => answer(
          jsonEncode(reply('You came to get me in the rain.', 'the rain'))));
      expect(
          await stubborn.write(
              report: report(), kind: DraftKind.appreciate, language: 'English'),
          'You came to get me in the rain.');
      expect(sent, hasLength(3));
    });

    test('their own line said back to them is caught, a retelling is not', () {
      // 对方夸用户先回了消息；原样搬回去就成了夸对方先回消息，做事的人反了
      const praise = ['你今天有先回我，我很开心'];
      expect(DraftClient.echoes('你今天主动回我消息，让我很开心。你总是这样在意我。', praise),
          isTrue);
      expect(
          DraftClient.echoes(
              '你上次说看到我及时回复消息很开心，其实我也特别喜欢你这样直接表达感受。', praise),
          isFalse);
      // 用自己的话讲对方做过的事，不算
      expect(
          DraftClient.echoes('谢谢你记得提醒我不要随便吃泡面，还主动说要给我带饭，真的很贴心。',
              ['那我中午给你带饭，你别又随便吃泡面']),
          isFalse);
      expect(
          DraftClient.echoes(
              'I really appreciate how you respected my need to postpone that talk.',
              ['Let\'s talk about it this weekend, no rush']),
          isFalse);
      expect(
          DraftClient.echoes(
              'You replied first today and that made me so happy, thank you.',
              ['You replied first today, that made me happy']),
          isTrue);
      // 很短的话不判
      expect(DraftClient.echoes('晚安，明天见', ['晚安']), isFalse);
    });

    test('a draft that says their line back is written again', () async {
      final s = buildSampleReport();
      final r = RelationshipReport(
        metrics: s.metrics,
        warmth: s.warmth,
        warmthReason: s.warmthReason,
        emotionCurve: s.emotionCurve,
        topics: s.topics,
        personalityYou: s.personalityYou,
        personalityPartner: s.personalityPartner,
        deepReading: s.deepReading,
        milestones: [
          Milestone('2026-03', 'Reply', '你今天有先回我，我很开心', saidBy: 'partner'),
        ],
        advice: s.advice,
      );
      var calls = 0;
      final c = client(() => draft(switch (++calls) {
            1 => '你今天主动回我消息，让我很开心。',
            _ => '你说我先回消息你很开心，谢谢你愿意直接告诉我。',
          }));
      final text = await c.write(
          report: r, kind: DraftKind.appreciate, language: 'Simplified Chinese');
      expect(calls, 2);
      expect(text, startsWith('你说我先回消息'));
      expect(user(), contains('which swaps who did what'));
    });

    test('an empty message is a bad answer, not a refusal', () async {
      var calls = 0;
      final c = client(() => draft(++calls == 1 ? '' : 'Thanks for coming.'));
      final text = await c.write(
          report: report(), kind: DraftKind.appreciate, language: 'English');
      expect(calls, 2);
      expect(text, 'Thanks for coming.');
    });

    test('service errors surface', () async {
      expect(
          () => client(() => http.Response('nope', 500)).write(
              report: report(),
              kind: DraftKind.appreciate,
              language: 'English'),
          throwsA(isA<ZaiException>()));
    });
  });

  test('drafts survive saving, and unknown ones are skipped', () {
    final r = report()
      ..drafts.add(const MessageDraft(kind: DraftKind.ask, text: 'could we'));
    final json = jsonDecode(jsonEncode(r.toJson())) as Map<String, dynamic>;
    (json['drafts'] as List).add({'kind': 'poem', 'text': 'roses'});
    final loaded = RelationshipReport.fromJson(json);
    expect(loaded.drafts.single.kind, DraftKind.ask);
    expect(loaded.drafts.single.text, 'could we');

    // 没有草稿字段的旧报告照常能读
    json.remove('drafts');
    expect(RelationshipReport.fromJson(json).drafts, isEmpty);
  });

  group('drafts screen', () {
    late NoSaveStore store;
    late int requests;

    setUp(() {
      store = NoSaveStore();
      requests = 0;
    });

    DraftClient client(http.Response Function() respond) =>
        DraftClient(ZaiClient(MockClient((req) async {
          requests++;
          return respond();
        })));

    Future<void> show(WidgetTester tester, RelationshipReport r, DraftClient c,
        {Locale locale = const Locale('en'),
        Size size = const Size(390, 1400)}) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        key: ValueKey(locale),
        locale: locale,
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        home: DraftsScreen(report: r, client: c, store: store),
      ));
      await tester.pumpAndSettle();
    }

    // 结束流式响应要经过真实的事件循环，假时钟下只等帧走不完
    Future<void> settle(WidgetTester tester) async {
      await tester.pumpAndSettle();
      // 欣赏类写完还有一次核对请求，多等几轮
      for (var i = 0; i < 4; i++) {
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 20)));
        await tester.pumpAndSettle();
      }
    }

    testWidgets('locked report: appreciation is free, the rest ask to unlock',
        (tester) async {
      final r = report();
      await show(tester, r, client(() => draft('Thanks for the trip.')));
      expect(find.text(en.draftsEntryTitle('Mia')), findsOneWidget);
      // 只有免费的那一种能写
      expect(find.text(en.draftWrite), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsNWidgets(2));
      expect(find.text(en.draftLocked), findsOneWidget);

      await tester.tap(find.text(en.draftWrite));
      await settle(tester);
      expect(find.text('Thanks for the trip.'), findsOneWidget);
      expect(r.drafts.single.kind, DraftKind.appreciate);
      expect(store.saves, 1);
      expect(find.text(en.draftSend), findsOneWidget);
      expect(find.text(en.draftAgain), findsOneWidget);

      await tester.tap(find.text(en.deepDiveBuy(r'$1.99')));
      await tester.pump();
      expect(gateway.buys, 1);
    });

    testWidgets('unlocked report: all three can be written and copied',
        (tester) async {
      final r = report(unlocked: true);
      await show(tester, r, client(() => draft('Could we talk tonight?')));
      expect(find.text(en.draftWrite), findsNWidgets(3));
      expect(find.byIcon(Icons.lock_outline), findsNothing);
      expect(find.text(en.draftLocked), findsNothing);

      await tester.tap(find.text(en.draftWrite).last);
      await settle(tester);
      expect(r.drafts.single.kind, DraftKind.ask);

      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null));
      // 用户改过的内容才是被复制的内容
      await tester.enterText(find.byType(TextField), 'my own words');
      await tester.tap(find.text(en.draftCopy));
      await tester.pumpAndSettle();
      expect(copied, 'my own words');
      expect(find.text(en.draftCopied), findsOneWidget);
    });

    testWidgets('saved drafts are shown again', (tester) async {
      final r = report(unlocked: true)
        ..drafts.add(
            const MessageDraft(kind: DraftKind.repair, text: 'About Friday.'));
      await show(tester, r, client(() => draft('x')));
      expect(find.text('About Friday.'), findsOneWidget);
      expect(requests, 0);
    });

    testWidgets('an ex gets a note instead of drafts', (tester) async {
      await show(tester, report(unlocked: true, relationship: 'ex'),
          client(() => draft('x')));
      expect(find.text(en.draftExNote), findsOneWidget);
      expect(find.text(en.draftWrite), findsNothing);
      expect(find.text(en.draftLocked), findsNothing);
    });

    testWidgets('a refusal shows where to get help, not a draft',
        (tester) async {
      final r = report();
      await show(tester, r, client(() => draft('', concern: true)));
      await tester.tap(find.text(en.draftWrite));
      await settle(tester);
      expect(find.text(en.draftUnsafe), findsOneWidget);
      expect(find.text(en.draftWrite), findsNothing);
      expect(r.drafts, isEmpty);
      expect(store.saves, 0);
    });

    testWidgets('a failed rewrite keeps the old draft and says why',
        (tester) async {
      final r = report()
        ..drafts.add(const MessageDraft(
            kind: DraftKind.appreciate, text: 'the old draft'));
      await show(tester, r, client(() => http.Response('nope', 500)));
      await tester.tap(find.text(en.draftAgain));
      await settle(tester);
      expect(find.text('the old draft'), findsOneWidget);
      expect(find.text(en.errorServiceUnavailable), findsOneWidget);
    });

    testWidgets('declining consent sends nothing', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await show(tester, report(), client(() => draft('x')));
      await tester.tap(find.text(en.draftWrite));
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.consentCancel));
      await tester.pumpAndSettle();
      expect(requests, 0);
    });

    testWidgets('fits narrow screens in every language', (tester) async {
      for (final locale in L.supportedLocales) {
        for (final unlocked in [false, true]) {
          final r = report(unlocked: unlocked)
            ..drafts.add(const MessageDraft(
                kind: DraftKind.appreciate, text: 'a saved draft'));
          await show(tester, r, client(() => draft('x')),
              locale: locale, size: const Size(320, 1600));
          expect(tester.takeException(), isNull,
              reason: '$locale unlocked=$unlocked');
        }
      }
    });
  });

  testWidgets('real reports offer the drafts, the sample does not',
      (tester) async {
    Purchases.paywallEnabled = false;
    tester.view.physicalSize = const Size(390, 6000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Future<void> show(bool isSample) async {
      await tester.pumpWidget(MaterialApp(
        key: ValueKey(isSample),
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        home: ReportScreen(report: buildSampleReport(), isSample: isSample),
      ));
      await tester.pumpAndSettle();
    }

    await show(false);
    expect(find.text(en.draftsEntryTitle('Mia')), findsOneWidget);
    await show(true);
    expect(find.text(en.draftsEntryTitle('Mia')), findsNothing);
  });
}
