import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../services/analytics.dart';
import '../theme.dart';

/// 换 AI 服务商或改变发送范围时递增版本号，让所有用户重新确认
const _consentKey = 'ai_consent_v1';

/// 首次分析前的 AI 处理知情同意：说清楚哪些内容会发给谁。
/// 同意后记住，之后不再弹；拒绝则本次不分析。
Future<bool> ensureAiConsent(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool(_consentKey) ?? false) return true;
  if (!context.mounted) return false;

  final l = L.of(context);
  final agreed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: UColors.screen,
          title: Text(l.consentTitle,
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Text(l.consentBody,
                style: const TextStyle(
                    fontSize: 13.5, height: 1.5, color: UColors.ink2)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.consentCancel,
                  style: const TextStyle(color: UColors.muted)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: UColors.rose,
                shape: const StadiumBorder(),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.consentAgree),
            ),
          ],
        ),
      ) ??
      false;

  Analytics.aiConsent(agreed ? 'accepted' : 'declined');
  if (agreed) await prefs.setBool(_consentKey, true);
  return agreed;
}
