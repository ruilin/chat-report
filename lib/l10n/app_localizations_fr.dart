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
      'Les statistiques sont calculées sur ton téléphone. Pour rédiger ton rapport, tes messages sont envoyés à notre fournisseur d\'IA — on ne les conserve jamais.';

  @override
  String get homeSampleTitle => 'Voir d\'abord un exemple de rapport';

  @override
  String get homeSampleSubtitle =>
      'Basé sur une discussion inventée · sans export';

  @override
  String get sampleBanner =>
      'Ceci est un exemple de rapport, basé sur une discussion inventée entre Alex et Mia. Le tien sera créé à partir de tes propres messages.';

  @override
  String get sampleCta => 'Analyser ma discussion';

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
      'Tes messages sont envoyés à notre fournisseur d\'IA uniquement pour rédiger ce rapport. On ne les conserve pas.';

  @override
  String get consentTitle => 'Avant l\'analyse';

  @override
  String get consentBody =>
      'Les comptes et les temps de réponse sont calculés sur ton téléphone. Pour rédiger ton rapport, le texte de cette discussion — y compris les messages et les noms de l\'autre personne — est envoyé via une connexion chiffrée à notre fournisseur d\'IA, Z.ai. On ne le conserve pas. N\'analyse que des discussions auxquelles tu participes.';

  @override
  String get consentAgree => 'Accepter et analyser';

  @override
  String get consentCancel => 'Pas maintenant';

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
  String get errorServiceUnavailable =>
      'Le service d\'analyse est momentanément indisponible. Réessaie plus tard.';

  @override
  String get errorEmptyResponse =>
      'Le service d\'analyse a renvoyé une réponse vide.';

  @override
  String get errorRateLimited =>
      'Le service d\'analyse reçoit trop de demandes. Réessaie dans un instant.';

  @override
  String get unlockTitle => 'Débloquer le rapport complet';

  @override
  String get unlockSubtitle =>
      'L\'analyse approfondie avec les messages exacts derrière chaque constat, des conseils personnalisés et le coach IA pour ce rapport.';

  @override
  String get deepDiveTitle => 'Analyse approfondie';

  @override
  String get attachmentAnxious => 'Tendance anxieuse';

  @override
  String get attachmentAvoidant => 'Tendance évitante';

  @override
  String get attachmentSecure => 'Tendance sécure';

  @override
  String get attachmentMixed => 'Mixte';

  @override
  String get deepDiveMissing =>
      'L\'analyse approfondie n\'a pas pu être générée cette fois. Analysez à nouveau cette discussion pour réessayer.';

  @override
  String get deepDiveSubtitle =>
      'Ce que le rapport gratuit n\'aborde pas. Chaque constat s\'appuie sur le message exact.';

  @override
  String get sectionConflict => 'Disputes et réconciliations';

  @override
  String get sectionRedFlags => 'Signaux d\'alerte';

  @override
  String get sectionGreenFlags => 'Signaux positifs';

  @override
  String get sectionAttachment => 'Styles d\'attachement';

  @override
  String get sectionTurningPoints => 'Tournants';

  @override
  String deepDiveBuy(String price) {
    return 'Débloquer pour $price';
  }

  @override
  String get deepDiveOneTime =>
      'Paiement unique pour ce rapport. Ce n\'est pas un abonnement.';

  @override
  String get deepDiveUnavailable =>
      'Les achats sont indisponibles pour le moment. Réessayez plus tard.';

  @override
  String get deepDivePending =>
      'Votre paiement est en attente. Ce rapport sera débloqué dès qu\'il aboutira.';

  @override
  String get deepDiveFailed => 'L\'achat n\'a pas abouti. Veuillez réessayer.';

  @override
  String get deepDiveUseCredit => 'Débloquer avec votre crédit déjà payé';

  @override
  String get deepDiveDisclaimer =>
      'Une lecture par IA pour réfléchir, pas un diagnostic.';

  @override
  String get deepDiveNoRedFlags =>
      'Aucun signal d\'alerte net dans ces messages.';

  @override
  String get deepDiveNoGreenFlags =>
      'Aucun signal positif net dans ces messages.';

  @override
  String get attachmentLoopLabel => 'Le schéma entre vous';

  @override
  String get sampleDeepDiveHint =>
      'Votre propre rapport inclura cette section.';

  @override
  String get savedTitle => 'Mes rapports';

  @override
  String savedSubtitle(int count) {
    return '$count enregistrés sur ce téléphone';
  }

  @override
  String get savedNote =>
      'Les rapports sont enregistrés uniquement sur ce téléphone. Désinstaller l\'app les supprime.';

  @override
  String get savedEmpty => 'Aucun rapport enregistré pour l\'instant.';

  @override
  String get savedDeleteTitle => 'Supprimer ce rapport ?';

  @override
  String get savedDeleteBody =>
      'Il sera impossible de le récupérer. Si vous avez payé pour le débloquer, ce déblocage est aussi perdu.';

  @override
  String get savedDeleteConfirm => 'Supprimer';

  @override
  String get savedDeleteCancel => 'Conserver';

  @override
  String get savedUnlockedBadge => 'Analyse approfondie débloquée';

  @override
  String get coachEntryTitle => 'Demander au coach IA';

  @override
  String get coachEntrySubtitle => 'Posez vos questions sur ce rapport';

  @override
  String get coachTitle => 'Coach IA';

  @override
  String get coachDisclaimer =>
      'Le coach est une IA : il peut se tromper et ne remplace pas une aide professionnelle.';

  @override
  String get coachHint => 'Posez une question sur cette relation…';

  @override
  String get coachSlow =>
      'L\'IA met plus de temps que d\'habitude. Nouvel essai…';

  @override
  String get coachSend => 'Envoyer';

  @override
  String get coachSuggest1 =>
      'Pourquoi se dispute-t-on toujours pour la même chose ?';

  @override
  String get coachSuggest2 => 'Comment aborder un sujet difficile ?';

  @override
  String get coachSuggest3 => 'Sur quoi devrais-je travailler d\'abord ?';

  @override
  String coachLeft(int count) {
    return 'Il vous reste $count questions';
  }

  @override
  String get coachOutTitle => 'Vos questions gratuites sont épuisées';

  @override
  String get coachOutBody =>
      'Débloquez ce rapport pour continuer à poser des questions. L\'analyse approfondie et des conseils personnalisés sont aussi inclus.';

  @override
  String get coachReportTitle => 'Signaler cette réponse';

  @override
  String get coachReportOffensive => 'Offensante ou inappropriée';

  @override
  String get coachReportHarmful => 'Conseil nuisible ou dangereux';

  @override
  String get coachReportWrong => 'Fausse ou inventée';

  @override
  String get coachReportThanks =>
      'Merci, nous avons bien reçu votre signalement.';
}
