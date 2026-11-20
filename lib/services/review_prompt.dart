import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'analytics.dart';

/// 在用户刚得到好处的时候，请他去 Google Play 评分。
///
/// 真正弹不弹窗由 Google 决定（它有自己的配额，也不告诉我们结果），
/// 这里只负责别问得太勤：一共最多问 [maxAsks] 次，两次之间至少隔 [minGap]。
class ReviewPrompt {
  static const maxAsks = 2;
  static const minGap = Duration(days: 30);

  /// 一份报告至少看了这么久，才算认真看过
  static Duration minReadTime = const Duration(seconds: 45);

  static const _countKey = 'review_asked_count';
  static const _lastKey = 'review_asked_at';

  /// 发起评分请求；商店不可用时返回 false。测试时替换
  static Future<bool> Function() request = _requestFromStore;

  /// [trigger] 只用于埋点：share / report_read
  static Future<void> maybeAsk(String trigger) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = prefs.getInt(_countKey) ?? 0;
      if (count >= maxAsks) return;
      final last = prefs.getInt(_lastKey);
      final now = DateTime.now();
      if (last != null &&
          now.difference(DateTime.fromMillisecondsSinceEpoch(last)) < minGap) {
        return;
      }
      if (!await request()) return;
      await prefs.setInt(_countKey, count + 1);
      await prefs.setInt(_lastKey, now.millisecondsSinceEpoch);
      Analytics.reviewPrompt(trigger);
    } catch (e) {
      // 评分只是锦上添花，出错不能影响正常使用
      // ignore: avoid_print
      print('[review] request failed: $e');
    }
  }

  static Future<bool> _requestFromStore() async {
    final review = InAppReview.instance;
    if (!await review.isAvailable()) return false;
    await review.requestReview();
    return true;
  }
}
