import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/report.dart';

/// 报告只存在本机：每份一个 JSON 文件，卸载应用即删除。
class ReportStore {
  final Future<Directory> Function() _dirOf;

  ReportStore({Future<Directory> Function()? dir})
      : _dirOf = dir ?? _defaultDir;

  static Future<Directory> _defaultDir() async {
    final docs = await getApplicationDocumentsDirectory();
    return Directory('${docs.path}/reports');
  }

  Future<File> _fileOf(String id) async {
    // id 由本机时间戳生成，这里只防文件被改过后的路径穿越
    if (!RegExp(r'^\d+$').hasMatch(id)) {
      throw ArgumentError.value(id, 'id');
    }
    return File('${(await _dirOf()).path}/$id.json');
  }

  /// 先写临时文件再改名，写到一半被杀进程也不会损坏已有报告
  Future<void> save(RelationshipReport report) async {
    final file = await _fileOf(report.id);
    await file.parent.create(recursive: true);
    // 临时文件名不重复：同一份报告同时保存时，不会互相改走对方的文件
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final tmp = File('${file.path}.$stamp.tmp');
    await tmp.writeAsString(jsonEncode(report.toJson()), flush: true);
    await tmp.rename(file.path);
  }

  /// 新的在前；读不了的文件跳过，不影响其他报告
  Future<List<RelationshipReport>> list() async {
    final dir = await _dirOf();
    if (!await dir.exists()) return [];
    final reports = <RelationshipReport>[];
    await for (final entity in dir.list()) {
      if (entity is! File || !entity.path.endsWith('.json')) continue;
      final report = await _read(entity);
      if (report != null) reports.add(report);
    }
    reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return reports;
  }

  Future<int> count() async {
    final dir = await _dirOf();
    if (!await dir.exists()) return 0;
    return dir
        .list()
        .where((e) => e is File && e.path.endsWith('.json'))
        .length;
  }

  Future<void> delete(String id) async {
    final file = await _fileOf(id);
    if (await file.exists()) await file.delete();
  }

  /// 报告不存在时返回 false，由调用方决定如何补偿
  Future<bool> markUnlocked(String id) async {
    final file = await _fileOf(id);
    if (!await file.exists()) return false;
    final report = await _read(file);
    if (report == null) return false;
    report.deepDiveUnlocked = true;
    await save(report);
    return true;
  }

  Future<RelationshipReport?> _read(File file) async {
    try {
      final json = jsonDecode(await file.readAsString());
      return RelationshipReport.fromJson(json as Map<String, dynamic>);
    } catch (e) {
      // ignore: avoid_print
      print('[store] skip unreadable report: $e');
      return null;
    }
  }
}
