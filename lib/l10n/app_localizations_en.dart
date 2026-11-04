// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class LEn extends L {
  LEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Chat Report';

  @override
  String get tagline => 'What\'s really in your chats?';

  @override
  String get homeImportTitle => 'Import a chat export';

  @override
  String get homeImportSubtitle => 'Full relationship report';

  @override
  String get homeImportHint =>
      'Step-by-step guide inside — takes about 30 seconds  →';

  @override
  String get homePasteTitle => 'Paste a conversation';

  @override
  String get homePasteSubtitle => 'Quick read · free · 30 seconds';

  @override
  String get homePrivacy =>
      'Stats are calculated on your phone. To write your report, your messages go to our AI provider — we never keep them.';

  @override
  String get homeSampleTitle => 'See a sample report first';

  @override
  String get homeSampleSubtitle =>
      'Made from a made-up chat · no export needed';

  @override
  String get sampleBanner =>
      'This is a sample report, made from a made-up chat between Alex and Mia. Yours will be built from your own messages.';

  @override
  String get sampleCta => 'Analyze my own chat';

  @override
  String get pasteSheetTitle => 'Paste a conversation';

  @override
  String get pasteSheetSubtitle =>
      'Copy messages from any chat and paste them here.';

  @override
  String get pasteSheetHint => '[21/03/24, 9:41 PM] Sam: hey, you up?…';

  @override
  String get pasteSheetAction => 'Read this chat';

  @override
  String get guideTitle => 'Export your chat';

  @override
  String get guideSubtitle => 'Takes about 30 seconds in WhatsApp.';

  @override
  String get guideStep1Title => 'Open WhatsApp';

  @override
  String get guideStep1Detail => 'Go to the chat you want to analyze.';

  @override
  String get guideStep2Title => 'Tap the ⋮ menu → More → Export chat';

  @override
  String get guideStep2Detail =>
      'On iPhone: tap the contact name → Export Chat.';

  @override
  String get guideStep3Title => 'Choose \"Without media\"';

  @override
  String get guideStep3Detail => 'Text only — smaller file, faster analysis.';

  @override
  String get guideStep4Title => 'Save the .txt, then come back';

  @override
  String get guideStep4Detail =>
      'Save to Files / Downloads, return here and pick it.';

  @override
  String get guideOpenWhatsApp => 'Open WhatsApp';

  @override
  String get guidePickFile => 'I have the file — pick it';

  @override
  String get guidePrivacy =>
      'The export never leaves your phone until you tap Analyze.';

  @override
  String get guideOpenFailed => 'Couldn\'t open WhatsApp — is it installed?';

  @override
  String get setupTitle => 'Who is this chat with?';

  @override
  String get setupSubtitle => 'We found your export — looks good.';

  @override
  String setupChatWith(String name) {
    return 'Chat with $name';
  }

  @override
  String setupMessageCount(int count, String range) {
    return '$count messages · $range';
  }

  @override
  String get setupWhichIsYou => 'Which one is you?';

  @override
  String get setupRelationship => 'Relationship';

  @override
  String get setupAnalyze => 'Analyze our chat';

  @override
  String get setupPrivacy => 'Names are anonymized in anything you share.';

  @override
  String get relPartner => '💘 Partner';

  @override
  String get relCrush => '👀 Crush';

  @override
  String get relFriend => '🫶 Friend';

  @override
  String get relEx => '🌧 Ex';

  @override
  String get relFamily => '🏡 Family';

  @override
  String get analyzing => 'ANALYZING';

  @override
  String get quip1 => 'Feeling the mood swings…';

  @override
  String get quip2 => 'Counting the late-night texts…';

  @override
  String get quip3 => 'Noticing who says goodnight first…';

  @override
  String get quip4 => 'Reading between the lines…';

  @override
  String stageReading(int count) {
    return 'Reading $count messages';
  }

  @override
  String get stageCounting => 'Counting who texts first';

  @override
  String get stageBetweenLines => 'Reading between the lines';

  @override
  String get stageWriting => 'Writing your report';

  @override
  String get analyzingPrivacy =>
      'Your messages are sent to our AI provider only to write this report. We don\'t keep them.';

  @override
  String get consentTitle => 'Before we analyze';

  @override
  String get consentBody =>
      'Counts and reply times are calculated on your phone. To write your report, the text of this chat — including the other person\'s messages and names — is sent over an encrypted connection to our AI provider, Z.ai. We don\'t store it. Only analyze chats you\'re part of.';

  @override
  String get consentAgree => 'Agree & analyze';

  @override
  String get consentCancel => 'Not now';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get errorRetry => 'Try again';

  @override
  String reportYouAnd(String name) {
    return 'You & $name';
  }

  @override
  String reportMessages(int count) {
    return '$count messages';
  }

  @override
  String get sectionWarmth => 'Relationship warmth';

  @override
  String get sectionBalance => 'Balance';

  @override
  String get sectionEmotionCurve => 'Emotion curve · by month';

  @override
  String get sectionTopics => 'What you talk about';

  @override
  String get sectionPersonalities => 'Chat personalities';

  @override
  String get sectionFullReading => 'The full reading';

  @override
  String get sectionMilestones => 'Milestones';

  @override
  String get sectionAdvice => 'For the road';

  @override
  String get labelYou => 'You';

  @override
  String get labelMessagesSent => 'Messages sent';

  @override
  String get labelWhoTextsFirst => 'Who texts first';

  @override
  String get labelYourReplyTime => 'YOUR REPLY TIME';

  @override
  String labelTheirReplyTime(String name) {
    return '$name\'S REPLY TIME';
  }

  @override
  String get curveNotEnough => 'Not enough months for a curve yet';

  @override
  String get shareTitle => 'Share your story';

  @override
  String get shareSubtitle => 'Names are shortened to initials automatically.';

  @override
  String get shareAction => 'Share image';

  @override
  String get sharePreparing => 'Preparing…';

  @override
  String shareFailed(String error) {
    return 'Share failed: $error';
  }

  @override
  String get shareCardBrand => 'CHAT REPORT';

  @override
  String get shareCardWarmth => 'RELATIONSHIP WARMTH';

  @override
  String get shareCardWatermark => 'MADE WITH CHAT REPORT';

  @override
  String shareCardYears(int count) {
    return '$count years of texts';
  }

  @override
  String shareCardMonths(int count) {
    return '$count months of texts';
  }

  @override
  String get shareCardOurChat => 'our chat';

  @override
  String shareCardMessages(int late) {
    return 'messages · $late late-night';
  }

  @override
  String shareCardStarted(String initial) {
    return 'of conversations started by $initial';
  }

  @override
  String get shareCardWarmestMonth => 'was the warmest month';

  @override
  String get shareText => 'Our chat, read by Chat Report';

  @override
  String parseUnrecognized(int count) {
    return 'Couldn\'t recognize the export format (only $count lines parsed)';
  }

  @override
  String parseTooFew(int count) {
    return 'Not enough messages ($count) — try the paste option instead';
  }

  @override
  String errorAllChunksFailed(String detail) {
    return 'Analysis failed for every month. $detail';
  }

  @override
  String get errorNoConnection =>
      'Couldn\'t reach the analysis service. Check your connection and try again.';

  @override
  String get errorServiceUnavailable =>
      'The analysis service is temporarily unavailable. Please try again later.';

  @override
  String get errorEmptyResponse =>
      'The analysis service returned an empty response.';

  @override
  String get errorRateLimited =>
      'The analysis service is rate-limiting requests. Please try again shortly.';

  @override
  String get deepDiveTitle => 'Deep dive';

  @override
  String get attachmentAnxious => 'Anxious-leaning';

  @override
  String get attachmentAvoidant => 'Avoidant-leaning';

  @override
  String get attachmentSecure => 'Secure-leaning';

  @override
  String get attachmentMixed => 'Mixed';

  @override
  String get deepDiveMissing =>
      'The deep dive couldn\'t be generated this time. Analyze this chat again to retry.';

  @override
  String get deepDiveSubtitle =>
      'What the free report doesn\'t cover. Every finding comes with the exact message behind it.';

  @override
  String get sectionConflict => 'Fights and making up';

  @override
  String get sectionRedFlags => 'Red flags';

  @override
  String get sectionGreenFlags => 'Green flags';

  @override
  String get sectionAttachment => 'Attachment styles';

  @override
  String get sectionTurningPoints => 'Turning points';

  @override
  String deepDiveBuy(String price) {
    return 'Unlock for $price';
  }

  @override
  String get deepDiveOneTime =>
      'One-time payment for this report. Not a subscription.';

  @override
  String get deepDiveUnavailable =>
      'Purchases aren\'t available right now. Please try again later.';

  @override
  String get deepDivePending =>
      'Your payment is pending. This report unlocks once it goes through.';

  @override
  String get deepDiveFailed =>
      'The purchase didn\'t complete. Please try again.';

  @override
  String get deepDiveUseCredit => 'Unlock with your prepaid credit';

  @override
  String get deepDiveDisclaimer =>
      'An AI reading for reflection, not a diagnosis.';

  @override
  String get deepDiveNoRedFlags => 'No clear red flags in these messages.';

  @override
  String get deepDiveNoGreenFlags => 'No clear green flags in these messages.';

  @override
  String get attachmentLoopLabel => 'The pattern between you';

  @override
  String get sampleDeepDiveHint => 'Your own report will include this section.';

  @override
  String get savedTitle => 'My reports';

  @override
  String savedSubtitle(int count) {
    return '$count saved on this phone';
  }

  @override
  String get savedNote =>
      'Reports are saved only on this phone. Uninstalling the app deletes them.';

  @override
  String get savedEmpty => 'No saved reports yet.';

  @override
  String get savedDeleteTitle => 'Delete this report?';

  @override
  String get savedDeleteBody =>
      'It can\'t be recovered. If you paid to unlock it, that unlock is lost too.';

  @override
  String get savedDeleteConfirm => 'Delete';

  @override
  String get savedDeleteCancel => 'Keep';

  @override
  String get savedUnlockedBadge => 'Deep dive unlocked';

  @override
  String get coachEntryTitle => 'Ask the AI coach';

  @override
  String get coachEntrySubtitle => 'Ask anything about this report';

  @override
  String get coachTitle => 'AI coach';

  @override
  String get coachDisclaimer =>
      'The coach is an AI: it can be wrong and doesn\'t replace professional help.';

  @override
  String get coachHint => 'Ask about this relationship…';

  @override
  String get coachSlow => 'The AI is taking longer than usual. Trying again…';

  @override
  String get coachSend => 'Send';

  @override
  String get coachSuggest1 => 'Why do we keep having the same fight?';

  @override
  String get coachSuggest2 => 'How can I bring up something hard?';

  @override
  String get coachSuggest3 => 'What should I work on first?';

  @override
  String coachLeft(int count) {
    return '$count questions left';
  }

  @override
  String get coachOutTitle => 'You\'re out of questions';

  @override
  String coachOutBody(int count) {
    return 'Get $count more to use on any of your reports.';
  }

  @override
  String coachBuy(int count, String price) {
    return '$count questions for $price';
  }

  @override
  String get coachBuyNote => 'One-time payment. Not a subscription.';

  @override
  String get coachPending =>
      'Your payment is pending. Your questions will be added once it goes through.';

  @override
  String get coachReportTitle => 'Report this answer';

  @override
  String get coachReportOffensive => 'Offensive or inappropriate';

  @override
  String get coachReportHarmful => 'Harmful or unsafe advice';

  @override
  String get coachReportWrong => 'Wrong or made up';

  @override
  String get coachReportThanks => 'Thanks, we\'ve received your report.';
}
