import '../models/metrics.dart';
import '../models/report.dart';

/// 仅供 debug 模式 UI 调试用的假报告（长按首页 logo 进入）。
/// 数据形态与真实管线输出一致，用于不跑 LLM 快速目检报告页/分享卡。
///
/// [lang] 取 'en' / 'zh' / 'zh-Hant'，模拟真实管线"报告正文跟随界面语言"的行为，
/// 也让商店截图能各语言各拍一套。文案写死在本文件，不进 ARB（调试用，不污染产物）。
RelationshipReport buildMockReport({String lang = 'en'}) {
  final zh = lang == 'zh';
  final hant = lang == 'zh-Hant';
  String pick(String en, String s, String t) => hant ? t : (zh ? s : en);
  final metrics = ChatMetrics(
    you: 'Alex',
    partner: 'Mia',
    totalMessages: 14203,
    messageCount: {'Alex': 8238, 'Mia': 5965},
    conversationStarts: {'Alex': 118, 'Mia': 72},
    medianReply: {
      'Alex': const Duration(minutes: 4, seconds: 12),
      'Mia': const Duration(minutes: 18, seconds: 40),
    },
    avgLength: {'Alex': 42.5, 'Mia': 61.3},
    lateNightCount: 612,
    longestSilenceDays: 12,
    months: [
      MonthBucket(2025, 9, 900),
      MonthBucket(2025, 10, 1100),
      MonthBucket(2025, 11, 950),
      MonthBucket(2025, 12, 1300),
      MonthBucket(2026, 1, 1250),
      MonthBucket(2026, 2, 1180),
      MonthBucket(2026, 3, 1420),
      MonthBucket(2026, 4, 310),
      MonthBucket(2026, 5, 980),
      MonthBucket(2026, 6, 1500),
      MonthBucket(2026, 7, 1800),
      MonthBucket(2026, 8, 1513),
    ],
  );

  return RelationshipReport(
    metrics: metrics,
    warmth: 78,
    warmthReason: pick(
      'Steady rhythm with a strong recovery after the April silence — '
          'the late-night talks carry this relationship.',
      '节奏稳定，四月那段沉默之后回暖明显 —— 深夜的聊天撑起了这段关系。',
      '節奏穩定，四月那段沉默之後回暖明顯 —— 深夜的對話撐起了這段關係。',
    ),
    emotionCurve: [
      MonthMood('2025-09', 6.2),
      MonthMood('2025-10', 6.8),
      MonthMood('2025-11', 6.5),
      MonthMood('2025-12', 7.4),
      MonthMood('2026-01', 7.0),
      MonthMood('2026-02', 6.9),
      MonthMood('2026-03', 7.6),
      MonthMood('2026-04', 3.1,
          note: pick('Apr · the silent week', '4 月 · 沉默的那一周',
              '4 月 · 沉默的那一週')),
      MonthMood('2026-05', 6.4),
      MonthMood('2026-06', 7.8),
      MonthMood('2026-07', 9.1,
          note: pick('Jul · 91° — trip together', '7 月 · 91° 一起旅行',
              '7 月 · 91° 一起旅行')),
      MonthMood('2026-08', 8.4),
    ],
    topics: [
      TopicShare(pick('Food & cooking', '美食与做饭', '美食與料理'), 24),
      TopicShare(pick('Work drama', '职场吐槽', '職場吐槽'), 19),
      TopicShare(pick('Travel plans', '旅行计划', '旅行計畫'), 15),
      TopicShare(pick('Memes', '梗图', '迷因'), 13),
      TopicShare(pick('The future', '关于未来', '關於未來'), 9),
    ],
    personalityYou: [
      pick('Night owl 🌙', '夜猫子 🌙', '夜貓子 🌙'),
      pick('Fast replier', '秒回选手', '秒回選手'),
      pick('Emoji maximalist', '表情包狂魔', '貼圖狂魔'),
    ],
    personalityPartner: [
      pick('Storyteller 📖', '说故事的人 📖', '說故事的人 📖'),
      pick('Slow burn', '慢热型', '慢熱型'),
      pick('Voice-note lover', '语音爱好者', '語音愛好者'),
    ],
    deepReading: pick(
      'The first thing that stands out about you and Mia is the rhythm — '
          'you open, Mia elaborates. You start 62% of conversations, but her '
          'replies run half again as long as yours, signs of a pairing where '
          'one person lights the fire and the other keeps it burning. '
          'April was the stress test: reply times tripled and the late-night '
          'messages stopped for twelve days after the cancelled Friday. What '
          'brought it back was not an apology loop but a plan — the Lisbon '
          'trip shows up in the data as a turning point, and July reads as '
          'your warmest month on record. The 612 late-night messages tend to '
          'be where the real conversations happen; daytime is logistics, '
          'midnight is meaning.',
      '你和 Mia 之间最先跳出来的是节奏 —— 你开口，她展开。62% 的对话由你先起头，'
          '但她的回复长度是你的一倍半，这是一种"一个人点火、另一个人添柴"的搭配。'
          '四月是压力测试：那个取消的周五之后，回复时长翻了三倍，深夜消息停了整整十二天。'
          '把关系拉回来的不是反复道歉，而是一个计划 —— 里斯本之行在数据上是明确的转折点，'
          '七月成了有记录以来最暖的一个月。612 条深夜消息往往是真话发生的地方：'
          '白天聊安排，午夜聊意义。',
      '你和 Mia 之間最先跳出來的是節奏 —— 你開口，她展開。62% 的對話由你先起頭，'
          '但她的回覆長度是你的一倍半，這是一種「一個人點火、另一個人添柴」的搭配。'
          '四月是壓力測試：那個取消的週五之後，回覆時間翻了三倍，深夜訊息停了整整十二天。'
          '把關係拉回來的不是反覆道歉，而是一個計畫 —— 里斯本之行在數據上是明確的轉折點，'
          '七月成了有紀錄以來最暖的一個月。612 則深夜訊息往往是真話發生的地方：'
          '白天聊安排，午夜聊意義。',
    ),
    milestones: [
      Milestone(
          '2025-12',
          pick('First "goodnight" streak begins', '第一次连续说晚安',
              '第一次連續說晚安'),
          'night Mia. same time tomorrow?'),
      Milestone('2026-03',
          pick('Lisbon flights booked', '订下里斯本机票', '訂下里斯本機票'),
          'AAAAAH it\'s happening!!'),
      Milestone('2026-04',
          pick('The silent week', '沉默的那一周', '沉默的那一週'),
          'I just need a few days'),
      Milestone(
          '2026-07',
          pick('Warmest month on record', '有记录以来最暖的月份',
              '有紀錄以來最暖的月份'),
          'best company ever'),
    ],
    advice: [
      pick('Protect the late-night window — it is where your best talks live.',
          '守住深夜那段时间 —— 你们最好的对话都发生在那里。',
          '守住深夜那段時間 —— 你們最好的對話都發生在那裡。'),
      pick('When plans change, tell Mia before the group chat hears it.',
          '计划有变时，先告诉 Mia，别让她从群里知道。',
          '計畫有變時，先告訴 Mia，別讓她從群組裡知道。'),
      pick(
          'Let Mia open the conversation sometimes: skip one morning text and see.',
          '偶尔让 Mia 先开口：试着跳过一次早安消息，看看会发生什么。',
          '偶爾讓 Mia 先開口：試著跳過一次早安訊息，看看會發生什麼。'),
    ],
  );
}
