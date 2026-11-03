import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L
/// returned by `L.of(context)`.
///
/// Applications need to include `L.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L.localizationsDelegates,
///   supportedLocales: L.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L.supportedLocales
/// property.
abstract class L {
  L(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L of(BuildContext context) {
    return Localizations.of<L>(context, L)!;
  }

  static const LocalizationsDelegate<L> delegate = _LDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('it'),
    Locale('pt'),
    Locale('tr'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat Report'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'What\'s really in your chats?'**
  String get tagline;

  /// No description provided for @homeImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import a chat export'**
  String get homeImportTitle;

  /// No description provided for @homeImportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Full relationship report'**
  String get homeImportSubtitle;

  /// No description provided for @homeImportHint.
  ///
  /// In en, this message translates to:
  /// **'Step-by-step guide inside — takes about 30 seconds  →'**
  String get homeImportHint;

  /// No description provided for @homePasteTitle.
  ///
  /// In en, this message translates to:
  /// **'Paste a conversation'**
  String get homePasteTitle;

  /// No description provided for @homePasteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quick read · free · 30 seconds'**
  String get homePasteSubtitle;

  /// No description provided for @homePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Stats are calculated on your phone. To write your report, your messages go to our AI provider — we never keep them.'**
  String get homePrivacy;

  /// No description provided for @pasteSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Paste a conversation'**
  String get pasteSheetTitle;

  /// No description provided for @pasteSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Copy messages from any chat and paste them here.'**
  String get pasteSheetSubtitle;

  /// No description provided for @pasteSheetHint.
  ///
  /// In en, this message translates to:
  /// **'[21/03/24, 9:41 PM] Sam: hey, you up?…'**
  String get pasteSheetHint;

  /// No description provided for @pasteSheetAction.
  ///
  /// In en, this message translates to:
  /// **'Read this chat'**
  String get pasteSheetAction;

  /// No description provided for @guideTitle.
  ///
  /// In en, this message translates to:
  /// **'Export your chat'**
  String get guideTitle;

  /// No description provided for @guideSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Takes about 30 seconds in WhatsApp.'**
  String get guideSubtitle;

  /// No description provided for @guideStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Open WhatsApp'**
  String get guideStep1Title;

  /// No description provided for @guideStep1Detail.
  ///
  /// In en, this message translates to:
  /// **'Go to the chat you want to analyze.'**
  String get guideStep1Detail;

  /// No description provided for @guideStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Tap the ⋮ menu → More → Export chat'**
  String get guideStep2Title;

  /// No description provided for @guideStep2Detail.
  ///
  /// In en, this message translates to:
  /// **'On iPhone: tap the contact name → Export Chat.'**
  String get guideStep2Detail;

  /// No description provided for @guideStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Choose \"Without media\"'**
  String get guideStep3Title;

  /// No description provided for @guideStep3Detail.
  ///
  /// In en, this message translates to:
  /// **'Text only — smaller file, faster analysis.'**
  String get guideStep3Detail;

  /// No description provided for @guideStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Save the .txt, then come back'**
  String get guideStep4Title;

  /// No description provided for @guideStep4Detail.
  ///
  /// In en, this message translates to:
  /// **'Save to Files / Downloads, return here and pick it.'**
  String get guideStep4Detail;

  /// No description provided for @guideOpenWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Open WhatsApp'**
  String get guideOpenWhatsApp;

  /// No description provided for @guidePickFile.
  ///
  /// In en, this message translates to:
  /// **'I have the file — pick it'**
  String get guidePickFile;

  /// No description provided for @guidePrivacy.
  ///
  /// In en, this message translates to:
  /// **'The export never leaves your phone until you tap Analyze.'**
  String get guidePrivacy;

  /// No description provided for @guideOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open WhatsApp — is it installed?'**
  String get guideOpenFailed;

  /// No description provided for @setupTitle.
  ///
  /// In en, this message translates to:
  /// **'Who is this chat with?'**
  String get setupTitle;

  /// No description provided for @setupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We found your export — looks good.'**
  String get setupSubtitle;

  /// No description provided for @setupChatWith.
  ///
  /// In en, this message translates to:
  /// **'Chat with {name}'**
  String setupChatWith(String name);

  /// No description provided for @setupMessageCount.
  ///
  /// In en, this message translates to:
  /// **'{count} messages · {range}'**
  String setupMessageCount(int count, String range);

  /// No description provided for @setupWhichIsYou.
  ///
  /// In en, this message translates to:
  /// **'Which one is you?'**
  String get setupWhichIsYou;

  /// No description provided for @setupRelationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get setupRelationship;

  /// No description provided for @setupAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Analyze our chat'**
  String get setupAnalyze;

  /// No description provided for @setupPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Names are anonymized in anything you share.'**
  String get setupPrivacy;

  /// No description provided for @relPartner.
  ///
  /// In en, this message translates to:
  /// **'💘 Partner'**
  String get relPartner;

  /// No description provided for @relCrush.
  ///
  /// In en, this message translates to:
  /// **'👀 Crush'**
  String get relCrush;

  /// No description provided for @relFriend.
  ///
  /// In en, this message translates to:
  /// **'🫶 Friend'**
  String get relFriend;

  /// No description provided for @relEx.
  ///
  /// In en, this message translates to:
  /// **'🌧 Ex'**
  String get relEx;

  /// No description provided for @relFamily.
  ///
  /// In en, this message translates to:
  /// **'🏡 Family'**
  String get relFamily;

  /// No description provided for @analyzing.
  ///
  /// In en, this message translates to:
  /// **'ANALYZING'**
  String get analyzing;

  /// No description provided for @quip1.
  ///
  /// In en, this message translates to:
  /// **'Feeling the mood swings…'**
  String get quip1;

  /// No description provided for @quip2.
  ///
  /// In en, this message translates to:
  /// **'Counting the late-night texts…'**
  String get quip2;

  /// No description provided for @quip3.
  ///
  /// In en, this message translates to:
  /// **'Noticing who says goodnight first…'**
  String get quip3;

  /// No description provided for @quip4.
  ///
  /// In en, this message translates to:
  /// **'Reading between the lines…'**
  String get quip4;

  /// No description provided for @stageReading.
  ///
  /// In en, this message translates to:
  /// **'Reading {count} messages'**
  String stageReading(int count);

  /// No description provided for @stageCounting.
  ///
  /// In en, this message translates to:
  /// **'Counting who texts first'**
  String get stageCounting;

  /// No description provided for @stageBetweenLines.
  ///
  /// In en, this message translates to:
  /// **'Reading between the lines'**
  String get stageBetweenLines;

  /// No description provided for @stageWriting.
  ///
  /// In en, this message translates to:
  /// **'Writing your report'**
  String get stageWriting;

  /// No description provided for @analyzingPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Your messages are sent to our AI provider only to write this report. We don\'t keep them.'**
  String get analyzingPrivacy;

  /// No description provided for @consentTitle.
  ///
  /// In en, this message translates to:
  /// **'Before we analyze'**
  String get consentTitle;

  /// No description provided for @consentBody.
  ///
  /// In en, this message translates to:
  /// **'Counts and reply times are calculated on your phone. To write your report, the text of this chat — including the other person\'s messages and names — is sent over an encrypted connection to our AI provider, Z.ai. We don\'t store it. Only analyze chats you\'re part of.'**
  String get consentBody;

  /// No description provided for @consentAgree.
  ///
  /// In en, this message translates to:
  /// **'Agree & analyze'**
  String get consentAgree;

  /// No description provided for @consentCancel.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get consentCancel;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorTitle;

  /// No description provided for @errorRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get errorRetry;

  /// No description provided for @reportYouAnd.
  ///
  /// In en, this message translates to:
  /// **'You & {name}'**
  String reportYouAnd(String name);

  /// No description provided for @reportMessages.
  ///
  /// In en, this message translates to:
  /// **'{count} messages'**
  String reportMessages(int count);

  /// No description provided for @sectionWarmth.
  ///
  /// In en, this message translates to:
  /// **'Relationship warmth'**
  String get sectionWarmth;

  /// No description provided for @sectionBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get sectionBalance;

  /// No description provided for @sectionEmotionCurve.
  ///
  /// In en, this message translates to:
  /// **'Emotion curve · by month'**
  String get sectionEmotionCurve;

  /// No description provided for @sectionTopics.
  ///
  /// In en, this message translates to:
  /// **'What you talk about'**
  String get sectionTopics;

  /// No description provided for @sectionPersonalities.
  ///
  /// In en, this message translates to:
  /// **'Chat personalities'**
  String get sectionPersonalities;

  /// No description provided for @sectionFullReading.
  ///
  /// In en, this message translates to:
  /// **'The full reading'**
  String get sectionFullReading;

  /// No description provided for @sectionMilestones.
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get sectionMilestones;

  /// No description provided for @sectionAdvice.
  ///
  /// In en, this message translates to:
  /// **'For the road'**
  String get sectionAdvice;

  /// No description provided for @labelYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get labelYou;

  /// No description provided for @labelMessagesSent.
  ///
  /// In en, this message translates to:
  /// **'Messages sent'**
  String get labelMessagesSent;

  /// No description provided for @labelWhoTextsFirst.
  ///
  /// In en, this message translates to:
  /// **'Who texts first'**
  String get labelWhoTextsFirst;

  /// No description provided for @labelYourReplyTime.
  ///
  /// In en, this message translates to:
  /// **'YOUR REPLY TIME'**
  String get labelYourReplyTime;

  /// No description provided for @labelTheirReplyTime.
  ///
  /// In en, this message translates to:
  /// **'{name}\'S REPLY TIME'**
  String labelTheirReplyTime(String name);

  /// No description provided for @curveNotEnough.
  ///
  /// In en, this message translates to:
  /// **'Not enough months for a curve yet'**
  String get curveNotEnough;

  /// No description provided for @shareTitle.
  ///
  /// In en, this message translates to:
  /// **'Share your story'**
  String get shareTitle;

  /// No description provided for @shareSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Names are shortened to initials automatically.'**
  String get shareSubtitle;

  /// No description provided for @shareAction.
  ///
  /// In en, this message translates to:
  /// **'Share image'**
  String get shareAction;

  /// No description provided for @sharePreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing…'**
  String get sharePreparing;

  /// No description provided for @shareFailed.
  ///
  /// In en, this message translates to:
  /// **'Share failed: {error}'**
  String shareFailed(String error);

  /// No description provided for @shareCardBrand.
  ///
  /// In en, this message translates to:
  /// **'CHAT REPORT'**
  String get shareCardBrand;

  /// No description provided for @shareCardWarmth.
  ///
  /// In en, this message translates to:
  /// **'RELATIONSHIP WARMTH'**
  String get shareCardWarmth;

  /// No description provided for @shareCardWatermark.
  ///
  /// In en, this message translates to:
  /// **'MADE WITH CHAT REPORT'**
  String get shareCardWatermark;

  /// No description provided for @shareCardYears.
  ///
  /// In en, this message translates to:
  /// **'{count} years of texts'**
  String shareCardYears(int count);

  /// No description provided for @shareCardMonths.
  ///
  /// In en, this message translates to:
  /// **'{count} months of texts'**
  String shareCardMonths(int count);

  /// No description provided for @shareCardOurChat.
  ///
  /// In en, this message translates to:
  /// **'our chat'**
  String get shareCardOurChat;

  /// No description provided for @shareCardMessages.
  ///
  /// In en, this message translates to:
  /// **'messages · {late} late-night'**
  String shareCardMessages(int late);

  /// No description provided for @shareCardStarted.
  ///
  /// In en, this message translates to:
  /// **'of conversations started by {initial}'**
  String shareCardStarted(String initial);

  /// No description provided for @shareCardWarmestMonth.
  ///
  /// In en, this message translates to:
  /// **'was the warmest month'**
  String get shareCardWarmestMonth;

  /// No description provided for @shareText.
  ///
  /// In en, this message translates to:
  /// **'Our chat, read by Chat Report'**
  String get shareText;

  /// No description provided for @parseUnrecognized.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t recognize the export format (only {count} lines parsed)'**
  String parseUnrecognized(int count);

  /// No description provided for @parseTooFew.
  ///
  /// In en, this message translates to:
  /// **'Not enough messages ({count}) — try the paste option instead'**
  String parseTooFew(int count);

  /// No description provided for @errorAllChunksFailed.
  ///
  /// In en, this message translates to:
  /// **'Analysis failed for every month. {detail}'**
  String errorAllChunksFailed(String detail);

  /// No description provided for @errorNoConnection.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the analysis service. Check your connection and try again.'**
  String get errorNoConnection;

  /// No description provided for @errorServiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The analysis service is temporarily unavailable. Please try again later.'**
  String get errorServiceUnavailable;

  /// No description provided for @errorEmptyResponse.
  ///
  /// In en, this message translates to:
  /// **'The analysis service returned an empty response.'**
  String get errorEmptyResponse;

  /// No description provided for @errorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'The analysis service is rate-limiting requests. Please try again shortly.'**
  String get errorRateLimited;
}

class _LDelegate extends LocalizationsDelegate<L> {
  const _LDelegate();

  @override
  Future<L> load(Locale locale) {
    return SynchronousFuture<L>(lookupL(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'id',
    'it',
    'pt',
    'tr',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_LDelegate old) => false;
}

L lookupL(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return LZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return LAr();
    case 'de':
      return LDe();
    case 'en':
      return LEn();
    case 'es':
      return LEs();
    case 'fr':
      return LFr();
    case 'hi':
      return LHi();
    case 'id':
      return LId();
    case 'it':
      return LIt();
    case 'pt':
      return LPt();
    case 'tr':
      return LTr();
    case 'zh':
      return LZh();
  }

  throw FlutterError(
    'L.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
