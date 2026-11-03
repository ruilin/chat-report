// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class LAr extends L {
  LAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Chat Report';

  @override
  String get tagline => 'ماذا تكشف محادثاتكم حقًا؟';

  @override
  String get homeImportTitle => 'استورد محادثة مُصدَّرة';

  @override
  String get homeImportSubtitle => 'تقرير كامل عن علاقتكم';

  @override
  String get homeImportHint => 'دليل خطوة بخطوة — يستغرق نحو 30 ثانية  ←';

  @override
  String get homePasteTitle => 'الصق محادثة';

  @override
  String get homePasteSubtitle => 'قراءة سريعة · مجانًا · 30 ثانية';

  @override
  String get homePrivacy =>
      'تُحسب الإحصاءات على هاتفك. ولكتابة تقريرك تُرسل رسائلك إلى مزوّد الذكاء الاصطناعي لدينا — ولا نحتفظ بها أبدًا.';

  @override
  String get pasteSheetTitle => 'الصق محادثة';

  @override
  String get pasteSheetSubtitle => 'انسخ رسائل من أي محادثة والصقها هنا.';

  @override
  String get pasteSheetHint =>
      '[21/03/24, 9:41 م] Sam: مرحبًا، هل أنت مستيقظ؟…';

  @override
  String get pasteSheetAction => 'اقرأ هذه المحادثة';

  @override
  String get guideTitle => 'صدِّر محادثتك';

  @override
  String get guideSubtitle => 'يستغرق نحو 30 ثانية في WhatsApp.';

  @override
  String get guideStep1Title => 'افتح WhatsApp';

  @override
  String get guideStep1Detail => 'ادخل إلى المحادثة التي تريد تحليلها.';

  @override
  String get guideStep2Title => 'اضغط على قائمة ⋮ ← المزيد ← تصدير الدردشة';

  @override
  String get guideStep2Detail =>
      'على iPhone: اضغط على اسم جهة الاتصال ← تصدير الدردشة.';

  @override
  String get guideStep3Title => 'اختر «بدون وسائط»';

  @override
  String get guideStep3Detail => 'نص فقط — ملف أصغر وتحليل أسرع.';

  @override
  String get guideStep4Title => 'احفظ ملف TXT ثم عُد إلى هنا';

  @override
  String get guideStep4Detail =>
      'احفظه في الملفات / التنزيلات، ثم عُد إلى هنا واختره.';

  @override
  String get guideOpenWhatsApp => 'افتح WhatsApp';

  @override
  String get guidePickFile => 'لديّ الملف — اختره';

  @override
  String get guidePrivacy => 'لا يغادر الملف المُصدَّر هاتفك حتى تضغط «حلّل».';

  @override
  String get guideOpenFailed => 'تعذّر فتح WhatsApp — هل هو مثبَّت؟';

  @override
  String get setupTitle => 'مع مَن هذه المحادثة؟';

  @override
  String get setupSubtitle => 'وجدنا الملف المُصدَّر — يبدو سليمًا.';

  @override
  String setupChatWith(String name) {
    return 'محادثة مع $name';
  }

  @override
  String setupMessageCount(int count, String range) {
    return 'عدد الرسائل: $count · $range';
  }

  @override
  String get setupWhichIsYou => 'أيّهما أنت؟';

  @override
  String get setupRelationship => 'نوع العلاقة';

  @override
  String get setupAnalyze => 'حلّل محادثتنا';

  @override
  String get setupPrivacy => 'تُخفى الأسماء في كل ما تشاركه.';

  @override
  String get relPartner => '💘 شريك';

  @override
  String get relCrush => '👀 إعجاب';

  @override
  String get relFriend => '🫶 صديق';

  @override
  String get relEx => '🌧 حبيب سابق';

  @override
  String get relFamily => '🏡 عائلة';

  @override
  String get analyzing => 'جارٍ التحليل';

  @override
  String get quip1 => 'نلتقط تقلّبات المزاج…';

  @override
  String get quip2 => 'نعدّ رسائل آخر الليل…';

  @override
  String get quip3 => 'نلاحظ مَن يقول «تصبح على خير» أولًا…';

  @override
  String get quip4 => 'نقرأ ما بين السطور…';

  @override
  String stageReading(int count) {
    return 'نقرأ $count رسالة';
  }

  @override
  String get stageCounting => 'نحسب مَن يبدأ الكلام أولًا';

  @override
  String get stageBetweenLines => 'نقرأ ما بين السطور';

  @override
  String get stageWriting => 'نكتب تقريرك';

  @override
  String get analyzingPrivacy =>
      'تُرسل رسائلك إلى مزوّد الذكاء الاصطناعي لدينا فقط لكتابة هذا التقرير. ولا نحتفظ بها.';

  @override
  String get consentTitle => 'قبل التحليل';

  @override
  String get consentBody =>
      'تُحسب الأعداد وأوقات الرد على هاتفك. ولكتابة تقريرك، يُرسل نص هذه المحادثة — بما في ذلك رسائل الطرف الآخر والأسماء — عبر اتصال مشفّر إلى مزوّد الذكاء الاصطناعي لدينا Z.ai. لا نحتفظ به. حلّل فقط المحادثات التي تشارك فيها.';

  @override
  String get consentAgree => 'موافق، حلّل';

  @override
  String get consentCancel => 'ليس الآن';

  @override
  String get errorTitle => 'حدث خطأ ما';

  @override
  String get errorRetry => 'حاول مجددًا';

  @override
  String reportYouAnd(String name) {
    return 'أنت و$name';
  }

  @override
  String reportMessages(int count) {
    return '$count رسالة';
  }

  @override
  String get sectionWarmth => 'دفء العلاقة';

  @override
  String get sectionBalance => 'التوازن';

  @override
  String get sectionEmotionCurve => 'منحنى المشاعر · شهريًا';

  @override
  String get sectionTopics => 'عمّ تتحدثان';

  @override
  String get sectionPersonalities => 'شخصيات المحادثة';

  @override
  String get sectionFullReading => 'القراءة الكاملة';

  @override
  String get sectionMilestones => 'محطات مهمة';

  @override
  String get sectionAdvice => 'زادٌ للطريق';

  @override
  String get labelYou => 'أنت';

  @override
  String get labelMessagesSent => 'الرسائل المُرسلة';

  @override
  String get labelWhoTextsFirst => 'مَن يبدأ أولًا';

  @override
  String get labelYourReplyTime => 'مدة ردّك';

  @override
  String labelTheirReplyTime(String name) {
    return 'مدة ردّ $name';
  }

  @override
  String get curveNotEnough => 'لا توجد أشهر كافية لرسم المنحنى بعد';

  @override
  String get shareTitle => 'شارك قصتك';

  @override
  String get shareSubtitle => 'تُختصر الأسماء إلى أحرفها الأولى تلقائيًا.';

  @override
  String get shareAction => 'شارك الصورة';

  @override
  String get sharePreparing => 'جارٍ التجهيز…';

  @override
  String shareFailed(String error) {
    return 'تعذّرت المشاركة: $error';
  }

  @override
  String get shareCardBrand => 'CHAT REPORT';

  @override
  String get shareCardWarmth => 'دفء العلاقة';

  @override
  String get shareCardWatermark => 'صُنع بواسطة CHAT REPORT';

  @override
  String shareCardYears(int count) {
    return '$count سنة من الرسائل';
  }

  @override
  String shareCardMonths(int count) {
    return '$count شهر من الرسائل';
  }

  @override
  String get shareCardOurChat => 'محادثتنا';

  @override
  String shareCardMessages(int late) {
    return 'رسالة · $late في آخر الليل';
  }

  @override
  String shareCardStarted(String initial) {
    return 'من المحادثات بدأها $initial';
  }

  @override
  String get shareCardWarmestMonth => 'كان الشهر الأدفأ';

  @override
  String get shareText => 'محادثتنا كما قرأها Chat Report';

  @override
  String parseUnrecognized(int count) {
    return 'تعذّر التعرّف على صيغة الملف (عدد الأسطر المقروءة: $count فقط)';
  }

  @override
  String parseTooFew(int count) {
    return 'الرسائل غير كافية ($count) — جرّب خيار اللصق بدلًا من ذلك';
  }

  @override
  String errorAllChunksFailed(String detail) {
    return 'فشل التحليل في كل الأشهر. $detail';
  }

  @override
  String get errorNoConnection =>
      'تعذّر الوصول إلى خدمة التحليل. تحقّق من اتصالك وحاول مجددًا.';

  @override
  String get errorEmptyResponse => 'أعادت خدمة التحليل ردًّا فارغًا.';

  @override
  String get errorRateLimited =>
      'خدمة التحليل تتلقى طلبات كثيرة حاليًا. حاول مجددًا بعد قليل.';
}
