import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'services/analytics.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Analytics.init();
  runApp(const ChatReportApp());
}

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
      navigatorObservers: Analytics.observers,
      home: const HomeScreen(),
    );
  }
}
