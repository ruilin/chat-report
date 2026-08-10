import 'package:flutter/widgets.dart';

/// 把当前界面语言映射成喂给 LLM 的语言名，让报告正文与 UI 语言一致。
String promptLanguageOf(BuildContext context) {
  final locale = Localizations.localeOf(context);
  if (locale.languageCode != 'zh') return 'English';
  final isTraditional = locale.scriptCode == 'Hant' ||
      const {'TW', 'HK', 'MO'}.contains(locale.countryCode);
  return isTraditional ? 'Traditional Chinese' : 'Simplified Chinese';
}
