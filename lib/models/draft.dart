/// 「写给 TA 的话」的三种用途
enum DraftKind { appreciate, repair, ask }

/// AI 起草、由用户自己修改和发送的一条消息。随报告一起只存在本机。
class MessageDraft {
  final DraftKind kind;
  final String text;

  const MessageDraft({required this.kind, required this.text});

  Map<String, dynamic> toJson() => {'kind': kind.name, 'text': text};

  /// 认不出类型的旧数据直接跳过
  static MessageDraft? maybeFromJson(dynamic v) {
    if (v is! Map) return null;
    final kind = DraftKind.values.asNameMap()[v['kind']];
    final text = v['text']?.toString() ?? '';
    if (kind == null || text.isEmpty) return null;
    return MessageDraft(kind: kind, text: text);
  }
}
