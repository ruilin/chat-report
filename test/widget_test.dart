import 'package:flutter_test/flutter_test.dart';
import 'package:chat_report/main.dart';

void main() {
  testWidgets('home screen renders both entry points', (tester) async {
    await tester.pumpWidget(const ChatReportApp());
    expect(find.text('Chat Report'), findsOneWidget);
    expect(find.text('Import a chat export'), findsOneWidget);
    expect(find.text('Paste a conversation'), findsOneWidget);
  });
}
