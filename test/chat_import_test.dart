import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:chat_report/l10n/app_localizations.dart';
import 'package:chat_report/screens/home_screen.dart';
import 'package:chat_report/screens/setup_screen.dart';
import 'package:chat_report/services/chat_import.dart';
import 'package:chat_report/services/whatsapp_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

String chatText({String partner = 'Mia'}) => [
      for (var i = 0; i < 40; i++)
        '${(i % 28 + 1).toString().padLeft(2, '0')}/03/2026, 20:${(i % 60).toString().padLeft(2, '0')}'
            ' - ${i.isEven ? 'Alex' : partner}: message number $i 你好',
    ].join('\n');

Uint8List bytesOf(String s) => Uint8List.fromList(utf8.encode(s));

Uint8List zipOf(Map<String, Uint8List> entries) {
  final archive = Archive();
  entries.forEach((name, data) => archive.add(ArchiveFile.bytes(name, data)));
  return Uint8List.fromList(ZipEncoder().encode(archive));
}

final photo = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 1, 2, 3, 4]);

void main() {
  group('finding the chat text', () {
    test('a plain .txt export', () {
      final text = ChatImport.textFromBytes(
          [('WhatsApp Chat with Mia.txt', bytesOf(chatText()))]);
      expect(text, chatText());
      expect(WhatsAppParser().parse(text!).messages, hasLength(40));
    });

    test('a zip with the chat inside, iPhone and Android names', () {
      for (final inner in ['_chat.txt', 'WhatsApp Chat with Mia.txt']) {
        final text = ChatImport.textFromBytes([
          ('WhatsApp Chat - Mia.zip', zipOf({inner: bytesOf(chatText())})),
        ]);
        expect(text, chatText(), reason: inner);
      }
    });

    test('a zip is recognised by its content, whatever it is called', () {
      final text = ChatImport.textFromBytes([
        ('export.bin', zipOf({'_chat.txt': bytesOf(chatText())})),
      ]);
      expect(text, chatText());
    });

    test('export with media: the chat is picked out of the photos', () {
      final text = ChatImport.textFromBytes([
        ('IMG-20260301-WA0001.jpg', photo),
        ('WhatsApp Chat with Mia.txt', bytesOf(chatText())),
        ('VID-20260302-WA0002.mp4', photo),
      ]);
      expect(text, chatText());

      final zipped = ChatImport.textFromBytes([
        (
          'chat.zip',
          zipOf({'IMG-0001.jpg': photo, '_chat.txt': bytesOf(chatText())})
        ),
      ]);
      expect(zipped, chatText());
    });

    test('the chat wins over other text files', () {
      final text = ChatImport.textFromBytes([
        ('notes.txt', bytesOf('x' * 100000)),
        ('WhatsApp Chat with Mia.txt', bytesOf(chatText())),
      ]);
      expect(text, chatText());
    });

    test('a single file without a .txt name is still tried as text', () {
      expect(ChatImport.textFromBytes([('document', bytesOf(chatText()))]),
          chatText());
    });

    test('nothing usable gives null instead of an error', () {
      expect(ChatImport.textFromBytes([]), isNull);
      expect(
          ChatImport.textFromBytes([('a.jpg', photo), ('b.mp4', photo)]), isNull);
      expect(ChatImport.textFromBytes([('empty.txt', bytesOf('  \n'))]), isNull);
      // 压缩包里没有文本
      expect(ChatImport.textFromBytes([('m.zip', zipOf({'a.jpg': photo}))]),
          isNull);
      // 被截断的压缩包
      final whole = zipOf({'_chat.txt': bytesOf(chatText())});
      expect(
          ChatImport.textFromBytes(
              [('cut.zip', Uint8List.sublistView(whole, 0, whole.length ~/ 2))]),
          isNull);
    });

    test('byte order mark and broken bytes do not break reading', () {
      final withBom =
          Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode(chatText())]);
      expect(ChatImport.decode(withBom), chatText());

      final broken = Uint8List.fromList([...utf8.encode(chatText()), 0xFF, 0xFE]);
      final text = ChatImport.decode(broken);
      expect(text, startsWith(chatText()));
      expect(WhatsAppParser().parse(text).messages, hasLength(40));
    });

    test('files on disk: reads the chat and skips unreadable ones', () async {
      final dir = await Directory.systemTemp.createTemp('import');
      addTearDown(() => dir.delete(recursive: true));
      final chat = File('${dir.path}/1.bin')..writeAsBytesSync(bytesOf(chatText()));
      final text = await ChatImport.textFrom([
        ImportFile(name: 'gone.txt', path: '${dir.path}/missing.bin'),
        ImportFile(name: 'WhatsApp Chat with Mia.txt', path: chat.path),
      ]);
      expect(text, chatText());
    });
  });

  group('sharing a chat into the app', () {
    const channel = MethodChannel('com.ruilin.chatreport/share');
    late L en;
    late int takes;

    void share(Map<String, Object?>? payload) {
      takes = 0;
      var pending = payload;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'take');
        takes++;
        final out = pending;
        pending = null;
        return out;
      });
    }

    setUp(() async => en = await L.delegate.load(const Locale('en')));
    tearDown(() => TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null));

    Future<void> open(WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        home: HomeScreen(),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('a shared chat goes straight to setup', (tester) async {
      share({'files': <Object?>[], 'text': chatText(), 'count': 1});
      await open(tester);
      expect(find.byType(SetupScreen), findsOneWidget);
      expect(takes, 1);
    });

    testWidgets('a share with no chat says how to export', (tester) async {
      share({'files': <Object?>[], 'text': null, 'count': 3});
      await open(tester);
      expect(find.byType(SetupScreen), findsNothing);
      expect(find.text(en.shareImportNoChat), findsOneWidget);
    });

    testWidgets('normal launch: nothing is imported', (tester) async {
      share(null);
      await open(tester);
      expect(find.byType(SetupScreen), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('a share that arrives while the app is open is picked up',
        (tester) async {
      share(null);
      await open(tester);
      expect(find.byType(SetupScreen), findsNothing);

      share({'files': <Object?>[], 'text': chatText(), 'count': 1});
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          channel.name,
          const StandardMethodCodec().encodeMethodCall(const MethodCall('arrived')),
          (_) {});
      await tester.pumpAndSettle();
      expect(find.byType(SetupScreen), findsOneWidget);
    });
  });
}
