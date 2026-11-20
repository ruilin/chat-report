import '../models/deep_dive.dart';
import '../models/report.dart';
import 'report_store.dart';

/// 专题分析在免费报告之后生成，用户不用等它就能先看报告。
/// 这里按报告 id 记住进行中的任务，以及失败后再来一次的办法。
///
/// 重试要用到聊天原文，而原文只留在内存里，所以 App 重启后就不能重试了。
class DeepDiveJobs {
  static final _running = <String, Future<DeepDive?>>{};
  static final _generators = <String, Future<DeepDive?> Function()>{};

  /// 生成好之后写回已保存的报告；测试时替换
  static ReportStore store = ReportStore();

  /// 正在生成时返回这次任务，否则为 null
  static Future<DeepDive?>? running(String id) => _running[id];

  /// 上次没生成出来，而且还留着重试需要的数据
  static bool canRetry(String id) =>
      _generators.containsKey(id) && !_running.containsKey(id);

  /// 开始生成。[generate] 自己处理异常，失败时返回 null
  static Future<DeepDive?> start(
      RelationshipReport report, Future<DeepDive?> Function() generate) {
    _generators[report.id] = generate;
    return _run(report);
  }

  static Future<DeepDive?>? retry(RelationshipReport report) =>
      canRetry(report.id) ? _run(report) : null;

  static Future<DeepDive?> _run(RelationshipReport report) {
    final id = report.id;
    final job = () async {
      DeepDive? dive;
      try {
        dive = await _generators[id]!();
        if (dive != null) {
          report.deepDive = dive;
          // 成功后不再需要聊天原文，放掉
          _generators.remove(id);
          await _persist(id, dive);
        }
      } finally {
        _running.remove(id);
      }
      return dive;
    }();
    _running[id] = job;
    return job;
  }

  static Future<void> _persist(String id, DeepDive dive) async {
    try {
      await store.setDeepDive(id, dive);
    } catch (e) {
      // 存不下只是下次打开看不到，这次仍然能看
      // ignore: avoid_print
      print('[deep dive] save failed: $e');
    }
  }

  /// 仅供测试：清掉所有任务
  static void reset() {
    _running.clear();
    _generators.clear();
  }
}
