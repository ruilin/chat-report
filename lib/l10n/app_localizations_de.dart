// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class LDe extends L {
  LDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Chat Report';

  @override
  String get tagline => 'Was steckt wirklich in deinen Chats?';

  @override
  String get homeImportTitle => 'Chat-Export importieren';

  @override
  String get homeImportSubtitle => 'Kompletter Beziehungsreport';

  @override
  String get homeImportHint =>
      'Mit Schritt-für-Schritt-Anleitung — dauert ca. 30 Sekunden  →';

  @override
  String get homePasteTitle => 'Unterhaltung einfügen';

  @override
  String get homePasteSubtitle => 'Schnell-Check · gratis · 30 Sekunden';

  @override
  String get homePrivacy =>
      'Die Statistiken werden auf deinem Handy berechnet. Für deinen Report gehen deine Nachrichten an unseren KI-Anbieter — wir speichern sie nie.';

  @override
  String get homeSampleTitle => 'Erst mal einen Beispiel-Report ansehen';

  @override
  String get homeSampleSubtitle =>
      'Aus einem erfundenen Chat · ganz ohne Export';

  @override
  String get sampleBanner =>
      'Das ist ein Beispiel-Report aus einem erfundenen Chat zwischen Alex und Mia. Deiner entsteht aus deinen eigenen Nachrichten.';

  @override
  String get sampleCta => 'Meinen Chat analysieren';

  @override
  String get pasteSheetTitle => 'Unterhaltung einfügen';

  @override
  String get pasteSheetSubtitle =>
      'Kopier Nachrichten aus einem beliebigen Chat und füg sie hier ein.';

  @override
  String get pasteSheetHint => '[21.03.24, 21:41] Sam: hey, noch wach?…';

  @override
  String get pasteSheetAction => 'Chat lesen';

  @override
  String get guideTitle => 'Exportiere deinen Chat';

  @override
  String get guideSubtitle => 'Dauert in WhatsApp ca. 30 Sekunden.';

  @override
  String get guideStep1Title => 'Öffne WhatsApp';

  @override
  String get guideStep1Detail => 'Geh in den Chat, den du analysieren willst.';

  @override
  String get guideStep2Title => 'Tippe auf ⋮ → Mehr → Chat exportieren';

  @override
  String get guideStep2Detail =>
      'Auf dem iPhone: Tippe auf den Kontaktnamen → Chat exportieren.';

  @override
  String get guideStep3Title => 'Wähle „Ohne Medien“';

  @override
  String get guideStep3Detail =>
      'Nur Text — kleinere Datei, schnellere Analyse.';

  @override
  String get guideStep4Title => 'Speichere die .txt und komm zurück';

  @override
  String get guideStep4Detail =>
      'In Dateien / Downloads speichern, hierher zurückkommen und auswählen.';

  @override
  String get guideOpenWhatsApp => 'WhatsApp öffnen';

  @override
  String get guidePickFile => 'Ich hab die Datei — auswählen';

  @override
  String get guidePrivacy =>
      'Der Export bleibt auf deinem Handy, bis du auf „Analysieren“ tippst.';

  @override
  String get guideOpenFailed =>
      'WhatsApp ließ sich nicht öffnen — ist es installiert?';

  @override
  String get setupTitle => 'Mit wem ist dieser Chat?';

  @override
  String get setupSubtitle => 'Export gefunden — sieht gut aus.';

  @override
  String setupChatWith(String name) {
    return 'Chat mit $name';
  }

  @override
  String setupMessageCount(int count, String range) {
    return '$count Nachrichten · $range';
  }

  @override
  String get setupWhichIsYou => 'Wer davon bist du?';

  @override
  String get setupRelationship => 'Beziehung';

  @override
  String get setupAnalyze => 'Chat analysieren';

  @override
  String get setupPrivacy =>
      'In allem, was du teilst, werden Namen anonymisiert.';

  @override
  String get relPartner => '💘 Partner:in';

  @override
  String get relCrush => '👀 Crush';

  @override
  String get relFriend => '🫶 Freund:in';

  @override
  String get relEx => '🌧 Ex';

  @override
  String get relFamily => '🏡 Familie';

  @override
  String get analyzing => 'ANALYSE LÄUFT';

  @override
  String get quip1 => 'Wir spüren den Stimmungsschwankungen nach…';

  @override
  String get quip2 => 'Wir zählen die Nachrichten nach Mitternacht…';

  @override
  String get quip3 => 'Wir schauen, wer zuerst gute Nacht sagt…';

  @override
  String get quip4 => 'Wir lesen zwischen den Zeilen…';

  @override
  String stageReading(int count) {
    return 'Lese $count Nachrichten';
  }

  @override
  String get stageCounting => 'Zähle, wer zuerst schreibt';

  @override
  String get stageBetweenLines => 'Lese zwischen den Zeilen';

  @override
  String get stageWriting => 'Schreibe deinen Report';

  @override
  String get analyzingPrivacy =>
      'Deine Nachrichten gehen nur für diesen Report an unseren KI-Anbieter. Wir speichern sie nicht.';

  @override
  String get consentTitle => 'Bevor wir analysieren';

  @override
  String get consentBody =>
      'Zählungen und Antwortzeiten werden auf deinem Handy berechnet. Für deinen Report wird der Text dieses Chats — inklusive der Nachrichten und Namen der anderen Person — verschlüsselt an unseren KI-Anbieter Z.ai gesendet. Wir speichern ihn nicht. Analysiere nur Chats, an denen du beteiligt bist.';

  @override
  String get consentAgree => 'Zustimmen & analysieren';

  @override
  String get consentCancel => 'Nicht jetzt';

  @override
  String get errorTitle => 'Da ist was schiefgelaufen';

  @override
  String get errorRetry => 'Nochmal versuchen';

  @override
  String reportYouAnd(String name) {
    return 'Du & $name';
  }

  @override
  String reportMessages(int count) {
    return '$count Nachrichten';
  }

  @override
  String get sectionWarmth => 'Beziehungswärme';

  @override
  String get sectionBalance => 'Balance';

  @override
  String get sectionEmotionCurve => 'Gefühlskurve · nach Monat';

  @override
  String get sectionTopics => 'Worüber ihr redet';

  @override
  String get sectionPersonalities => 'Chat-Persönlichkeiten';

  @override
  String get sectionFullReading => 'Die ganze Analyse';

  @override
  String get sectionMilestones => 'Meilensteine';

  @override
  String get sectionAdvice => 'Mit auf den Weg';

  @override
  String get labelYou => 'Du';

  @override
  String get labelMessagesSent => 'Gesendete Nachrichten';

  @override
  String get labelWhoTextsFirst => 'Wer zuerst schreibt';

  @override
  String get labelYourReplyTime => 'DEINE ANTWORTZEIT';

  @override
  String labelTheirReplyTime(String name) {
    return 'ANTWORTZEIT VON $name';
  }

  @override
  String get curveNotEnough => 'Noch zu wenige Monate für eine Kurve';

  @override
  String get shareTitle => 'Teile deine Story';

  @override
  String get shareSubtitle => 'Namen werden automatisch zu Initialen gekürzt.';

  @override
  String get shareAction => 'Bild teilen';

  @override
  String get sharePreparing => 'Wird vorbereitet…';

  @override
  String shareFailed(String error) {
    return 'Teilen fehlgeschlagen: $error';
  }

  @override
  String get shareCardBrand => 'CHAT REPORT';

  @override
  String get shareCardWarmth => 'BEZIEHUNGSWÄRME';

  @override
  String get shareCardWatermark => 'ERSTELLT MIT CHAT REPORT';

  @override
  String shareCardYears(int count) {
    return '$count Jahre Nachrichten';
  }

  @override
  String shareCardMonths(int count) {
    return '$count Monate Nachrichten';
  }

  @override
  String get shareCardOurChat => 'unser Chat';

  @override
  String shareCardMessages(int late) {
    return 'Nachrichten · $late davon nachts';
  }

  @override
  String shareCardStarted(String initial) {
    return 'der Gespräche startet $initial';
  }

  @override
  String get shareCardWarmestMonth => 'war der wärmste Monat';

  @override
  String get shareText => 'Unser Chat, gelesen von Chat Report';

  @override
  String parseUnrecognized(int count) {
    return 'Exportformat nicht erkannt (gelesene Zeilen: $count)';
  }

  @override
  String parseTooFew(int count) {
    return 'Zu wenige Nachrichten ($count) — probier lieber das Einfügen';
  }

  @override
  String errorAllChunksFailed(String detail) {
    return 'Die Analyse ist für alle Monate fehlgeschlagen. $detail';
  }

  @override
  String get errorNoConnection =>
      'Analysedienst nicht erreichbar. Prüf deine Verbindung und versuch\'s nochmal.';

  @override
  String get errorServiceUnavailable =>
      'Der Analysedienst ist gerade nicht erreichbar. Versuch es später noch mal.';

  @override
  String get errorEmptyResponse =>
      'Der Analysedienst hat eine leere Antwort geliefert.';

  @override
  String get errorRateLimited =>
      'Der Analysedienst bekommt gerade zu viele Anfragen. Versuch\'s gleich nochmal.';

  @override
  String get unlockTitle => 'Vollständigen Bericht freischalten';

  @override
  String get unlockSubtitle =>
      'Die Tiefenanalyse mit den genauen Nachrichten zu jedem Befund, persönliche Tipps und der KI-Coach für diesen Bericht.';

  @override
  String get deepDiveTitle => 'Tiefenanalyse';

  @override
  String get attachmentAnxious => 'Eher ängstlich';

  @override
  String get attachmentAvoidant => 'Eher vermeidend';

  @override
  String get attachmentSecure => 'Eher sicher';

  @override
  String get attachmentMixed => 'Gemischt';

  @override
  String get deepDiveMissing =>
      'Die Tiefenanalyse konnte diesmal nicht erstellt werden. Analysiere diesen Chat erneut, um es noch einmal zu versuchen.';

  @override
  String get deepDiveSubtitle =>
      'Was der kostenlose Bericht nicht abdeckt. Jede Erkenntnis kommt mit der genauen Nachricht dahinter.';

  @override
  String get sectionConflict => 'Streit und Versöhnung';

  @override
  String get sectionRedFlags => 'Warnsignale';

  @override
  String get sectionGreenFlags => 'Positive Signale';

  @override
  String get sectionAttachment => 'Bindungsstile';

  @override
  String get sectionTurningPoints => 'Wendepunkte';

  @override
  String deepDiveBuy(String price) {
    return 'Für $price freischalten';
  }

  @override
  String get deepDiveOneTime => 'Einmalzahlung für diesen Bericht. Kein Abo.';

  @override
  String get deepDiveUnavailable =>
      'Käufe sind gerade nicht verfügbar. Bitte versuch es später noch einmal.';

  @override
  String get deepDivePending =>
      'Deine Zahlung steht noch aus. Dieser Bericht wird freigeschaltet, sobald sie eingegangen ist.';

  @override
  String get deepDiveFailed =>
      'Der Kauf wurde nicht abgeschlossen. Bitte versuch es noch einmal.';

  @override
  String get deepDiveUseCredit => 'Mit deinem bezahlten Guthaben freischalten';

  @override
  String get deepDiveDisclaimer =>
      'Eine KI-Einschätzung zum Nachdenken, keine Diagnose.';

  @override
  String get deepDiveNoRedFlags =>
      'Keine klaren Warnsignale in diesen Nachrichten.';

  @override
  String get deepDiveNoGreenFlags =>
      'Keine klaren positiven Signale in diesen Nachrichten.';

  @override
  String get attachmentLoopLabel => 'Das Muster zwischen euch';

  @override
  String get sampleDeepDiveHint =>
      'Dein eigener Bericht enthält diesen Abschnitt.';

  @override
  String get savedTitle => 'Meine Berichte';

  @override
  String savedSubtitle(int count) {
    return '$count auf diesem Handy gespeichert';
  }

  @override
  String get savedNote =>
      'Berichte werden nur auf diesem Handy gespeichert. Beim Deinstallieren der App werden sie gelöscht.';

  @override
  String get savedEmpty => 'Noch keine gespeicherten Berichte.';

  @override
  String get savedDeleteTitle => 'Diesen Bericht löschen?';

  @override
  String get savedDeleteBody =>
      'Er lässt sich nicht wiederherstellen. Hast du ihn bezahlt freigeschaltet, geht auch das verloren.';

  @override
  String get savedDeleteConfirm => 'Löschen';

  @override
  String get savedDeleteCancel => 'Behalten';

  @override
  String get savedUnlockedBadge => 'Tiefenanalyse freigeschaltet';

  @override
  String get coachEntryTitle => 'KI-Coach fragen';

  @override
  String get coachEntrySubtitle => 'Frag alles zu diesem Bericht';

  @override
  String get coachTitle => 'KI-Coach';

  @override
  String get coachDisclaimer =>
      'Der Coach ist eine KI: Er kann sich irren und ersetzt keine professionelle Hilfe.';

  @override
  String get coachHint => 'Frag etwas zu dieser Beziehung…';

  @override
  String get coachSlow => 'Die KI braucht länger als sonst. Neuer Versuch…';

  @override
  String get coachSend => 'Senden';

  @override
  String get coachSuggest1 => 'Warum streiten wir immer über dasselbe?';

  @override
  String get coachSuggest2 => 'Wie spreche ich etwas Schwieriges an?';

  @override
  String get coachSuggest3 => 'Woran sollte ich zuerst arbeiten?';

  @override
  String coachLeft(int count) {
    return 'Noch $count Fragen';
  }

  @override
  String get coachOutTitle => 'Deine kostenlosen Fragen sind aufgebraucht';

  @override
  String get coachOutBody =>
      'Schalte diesen Bericht frei, um weiterzufragen. Die Tiefenanalyse und persönliche Tipps sind auch dabei.';

  @override
  String get coachReportTitle => 'Diese Antwort melden';

  @override
  String get coachReportOffensive => 'Beleidigend oder unangemessen';

  @override
  String get coachReportHarmful => 'Schädlicher oder gefährlicher Rat';

  @override
  String get coachReportWrong => 'Falsch oder erfunden';

  @override
  String get coachReportThanks => 'Danke, wir haben deine Meldung erhalten.';
}
