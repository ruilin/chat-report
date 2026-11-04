import '../models/chat_data.dart';

/// 核对模型给出的「原话」是否真的出现在聊天记录里。
/// 付费内容以原话作证据，模型编造或改写过的引用必须丢弃。
class QuoteVerifier {
  final String _haystack;

  QuoteVerifier(ChatData data)
      : _haystack = data.messages
            .where((m) => !m.isMedia)
            .map((m) => _normalize(m.text))
            .join('\n');

  bool contains(String quote) {
    final q = _normalize(quote);
    return q.isNotEmpty && _haystack.contains(q);
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
