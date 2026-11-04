/// 付费专题分析：争吵与和好、红旗绿旗、依恋风格、关系转折。
/// 全部来自 LLM；带原话的条目已和聊天记录逐字核对过（见 QuoteVerifier）。
class DeepDive {
  final String conflictSummary;
  final List<EvidenceItem> conflicts;
  final List<EvidenceItem> redFlags;
  final List<EvidenceItem> greenFlags;
  final AttachmentRead? attachmentYou;
  final AttachmentRead? attachmentPartner;
  final String attachmentLoop;
  final List<TurningPoint> turningPoints;

  const DeepDive({
    this.conflictSummary = '',
    this.conflicts = const [],
    this.redFlags = const [],
    this.greenFlags = const [],
    this.attachmentYou,
    this.attachmentPartner,
    this.attachmentLoop = '',
    this.turningPoints = const [],
  });

  /// 没有任何可卖的内容时不展示付费入口
  bool get isEmpty =>
      conflicts.isEmpty &&
      redFlags.isEmpty &&
      greenFlags.isEmpty &&
      turningPoints.isEmpty &&
      attachmentYou == null &&
      attachmentPartner == null;

  Map<String, dynamic> toJson() => {
        'conflict_summary': conflictSummary,
        'conflicts': [for (final e in conflicts) e.toJson()],
        'red_flags': [for (final e in redFlags) e.toJson()],
        'green_flags': [for (final e in greenFlags) e.toJson()],
        'attachment_you': attachmentYou?.toJson(),
        'attachment_partner': attachmentPartner?.toJson(),
        'attachment_loop': attachmentLoop,
        'turning_points': [for (final t in turningPoints) t.toJson()],
      };

  factory DeepDive.fromJson(Map<String, dynamic> j) => DeepDive(
        conflictSummary: j['conflict_summary'] as String? ?? '',
        conflicts: _items(j['conflicts']),
        redFlags: _items(j['red_flags']),
        greenFlags: _items(j['green_flags']),
        attachmentYou: AttachmentRead.maybeFromJson(j['attachment_you']),
        attachmentPartner:
            AttachmentRead.maybeFromJson(j['attachment_partner']),
        attachmentLoop: j['attachment_loop'] as String? ?? '',
        turningPoints: [
          for (final t in (j['turning_points'] as List? ?? const []))
            TurningPoint.fromJson(t as Map<String, dynamic>),
        ],
      );

  static List<EvidenceItem> _items(dynamic v) => [
        for (final e in (v as List? ?? const []))
          EvidenceItem.fromJson(e as Map<String, dynamic>),
      ];
}

/// 一条有聊天原话作证据的判断
class EvidenceItem {
  final String date; // YYYY-MM
  final String title;
  final String detail;
  final String quote;

  const EvidenceItem({
    required this.date,
    required this.title,
    required this.detail,
    required this.quote,
  });

  Map<String, dynamic> toJson() =>
      {'date': date, 'title': title, 'detail': detail, 'quote': quote};

  factory EvidenceItem.fromJson(Map<String, dynamic> j) => EvidenceItem(
        date: j['date'] as String? ?? '',
        title: j['title'] as String? ?? '',
        detail: j['detail'] as String? ?? '',
        quote: j['quote'] as String? ?? '',
      );
}

class TurningPoint extends EvidenceItem {
  final bool rising; // true = 升温，false = 降温

  const TurningPoint({
    required super.date,
    required super.title,
    required super.detail,
    required super.quote,
    required this.rising,
  });

  @override
  Map<String, dynamic> toJson() => {...super.toJson(), 'rising': rising};

  factory TurningPoint.fromJson(Map<String, dynamic> j) => TurningPoint(
        date: j['date'] as String? ?? '',
        title: j['title'] as String? ?? '',
        detail: j['detail'] as String? ?? '',
        quote: j['quote'] as String? ?? '',
        rising: j['rising'] as bool? ?? true,
      );
}

/// 依恋倾向（不是临床诊断）
class AttachmentRead {
  final String style;
  final String detail;

  const AttachmentRead({required this.style, required this.detail});

  Map<String, dynamic> toJson() => {'style': style, 'detail': detail};

  static AttachmentRead? maybeFromJson(dynamic v) {
    if (v is! Map) return null;
    final style = v['style']?.toString().trim() ?? '';
    if (style.isEmpty) return null;
    return AttachmentRead(
        style: style, detail: v['detail']?.toString().trim() ?? '');
  }
}
