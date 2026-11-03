import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

/// Firebase Analytics 埋点入口。
///
/// 隐私边界：只上报用户行为、计数和枚举值；聊天文本、参与者名字、
/// 报告正文一律不上报（与首页「聊天内容从不留存」的承诺一致）。
///
/// 未配置 Firebase 的平台（目前 iOS 缺 GoogleService-Info.plist）
/// 初始化会失败，此时所有方法静默降级为 no-op，不影响主流程。
class Analytics {
  Analytics._();

  static FirebaseAnalytics? _fa;

  static Future<void> init() async {
    try {
      await Firebase.initializeApp();
      _fa = FirebaseAnalytics.instance;
    } catch (e) {
      debugPrint('[analytics] disabled: $e');
    }
  }

  /// 按 RouteSettings.name 自动上报 screen_view
  static List<NavigatorObserver> get observers =>
      [if (_fa case final fa?) FirebaseAnalyticsObserver(analytics: fa)];

  static void _log(String name, [Map<String, Object>? params]) {
    final fa = _fa;
    if (fa == null) return;
    // 埋点失败不能打断用户操作
    fa.logEvent(name: name, parameters: params).catchError(
        (Object e) => debugPrint('[analytics] $name failed: $e'));
  }

  // —— 导入 ——

  static void importGuideOpen() => _log('import_guide_open');

  /// [result]: app / web / failed
  static void whatsappOpen(String result) =>
      _log('whatsapp_open', {'result': result});

  /// [result]: picked / cancelled
  static void importFilePick(String result) =>
      _log('import_file_pick', {'result': result});

  static void pasteSheetOpen() => _log('paste_sheet_open');

  /// [source]: file / paste
  static void chatParseSuccess({
    required String source,
    required int messageCount,
    required int participantCount,
    required int daySpan,
  }) =>
      _log('chat_parse_success', {
        'source': source,
        'message_count': messageCount,
        'participant_count': participantCount,
        'day_span': daySpan,
      });

  /// [reason]: ParseErrorKind.name
  static void chatParseFail({required String source, required String reason}) =>
      _log('chat_parse_fail', {'source': source, 'reason': reason});

  // —— 分析 ——

  /// 首次分析前的 AI 处理同意弹窗，[result]: accepted / declined
  static void aiConsent(String result) =>
      _log('ai_consent', {'result': result});

  static void analysisStart({
    required String relationship,
    required int messageCount,
  }) =>
      _log('analysis_start', {
        'relationship': relationship,
        'message_count': messageCount,
      });

  static void analysisSuccess({
    required String relationship,
    required int messageCount,
    required int durationSec,
  }) =>
      _log('analysis_success', {
        'relationship': relationship,
        'message_count': messageCount,
        'duration_sec': durationSec,
      });

  /// [errorKind]: ZaiErrorKind.name，非接口错误为 other。
  /// [statusCode]: 接口 HTTP 状态码，没有则记 0；401 突增通常意味着 key 失效或被盗用
  static void analysisFail({
    required String relationship,
    required String errorKind,
    required int durationSec,
    int? statusCode,
  }) =>
      _log('analysis_fail', {
        'relationship': relationship,
        'error_kind': errorKind,
        'duration_sec': durationSec,
        'status_code': statusCode ?? 0,
      });

  /// 分析未结束用户就离开了分析页
  static void analysisCancel({
    required String relationship,
    required int elapsedSec,
  }) =>
      _log('analysis_cancel', {
        'relationship': relationship,
        'elapsed_sec': elapsedSec,
      });

  // —— 分享 ——

  static void shareSheetOpen() => _log('share_sheet_open');

  /// [status]: success / dismissed / unavailable / error
  static void shareResult(String status) =>
      _log('share_result', {'status': status});
}
