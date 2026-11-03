// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class LZh extends L {
  LZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Chat Report';

  @override
  String get tagline => '你们的聊天，到底说明了什么？';

  @override
  String get homeImportTitle => '导入聊天记录';

  @override
  String get homeImportSubtitle => '生成完整关系报告';

  @override
  String get homeImportHint => '内含分步引导 —— 约 30 秒完成  →';

  @override
  String get homePasteTitle => '粘贴一段对话';

  @override
  String get homePasteSubtitle => '快读 · 免费 · 30 秒';

  @override
  String get homePrivacy => '统计在你的手机上完成。为了生成报告，聊天内容会发送给我们的 AI 服务商，我们不留存。';

  @override
  String get pasteSheetTitle => '粘贴一段对话';

  @override
  String get pasteSheetSubtitle => '从任意聊天软件复制消息，粘贴到这里。';

  @override
  String get pasteSheetHint => '[21/03/24, 21:41] Sam: 在吗？';

  @override
  String get pasteSheetAction => '读一读这段对话';

  @override
  String get guideTitle => '导出你的聊天记录';

  @override
  String get guideSubtitle => '在 WhatsApp 里约 30 秒完成。';

  @override
  String get guideStep1Title => '打开 WhatsApp';

  @override
  String get guideStep1Detail => '进入你想分析的那段对话。';

  @override
  String get guideStep2Title => '点 ⋮ 菜单 → 更多 → 导出聊天';

  @override
  String get guideStep2Detail => 'iPhone：点顶部联系人名字 → 导出聊天。';

  @override
  String get guideStep3Title => '选择「不含媒体文件」';

  @override
  String get guideStep3Detail => '只导出文字 —— 文件更小，分析更快。';

  @override
  String get guideStep4Title => '保存 .txt 后回到这里';

  @override
  String get guideStep4Detail => '存到「文件」或「下载」，回来选中它。';

  @override
  String get guideOpenWhatsApp => '打开 WhatsApp';

  @override
  String get guidePickFile => '已有文件 —— 去选择';

  @override
  String get guidePrivacy => '在你点「分析」之前，导出文件不会离开手机。';

  @override
  String get guideOpenFailed => '无法打开 WhatsApp —— 是否已安装？';

  @override
  String get setupTitle => '这段对话是和谁的？';

  @override
  String get setupSubtitle => '已找到你的导出文件，格式没问题。';

  @override
  String setupChatWith(String name) {
    return '与 $name 的对话';
  }

  @override
  String setupMessageCount(int count, String range) {
    return '$count 条消息 · $range';
  }

  @override
  String get setupWhichIsYou => '哪个是你？';

  @override
  String get setupRelationship => '关系类型';

  @override
  String get setupAnalyze => '开始分析';

  @override
  String get setupPrivacy => '分享内容中的姓名会自动匿名化。';

  @override
  String get relPartner => '💘 伴侣';

  @override
  String get relCrush => '👀 暧昧';

  @override
  String get relFriend => '🫶 好友';

  @override
  String get relEx => '🌧 前任';

  @override
  String get relFamily => '🏡 家人';

  @override
  String get analyzing => '分析中';

  @override
  String get quip1 => '正在感受情绪的起伏……';

  @override
  String get quip2 => '正在数那些深夜的消息……';

  @override
  String get quip3 => '看看谁总是先说晚安……';

  @override
  String get quip4 => '正在读出字里行间的意思……';

  @override
  String stageReading(int count) {
    return '读取 $count 条消息';
  }

  @override
  String get stageCounting => '统计谁更常先开口';

  @override
  String get stageBetweenLines => '读出言外之意';

  @override
  String get stageWriting => '撰写你的报告';

  @override
  String get analyzingPrivacy => '聊天内容仅发送给 AI 服务商用于生成本次报告，我们不留存。';

  @override
  String get consentTitle => '分析前请确认';

  @override
  String get consentBody =>
      '消息数、回复时长等统计在你的手机上完成。为了生成报告，这段聊天的文字（包括对方的消息和双方名字）会经加密连接发送给我们的 AI 服务商 Z.ai（智谱）。我们不保存这些内容。请只分析你本人参与的聊天。';

  @override
  String get consentAgree => '同意并分析';

  @override
  String get consentCancel => '暂不';

  @override
  String get errorTitle => '出了点问题';

  @override
  String get errorRetry => '重试';

  @override
  String reportYouAnd(String name) {
    return '你和 $name';
  }

  @override
  String reportMessages(int count) {
    return '$count 条消息';
  }

  @override
  String get sectionWarmth => '关系温度';

  @override
  String get sectionBalance => '互动平衡';

  @override
  String get sectionEmotionCurve => '情绪曲线 · 逐月';

  @override
  String get sectionTopics => '你们都聊些什么';

  @override
  String get sectionPersonalities => '聊天人格';

  @override
  String get sectionFullReading => '深度解读';

  @override
  String get sectionMilestones => '关系里程碑';

  @override
  String get sectionAdvice => '给你的建议';

  @override
  String get labelYou => '你';

  @override
  String get labelMessagesSent => '消息条数';

  @override
  String get labelWhoTextsFirst => '谁更常先开口';

  @override
  String get labelYourReplyTime => '你的回复时长';

  @override
  String labelTheirReplyTime(String name) {
    return '$name 的回复时长';
  }

  @override
  String get curveNotEnough => '月份太少，还画不出曲线';

  @override
  String get shareTitle => '分享你们的故事';

  @override
  String get shareSubtitle => '姓名会自动缩写为首字母。';

  @override
  String get shareAction => '分享图片';

  @override
  String get sharePreparing => '生成中……';

  @override
  String shareFailed(String error) {
    return '分享失败：$error';
  }

  @override
  String get shareCardBrand => 'CHAT REPORT';

  @override
  String get shareCardWarmth => '关系温度';

  @override
  String get shareCardWatermark => '由 CHAT REPORT 生成';

  @override
  String shareCardYears(int count) {
    return '$count 年的聊天';
  }

  @override
  String shareCardMonths(int count) {
    return '$count 个月的聊天';
  }

  @override
  String get shareCardOurChat => '我们的聊天';

  @override
  String shareCardMessages(int late) {
    return '条消息 · $late 条深夜';
  }

  @override
  String shareCardStarted(String initial) {
    return '的对话由 $initial 先开口';
  }

  @override
  String get shareCardWarmestMonth => '是最温暖的月份';

  @override
  String get shareText => '我们的聊天，由 Chat Report 解读';

  @override
  String parseUnrecognized(int count) {
    return '无法识别导出格式（仅解析到 $count 条）';
  }

  @override
  String parseTooFew(int count) {
    return '有效消息不足（$count 条），试试粘贴入口';
  }

  @override
  String errorAllChunksFailed(String detail) {
    return '所有月份的分析都失败了。$detail';
  }

  @override
  String get errorNoConnection => '无法连接分析服务，请检查网络后重试。';

  @override
  String get errorServiceUnavailable => '分析服务暂时不可用，请稍后再试。';

  @override
  String get errorEmptyResponse => '分析服务返回了空内容。';

  @override
  String get errorRateLimited => '分析服务正在限流，请稍后重试。';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class LZhHant extends LZh {
  LZhHant() : super('zh_Hant');

  @override
  String get appTitle => 'Chat Report';

  @override
  String get tagline => '你們的對話，到底說明了什麼？';

  @override
  String get homeImportTitle => '匯入聊天紀錄';

  @override
  String get homeImportSubtitle => '產生完整關係報告';

  @override
  String get homeImportHint => '內含逐步引導 —— 約 30 秒完成  →';

  @override
  String get homePasteTitle => '貼上一段對話';

  @override
  String get homePasteSubtitle => '快讀 · 免費 · 30 秒';

  @override
  String get homePrivacy => '統計在你的手機上完成。為了產生報告，聊天內容會傳送給我們的 AI 服務商，我們不留存。';

  @override
  String get pasteSheetTitle => '貼上一段對話';

  @override
  String get pasteSheetSubtitle => '從任何聊天軟體複製訊息，貼到這裡。';

  @override
  String get pasteSheetHint => '[21/03/24, 21:41] Sam: 在嗎？';

  @override
  String get pasteSheetAction => '讀讀這段對話';

  @override
  String get guideTitle => '匯出你的聊天紀錄';

  @override
  String get guideSubtitle => '在 WhatsApp 裡約 30 秒完成。';

  @override
  String get guideStep1Title => '開啟 WhatsApp';

  @override
  String get guideStep1Detail => '進入你想分析的那段對話。';

  @override
  String get guideStep2Title => '點 ⋮ 選單 → 更多 → 匯出聊天';

  @override
  String get guideStep2Detail => 'iPhone：點頂端聯絡人名稱 → 匯出聊天。';

  @override
  String get guideStep3Title => '選擇「不含媒體檔案」';

  @override
  String get guideStep3Detail => '只匯出文字 —— 檔案更小，分析更快。';

  @override
  String get guideStep4Title => '儲存 .txt 後回到這裡';

  @override
  String get guideStep4Detail => '存到「檔案」或「下載」，回來選取它。';

  @override
  String get guideOpenWhatsApp => '開啟 WhatsApp';

  @override
  String get guidePickFile => '已有檔案 —— 去選取';

  @override
  String get guidePrivacy => '在你點「分析」之前，匯出檔案不會離開手機。';

  @override
  String get guideOpenFailed => '無法開啟 WhatsApp —— 是否已安裝？';

  @override
  String get setupTitle => '這段對話是和誰的？';

  @override
  String get setupSubtitle => '已找到你的匯出檔案，格式沒問題。';

  @override
  String setupChatWith(String name) {
    return '與 $name 的對話';
  }

  @override
  String setupMessageCount(int count, String range) {
    return '$count 則訊息 · $range';
  }

  @override
  String get setupWhichIsYou => '哪一個是你？';

  @override
  String get setupRelationship => '關係類型';

  @override
  String get setupAnalyze => '開始分析';

  @override
  String get setupPrivacy => '分享內容中的姓名會自動匿名化。';

  @override
  String get relPartner => '💘 伴侶';

  @override
  String get relCrush => '👀 曖昧';

  @override
  String get relFriend => '🫶 好友';

  @override
  String get relEx => '🌧 前任';

  @override
  String get relFamily => '🏡 家人';

  @override
  String get analyzing => '分析中';

  @override
  String get quip1 => '正在感受情緒的起伏……';

  @override
  String get quip2 => '正在數那些深夜的訊息……';

  @override
  String get quip3 => '看看誰總是先說晚安……';

  @override
  String get quip4 => '正在讀出字裡行間的意思……';

  @override
  String stageReading(int count) {
    return '讀取 $count 則訊息';
  }

  @override
  String get stageCounting => '統計誰更常先開口';

  @override
  String get stageBetweenLines => '讀出言外之意';

  @override
  String get stageWriting => '撰寫你的報告';

  @override
  String get analyzingPrivacy => '聊天內容僅傳送給 AI 服務商用於產生本次報告，我們不留存。';

  @override
  String get consentTitle => '分析前請確認';

  @override
  String get consentBody =>
      '訊息數、回覆時間等統計在你的手機上完成。為了產生報告，這段聊天的文字（包括對方的訊息和雙方名字）會經加密連線傳送給我們的 AI 服務商 Z.ai（智譜）。我們不儲存這些內容。請只分析你本人參與的聊天。';

  @override
  String get consentAgree => '同意並分析';

  @override
  String get consentCancel => '暫不';

  @override
  String get errorTitle => '出了點問題';

  @override
  String get errorRetry => '重試';

  @override
  String reportYouAnd(String name) {
    return '你和 $name';
  }

  @override
  String reportMessages(int count) {
    return '$count 則訊息';
  }

  @override
  String get sectionWarmth => '關係溫度';

  @override
  String get sectionBalance => '互動平衡';

  @override
  String get sectionEmotionCurve => '情緒曲線 · 逐月';

  @override
  String get sectionTopics => '你們都聊些什麼';

  @override
  String get sectionPersonalities => '聊天人格';

  @override
  String get sectionFullReading => '深度解讀';

  @override
  String get sectionMilestones => '關係里程碑';

  @override
  String get sectionAdvice => '給你的建議';

  @override
  String get labelYou => '你';

  @override
  String get labelMessagesSent => '訊息則數';

  @override
  String get labelWhoTextsFirst => '誰更常先開口';

  @override
  String get labelYourReplyTime => '你的回覆時間';

  @override
  String labelTheirReplyTime(String name) {
    return '$name 的回覆時間';
  }

  @override
  String get curveNotEnough => '月份太少，還畫不出曲線';

  @override
  String get shareTitle => '分享你們的故事';

  @override
  String get shareSubtitle => '姓名會自動縮寫為首字母。';

  @override
  String get shareAction => '分享圖片';

  @override
  String get sharePreparing => '產生中……';

  @override
  String shareFailed(String error) {
    return '分享失敗：$error';
  }

  @override
  String get shareCardBrand => 'CHAT REPORT';

  @override
  String get shareCardWarmth => '關係溫度';

  @override
  String get shareCardWatermark => '由 CHAT REPORT 產生';

  @override
  String shareCardYears(int count) {
    return '$count 年的對話';
  }

  @override
  String shareCardMonths(int count) {
    return '$count 個月的對話';
  }

  @override
  String get shareCardOurChat => '我們的對話';

  @override
  String shareCardMessages(int late) {
    return '則訊息 · $late 則深夜';
  }

  @override
  String shareCardStarted(String initial) {
    return '的對話由 $initial 先開口';
  }

  @override
  String get shareCardWarmestMonth => '是最溫暖的月份';

  @override
  String get shareText => '我們的對話，由 Chat Report 解讀';

  @override
  String parseUnrecognized(int count) {
    return '無法辨識匯出格式（僅解析到 $count 則）';
  }

  @override
  String parseTooFew(int count) {
    return '有效訊息不足（$count 則），試試貼上入口';
  }

  @override
  String errorAllChunksFailed(String detail) {
    return '所有月份的分析都失敗了。$detail';
  }

  @override
  String get errorNoConnection => '無法連線分析服務，請檢查網路後重試。';

  @override
  String get errorServiceUnavailable => '分析服務暫時無法使用，請稍後再試。';

  @override
  String get errorEmptyResponse => '分析服務回傳了空內容。';

  @override
  String get errorRateLimited => '分析服務正在限流，請稍後重試。';
}
