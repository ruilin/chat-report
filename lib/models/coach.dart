/// AI 教练对话里的一条消息，随报告一起只存在本机。
class CoachMessage {
  final bool fromUser;
  final String text;

  const CoachMessage({required this.fromUser, required this.text});

  Map<String, dynamic> toJson() => {'from_user': fromUser, 'text': text};

  factory CoachMessage.fromJson(Map<String, dynamic> j) => CoachMessage(
      fromUser: j['from_user'] as bool, text: j['text'] as String);
}
