import 'dart:ui';

import '../models/deep_dive.dart';
import '../models/metrics.dart';
import '../models/report.dart';

/// 示例报告：首页「先看一份示例报告」入口展示，也供 debug 长按 logo 目检
/// 报告页 / 采集商店截图。数据形态与真实管线输出一致，人物与聊天均为虚构。
///
/// 正文跟随界面语言（同真实管线"报告正文跟随界面语言"）；文案按语言放在
/// [_copy]，新增界面语言时在这里补一份，缺的语言回退英文。
RelationshipReport buildSampleReport({String lang = 'en'}) {
  final c = _copy[lang] ?? _copy['en']!;
  String t(String key) => c[key] ?? _copy['en']![key]!;

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
    warmthReason: t('warmthReason'),
    emotionCurve: [
      MonthMood('2025-09', 6.2),
      MonthMood('2025-10', 6.8),
      MonthMood('2025-11', 6.5),
      MonthMood('2025-12', 7.4),
      MonthMood('2026-01', 7.0),
      MonthMood('2026-02', 6.9),
      MonthMood('2026-03', 7.6),
      MonthMood('2026-04', 3.1, note: t('noteApr')),
      MonthMood('2026-05', 6.4),
      MonthMood('2026-06', 7.8),
      MonthMood('2026-07', 9.1, note: t('noteJul')),
      MonthMood('2026-08', 8.4),
    ],
    topics: [
      TopicShare(t('topicFood'), 24),
      TopicShare(t('topicWork'), 19),
      TopicShare(t('topicTravel'), 15),
      TopicShare(t('topicMemes'), 13),
      TopicShare(t('topicFuture'), 9),
    ],
    personalityYou: [t('youNightOwl'), t('youFastReplier'), t('youEmoji')],
    personalityPartner: [
      t('partnerStoryteller'),
      t('partnerSlowBurn'),
      t('partnerVoiceNotes'),
    ],
    deepReading: t('deepReading'),
    milestones: [
      Milestone('2025-12', t('msGoodnight'), t('quoteGoodnight')),
      Milestone('2026-03', t('msFlights'), t('quoteFlights')),
      Milestone('2026-04', t('msSilent'), t('quoteSilent')),
      Milestone('2026-07', t('msWarmest'), t('quoteWarmest')),
    ],
    advice: [t('advice1'), t('advice2'), t('advice3')],
    // 示例把付费内容全部展示出来，用户才知道解锁能看到什么
    deepDive: _sampleDive(lang, t),
    deepDiveUnlocked: true,
  );
}

/// 示例的专题分析。原话沿用虚构聊天的英文原文
DeepDive _sampleDive(String lang, String Function(String) t) {
  final c = _diveCopy[lang] ?? _diveCopy['en']!;
  String d(String key) => c[key] ?? _diveCopy['en']![key]!;
  return DeepDive(
    conflictSummary: d('dvConflictSummary'),
    conflicts: [
      EvidenceItem(
          date: '2026-04',
          title: d('dvConflictTitle'),
          detail: d('dvConflictDetail'),
          quote: 'you said Friday was ours'),
    ],
    horsemen: [
      HorsemanItem(
          date: '2026-04',
          title: d('dvCritTitle'),
          detail: d('dvCritDetail'),
          quote: 'you always cancel last minute',
          kind: Horseman.criticism,
          byYou: true),
      HorsemanItem(
          date: '2026-04',
          title: d('dvStoneTitle'),
          detail: d('dvStoneDetail'),
          quote: 'can we not do this right now',
          kind: Horseman.stonewalling,
          byYou: false),
    ],
    greenFlags: [
      EvidenceItem(
          date: '2026-05',
          title: d('dvGreenTitle'),
          detail: d('dvGreenDetail'),
          quote: 'I\'m sorry about Friday. can I make it up to you?'),
    ],
    attachmentYou: AttachmentRead(style: 'anxious', detail: d('dvAttachYou')),
    attachmentPartner:
        AttachmentRead(style: 'avoidant', detail: d('dvAttachPartner')),
    attachmentLoop: d('dvLoop'),
    loveYou: LoveLanguageRead(
        primary: LoveLanguage.words,
        detail: d('dvLoveYou'),
        quote: t('quoteGoodnight')),
    lovePartner: LoveLanguageRead(
        primary: LoveLanguage.time,
        detail: d('dvLovePartner'),
        quote: 'let\'s just walk around all day, no plans'),
    turningPoints: [
      TurningPoint(
          date: '2026-04',
          title: t('msSilent'),
          detail: d('dvTurnDown'),
          quote: t('quoteSilent'),
          rising: false),
      TurningPoint(
          date: '2026-07',
          title: t('msWarmest'),
          detail: d('dvTurnUp'),
          quote: t('quoteWarmest'),
          rising: true),
    ],
  );
}

/// 界面语言 → 示例文案语言键（与 promptLanguageOf 的繁简判定同源）
String sampleLangOf(Locale locale) {
  if (locale.languageCode == 'zh') {
    final hant = locale.scriptCode == 'Hant' ||
        const {'TW', 'HK', 'MO'}.contains(locale.countryCode);
    return hant ? 'zh-Hant' : 'zh';
  }
  return _copy.containsKey(locale.languageCode) ? locale.languageCode : 'en';
}

