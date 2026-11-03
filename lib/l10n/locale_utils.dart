import 'package:flutter/widgets.dart';

/// 把当前界面语言映射成喂给 LLM 的语言名，让报告正文与 UI 语言一致。
String promptLanguageOf(BuildContext context) {
  final locale = Localizations.localeOf(context);
  if (locale.languageCode == 'zh') {
    final isTraditional = locale.scriptCode == 'Hant' ||
        const {'TW', 'HK', 'MO'}.contains(locale.countryCode);
    return isTraditional ? 'Traditional Chinese' : 'Simplified Chinese';
  }
  return _promptLanguages[locale.languageCode] ?? 'English';
}

/// 与 lib/l10n/app_*.arb 一一对应；新增语言时两边一起加
const _promptLanguages = {
  'en': 'English',
  'es': 'Spanish',
  'pt': 'Brazilian Portuguese',
  'fr': 'French',
  'de': 'German',
  'it': 'Italian',
  'tr': 'Turkish',
  'ar': 'Arabic',
  'hi': 'Hindi',
  'id': 'Indonesian',
};
