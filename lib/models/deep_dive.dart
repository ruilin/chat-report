/// 付费专题分析：争吵与和好、冲突四骑士、红旗绿旗、依恋风格、爱的语言、关系转折。
/// 全部来自 LLM；带原话的条目已和聊天记录逐字核对过（见 QuoteVerifier）。
class DeepDive {
  final String conflictSummary;
  final List<EvidenceItem> conflicts;
  final List<HorsemanItem> horsemen;
  final List<EvidenceItem> redFlags;
  final List<EvidenceItem> greenFlags;
  final AttachmentRead? attachmentYou;
  final AttachmentRead? attachmentPartner;
  final String attachmentLoop;
  final LoveLanguageRead? loveYou;
  final LoveLanguageRead? lovePartner;
  final List<TurningPoint> turningPoints;

  const DeepDive({
    this.conflictSummary = '',
    this.conflicts = const [],
    this.horsemen = const [],
    this.redFlags = const [],
    this.greenFlags = const [],
    this.attachmentYou,
    this.attachmentPartner,
    this.attachmentLoop = '',
    this.loveYou,
    this.lovePartner,
    this.turningPoints = const [],
  });

  /// 没有任何可卖的内容时不展示付费入口
  bool get isEmpty =>
      conflicts.isEmpty &&
      horsemen.isEmpty &&
      redFlags.isEmpty &&
      greenFlags.isEmpty &&
      turningPoints.isEmpty &&
      attachmentYou == null &&
      attachmentPartner == null &&
      loveYou == null &&
      lovePartner == null;

  Map<String, dynamic> toJson() => {
        'conflict_summary': conflictSummary,
        'conflicts': [for (final e in conflicts) e.toJson()],
        'horsemen': [for (final e in horsemen) e.toJson()],
        'red_flags': [for (final e in redFlags) e.toJson()],
        'green_flags': [for (final e in greenFlags) e.toJson()],
        'attachment_you': attachmentYou?.toJson(),
        'attachment_partner': attachmentPartner?.toJson(),
        'attachment_loop': attachmentLoop,
        'love_you': loveYou?.toJson(),
        'love_partner': lovePartner?.toJson(),
        'turning_points': [for (final t in turningPoints) t.toJson()],
      };

  factory DeepDive.fromJson(Map<String, dynamic> j) => DeepDive(
        conflictSummary: j['conflict_summary'] as String? ?? '',
        conflicts: _items(j['conflicts']),
        horsemen: [
          for (final e in (j['horsemen'] as List? ?? const []))
            ?HorsemanItem.maybeFromJson(e),
        ],
        redFlags: _items(j['red_flags']),
        greenFlags: _items(j['green_flags']),
        attachmentYou: AttachmentRead.maybeFromJson(j['attachment_you']),
        attachmentPartner:
            AttachmentRead.maybeFromJson(j['attachment_partner']),
        attachmentLoop: j['attachment_loop'] as String? ?? '',
        loveYou: LoveLanguageRead.maybeFromJson(j['love_you']),
        lovePartner: LoveLanguageRead.maybeFromJson(j['love_partner']),
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

/// 戈特曼研究里最伤关系的四种吵架方式
enum Horseman { criticism, contempt, defensiveness, stonewalling }

/// 一次四骑士式的沟通，标明是谁说的
class HorsemanItem extends EvidenceItem {
  final Horseman kind;
  final bool byYou;

  const HorsemanItem({
    required super.date,
    required super.title,
    required super.detail,
    required super.quote,
    required this.kind,
    required this.byYou,
  });

  @override
  Map<String, dynamic> toJson() =>
      {...super.toJson(), 'kind': kind.name, 'by_you': byYou};

  /// 旧数据或认不出的类型直接跳过
  static HorsemanItem? maybeFromJson(dynamic v) {
    if (v is! Map) return null;
    final kind = Horseman.values.asNameMap()[v['kind']];
    if (kind == null) return null;
    final e = EvidenceItem.fromJson(Map<String, dynamic>.from(v));
    return HorsemanItem(
        date: e.date,
        title: e.title,
        detail: e.detail,
        quote: e.quote,
        kind: kind,
        byYou: v['by_you'] == true);
  }
}

/// 爱的语言（流行框架，不是科学测试）
enum LoveLanguage { words, time, gifts, acts, touch }

class LoveLanguageRead {
  final LoveLanguage primary;
  final String detail;

  /// 核对过的原话；没有就是空字符串
  final String quote;

  const LoveLanguageRead(
      {required this.primary, required this.detail, this.quote = ''});

  Map<String, dynamic> toJson() =>
      {'primary': primary.name, 'detail': detail, 'quote': quote};

  static LoveLanguageRead? maybeFromJson(dynamic v) {
    if (v is! Map) return null;
    final primary = LoveLanguage.values.asNameMap()[v['primary']];
    if (primary == null) return null;
    return LoveLanguageRead(
        primary: primary,
        detail: v['detail']?.toString().trim() ?? '',
        quote: v['quote']?.toString().trim() ?? '');
  }
}