const _copy = <String, Map<String, String>>{
  'en': {
    'warmthReason':
        'Steady rhythm with a strong recovery after the April silence — '
            'the late-night talks carry this relationship.',
    'noteApr': 'Apr · the silent week',
    'noteJul': 'Jul · 91° — trip together',
    'topicFood': 'Food & cooking',
    'topicWork': 'Work drama',
    'topicTravel': 'Travel plans',
    'topicMemes': 'Memes',
    'topicFuture': 'The future',
    'youNightOwl': 'Night owl 🌙',
    'youFastReplier': 'Fast replier',
    'youEmoji': 'Emoji maximalist',
    'partnerStoryteller': 'Storyteller 📖',
    'partnerSlowBurn': 'Slow burn',
    'partnerVoiceNotes': 'Voice-note lover',
    'deepReading':
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
    'msGoodnight': 'First "goodnight" streak begins',
    'msFlights': 'Lisbon flights booked',
    'msSilent': 'The silent week',
    'msWarmest': 'Warmest month on record',
    'quoteGoodnight': 'night Mia. same time tomorrow?',
    'quoteFlights': 'AAAAAH it\'s happening!!',
    'quoteSilent': 'I just need a few days',
    'quoteWarmest': 'best company ever',
    'advice1':
        'Protect the late-night window — it is where your best talks live.',
    'advice2': 'When plans change, tell Mia before the group chat hears it.',
    'advice3':
        'Let Mia open the conversation sometimes: skip one morning text and see.',
  },
  // 中文版沿用英文原话作为金句（虚构聊天本身是英文）
  'zh': {
    'warmthReason': '节奏稳定，四月那段沉默之后回暖明显 —— 深夜的聊天撑起了这段关系。',
    'noteApr': '4 月 · 沉默的那一周',
    'noteJul': '7 月 · 91° 一起旅行',
    'topicFood': '美食与做饭',
    'topicWork': '职场吐槽',
    'topicTravel': '旅行计划',
    'topicMemes': '梗图',
    'topicFuture': '关于未来',
    'youNightOwl': '夜猫子 🌙',
    'youFastReplier': '秒回选手',
    'youEmoji': '表情包狂魔',
    'partnerStoryteller': '说故事的人 📖',
    'partnerSlowBurn': '慢热型',
    'partnerVoiceNotes': '语音爱好者',
    'deepReading': '你和 Mia 之间最先跳出来的是节奏 —— 你开口，她展开。62% 的对话由你先起头，'
        '但她的回复长度是你的一倍半，这是一种"一个人点火、另一个人添柴"的搭配。'
        '四月是压力测试：那个取消的周五之后，回复时长翻了三倍，深夜消息停了整整十二天。'
        '把关系拉回来的不是反复道歉，而是一个计划 —— 里斯本之行在数据上是明确的转折点，'
        '七月成了有记录以来最暖的一个月。612 条深夜消息往往是真话发生的地方：'
        '白天聊安排，午夜聊意义。',
    'msGoodnight': '第一次连续说晚安',
    'msFlights': '订下里斯本机票',
    'msSilent': '沉默的那一周',
    'msWarmest': '有记录以来最暖的月份',
    'advice1': '守住深夜那段时间 —— 你们最好的对话都发生在那里。',
    'advice2': '计划有变时，先告诉 Mia，别让她从群里知道。',
    'advice3': '偶尔让 Mia 先开口：试着跳过一次早安消息，看看会发生什么。',
  },
  'zh-Hant': {
    'warmthReason': '節奏穩定，四月那段沉默之後回暖明顯 —— 深夜的對話撐起了這段關係。',
    'noteApr': '4 月 · 沉默的那一週',
    'noteJul': '7 月 · 91° 一起旅行',
    'topicFood': '美食與料理',
    'topicWork': '職場吐槽',
    'topicTravel': '旅行計畫',
    'topicMemes': '迷因',
    'topicFuture': '關於未來',
    'youNightOwl': '夜貓子 🌙',
    'youFastReplier': '秒回選手',
    'youEmoji': '貼圖狂魔',
    'partnerStoryteller': '說故事的人 📖',
    'partnerSlowBurn': '慢熱型',
    'partnerVoiceNotes': '語音愛好者',
    'deepReading': '你和 Mia 之間最先跳出來的是節奏 —— 你開口，她展開。62% 的對話由你先起頭，'
        '但她的回覆長度是你的一倍半，這是一種「一個人點火、另一個人添柴」的搭配。'
        '四月是壓力測試：那個取消的週五之後，回覆時間翻了三倍，深夜訊息停了整整十二天。'
        '把關係拉回來的不是反覆道歉，而是一個計畫 —— 里斯本之行在數據上是明確的轉折點，'
        '七月成了有紀錄以來最暖的一個月。612 則深夜訊息往往是真話發生的地方：'
        '白天聊安排，午夜聊意義。',
    'msGoodnight': '第一次連續說晚安',
    'msFlights': '訂下里斯本機票',
    'msSilent': '沉默的那一週',
    'msWarmest': '有紀錄以來最暖的月份',
    'advice1': '守住深夜那段時間 —— 你們最好的對話都發生在那裡。',
    'advice2': '計畫有變時，先告訴 Mia，別讓她從群組裡知道。',
    'advice3': '偶爾讓 Mia 先開口：試著跳過一次早安訊息，看看會發生什麼。',
  },
  'es': {
    'warmthReason': 'Un ritmo constante y una gran recuperación después del silencio de abril — las charlas de madrugada sostienen esta relación.',
    'noteApr': 'Abr · la semana del silencio',
    'noteJul': 'Jul · 91° — viaje juntos',
    'topicFood': 'Comida y cocina',
    'topicWork': 'Drama laboral',
    'topicTravel': 'Planes de viaje',
    'topicMemes': 'Memes',
    'topicFuture': 'El futuro',
    'youNightOwl': 'Búho nocturno 🌙',
    'youFastReplier': 'Responde al instante',
    'youEmoji': 'Maximalista del emoji',
    'partnerStoryteller': 'Cuentacuentos 📖',
    'partnerSlowBurn': 'Fuego lento',
    'partnerVoiceNotes': 'Fan de los audios',
    'deepReading': 'Lo primero que salta a la vista entre tú y Mia es el ritmo — tú abres, Mia desarrolla. Inicias el 62% de las conversaciones, pero sus respuestas son una vez y media más largas que las tuyas: señales de una pareja donde una persona enciende el fuego y la otra lo mantiene vivo. Abril fue la gran prueba: los tiempos de respuesta se triplicaron y los mensajes de madrugada se detuvieron durante doce días después de aquel viernes cancelado. Lo que los volvió a acercar no fue una ronda interminable de disculpas, sino un plan — el viaje a Lisboa aparece en los datos como un punto de inflexión, y julio se perfila como el mes más cálido de su historia. Los 612 mensajes de madrugada suelen ser donde ocurren las conversaciones de verdad; el día es para la logística, la medianoche es para lo que importa.',
    'msGoodnight': 'Empieza la primera racha de "buenas noches"',
    'msFlights': 'Vuelos a Lisboa reservados',
    'msSilent': 'La semana del silencio',
    'msWarmest': 'El mes más cálido de su historia',
    'quoteGoodnight': 'buenas noches Mia. ¿mañana a la misma hora?',
    'quoteFlights': 'AAAAAH ¡¡ya es oficial!!',
    'quoteSilent': 'Solo necesito unos días',
    'quoteWarmest': 'la mejor compañía del mundo',
    'advice1': 'Cuida la ventana de madrugada — ahí es donde tienen sus mejores charlas.',
    'advice2': 'Cuando cambien los planes, avísale a Mia antes de que se entere el grupo.',
    'advice3': 'Deja que Mia abra la conversación de vez en cuando: sáltate un mensaje de buenos días y ve qué pasa.',
  },
  'pt': {
    'warmthReason': 'Ritmo constante e uma bela retomada depois do silêncio de abril — as conversas de madrugada sustentam essa relação.',
    'noteApr': 'Abr · a semana do silêncio',
    'noteJul': 'Jul · 91° — viagem juntos',
    'topicFood': 'Comida e cozinha',
    'topicWork': 'Drama no trabalho',
    'topicTravel': 'Planos de viagem',
    'topicMemes': 'Memes',
    'topicFuture': 'O futuro',
    'youNightOwl': 'Coruja noturna 🌙',
    'youFastReplier': 'Responde na hora',
    'youEmoji': 'Maximalista de emoji',
    'partnerStoryteller': 'Contadora de histórias 📖',
    'partnerSlowBurn': 'Fogo lento',
    'partnerVoiceNotes': 'Rainha dos áudios',
    'deepReading': 'A primeira coisa que chama atenção em você e na Mia é o ritmo — você puxa o assunto, a Mia desenvolve. Você começa 62% das conversas, mas as respostas dela são uma vez e meia mais longas que as suas: sinais de uma dupla em que uma pessoa acende o fogo e a outra o mantém aceso. Abril foi o teste de estresse: o tempo de resposta triplicou e as mensagens de madrugada pararam por doze dias depois daquela sexta-feira cancelada. O que trouxe tudo de volta não foi um ciclo de desculpas, e sim um plano — a viagem para Lisboa aparece nos dados como uma virada, e julho desponta como o mês mais quente que vocês já tiveram. As 612 mensagens de madrugada costumam ser onde as conversas de verdade acontecem; de dia é logística, à meia-noite é significado.',
    'msGoodnight': 'Começa a primeira sequência de "boa noite"',
    'msFlights': 'Passagens para Lisboa compradas',
    'msSilent': 'A semana do silêncio',
    'msWarmest': 'O mês mais quente de todos',
    'quoteGoodnight': 'boa noite Mia. amanhã no mesmo horário?',
    'quoteFlights': 'AAAAAH vai acontecer!!',
    'quoteSilent': 'Só preciso de uns dias',
    'quoteWarmest': 'melhor companhia do mundo',
    'advice1': 'Protejam a janela da madrugada — é lá que moram as melhores conversas de vocês.',
    'advice2': 'Quando os planos mudarem, conte pra Mia antes que o grupo fique sabendo.',
    'advice3': 'Deixe a Mia puxar assunto às vezes: pule uma mensagem de bom dia e veja o que acontece.',
  },
  'fr': {
    'warmthReason': 'Un rythme régulier et un beau rebond après le silence d\'avril — ce sont les conversations nocturnes qui portent cette relation.',
    'noteApr': 'Avr. · la semaine du silence',
    'noteJul': 'Juil. · 91° — voyage à deux',
    'topicFood': 'Bouffe & cuisine',
    'topicWork': 'Drames au boulot',
    'topicTravel': 'Projets de voyage',
    'topicMemes': 'Mèmes',
    'topicFuture': 'L\'avenir',
    'youNightOwl': 'Oiseau de nuit 🌙',
    'youFastReplier': 'Réponse éclair',
    'youEmoji': 'Accro aux emojis',
    'partnerStoryteller': 'Conteuse 📖',
    'partnerSlowBurn': 'Feu doux',
    'partnerVoiceNotes': 'Reine des vocaux',
    'deepReading': 'Ce qui frappe d\'abord entre toi et Mia, c\'est le rythme — tu lances, Mia développe. Tu ouvres 62% des conversations, mais ses réponses sont une fois et demie plus longues que les tiennes : le signe d\'un duo où l\'un allume le feu et l\'autre l\'entretient. Avril a été le crash-test : les délais de réponse ont triplé et les messages nocturnes se sont arrêtés pendant douze jours après ce vendredi annulé. Ce qui a tout relancé, ce n\'est pas une spirale d\'excuses mais un projet — le voyage à Lisbonne apparaît dans les données comme un tournant, et juillet s\'impose comme votre mois le plus chaleureux jamais enregistré. Les 612 messages nocturnes, c\'est souvent là que se jouent les vraies conversations ; le jour, c\'est la logistique, à minuit, c\'est l\'essentiel.',
    'msGoodnight': 'Début de la première série de « bonne nuit »',
    'msFlights': 'Billets pour Lisbonne réservés',
    'msSilent': 'La semaine du silence',
    'msWarmest': 'Le mois le plus chaleureux jamais vu',
    'quoteGoodnight': 'bonne nuit Mia. même heure demain ?',
    'quoteFlights': 'AAAAAH ça y est, on y va !!',
    'quoteSilent': 'J\'ai juste besoin de quelques jours',
    'quoteWarmest': 'la meilleure compagnie du monde',
    'advice1': 'Protège ce créneau nocturne — c\'est là que naissent vos meilleures conversations.',
    'advice2': 'Quand les plans changent, préviens Mia avant que le groupe l\'apprenne.',
    'advice3': 'Laisse Mia lancer la conversation de temps en temps : saute un message du matin et observe.',
  },
  'de': {
    'warmthReason': 'Gleichmäßiger Rhythmus und ein starkes Comeback nach der Funkstille im April — die nächtlichen Gespräche tragen diese Beziehung.',
    'noteApr': 'Apr. · die stille Woche',
    'noteJul': 'Jul. · 91° — gemeinsame Reise',
    'topicFood': 'Essen & Kochen',
    'topicWork': 'Job-Drama',
    'topicTravel': 'Reisepläne',
    'topicMemes': 'Memes',
    'topicFuture': 'Die Zukunft',
    'youNightOwl': 'Nachteule 🌙',
    'youFastReplier': 'Antwortet sofort',
    'youEmoji': 'Emoji-Dauerfeuer',
    'partnerStoryteller': 'Erzählerin 📖',
    'partnerSlowBurn': 'Taut langsam auf',
    'partnerVoiceNotes': 'Sprachnachrichten-Queen',
    'deepReading': 'Das Erste, was bei dir und Mia auffällt, ist der Rhythmus — du eröffnest, Mia führt aus. Du startest 62% der Gespräche, aber ihre Antworten sind anderthalbmal so lang wie deine: typisch für ein Duo, in dem eine Person das Feuer entfacht und die andere es am Brennen hält. Der April war der Stresstest: Die Antwortzeiten haben sich verdreifacht, und nach dem abgesagten Freitag kamen zwölf Tage lang keine nächtlichen Nachrichten mehr. Zurückgebracht hat euch keine Entschuldigungsschleife, sondern ein Plan — die Lissabon-Reise taucht in den Daten als Wendepunkt auf, und der Juli liest sich als euer wärmster Monat überhaupt. In den 612 Nachrichten nach Mitternacht stecken meist die echten Gespräche; tagsüber geht es um Logistik, um Mitternacht um das, was zählt.',
    'msGoodnight': 'Die erste „Gute Nacht“-Serie beginnt',
    'msFlights': 'Flüge nach Lissabon gebucht',
    'msSilent': 'Die stille Woche',
    'msWarmest': 'Wärmster Monat überhaupt',
    'quoteGoodnight': 'nacht Mia. morgen selbe zeit?',
    'quoteFlights': 'AAAAAH es passiert wirklich!!',
    'quoteSilent': 'Ich brauch nur ein paar Tage',
    'quoteWarmest': 'beste gesellschaft überhaupt',
    'advice1': 'Schütz euer Nachtfenster — dort finden eure besten Gespräche statt.',
    'advice2': 'Wenn sich Pläne ändern, sag es Mia, bevor der Gruppenchat davon erfährt.',
    'advice3': 'Lass Mia auch mal das Gespräch anfangen: Überspring eine Guten-Morgen-Nachricht und schau, was passiert.',
  },
  'it': {
    'warmthReason': 'Un ritmo costante e una bella ripresa dopo il silenzio di aprile — sono le chiacchierate notturne a reggere questa relazione.',
    'noteApr': 'Apr · la settimana del silenzio',
    'noteJul': 'Lug · 91° — viaggio insieme',
    'topicFood': 'Cibo e cucina',
    'topicWork': 'Drammi al lavoro',
    'topicTravel': 'Piani di viaggio',
    'topicMemes': 'Meme',
    'topicFuture': 'Il futuro',
    'youNightOwl': 'Animale notturno 🌙',
    'youFastReplier': 'Risposta lampo',
    'youEmoji': 'Emoji a raffica',
    'partnerStoryteller': 'Cantastorie 📖',
    'partnerSlowBurn': 'Fuoco lento',
    'partnerVoiceNotes': 'Regina dei vocali',
    'deepReading': 'La prima cosa che salta all\'occhio tra te e Mia è il ritmo — tu apri, Mia approfondisce. Inizi il 62% delle conversazioni, ma le sue risposte sono lunghe una volta e mezzo le tue: il segno di una coppia in cui una persona accende il fuoco e l\'altra lo tiene vivo. Aprile è stato il vero banco di prova: i tempi di risposta si sono triplicati e i messaggi notturni si sono fermati per dodici giorni dopo quel venerdì saltato. A riavvicinarvi non è stato un giro infinito di scuse, ma un progetto — il viaggio a Lisbona emerge dai dati come una svolta, e luglio risulta il vostro mese più caldo di sempre. I 612 messaggi notturni sono spesso il luogo delle conversazioni vere; di giorno si parla di logistica, a mezzanotte di ciò che conta.',
    'msGoodnight': 'Inizia la prima serie di "buonanotte"',
    'msFlights': 'Voli per Lisbona prenotati',
    'msSilent': 'La settimana del silenzio',
    'msWarmest': 'Il mese più caldo di sempre',
    'quoteGoodnight': 'notte Mia. domani stessa ora?',
    'quoteFlights': 'AAAAAH sta succedendo davvero!!',
    'quoteSilent': 'Ho solo bisogno di qualche giorno',
    'quoteWarmest': 'la compagnia migliore di sempre',
    'advice1': 'Proteggi la finestra notturna — è lì che nascono le vostre conversazioni migliori.',
    'advice2': 'Quando i piani cambiano, dillo a Mia prima che lo sappia il gruppo.',
    'advice3': 'Lascia che ogni tanto sia Mia ad aprire la conversazione: salta un messaggio del buongiorno e vedi che succede.',
  },
  'tr': {
    'warmthReason': 'Nisan\'daki sessizlikten sonra güçlü bir toparlanmayla istikrarlı bir ritim — bu ilişkiyi gece yarısı sohbetleri taşıyor.',
    'noteApr': 'Nis · sessiz hafta',
    'noteJul': 'Tem · 91° — birlikte tatil',
    'topicFood': 'Yemek & mutfak',
    'topicWork': 'İş dramaları',
    'topicTravel': 'Seyahat planları',
    'topicMemes': 'Caps & meme',
    'topicFuture': 'Gelecek',
    'youNightOwl': 'Gece kuşu 🌙',
    'youFastReplier': 'Anında cevapçı',
    'youEmoji': 'Emoji delisi',
    'partnerStoryteller': 'Hikâye anlatıcısı 📖',
    'partnerSlowBurn': 'Yavaş ısınan',
    'partnerVoiceNotes': 'Sesli mesaj tutkunu',
    'deepReading': 'Sen ve Mia hakkında ilk göze çarpan şey ritim — sen açıyorsun, Mia derinleştiriyor. Sohbetlerin %62\'sini sen başlatıyorsun ama onun cevapları seninkilerden bir buçuk kat uzun; biri ateşi yakıyor, diğeri sönmemesini sağlıyor. Nisan bir stres testiydi: iptal edilen o cumadan sonra cevap süreleri üçe katlandı ve gece mesajları 12 gün boyunca kesildi. İşleri yoluna sokan şey bitmeyen özürler değil, bir plan oldu — Lizbon gezisi verilerde net bir dönüm noktası olarak beliriyor ve Temmuz, kayıtlardaki en sıcak ayınız. 612 gece mesajı, asıl sohbetlerin döndüğü yer; gündüz lojistik, gece yarısı anlam.',
    'msGoodnight': 'İlk “iyi geceler” serisi başlıyor',
    'msFlights': 'Lizbon biletleri alındı',
    'msSilent': 'Sessiz hafta',
    'msWarmest': 'Kayıtlardaki en sıcak ay',
    'quoteGoodnight': 'iyi geceler Mia. yarın aynı saatte?',
    'quoteFlights': 'AAAAAH gerçekten oluyor!!',
    'quoteSilent': 'Sadece birkaç güne ihtiyacım var',
    'quoteWarmest': 'dünyanın en iyi yol arkadaşı',
    'advice1': 'Gece saatlerini koru — en güzel sohbetleriniz orada yaşanıyor.',
    'advice2': 'Planlar değişince, grup sohbeti duymadan önce Mia\'ya söyle.',
    'advice3': 'Bazen sohbeti Mia başlatsın: bir sabah mesajını atla ve ne olacağını gör.',
  },
  'ar': {
    'warmthReason': 'إيقاع ثابت وتعافٍ قوي بعد صمت أبريل — أحاديث آخر الليل هي ما يحمل هذه العلاقة.',
    'noteApr': 'أبريل · أسبوع الصمت',
    'noteJul': 'يوليو · 91° — رحلة معًا',
    'topicFood': 'الأكل والطبخ',
    'topicWork': 'دراما العمل',
    'topicTravel': 'خطط السفر',
    'topicMemes': 'الميمز',
    'topicFuture': 'المستقبل',
    'youNightOwl': 'كائن ليلي 🌙',
    'youFastReplier': 'سريع الرد',
    'youEmoji': 'مهووس بالإيموجي',
    'partnerStoryteller': 'حكّاءة 📖',
    'partnerSlowBurn': 'على نار هادئة',
    'partnerVoiceNotes': 'عاشقة الرسائل الصوتية',
    'deepReading': 'أول ما يلفت النظر بينك وبين Mia هو الإيقاع — أنت تفتح الحديث، وMia تُكمله وتتوسّع فيه. تبدأ أنت 62% من المحادثات، لكن طول ردودها مرة ونصف طول ردودك، وهذه علامة ثنائي يُشعل فيه أحدهما النار ويُبقيها الآخر متّقدة. كان أبريل اختبار الضغط: بعد يوم الجمعة الذي أُلغي، تضاعف وقت الرد ثلاث مرات وتوقفت رسائل آخر الليل 12 يومًا. وما أعاد الدفء لم يكن دوامة من الاعتذارات بل خطة — رحلة لشبونة تظهر في البيانات كنقطة تحوّل، ويوليو يبدو أدفأ شهر في سجلّكما. أما رسائل آخر الليل الـ612 فهي غالبًا حيث تدور الأحاديث الحقيقية؛ النهار للترتيبات، ومنتصف الليل للمعنى.',
    'msGoodnight': 'بداية أول سلسلة «ليلة سعيدة»',
    'msFlights': 'حجز تذاكر لشبونة',
    'msSilent': 'أسبوع الصمت',
    'msWarmest': 'أدفأ شهر على الإطلاق',
    'quoteGoodnight': 'تصبحين على خير يا Mia. نفس الموعد غدًا؟',
    'quoteFlights': 'آآآآآه سنسافر فعلًا!!',
    'quoteSilent': 'أحتاج فقط إلى بضعة أيام',
    'quoteWarmest': 'أحلى رفقة على الإطلاق',
    'advice1': 'احمِ وقت آخر الليل — ففيه تدور أجمل أحاديثكما.',
    'advice2': 'حين تتغير الخطط، أخبر Mia قبل أن تسمع بها مجموعة الأصدقاء.',
    'advice3': 'دع Mia تبدأ المحادثة أحيانًا: تخطَّ رسالة صباحية واحدة وانتظر ما سيحدث.',
  },
  'hi': {
    'warmthReason': 'रिदम लगातार बना रहा, और अप्रैल की खामोशी के बाद ज़बरदस्त वापसी हुई — देर रात की बातें ही इस रिश्ते की जान हैं।',
    'noteApr': 'अप्रैल · खामोश हफ़्ता',
    'noteJul': 'जुलाई · 91° — साथ में ट्रिप',
    'topicFood': 'खाना & कुकिंग',
    'topicWork': 'ऑफ़िस ड्रामा',
    'topicTravel': 'ट्रैवल प्लान्स',
    'topicMemes': 'मीम्स',
    'topicFuture': 'फ़्यूचर',
    'youNightOwl': 'नाइट आउल 🌙',
    'youFastReplier': 'फ़टाफ़ट रिप्लाई',
    'youEmoji': 'इमोजी के दीवाने',
    'partnerStoryteller': 'किस्सागो 📖',
    'partnerSlowBurn': 'धीमी आँच',
    'partnerVoiceNotes': 'वॉइस-नोट लवर',
    'deepReading': 'आपके और Mia के बारे में सबसे पहले जो बात नज़र आती है, वो है रिदम — आप बात शुरू करते हैं, Mia उसे आगे बढ़ाती है। 62% बातचीत आप शुरू करते हैं, लेकिन उसके रिप्लाई आपके रिप्लाई से डेढ़ गुना लंबे होते हैं — यानी ऐसी जोड़ी जहाँ एक आग जलाता है और दूसरा उसे बुझने नहीं देता। अप्रैल असली टेस्ट था: उस कैंसल हुए शुक्रवार के बाद रिप्लाई टाइम तीन गुना हो गया और देर रात के मैसेज 12 दिन तक बंद रहे। चीज़ें माफ़ियों के सिलसिले से नहीं, एक प्लान से पटरी पर लौटीं — डेटा में लिस्बन ट्रिप साफ़ टर्निंग पॉइंट दिखती है, और जुलाई अब तक का आपका सबसे गर्मजोशी भरा महीना रहा। देर रात के 612 मैसेज ही वो जगह हैं जहाँ असली बातें होती हैं; दिन में लॉजिस्टिक्स, आधी रात को दिल की बातें।',
    'msGoodnight': 'पहली "गुड नाइट" स्ट्रीक शुरू',
    'msFlights': 'लिस्बन की फ़्लाइट्स बुक',
    'msSilent': 'खामोश हफ़्ता',
    'msWarmest': 'अब तक का सबसे गर्मजोशी भरा महीना',
    'quoteGoodnight': 'गुड नाइट Mia। कल इसी टाइम?',
    'quoteFlights': 'आआआआह सच में हो रहा है!!',
    'quoteSilent': 'मुझे बस कुछ दिन चाहिए',
    'quoteWarmest': 'अब तक का सबसे बढ़िया साथ',
    'advice1': 'देर रात का वो वक़्त संभालकर रखें — आपकी सबसे अच्छी बातें वहीं होती हैं।',
    'advice2': 'जब प्लान बदले, तो ग्रुप चैट को पता चलने से पहले Mia को बताएं।',
    'advice3': 'कभी-कभी बातचीत Mia को शुरू करने दें: एक दिन सुबह का मैसेज स्किप करके देखें।',
  },
  'id': {
    'warmthReason': 'Ritmenya stabil, dan bangkit kuat setelah hening di bulan April — obrolan larut malam yang menopang hubungan ini.',
    'noteApr': 'Apr · minggu hening',
    'noteJul': 'Jul · 91° — liburan bareng',
    'topicFood': 'Makanan & masak',
    'topicWork': 'Drama kantor',
    'topicTravel': 'Rencana liburan',
    'topicMemes': 'Meme',
    'topicFuture': 'Masa depan',
    'youNightOwl': 'Anak malam 🌙',
    'youFastReplier': 'Balas kilat',
    'youEmoji': 'Maniak emoji',
    'partnerStoryteller': 'Tukang cerita 📖',
    'partnerSlowBurn': 'Pelan tapi pasti',
    'partnerVoiceNotes': 'Pencinta voice note',
    'deepReading': 'Hal pertama yang mencolok dari kamu dan Mia adalah ritmenya — kamu membuka, Mia mengembangkan. Kamu memulai 62% percakapan, tapi balasan Mia satu setengah kali lebih panjang dari balasanmu, tanda pasangan di mana satu orang menyalakan api dan yang lain menjaganya tetap menyala. April jadi ujiannya: setelah Jumat yang batal itu, waktu balas jadi tiga kali lipat dan chat larut malam berhenti selama 12 hari. Yang membawa kalian kembali bukan rentetan permintaan maaf, tapi sebuah rencana — trip ke Lisbon muncul di data sebagai titik balik, dan Juli tercatat sebagai bulan terhangat kalian. 612 chat larut malam itu biasanya jadi tempat obrolan yang sesungguhnya; siang buat urusan teknis, tengah malam buat hal-hal yang berarti.',
    'msGoodnight': 'Streak "selamat tidur" pertama dimulai',
    'msFlights': 'Tiket ke Lisbon sudah dipesan',
    'msSilent': 'Minggu yang hening',
    'msWarmest': 'Bulan terhangat sepanjang masa',
    'quoteGoodnight': 'met tidur Mia. besok jam yang sama ya?',
    'quoteFlights': 'AAAAAH beneran jadi!!',
    'quoteSilent': 'Aku cuma butuh beberapa hari',
    'quoteWarmest': 'teman jalan terbaik sedunia',
    'advice1': 'Jaga waktu larut malam kalian — di situlah obrolan terbaik kalian terjadi.',
    'advice2': 'Kalau rencana berubah, kasih tahu Mia dulu sebelum grup chat tahu.',
    'advice3': 'Sesekali biarkan Mia yang mulai duluan: coba skip satu chat pagi, lalu lihat apa yang terjadi.',
  },
};

