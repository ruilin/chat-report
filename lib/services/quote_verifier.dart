import '../models/chat_data.dart';

/// 核对模型给出的「原话」是否真的出现在聊天记录里。
/// 付费内容以原话作证据，模型编造或改写过的引用必须丢弃。
class QuoteVerifier {
  final String _haystack;

  /// (发送者, 归一化后的正文)，用来查一句话是谁说的
  final List<(String, String)> _messages;

  QuoteVerifier(ChatData data)
      : this._([
          for (final m in data.messages)
            if (!m.isMedia) (m.sender, _normalize(m.text)),
        ]);

  QuoteVerifier._(this._messages)
      : _haystack = _messages.map((m) => m.$2).join('\n');

  bool contains(String quote) {
    final q = _normalize(quote);
    return q.isNotEmpty && _haystack.contains(q);
  }

  /// 这句话是谁发的。模型常把说话人弄反，所以不问模型，直接查聊天记录。
  /// 找不到（比如引用跨了两条消息），或两个人都说过同样的话时返回 null
  String? senderOf(String quote) {
    final q = _normalize(quote);
    if (q.isEmpty) return null;
    final senders = {
      for (final (sender, text) in _messages)
        if (text.contains(q)) sender,
    };
    return senders.length == 1 ? senders.single : null;
  }

  /// 只抹平大小写、空白、弯引号和首尾引号这类无关差异，其余必须逐字一致
  static String _normalize(String s) {
    final t = s
        .toLowerCase()
        .replaceAll(RegExp(r'[‘’]'), "'")
        .replaceAll(RegExp(r'[“”]'), '"')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return t.replaceAll(RegExp(r'''^["'「『]+|["'」』]+$'''), '').trim();
  }
}
