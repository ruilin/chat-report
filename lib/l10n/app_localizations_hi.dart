// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class LHi extends L {
  LHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'Chat Report';

  @override
  String get tagline => 'आपकी चैट्स असल में क्या कहती हैं?';

  @override
  String get homeImportTitle => 'चैट इम्पोर्ट करें';

  @override
  String get homeImportSubtitle => 'पूरी रिलेशनशिप रिपोर्ट';

  @override
  String get homeImportHint =>
      'अंदर स्टेप-बाय-स्टेप गाइड है — बस 30 सेकंड लगेंगे  →';

  @override
  String get homePasteTitle => 'बातचीत पेस्ट करें';

  @override
  String get homePasteSubtitle => 'झटपट रीड · फ़्री · 30 सेकंड';

  @override
  String get homePrivacy =>
      'आंकड़े आपके फ़ोन पर ही निकाले जाते हैं। रिपोर्ट लिखने के लिए आपके मैसेज हमारे AI प्रोवाइडर को भेजे जाते हैं — हम उन्हें कभी सेव नहीं करते।';

  @override
  String get homeSampleTitle => 'पहले एक सैंपल रिपोर्ट देखें';

  @override
  String get homeSampleSubtitle =>
      'एक काल्पनिक चैट से बनी · एक्सपोर्ट की ज़रूरत नहीं';

  @override
  String get sampleBanner =>
      'यह एक सैंपल रिपोर्ट है, जो Alex और Mia की एक काल्पनिक चैट से बनी है। आपकी रिपोर्ट आपके अपने मैसेज से बनेगी।';

  @override
  String get sampleCta => 'मेरी चैट एनालाइज़ करें';

  @override
  String get pasteSheetTitle => 'बातचीत पेस्ट करें';

  @override
  String get pasteSheetSubtitle =>
      'किसी भी चैट से मैसेज कॉपी करें और यहाँ पेस्ट करें।';

  @override
  String get pasteSheetHint => '[21/03/24, 9:41 pm] Sam: हाय, जाग रहे हो?…';

  @override
  String get pasteSheetAction => 'यह चैट पढ़ें';

  @override
  String get guideTitle => 'अपनी चैट एक्सपोर्ट करें';

  @override
  String get guideSubtitle => 'WhatsApp में बस 30 सेकंड लगते हैं।';

  @override
  String get guideStep1Title => 'WhatsApp खोलें';

  @override
  String get guideStep1Detail =>
      'वह चैट खोलें जिसे आप एनालाइज़ करना चाहते हैं।';

  @override
  String get guideStep2Title =>
      '⋮ मेन्यू → ज़्यादा → चैट एक्सपोर्ट करें पर टैप करें';

  @override
  String get guideStep2Detail =>
      'iPhone पर: कॉन्टैक्ट के नाम पर टैप करें → चैट एक्सपोर्ट करें।';

  @override
  String get guideStep3Title => '\"मीडिया के बिना\" चुनें';

  @override
  String get guideStep3Detail => 'सिर्फ़ टेक्स्ट — छोटी फ़ाइल, तेज़ एनालिसिस।';

  @override
  String get guideStep4Title => '.txt सेव करें, फिर यहाँ लौटें';

  @override
  String get guideStep4Detail =>
      'फ़ाइलें / डाउनलोड में सेव करें, फिर यहाँ आकर उसे चुनें।';

  @override
  String get guideOpenWhatsApp => 'WhatsApp खोलें';

  @override
  String get guidePickFile => 'फ़ाइल मेरे पास है — चुनें';

  @override
  String get guidePrivacy =>
      'जब तक आप एनालाइज़ पर टैप नहीं करते, एक्सपोर्ट आपके फ़ोन से बाहर नहीं जाता।';

  @override
  String get guideOpenFailed => 'WhatsApp नहीं खुल पाया — क्या यह इंस्टॉल है?';

  @override
  String get setupTitle => 'यह चैट किसके साथ है?';

  @override
  String get setupSubtitle => 'आपका एक्सपोर्ट मिल गया — सब ठीक लग रहा है।';

  @override
  String setupChatWith(String name) {
    return '$name के साथ चैट';
  }

  @override
  String setupMessageCount(int count, String range) {
    return '$count मैसेज · $range';
  }

  @override
  String get setupWhichIsYou => 'इनमें से आप कौन हैं?';

  @override
  String get setupRelationship => 'रिश्ता';

  @override
  String get setupAnalyze => 'हमारी चैट एनालाइज़ करें';

  @override
  String get setupPrivacy => 'आप जो भी शेयर करेंगे, उसमें नाम छिपे रहेंगे।';

  @override
  String get relPartner => '💘 पार्टनर';

  @override
  String get relCrush => '👀 क्रश';

  @override
  String get relFriend => '🫶 दोस्त';

  @override
  String get relEx => '🌧 एक्स';

  @override
  String get relFamily => '🏡 परिवार';

  @override
  String get analyzing => 'एनालाइज़ हो रहा है';

  @override
  String get quip1 => 'मूड स्विंग्स महसूस कर रहे हैं…';

  @override
  String get quip2 => 'देर रात के मैसेज गिन रहे हैं…';

  @override
  String get quip3 => 'देख रहे हैं कि पहले गुड नाइट कौन कहता है…';

  @override
  String get quip4 => 'लाइनों के बीच छिपी बातें पढ़ रहे हैं…';

  @override
  String stageReading(int count) {
    return '$count मैसेज पढ़ रहे हैं';
  }

  @override
  String get stageCounting => 'देख रहे हैं कि पहले मैसेज कौन करता है';

  @override
  String get stageBetweenLines => 'अनकही बातें पढ़ रहे हैं';

  @override
  String get stageWriting => 'आपकी रिपोर्ट लिख रहे हैं';

  @override
  String get analyzingPrivacy =>
      'आपके मैसेज सिर्फ़ यह रिपोर्ट लिखने के लिए हमारे AI प्रोवाइडर को भेजे जाते हैं। हम उन्हें सेव नहीं करते।';

  @override
  String get consentTitle => 'एनालिसिस से पहले';

  @override
  String get consentBody =>
      'मैसेज की गिनती और रिप्लाई टाइम आपके फ़ोन पर ही निकाले जाते हैं। रिपोर्ट लिखने के लिए इस चैट का टेक्स्ट — दूसरे व्यक्ति के मैसेज और नाम समेत — एन्क्रिप्टेड कनेक्शन से हमारे AI प्रोवाइडर Z.ai को भेजा जाता है। हम इसे सेव नहीं करते। सिर्फ़ वही चैट एनालाइज़ करें जिनमें आप शामिल हैं।';

  @override
  String get consentAgree => 'सहमत, एनालाइज़ करें';

  @override
  String get consentCancel => 'अभी नहीं';

  @override
  String get errorTitle => 'कुछ गड़बड़ हो गई';

  @override
  String get errorRetry => 'फिर से कोशिश करें';

  @override
  String reportYouAnd(String name) {
    return 'आप और $name';
  }

  @override
  String reportMessages(int count) {
    return '$count मैसेज';
  }

  @override
  String get sectionWarmth => 'रिश्ते की गर्माहट';

  @override
  String get sectionBalance => 'बैलेंस';

  @override
  String get sectionEmotionCurve => 'इमोशन कर्व · महीने के हिसाब से';

  @override
  String get sectionTopics => 'आप किस बारे में बात करते हैं';

  @override
  String get sectionPersonalities => 'चैट पर्सनैलिटी';

  @override
  String get sectionFullReading => 'पूरी रीडिंग';

  @override
  String get sectionMilestones => 'खास पल';

  @override
  String get sectionAdvice => 'आगे के लिए';

  @override
  String get labelYou => 'आप';

  @override
  String get labelMessagesSent => 'भेजे गए मैसेज';

  @override
  String get labelWhoTextsFirst => 'पहले मैसेज कौन करता है';

  @override
  String get labelYourReplyTime => 'आपका रिप्लाई टाइम';

  @override
  String labelTheirReplyTime(String name) {
    return '$name का रिप्लाई टाइम';
  }

  @override
  String get curveNotEnough => 'कर्व बनाने के लिए अभी काफ़ी महीने नहीं हैं';

  @override
  String get shareTitle => 'अपनी स्टोरी शेयर करें';

  @override
  String get shareSubtitle => 'नाम अपने-आप इनिशियल्स में बदल जाते हैं।';

  @override
  String get shareAction => 'इमेज शेयर करें';

  @override
  String get sharePreparing => 'तैयार हो रहा है…';

  @override
  String shareFailed(String error) {
    return 'शेयर नहीं हो पाया: $error';
  }

  @override
  String get shareCardBrand => 'CHAT REPORT';

  @override
  String get shareCardWarmth => 'रिश्ते की गर्माहट';

  @override
  String get shareCardWatermark => 'CHAT REPORT से बनाया गया';

  @override
  String shareCardYears(int count) {
    return '$count साल की चैट';
  }

  @override
  String shareCardMonths(int count) {
    return '$count महीने की चैट';
  }

  @override
  String get shareCardOurChat => 'हमारी चैट';

  @override
  String shareCardMessages(int late) {
    return 'मैसेज · $late देर रात';
  }

  @override
  String shareCardStarted(String initial) {
    return 'बातचीत $initial ने शुरू की';
  }

  @override
  String get shareCardWarmestMonth => 'सबसे गर्माहट भरा महीना रहा';

  @override
  String get shareText => 'हमारी चैट, Chat Report की नज़र से';

  @override
  String parseUnrecognized(int count) {
    return 'एक्सपोर्ट फ़ॉर्मेट पहचाना नहीं जा सका (सिर्फ़ $count लाइनें पढ़ी गईं)';
  }

  @override
  String parseTooFew(int count) {
    return 'मैसेज काफ़ी नहीं हैं ($count) — पेस्ट वाला ऑप्शन आज़माएँ';
  }

  @override
  String errorAllChunksFailed(String detail) {
    return 'किसी भी महीने का एनालिसिस नहीं हो पाया। $detail';
  }

  @override
  String get errorNoConnection =>
      'एनालिसिस सर्विस से कनेक्ट नहीं हो पाया। अपना कनेक्शन चेक करके फिर से कोशिश करें।';

  @override
  String get errorServiceUnavailable =>
      'एनालिसिस सर्विस अभी उपलब्ध नहीं है। कृपया थोड़ी देर बाद फिर कोशिश करें।';

  @override
  String get errorEmptyResponse => 'एनालिसिस सर्विस से खाली जवाब मिला।';

  @override
  String get errorRateLimited =>
      'एनालिसिस सर्विस पर अभी बहुत ज़्यादा रिक्वेस्ट हैं। थोड़ी देर बाद फिर कोशिश करें।';

  @override
  String get unlockTitle => 'पूरी रिपोर्ट अनलॉक करें';

  @override
  String get unlockSubtitle =>
      'हर निष्कर्ष के पीछे के सटीक संदेशों के साथ गहन विश्लेषण, निजी सुझाव और इस रिपोर्ट के लिए AI कोच।';

  @override
  String get deepDiveTitle => 'गहन विश्लेषण';

  @override
  String get attachmentAnxious => 'चिंतित झुकाव';

  @override
  String get attachmentAvoidant => 'परहेज़ी झुकाव';

  @override
  String get attachmentSecure => 'सुरक्षित झुकाव';

  @override
  String get attachmentMixed => 'मिश्रित';

  @override
  String get deepDiveMissing =>
      'इस बार गहन विश्लेषण नहीं बन सका। फिर से कोशिश करने के लिए इस चैट का दोबारा विश्लेषण करें।';

  @override
  String get deepDiveSubtitle =>
      'जो मुफ़्त रिपोर्ट में नहीं है। हर निष्कर्ष के साथ वही मैसेज दिया गया है जिस पर वह आधारित है।';

  @override
  String get sectionConflict => 'झगड़े और सुलह';

  @override
  String get sectionRedFlags => 'चेतावनी के संकेत';

  @override
  String get sectionGreenFlags => 'अच्छे संकेत';

  @override
  String get sectionAttachment => 'लगाव की शैलियाँ';

  @override
  String get sectionTurningPoints => 'अहम मोड़';

  @override
  String deepDiveBuy(String price) {
    return '$price में अनलॉक करें';
  }

  @override
  String get deepDiveOneTime =>
      'इस रिपोर्ट के लिए एक बार का भुगतान। यह सदस्यता नहीं है।';

  @override
  String get deepDiveUnavailable =>
      'अभी खरीदारी उपलब्ध नहीं है। कृपया बाद में फिर कोशिश करें।';

  @override
  String get deepDivePending =>
      'आपका भुगतान लंबित है। पूरा होने पर यह रिपोर्ट अनलॉक हो जाएगी।';

  @override
  String get deepDiveFailed => 'खरीदारी पूरी नहीं हुई। कृपया फिर कोशिश करें।';

  @override
  String get deepDiveUseCredit => 'पहले से भुगतान किए गए क्रेडिट से अनलॉक करें';

  @override
  String get deepDiveDisclaimer =>
      'सोचने-समझने के लिए AI का विश्लेषण, कोई निदान नहीं।';

  @override
  String get deepDiveNoRedFlags =>
      'इन मैसेज में चेतावनी के कोई स्पष्ट संकेत नहीं हैं।';

  @override
  String get deepDiveNoGreenFlags =>
      'इन मैसेज में अच्छे संकेत स्पष्ट नहीं हैं।';

  @override
  String get attachmentLoopLabel => 'आप दोनों के बीच का पैटर्न';

  @override
  String get sampleDeepDiveHint =>
      'आपकी अपनी रिपोर्ट में यह हिस्सा शामिल होगा।';

  @override
  String get savedTitle => 'मेरी रिपोर्ट';

  @override
  String savedSubtitle(int count) {
    return 'इस फ़ोन पर $count सेव हैं';
  }

  @override
  String get savedNote =>
      'रिपोर्ट सिर्फ़ इस फ़ोन पर सेव होती हैं। ऐप अनइंस्टॉल करने पर वे मिट जाती हैं।';

  @override
  String get savedEmpty => 'अभी कोई रिपोर्ट सेव नहीं है।';

  @override
  String get savedDeleteTitle => 'यह रिपोर्ट मिटाएँ?';

  @override
  String get savedDeleteBody =>
      'इसे वापस नहीं लाया जा सकता। अगर आपने इसे पैसे देकर अनलॉक किया था, तो वह भी चला जाएगा।';

  @override
  String get savedDeleteConfirm => 'मिटाएँ';

  @override
  String get savedDeleteCancel => 'रखें';

  @override
  String get savedUnlockedBadge => 'गहन विश्लेषण अनलॉक हो गया';

  @override
  String get coachEntryTitle => 'AI कोच से पूछें';

  @override
  String get coachEntrySubtitle => 'इस रिपोर्ट के बारे में कुछ भी पूछें';

  @override
  String get coachTitle => 'AI कोच';

  @override
  String get coachDisclaimer =>
      'कोच एक AI है: यह गलत हो सकता है और पेशेवर मदद की जगह नहीं लेता।';

  @override
  String get coachHint => 'इस रिश्ते के बारे में पूछें…';

  @override
  String get coachSlow =>
      'AI को सामान्य से ज़्यादा समय लग रहा है। फिर से कोशिश कर रहे हैं…';

  @override
  String get coachSend => 'भेजें';

  @override
  String get coachSuggest1 => 'हम हमेशा एक ही बात पर क्यों झगड़ते हैं?';

  @override
  String get coachSuggest2 => 'मुश्किल बात कैसे शुरू करूँ?';

  @override
  String get coachSuggest3 => 'मुझे सबसे पहले किस पर काम करना चाहिए?';

  @override
  String coachLeft(int count) {
    return '$count सवाल बाकी हैं';
  }

  @override
  String get coachOutTitle => 'आपके मुफ़्त सवाल खत्म हो गए';

  @override
  String get coachOutBody =>
      'सवाल पूछते रहने के लिए यह रिपोर्ट अनलॉक करें। इसमें गहन विश्लेषण और निजी सुझाव भी शामिल हैं।';

  @override
  String get coachReportTitle => 'इस जवाब की शिकायत करें';

  @override
  String get coachReportOffensive => 'आपत्तिजनक या अनुचित';

  @override
  String get coachReportHarmful => 'नुकसानदेह या असुरक्षित सलाह';

  @override
  String get coachReportWrong => 'गलत या मनगढ़ंत';

  @override
  String get coachReportThanks => 'धन्यवाद, हमें आपकी शिकायत मिल गई है।';
}