/// 示例专题分析的文案，语言键与 [_copy] 相同
const _diveCopy = <String, Map<String, String>>{
  'en': {
    'dvConflictSummary':
        'You two tend to argue about plans that change at the last minute. You usually push to talk it through right away, Mia tends to step back first, and things settle once one of you makes a concrete plan.',
    'dvConflictTitle':
        'The cancelled Friday',
    'dvConflictDetail':
        'A plan fell through and the talk turned sharp within minutes.',
    'dvStoneTitle':
        'Stepping out of the talk',
    'dvStoneDetail':
        'Mia tends to pause the conversation when it gets heated.',
    'dvCritTitle':
        '"Always" language',
    'dvCritDetail':
        'You turned one cancelled plan into a statement about who Mia is.',
    'dvGreenTitle':
        'A real repair attempt',
    'dvGreenDetail':
        'Mia came back with an apology and an offer, not just "sorry".',
    'dvAttachYou':
        'You tend to check in and seek reassurance when replies slow down.',
    'dvAttachPartner':
        'Mia shows signs of needing space before she can talk things through.',
    'dvLoop':
        'The more you reach for an answer, the more Mia steps back, and the silence makes you reach harder.',
    'dvLoveYou':
        'You show love in words: daily goodnights and quick check-ins.',
    'dvLovePartner':
        'Mia seems to feel closest through unhurried time together.',
    'dvTurnDown':
        'Reply times tripled and the late-night messages stopped for twelve days.',
    'dvTurnUp':
        'After the trip, messages got longer and warmer on both sides.',
  },
  'zh': {
    'dvConflictSummary':
        '你们的争执多半因为临时变卦的计划。你倾向于马上说清楚，Mia 倾向于先退开，等其中一人提出具体安排后才缓和下来。',
    'dvConflictTitle':
        '被取消的周五',
    'dvConflictDetail':
        '计划落空后，几分钟内对话就变得尖锐。',
    'dvStoneTitle':
        '从对话里退出',
    'dvStoneDetail':
        '谈话升温时，Mia 倾向于按下暂停。',
    'dvCritTitle':
        '用了「总是」',
    'dvCritDetail':
        '你把一次取消的计划，说成了 Mia 这个人的问题。',
    'dvGreenTitle':
        '真诚的修复',
    'dvGreenDetail':
        'Mia 回来时不只说了对不起，还提出了补偿。',
    'dvAttachYou':
        '回复变慢时，你倾向于主动确认、寻求安心。',
    'dvAttachPartner':
        'Mia 似乎需要先有空间，才能把事情谈开。',
    'dvLoop':
        '你越想要一个答复，Mia 越往后退，而沉默又让你追得更紧。',
    'dvLoveYou':
        '你用言语表达爱：每天的晚安和随时的问候。',
    'dvLovePartner':
        'Mia 似乎在不赶时间的相处里最感到亲近。',
    'dvTurnDown':
        '回复时间变成原来的三倍，深夜消息停了十二天。',
    'dvTurnUp':
        '旅行之后，双方的消息都变得更长、更暖。',
  },
  'zh-Hant': {
    'dvConflictSummary':
        '你們的爭執多半因為臨時變卦的計畫。你傾向於馬上說清楚，Mia 傾向於先退開，等其中一人提出具體安排後才緩和下來。',
    'dvConflictTitle':
        '被取消的週五',
    'dvConflictDetail':
        '計畫落空後，幾分鐘內對話就變得尖銳。',
    'dvStoneTitle':
        '從對話裡退出',
    'dvStoneDetail':
        '談話升溫時，Mia 傾向於按下暫停。',
    'dvCritTitle':
        '用了「總是」',
    'dvCritDetail':
        '你把一次取消的計畫，說成了 Mia 這個人的問題。',
    'dvGreenTitle':
        '真誠的修復',
    'dvGreenDetail':
        'Mia 回來時不只說了對不起，還提出了補償。',
    'dvAttachYou':
        '回覆變慢時，你傾向於主動確認、尋求安心。',
    'dvAttachPartner':
        'Mia 似乎需要先有空間，才能把事情談開。',
    'dvLoop':
        '你越想要一個答覆，Mia 越往後退，而沉默又讓你追得更緊。',
    'dvLoveYou':
        '你用言語表達愛：每天的晚安和隨時的問候。',
    'dvLovePartner':
        'Mia 似乎在不趕時間的相處裡最感到親近。',
    'dvTurnDown':
        '回覆時間變成原來的三倍，深夜訊息停了十二天。',
    'dvTurnUp':
        '旅行之後，雙方的訊息都變得更長、更暖。',
  },
  'es': {
    'dvConflictSummary':
        'Suelen discutir por planes que cambian a último momento. Tú tiendes a querer hablarlo enseguida, Mia tiende a tomar distancia primero, y todo se calma cuando alguno propone un plan concreto.',
    'dvConflictTitle':
        'El viernes cancelado',
    'dvConflictDetail':
        'Un plan se cayó y la conversación se volvió tensa en minutos.',
    'dvStoneTitle':
        'Salirse de la conversación',
    'dvStoneDetail':
        'Mia tiende a pausar la charla cuando sube de tono.',
    'dvCritTitle':
        'El "siempre"',
    'dvCritDetail':
        'Convertiste un plan cancelado en una afirmación sobre cómo es Mia.',
    'dvGreenTitle':
        'Un intento real de reparar',
    'dvGreenDetail':
        'Mia volvió con una disculpa y una propuesta, no solo con un "perdón".',
    'dvAttachYou':
        'Tiendes a buscar confirmación cuando las respuestas se demoran.',
    'dvAttachPartner':
        'Mia muestra señales de necesitar espacio antes de poder hablar las cosas.',
    'dvLoop':
        'Cuanto más buscas una respuesta, más se aleja Mia, y el silencio te hace insistir más.',
    'dvLoveYou':
        'Demuestras amor con palabras: buenas noches diarias y mensajes para saber cómo está.',
    'dvLovePartner':
        'Mia parece sentirse más cerca con tiempo compartido sin prisa.',
    'dvTurnDown':
        'Los tiempos de respuesta se triplicaron y los mensajes nocturnos pararon doce días.',
    'dvTurnUp':
        'Después del viaje, los mensajes se volvieron más largos y cálidos de ambos lados.',
  },
  'pt': {
    'dvConflictSummary':
        'Vocês costumam discutir por planos que mudam em cima da hora. Você tende a querer resolver na hora, a Mia tende a se afastar primeiro, e tudo se acalma quando alguém propõe um plano concreto.',
    'dvConflictTitle':
        'A sexta cancelada',
    'dvConflictDetail':
        'Um plano caiu e a conversa ficou tensa em minutos.',
    'dvStoneTitle':
        'Saindo da conversa',
    'dvStoneDetail':
        'A Mia tende a pausar a conversa quando ela esquenta.',
    'dvCritTitle':
        'O "sempre"',
    'dvCritDetail':
        'Você transformou um plano cancelado em uma afirmação sobre quem a Mia é.',
    'dvGreenTitle':
        'Uma tentativa real de reparo',
    'dvGreenDetail':
        'A Mia voltou com um pedido de desculpas e uma proposta, não só um "desculpa".',
    'dvAttachYou':
        'Você tende a buscar confirmação quando as respostas demoram.',
    'dvAttachPartner':
        'A Mia mostra sinais de precisar de espaço antes de conseguir conversar.',
    'dvLoop':
        'Quanto mais você busca uma resposta, mais a Mia recua, e o silêncio faz você insistir mais.',
    'dvLoveYou':
        'Você demonstra amor com palavras: boa-noite todo dia e mensagens para saber como ela está.',
    'dvLovePartner':
        'A Mia parece se sentir mais próxima com tempo junto, sem pressa.',
    'dvTurnDown':
        'O tempo de resposta triplicou e as mensagens da madrugada pararam por doze dias.',
    'dvTurnUp':
        'Depois da viagem, as mensagens ficaram mais longas e calorosas dos dois lados.',
  },
  'fr': {
    'dvConflictSummary':
        'Vos disputes portent souvent sur des plans qui changent au dernier moment. Tu as tendance à vouloir en parler tout de suite, Mia à prendre du recul d\'abord, et tout s\'apaise quand l\'un de vous propose un plan concret.',
    'dvConflictTitle':
        'Le vendredi annulé',
    'dvConflictDetail':
        'Un plan est tombé à l\'eau et le ton est monté en quelques minutes.',
    'dvStoneTitle':
        'Sortir de la discussion',
    'dvStoneDetail':
        'Mia a tendance à mettre la conversation en pause quand elle s\'échauffe.',
    'dvCritTitle':
        'Le « toujours »',
    'dvCritDetail':
        'Tu as fait d\'un plan annulé une affirmation sur qui est Mia.',
    'dvGreenTitle':
        'Une vraie tentative de réparation',
    'dvGreenDetail':
        'Mia est revenue avec des excuses et une proposition, pas juste un « désolée ».',
    'dvAttachYou':
        'Tu as tendance à chercher à être rassuré quand les réponses tardent.',
    'dvAttachPartner':
        'Mia semble avoir besoin d\'espace avant de pouvoir parler des choses.',
    'dvLoop':
        'Plus tu cherches une réponse, plus Mia recule, et le silence te pousse à insister.',
    'dvLoveYou':
        'Tu montres ton amour par les mots : des bonne nuit quotidiens et des petits messages pour prendre des nouvelles.',
    'dvLovePartner':
        'Mia semble se sentir la plus proche dans les moments partagés sans se presser.',
    'dvTurnDown':
        'Les temps de réponse ont triplé et les messages nocturnes se sont arrêtés pendant douze jours.',
    'dvTurnUp':
        'Après le voyage, les messages sont devenus plus longs et plus chaleureux des deux côtés.',
  },
  'de': {
    'dvConflictSummary':
        'Ihr streitet meist über Pläne, die sich kurzfristig ändern. Du willst es eher sofort klären, Mia zieht sich eher erst zurück, und es beruhigt sich, sobald einer von euch einen konkreten Plan macht.',
    'dvConflictTitle':
        'Der abgesagte Freitag',
    'dvConflictDetail':
        'Ein Plan platzte, und das Gespräch wurde binnen Minuten scharf.',
    'dvStoneTitle':
        'Raus aus dem Gespräch',
    'dvStoneDetail':
        'Mia neigt dazu, das Gespräch zu pausieren, wenn es hitzig wird.',
    'dvCritTitle':
        'Das Wort „immer“',
    'dvCritDetail':
        'Du hast aus einem abgesagten Plan eine Aussage über Mia als Person gemacht.',
    'dvGreenTitle':
        'Ein echter Versöhnungsversuch',
    'dvGreenDetail':
        'Mia kam mit einer Entschuldigung und einem Angebot zurück, nicht nur mit „sorry“.',
    'dvAttachYou':
        'Du neigst dazu, nachzufragen und Bestätigung zu suchen, wenn Antworten länger dauern.',
    'dvAttachPartner':
        'Mia zeigt Anzeichen, erst Abstand zu brauchen, bevor sie Dinge besprechen kann.',
    'dvLoop':
        'Je mehr du auf eine Antwort drängst, desto mehr zieht sich Mia zurück, und die Stille lässt dich stärker drängen.',
    'dvLoveYou':
        'Du zeigst Liebe mit Worten: tägliche Gute-Nacht-Nachrichten und kurze Nachfragen.',
    'dvLovePartner':
        'Mia scheint sich bei gemeinsamer Zeit ohne Eile am nächsten zu fühlen.',
    'dvTurnDown':
        'Die Antwortzeiten verdreifachten sich, und die Nachrichten spät in der Nacht blieben zwölf Tage aus.',
    'dvTurnUp':
        'Nach der Reise wurden die Nachrichten auf beiden Seiten länger und wärmer.',
  },
  'it': {
    'dvConflictSummary':
        'Di solito litigate per piani che cambiano all\'ultimo momento. Tu tendi a voler chiarire subito, Mia tende prima a prendere le distanze, e tutto si calma quando uno dei due propone un piano concreto.',
    'dvConflictTitle':
        'Il venerdì annullato',
    'dvConflictDetail':
        'Un piano è saltato e in pochi minuti il tono si è fatto teso.',
    'dvStoneTitle':
        'Uscire dalla conversazione',
    'dvStoneDetail':
        'Mia tende a mettere in pausa il discorso quando si scalda.',
    'dvCritTitle':
        'Il "sempre"',
    'dvCritDetail':
        'Hai trasformato un piano annullato in un\'affermazione su com\'è Mia.',
    'dvGreenTitle':
        'Un vero tentativo di riparare',
    'dvGreenDetail':
        'Mia è tornata con delle scuse e una proposta, non solo con uno "scusa".',
    'dvAttachYou':
        'Tendi a cercare conferme quando le risposte rallentano.',
    'dvAttachPartner':
        'Mia mostra segnali di aver bisogno di spazio prima di riuscire a parlarne.',
    'dvLoop':
        'Più cerchi una risposta, più Mia si allontana, e il silenzio ti spinge a insistere.',
    'dvLoveYou':
        'Mostri amore con le parole: la buonanotte ogni giorno e messaggi per sapere come sta.',
    'dvLovePartner':
        'Mia sembra sentirsi più vicina nel tempo passato insieme senza fretta.',
    'dvTurnDown':
        'I tempi di risposta sono triplicati e i messaggi notturni si sono fermati per dodici giorni.',
    'dvTurnUp':
        'Dopo il viaggio, i messaggi sono diventati più lunghi e affettuosi da entrambe le parti.',
  },
  'tr': {
    'dvConflictSummary':
        'Genellikle son anda değişen planlar yüzünden tartışıyorsunuz. Sen hemen konuşup çözmek istiyorsun, Mia önce geri çekilme eğiliminde; biriniz somut bir plan yapınca ortam yatışıyor.',
    'dvConflictTitle':
        'İptal edilen cuma',
    'dvConflictDetail':
        'Bir plan bozuldu ve konuşma dakikalar içinde sertleşti.',
    'dvStoneTitle':
        'Konuşmadan çekilmek',
    'dvStoneDetail':
        'Mia, konuşma gerginleşince ara verme eğiliminde.',
    'dvCritTitle':
        '"Hep" kelimesi',
    'dvCritDetail':
        'İptal edilen tek bir planı Mia\'nın nasıl biri olduğuna dair bir yargıya çevirdin.',
    'dvGreenTitle':
        'Gerçek bir onarım çabası',
    'dvGreenDetail':
        'Mia sadece "özür dilerim" demedi, bir teklifle geri döndü.',
    'dvAttachYou':
        'Yanıtlar gecikince yoklama ve güvence arama eğilimindesin.',
    'dvAttachPartner':
        'Mia, konuları konuşabilmek için önce alana ihtiyaç duyduğuna dair işaretler gösteriyor.',
    'dvLoop':
        'Sen yanıt aradıkça Mia geri çekiliyor, sessizlik de seni daha çok üstelemeye itiyor.',
    'dvLoveYou':
        'Sevgini sözlerle gösteriyorsun: her gece iyi geceler mesajları ve kısa hal hatır sormalar.',
    'dvLovePartner':
        'Mia kendini en çok acele etmeden birlikte geçirilen zamanda yakın hissediyor gibi.',
    'dvTurnDown':
        'Yanıt süreleri üç katına çıktı ve gece mesajları on iki gün kesildi.',
    'dvTurnUp':
        'Geziden sonra iki tarafın da mesajları uzadı ve sıcaklaştı.',
  },
  'ar': {
    'dvConflictSummary':
        'تتشاجران غالبًا بسبب خطط تتغير في اللحظة الأخيرة. تميل أنت إلى الحديث عن الأمر فورًا، وتميل Mia إلى الابتعاد أولًا، ثم تهدأ الأمور عندما يقترح أحدكما خطة محددة.',
    'dvConflictTitle':
        'الجمعة الملغاة',
    'dvConflictDetail':
        'أُلغيت خطة فاحتدّ الحديث خلال دقائق.',
    'dvStoneTitle':
        'الانسحاب من الحديث',
    'dvStoneDetail':
        'تميل Mia إلى إيقاف الحديث مؤقتًا عندما يحتدّ.',
    'dvCritTitle':
        'كلمة «دائمًا»',
    'dvCritDetail':
        'حوّلتَ خطة ملغاة واحدة إلى حكم على شخصية Mia.',
    'dvGreenTitle':
        'محاولة إصلاح حقيقية',
    'dvGreenDetail':
        'عادت Mia باعتذار وعرض للتعويض، لا بكلمة «آسفة» فقط.',
    'dvAttachYou':
        'تميل إلى الاطمئنان وطلب التأكيد عندما تتأخر الردود.',
    'dvAttachPartner':
        'تُظهر Mia علامات على حاجتها إلى مساحة قبل أن تتمكن من مناقشة الأمور.',
    'dvLoop':
        'كلما سعيتَ إلى جواب ابتعدت Mia أكثر، والصمت يدفعك إلى الإلحاح أكثر.',
    'dvLoveYou':
        'تعبّر عن حبك بالكلمات: تحية مساء يومية ورسائل قصيرة للاطمئنان.',
    'dvLovePartner':
        'يبدو أن Mia تشعر بأكبر قرب في الوقت المشترك غير المستعجل.',
    'dvTurnDown':
        'تضاعفت أوقات الرد ثلاث مرات وتوقفت رسائل آخر الليل اثني عشر يومًا.',
    'dvTurnUp':
        'بعد الرحلة، أصبحت الرسائل أطول وأدفأ من الطرفين.',
  },
  'hi': {
    'dvConflictSummary':
        'आप दोनों की बहस अक्सर आख़िरी समय पर बदलने वाली योजनाओं को लेकर होती है। आप तुरंत बात करके सुलझाना चाहते हैं, Mia पहले पीछे हटती हैं, और जब कोई एक ठोस योजना बनाता है तब बात संभलती है।',
    'dvConflictTitle':
        'रद्द हुआ शुक्रवार',
    'dvConflictDetail':
        'एक योजना टूट गई और कुछ ही मिनटों में बातचीत तीखी हो गई।',
    'dvStoneTitle':
        'बातचीत से हट जाना',
    'dvStoneDetail':
        'बात गरम होने पर Mia बातचीत रोक देने की ओर झुकती हैं।',
    'dvCritTitle':
        '"हमेशा" वाली भाषा',
    'dvCritDetail':
        'आपने एक रद्द हुई योजना को Mia के स्वभाव पर टिप्पणी बना दिया।',
    'dvGreenTitle':
        'सुधार की सच्ची कोशिश',
    'dvGreenDetail':
        'Mia सिर्फ़ "सॉरी" नहीं, माफ़ी के साथ एक प्रस्ताव लेकर लौटीं।',
    'dvAttachYou':
        'जवाब धीमे पड़ने पर आप हाल-चाल पूछने और भरोसा पाने की ओर झुकते हैं।',
    'dvAttachPartner':
        'Mia में ऐसे संकेत दिखते हैं कि बात करने से पहले उन्हें थोड़ी दूरी चाहिए।',
    'dvLoop':
        'आप जितना जवाब चाहते हैं, Mia उतना पीछे हटती हैं, और चुप्पी आपको और ज़ोर लगाने पर मजबूर करती है।',
    'dvLoveYou':
        'आप शब्दों से प्यार जताते हैं: रोज़ की गुडनाइट और छोटे-छोटे हाल-चाल।',
    'dvLovePartner':
        'लगता है Mia बिना जल्दबाज़ी के साथ बिताए समय में सबसे क़रीब महसूस करती हैं।',
    'dvTurnDown':
        'जवाब आने का समय तीन गुना हो गया और देर रात के संदेश बारह दिन बंद रहे।',
    'dvTurnUp':
        'यात्रा के बाद दोनों तरफ़ के संदेश लंबे और ज़्यादा गर्मजोशी भरे हो गए।',
  },
  'id': {
    'dvConflictSummary':
        'Kalian cenderung bertengkar soal rencana yang berubah mendadak. Kamu cenderung ingin langsung membahasnya, Mia cenderung menjauh dulu, dan suasana mereda begitu salah satu membuat rencana yang jelas.',
    'dvConflictTitle':
        'Jumat yang batal',
    'dvConflictDetail':
        'Sebuah rencana batal dan obrolan berubah tajam dalam hitungan menit.',
    'dvStoneTitle':
        'Keluar dari obrolan',
    'dvStoneDetail':
        'Mia cenderung menjeda percakapan saat mulai memanas.',
    'dvCritTitle':
        'Kata "selalu"',
    'dvCritDetail':
        'Kamu mengubah satu rencana yang batal menjadi penilaian tentang diri Mia.',
    'dvGreenTitle':
        'Upaya memperbaiki yang tulus',
    'dvGreenDetail':
        'Mia kembali dengan permintaan maaf dan tawaran, bukan sekadar "maaf".',
    'dvAttachYou':
        'Kamu cenderung mengecek dan mencari kepastian saat balasan melambat.',
    'dvAttachPartner':
        'Mia menunjukkan tanda-tanda butuh ruang sebelum bisa membicarakan masalah.',
    'dvLoop':
        'Makin kamu mengejar jawaban, makin Mia menjauh, dan diamnya membuatmu makin mengejar.',
    'dvLoveYou':
        'Kamu menunjukkan cinta lewat kata-kata: ucapan selamat malam tiap hari dan sapaan singkat.',
    'dvLovePartner':
        'Mia tampaknya merasa paling dekat lewat waktu bersama yang tidak terburu-buru.',
    'dvTurnDown':
        'Waktu balas jadi tiga kali lebih lama dan pesan larut malam berhenti selama dua belas hari.',
    'dvTurnUp':
        'Setelah perjalanan itu, pesan dari kedua pihak jadi lebih panjang dan hangat.',
  },
};
