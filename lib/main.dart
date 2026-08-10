import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'theme.dart';

void main() => runApp(const ChatReportApp());

class ChatReportApp extends StatelessWidget {
  const ChatReportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => L.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      localizationsDelegates: L.localizationsDelegates,
      supportedLocales: L.supportedLocales,
      home: const HomeScreen(),
    );
  }
}
