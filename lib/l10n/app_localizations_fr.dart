// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class LFr extends L {
  LFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Chat Report';

  @override
  String get tagline => 'Que racontent vraiment tes conversations ?';

  @override
  String get homeImportTitle => 'Importer une discussion';

  @override
  String get homeImportSubtitle => 'Le rapport complet de ta relation';

  @override
  String get homeImportHint =>
      'Guide pas à pas inclus — environ 30 secondes  →';

  @override
  String get homePasteTitle => 'Coller une conversation';

  @override
  String get homePasteSubtitle => 'Lecture rapide · gratuit · 30 secondes';

  @override
  String get homePrivacy =>
      'L\'analyse se fait sur ton téléphone. Tes discussions ne sont jamais conservées — elles sont supprimées dès que ton rapport est prêt.';

  @override
  String get pasteSheetTitle => 'Coller une conversation';

  @override
  String get pasteSheetSubtitle =>
      'Copie des messages depuis n\'importe quelle discussion et colle-les ici.';

  @override
  String get pasteSheetHint => '[21/03/24, 21:41] Sam: hé, tu dors ?…';

  @override
  String get pasteSheetAction => 'Lire cette discussion';

  @override
  String get guideTitle => 'Exporte ta discussion';

  @override
  String get guideSubtitle => 'Ça prend environ 30 secondes dans WhatsApp.';

  @override
  String get guideStep1Title => 'Ouvre WhatsApp';

  @override
  String get guideStep1Detail => 'Va dans la discussion que tu veux analyser.';

  @override
  String get guideStep2Title =>
      'Touche le menu ⋮ → Plus → Exporter la discussion';

  @override
  String get guideStep2Detail =>
      'Sur iPhone : touche le nom du contact → Exporter la discussion.';

  @override
  String get guideStep3Title => 'Choisis « Sans médias »';

  @override
  String get guideStep3Detail =>
      'Texte uniquement — fichier plus léger, analyse plus rapide.';

  @override
  String get guideStep4Title => 'Enregistre le .txt, puis reviens';

  @override
  String get guideStep4Detail =>
      'Enregistre-le dans Fichiers / Téléchargements, reviens ici et sélectionne-le.';

  @override
  String get guideOpenWhatsApp => 'Ouvrir WhatsApp';

  @override
  String get guidePickFile => 'J\'ai le fichier — le choisir';

  @override
  String get guidePrivacy =>
      'L\'export reste sur ton téléphone tant que tu n\'as pas touché « Analyser ».';

  @override
  String get guideOpenFailed =>
      'Impossible d\'ouvrir WhatsApp — l\'app est bien installée ?';

  @override
  String get setupTitle => 'Avec qui est cette discussion ?';

  @override
  String get setupSubtitle => 'On a trouvé ton export — tout a l\'air bon.';

  @override
  String setupChatWith(String name) {
    return 'Discussion avec $name';
  }

  @override
  String setupMessageCount(int count, String range) {
    return '$count messages · $range';
  }

  @override
  String get setupWhichIsYou => 'Lequel, c\'est toi ?';

  @override
  String get setupRelationship => 'Relation';

  @override
  String get setupAnalyze => 'Analyser la discussion';

  @override
  String get setupPrivacy =>
      'Les noms sont anonymisés dans tout ce que tu partages.';

  @override
  String get relPartner => '💘 Couple';

  @override
  String get relCrush => '👀 Crush';

  @override
  String get relFriend => '🫶 Amitié';

  @override
  String get relEx => '🌧 Ex';

  @override
  String get relFamily => '🏡 Famille';

  @override
  String get analyzing => 'ANALYSE EN COURS';

  @override
  String get quip1 => 'On capte les sautes d\'humeur…';

  @override
  String get quip2 => 'On compte les messages de minuit…';

  @override
  String get quip3 => 'On regarde qui dit bonne nuit en premier…';

  @override
  String get quip4 => 'On lit entre les lignes…';

  @override
  String stageReading(int count) {
    return 'Lecture de $count messages';
  }

  @override
  String get stageCounting => 'Qui écrit en premier';

  @override
  String get stageBetweenLines => 'Lecture entre les lignes';

  @override
  String get stageWriting => 'Rédaction de ton rapport';

  @override
  String get analyzingPrivacy =>
      'Tes discussions sont supprimées de nos serveurs dès que c\'est terminé.';

  @override
  String get errorTitle => 'Oups, quelque chose a coincé';

  @override
  String get errorRetry => 'Réessayer';

  @override
  String reportYouAnd(String name) {
    return 'Toi & $name';
  }

  @override
  String reportMessages(int count) {
    return '$count messages';
  }

  @override
  String get sectionWarmth => 'Chaleur de la relation';

  @override
  String get sectionBalance => 'Équilibre';

  @override
  String get sectionEmotionCurve => 'Courbe des émotions · par mois';

  @override
  String get sectionTopics => 'De quoi vous parlez';

  @override
  String get sectionPersonalities => 'Personnalités de chat';

  @override
  String get sectionFullReading => 'L\'analyse complète';

  @override
  String get sectionMilestones => 'Moments clés';

  @override
  String get sectionAdvice => 'Pour la route';

  @override
  String get labelYou => 'Toi';

  @override
  String get labelMessagesSent => 'Messages envoyés';

  @override
  String get labelWhoTextsFirst => 'Qui écrit en premier';

  @override
  String get labelYourReplyTime => 'TON TEMPS DE RÉPONSE';

  @override
  String labelTheirReplyTime(String name) {
    return 'TEMPS DE RÉPONSE · $name';
  }

  @override
  String get curveNotEnough =>
      'Pas encore assez de mois pour tracer une courbe';

  @override
  String get shareTitle => 'Partage ton histoire';

  @override
  String get shareSubtitle =>
      'Les noms sont réduits automatiquement aux initiales.';

  @override
  String get shareAction => 'Partager l\'image';

  @override
  String get sharePreparing => 'Préparation…';

  @override
  String shareFailed(String error) {
    return 'Échec du partage : $error';
  }

  @override
  String get shareCardBrand => 'CHAT REPORT';

  @override
  String get shareCardWarmth => 'CHALEUR DE LA RELATION';

  @override
  String get shareCardWatermark => 'CRÉÉ AVEC CHAT REPORT';

  @override
  String shareCardYears(int count) {
    return '$count ans de messages';
  }

  @override
  String shareCardMonths(int count) {
    return '$count mois de messages';
  }

  @override
  String get shareCardOurChat => 'notre discussion';

  @override
  String shareCardMessages(int late) {
    return 'messages · dont $late la nuit';
  }

  @override
  String shareCardStarted(String initial) {
    return 'des conversations lancées par $initial';
  }

  @override
  String get shareCardWarmestMonth => 'a été le mois le plus chaleureux';

  @override
  String get shareText => 'Notre discussion, décryptée par Chat Report';

  @override
  String parseUnrecognized(int count) {
    return 'Format d\'export non reconnu (lignes lues : $count)';
  }

  @override
  String parseTooFew(int count) {
    return 'Pas assez de messages ($count) — essaie plutôt de coller la conversation';
  }

  @override
  String errorAllChunksFailed(String detail) {
    return 'L\'analyse a échoué pour tous les mois. $detail';
  }

  @override
  String get errorNoConnection =>
      'Impossible de joindre le service d\'analyse. Vérifie ta connexion et réessaie.';

  @override
  String get errorEmptyResponse =>
      'Le service d\'analyse a renvoyé une réponse vide.';

  @override
  String get errorRateLimited =>
      'Le service d\'analyse reçoit trop de demandes. Réessaie dans un instant.';
}
