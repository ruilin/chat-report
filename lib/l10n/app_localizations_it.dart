// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class LIt extends L {
  LIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Chat Report';

  @override
  String get tagline => 'Cosa dicono davvero le tue chat?';

  @override
  String get homeImportTitle => 'Importa una chat esportata';

  @override
  String get homeImportSubtitle => 'Report completo della relazione';

  @override
  String get homeImportHint =>
      'Guida passo passo inclusa — circa 30 secondi  →';

  @override
  String get homePasteTitle => 'Incolla una conversazione';

  @override
  String get homePasteSubtitle => 'Lettura veloce · gratis · 30 secondi';

  @override
  String get homePrivacy =>
      'Le statistiche vengono calcolate sul tuo telefono. Per scrivere il report, i tuoi messaggi vanno al nostro fornitore di IA: non li conserviamo mai.';

  @override
  String get pasteSheetTitle => 'Incolla una conversazione';

  @override
  String get pasteSheetSubtitle =>
      'Copia i messaggi da qualsiasi chat e incollali qui.';

  @override
  String get pasteSheetHint => '[21/03/24, 21:41] Sam: ehi, sei sveglio?…';

  @override
  String get pasteSheetAction => 'Leggi questa chat';

  @override
  String get guideTitle => 'Esporta la tua chat';

  @override
  String get guideSubtitle => 'Su WhatsApp ci vogliono circa 30 secondi.';

  @override
  String get guideStep1Title => 'Apri WhatsApp';

  @override
  String get guideStep1Detail => 'Vai alla chat che vuoi analizzare.';

  @override
  String get guideStep2Title => 'Tocca il menu ⋮ → Altro → Esporta chat';

  @override
  String get guideStep2Detail =>
      'Su iPhone: tocca il nome del contatto → Esporta chat.';

  @override
  String get guideStep3Title => 'Scegli \"Senza media\"';

  @override
  String get guideStep3Detail =>
      'Solo testo — file più leggero, analisi più veloce.';

  @override
  String get guideStep4Title => 'Salva il .txt e torna qui';

  @override
  String get guideStep4Detail =>
      'Salvalo in File / Download, torna qui e selezionalo.';

  @override
  String get guideOpenWhatsApp => 'Apri WhatsApp';

  @override
  String get guidePickFile => 'Ho il file — selezionalo';

  @override
  String get guidePrivacy =>
      'Il file non lascia il tuo telefono finché non tocchi Analizza.';

  @override
  String get guideOpenFailed => 'Impossibile aprire WhatsApp. È installato?';

  @override
  String get setupTitle => 'Con chi è questa chat?';

  @override
  String get setupSubtitle => 'Abbiamo trovato il tuo file — tutto ok.';

  @override
  String setupChatWith(String name) {
    return 'Chat con $name';
  }

  @override
  String setupMessageCount(int count, String range) {
    return '$count messaggi · $range';
  }

  @override
  String get setupWhichIsYou => 'Quale sei tu?';

  @override
  String get setupRelationship => 'Relazione';

  @override
  String get setupAnalyze => 'Analizza la nostra chat';

  @override
  String get setupPrivacy =>
      'I nomi sono resi anonimi in tutto ciò che condividi.';

  @override
  String get relPartner => '💘 Partner';

  @override
  String get relCrush => '👀 Crush';

  @override
  String get relFriend => '🫶 Amicizia';

  @override
  String get relEx => '🌧 Ex';

  @override
  String get relFamily => '🏡 Famiglia';

  @override
  String get analyzing => 'ANALISI IN CORSO';

  @override
  String get quip1 => 'Sentiamo gli sbalzi d\'umore…';

  @override
  String get quip2 => 'Contiamo i messaggi a notte fonda…';

  @override
  String get quip3 => 'Vediamo chi dà la buonanotte per primo…';

  @override
  String get quip4 => 'Leggiamo tra le righe…';

  @override
  String stageReading(int count) {
    return 'Lettura di $count messaggi';
  }

  @override
  String get stageCounting => 'Contiamo chi scrive per primo';

  @override
  String get stageBetweenLines => 'Leggiamo tra le righe';

  @override
  String get stageWriting => 'Scriviamo il tuo report';

  @override
  String get analyzingPrivacy =>
      'I tuoi messaggi vengono inviati al nostro fornitore di IA solo per scrivere questo report. Non li conserviamo.';

  @override
  String get consentTitle => 'Prima dell\'analisi';

  @override
  String get consentBody =>
      'Conteggi e tempi di risposta vengono calcolati sul tuo telefono. Per scrivere il report, il testo di questa chat, compresi i messaggi e i nomi dell\'altra persona, viene inviato con una connessione crittografata al nostro fornitore di IA, Z.ai. Non lo conserviamo. Analizza solo chat a cui partecipi.';

  @override
  String get consentAgree => 'Accetta e analizza';

  @override
  String get consentCancel => 'Non ora';

  @override
  String get errorTitle => 'Qualcosa è andato storto';

  @override
  String get errorRetry => 'Riprova';

  @override
  String reportYouAnd(String name) {
    return 'Tu e $name';
  }

  @override
  String reportMessages(int count) {
    return '$count messaggi';
  }

  @override
  String get sectionWarmth => 'Calore della relazione';

  @override
  String get sectionBalance => 'Equilibrio';

  @override
  String get sectionEmotionCurve => 'Curva emotiva · per mese';

  @override
  String get sectionTopics => 'Di cosa parlate';

  @override
  String get sectionPersonalities => 'Personalità in chat';

  @override
  String get sectionFullReading => 'La lettura completa';

  @override
  String get sectionMilestones => 'Tappe importanti';

  @override
  String get sectionAdvice => 'Per il futuro';

  @override
  String get labelYou => 'Tu';

  @override
  String get labelMessagesSent => 'Messaggi inviati';

  @override
  String get labelWhoTextsFirst => 'Chi scrive per primo';

  @override
  String get labelYourReplyTime => 'IL TUO TEMPO DI RISPOSTA';

  @override
  String labelTheirReplyTime(String name) {
    return 'TEMPO DI RISPOSTA DI $name';
  }

  @override
  String get curveNotEnough =>
      'Non ci sono ancora abbastanza mesi per una curva';

  @override
  String get shareTitle => 'Condividi la vostra storia';

  @override
  String get shareSubtitle => 'I nomi diventano iniziali in automatico.';

  @override
  String get shareAction => 'Condividi immagine';

  @override
  String get sharePreparing => 'Preparazione…';

  @override
  String shareFailed(String error) {
    return 'Condivisione non riuscita: $error';
  }

  @override
  String get shareCardBrand => 'CHAT REPORT';

  @override
  String get shareCardWarmth => 'CALORE DELLA RELAZIONE';

  @override
  String get shareCardWatermark => 'CREATO CON CHAT REPORT';

  @override
  String shareCardYears(int count) {
    return '$count anni di messaggi';
  }

  @override
  String shareCardMonths(int count) {
    return '$count mesi di messaggi';
  }

  @override
  String get shareCardOurChat => 'la nostra chat';

  @override
  String shareCardMessages(int late) {
    return 'messaggi · $late a notte fonda';
  }

  @override
  String shareCardStarted(String initial) {
    return 'delle conversazioni iniziate da $initial';
  }

  @override
  String get shareCardWarmestMonth => 'è stato il mese più caldo';

  @override
  String get shareText => 'La nostra chat, letta da Chat Report';

  @override
  String parseUnrecognized(int count) {
    return 'Formato del file non riconosciuto (righe lette: $count)';
  }

  @override
  String parseTooFew(int count) {
    return 'Messaggi insufficienti ($count) — prova a incollare la conversazione';
  }

  @override
  String errorAllChunksFailed(String detail) {
    return 'L\'analisi non è riuscita per nessun mese. $detail';
  }

  @override
  String get errorNoConnection =>
      'Impossibile raggiungere il servizio di analisi. Controlla la connessione e riprova.';

  @override
  String get errorEmptyResponse =>
      'Il servizio di analisi ha restituito una risposta vuota.';

  @override
  String get errorRateLimited =>
      'Il servizio di analisi sta limitando le richieste. Riprova tra poco.';
}
