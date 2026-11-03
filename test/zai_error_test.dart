import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:chat_report/l10n/app_localizations.dart';
import 'package:chat_report/models/chat_data.dart';
import 'package:chat_report/services/analysis_pipeline.dart';
import 'package:chat_report/services/metrics_engine.dart';
import 'package:chat_report/services/zai_client.dart';

void main() {
  late L en;
  setUpAll(() async => en = await L.delegate.load(const Locale('en')));

  Future<ZaiException> failWith(http.Client client) async {
    try {
      await ZaiClient(client).complete(model: 'm', system: 's', user: 'u');
    } on ZaiException catch (e) {
      return e;
    }
    fail('expected ZaiException');
  }

  test('401 is a service problem, not a network one', () async {
    final e = await failWith(MockClient((_) async => http.Response(
        '{"error":{"code":"401","message":"token expired or incorrect"}}',
        401)));
    expect(e.kind, ZaiErrorKind.http);
    expect(e.statusCode, 401);
    expect(e.localize(en), en.errorServiceUnavailable);
    expect(e.localize(en), isNot(en.errorNoConnection));
  });

  test('429 maps to rate limited', () async {
    final e = await failWith(MockClient((_) async => http.Response('', 429)));
    expect(e.kind, ZaiErrorKind.rateLimited);
    expect(e.localize(en), en.errorRateLimited);
  });

  test('unreachable endpoints map to no connection', () async {
    final e = await failWith(
        MockClient((_) async => throw http.ClientException('offline')));
    expect(e.kind, ZaiErrorKind.noConnection);
    expect(e.localize(en), en.errorNoConnection);
  });

  test('pipeline keeps the last error kind and status code', () async {
    final data = ChatData(
      messages: [
        for (var i = 0; i < 12; i++)
          ChatMessage(
              time: DateTime(2024, 3, 1, 21, i),
              sender: i.isEven ? 'Sam' : 'Mia',
              text: 'hello $i'),
      ],
      participants: ['Sam', 'Mia'],
    );
    final pipeline = AnalysisPipeline(
        ZaiClient(MockClient((_) async => http.Response('nope', 401))));
    try {
      await pipeline.run(
        data: data,
        metrics: MetricsEngine().compute(data, you: 'Sam'),
        relationship: Relationship.friend,
      );
      fail('expected ZaiException');
    } on ZaiException catch (e) {
      expect(e.kind, ZaiErrorKind.http);
      expect(e.statusCode, 401);
    }
  });
}
