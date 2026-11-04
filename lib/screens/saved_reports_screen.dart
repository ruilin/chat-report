import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/report.dart';
import '../services/analytics.dart';
import '../services/report_store.dart';
import '../theme.dart';
import 'report_screen.dart';

/// 已保存的报告。只存在本机，用户可以随时删除。
class SavedReportsScreen extends StatefulWidget {
  const SavedReportsScreen({super.key});

  @override
  State<SavedReportsScreen> createState() => _SavedReportsScreenState();
}

class _SavedReportsScreenState extends State<SavedReportsScreen> {
  final _store = ReportStore();
  List<RelationshipReport>? _reports;

  @override
  void initState() {
    super.initState();
    Analytics.savedReportsOpen();
    _load();
  }

  Future<void> _load() async {
    List<RelationshipReport> reports;
    try {
      reports = await _store.list();
    } catch (e) {
      // ignore: avoid_print
      print('[saved] list failed: $e');
      reports = [];
    }
    if (mounted) setState(() => _reports = reports);
  }

  Future<void> _open(RelationshipReport report) async {
    await Navigator.of(context).push(MaterialPageRoute(
        settings: const RouteSettings(name: 'report_saved'),
        builder: (_) => ReportScreen(report: report)));
    // 可能在报告页解锁过
    await _load();
  }

  Future<void> _delete(RelationshipReport report) async {
    final l = L.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.savedDeleteTitle),
        content: Text(l.savedDeleteBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.savedDeleteCancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.savedDeleteConfirm)),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _store.delete(report.id);
      Analytics.savedReportDelete();
    } catch (e) {
      // ignore: avoid_print
      print('[saved] delete failed: $e');
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final reports = _reports;
    return Scaffold(
      appBar: AppBar(title: Text(l.savedTitle)),
      body: reports == null
          ? const Center(
              child: CircularProgressIndicator(color: UColors.rose))
          : ListView(
              padding: EdgeInsets.fromLTRB(
                  20, 8, 20, 32 + MediaQuery.paddingOf(context).bottom),
              children: [
                PrivacyNote(l.savedNote),
                const SizedBox(height: 14),
                if (reports.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(l.savedEmpty,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: UColors.muted)),
                  ),
                for (final r in reports)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ReportTile(
                      report: r,
                      onTap: () => _open(r),
                      onDelete: () => _delete(r),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  final RelationshipReport report;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ReportTile(
      {required this.report, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final m = report.metrics;
    final locale = Localizations.localeOf(context);
    final tag = locale.toString();
    final date = DateFormat.yMMMd(
            DateFormat.localeExists(tag) ? tag : locale.languageCode)
        .format(report.createdAt);

    return UCard(
      padding: EdgeInsets.zero,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 4, 10),
            child: Row(
              children: [
                UAvatar(m.partner, isYou: false, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.reportYouAnd(m.partner),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700)),
                      Text('$date · ${l.reportMessages(m.totalMessages)}',
                          style: const TextStyle(
                              fontSize: 11.5, color: UColors.muted)),
                      if (report.deepDiveUnlocked)
                        Text(l.savedUnlockedBadge,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: UColors.gold)),
                    ],
                  ),
                ),
                Text('${report.warmth}°',
                    style: UType.num.copyWith(fontSize: 18)),
                IconButton(
                  tooltip: l.savedDeleteConfirm,
                  icon: const Icon(Icons.delete_outline,
                      size: 20, color: UColors.muted),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
