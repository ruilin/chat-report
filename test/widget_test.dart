import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chat_report/l10n/app_localizations.dart';
import 'package:chat_report/main.dart';
import 'package:chat_report/models/chat_data.dart';
import 'package:chat_report/screens/setup_screen.dart';

void main() {
  testWidgets('home screen renders both entry points', (tester) async {
    await tester.pumpWidget(const ChatReportApp());
    expect(find.text('Chat Report'), findsOneWidget);
    expect(find.text('Import a chat export'), findsOneWidget);
    expect(find.text('Paste a conversation'), findsOneWidget);
  });

  testWidgets('setup date range follows UI locale', (tester) async {
    final data = ChatData(
      messages: [
        ChatMessage(time: DateTime(2024, 3, 2), sender: 'Sam', text: 'hi'),
        ChatMessage(time: DateTime(2024, 7, 9), sender: 'Mia', text: 'yo'),
      ],
      participants: ['Sam', 'Mia'],
    );

    Future<String> rangeFor(Locale locale) async {
      await tester.pumpWidget(MaterialApp(
        locale: locale,
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        home: SetupScreen(data: data),
      ));
      await tester.pumpAndSettle();
      // 「{count} messages · {range}」整行
      final line = find.textContaining(' – ').evaluate().single.widget as Text;
      return line.data!;
    }

    expect(await rangeFor(const Locale('en')), contains('Mar 2024 – Jul 2024'));
    expect(await rangeFor(const Locale('de')), contains('März'));
    expect(await rangeFor(const Locale('es')), contains('mar'));
    // intl 无 zh_Hant 专属数据时回退 zh，不能崩
    expect(
        await rangeFor(const Locale.fromSubtags(
            languageCode: 'zh', scriptCode: 'Hant')),
        contains('2024'));
  });
}
