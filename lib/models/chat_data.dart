import '../l10n/app_localizations.dart';

/// 解析后的单条消息。
class ChatMessage {
  final DateTime time;
  final String sender;
  final String text;
  final bool isMedia;

  const ChatMessage({
    required this.time,
    required this.sender,
    required this.text,
    this.isMedia = false,
  });
}

/// 一次导入的完整对话。
class ChatData {
  final List<ChatMessage> messages;
  final List<String> participants;

  ChatData({required this.messages, required this.participants});

  bool get isTwoPerson => participants.length == 2;

  DateTime get firstDate => messages.first.time;
  DateTime get lastDate => messages.last.time;
}

enum Relationship { partner, crush, friend, ex, family }

extension RelationshipLabel on Relationship {
  /// 本地化标签（emoji 各语言通用，仅文字翻译）
  String label(L l) => switch (this) {
        Relationship.partner => l.relPartner,
        Relationship.crush => l.relCrush,
        Relationship.friend => l.relFriend,
        Relationship.ex => l.relEx,
        Relationship.family => l.relFamily,
      };

  /// 喂给 LLM 的稳定标识（不随界面语言变化）
  String get promptName => name;
}
