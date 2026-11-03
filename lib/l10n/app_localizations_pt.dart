// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class LPt extends L {
  LPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Chat Report';

  @override
  String get tagline => 'O que suas conversas dizem de verdade?';

  @override
  String get homeImportTitle => 'Importe uma conversa exportada';

  @override
  String get homeImportSubtitle => 'Relatório completo da relação';

  @override
  String get homeImportHint =>
      'Com guia passo a passo — leva uns 30 segundos  →';

  @override
  String get homePasteTitle => 'Cole uma conversa';

  @override
  String get homePasteSubtitle => 'Leitura rápida · grátis · 30 segundos';

  @override
  String get homePrivacy =>
      'As estatísticas são calculadas no seu celular. Para escrever o relatório, suas mensagens vão para nosso provedor de IA — nunca as guardamos.';

  @override
  String get pasteSheetTitle => 'Cole uma conversa';

  @override
  String get pasteSheetSubtitle =>
      'Copie mensagens de qualquer conversa e cole aqui.';

  @override
  String get pasteSheetHint => '[21/03/24, 21:41] Sam: oi, tá acordado?…';

  @override
  String get pasteSheetAction => 'Ler esta conversa';

  @override
  String get guideTitle => 'Exporte sua conversa';

  @override
  String get guideSubtitle => 'Leva uns 30 segundos no WhatsApp.';

  @override
  String get guideStep1Title => 'Abra o WhatsApp';

  @override
  String get guideStep1Detail => 'Vá até a conversa que você quer analisar.';

  @override
  String get guideStep2Title => 'Toque no menu ⋮ → Mais → Exportar conversa';

  @override
  String get guideStep2Detail =>
      'No iPhone: toque no nome do contato → Exportar conversa.';

  @override
  String get guideStep3Title => 'Escolha \"Sem mídia\"';

  @override
  String get guideStep3Detail =>
      'Só texto — arquivo menor, análise mais rápida.';

  @override
  String get guideStep4Title => 'Salve o .txt e volte aqui';

  @override
  String get guideStep4Detail =>
      'Salve em Arquivos / Downloads, volte e selecione.';

  @override
  String get guideOpenWhatsApp => 'Abrir WhatsApp';

  @override
  String get guidePickFile => 'Já tenho o arquivo — escolher';

  @override
  String get guidePrivacy =>
      'O arquivo não sai do seu celular até você tocar em Analisar.';

  @override
  String get guideOpenFailed =>
      'Não deu para abrir o WhatsApp. Ele está instalado?';

  @override
  String get setupTitle => 'Com quem é esta conversa?';

  @override
  String get setupSubtitle => 'Achamos seu arquivo — tudo certo.';

  @override
  String setupChatWith(String name) {
    return 'Conversa com $name';
  }

  @override
  String setupMessageCount(int count, String range) {
    return '$count mensagens · $range';
  }

  @override
  String get setupWhichIsYou => 'Qual é você?';

  @override
  String get setupRelationship => 'Relação';

  @override
  String get setupAnalyze => 'Analisar nossa conversa';

  @override
  String get setupPrivacy =>
      'Os nomes ficam anônimos em tudo que você compartilhar.';

  @override
  String get relPartner => '💘 Namoro';

  @override
  String get relCrush => '👀 Crush';

  @override
  String get relFriend => '🫶 Amizade';

  @override
  String get relEx => '🌧 Ex';

  @override
  String get relFamily => '🏡 Família';

  @override
  String get analyzing => 'ANALISANDO';

  @override
  String get quip1 => 'Sentindo as mudanças de humor…';

  @override
  String get quip2 => 'Contando as mensagens de madrugada…';

  @override
  String get quip3 => 'Vendo quem dá boa noite primeiro…';

  @override
  String get quip4 => 'Lendo nas entrelinhas…';

  @override
  String stageReading(int count) {
    return 'Lendo $count mensagens';
  }

  @override
  String get stageCounting => 'Contando quem puxa assunto primeiro';

  @override
  String get stageBetweenLines => 'Lendo nas entrelinhas';

  @override
  String get stageWriting => 'Escrevendo seu relatório';

  @override
  String get analyzingPrivacy =>
      'Suas mensagens são enviadas ao nosso provedor de IA só para escrever este relatório. Não as guardamos.';

  @override
  String get consentTitle => 'Antes de analisar';

  @override
  String get consentBody =>
      'Contagens e tempos de resposta são calculados no seu celular. Para escrever o relatório, o texto desta conversa — incluindo as mensagens e os nomes da outra pessoa — é enviado por uma conexão criptografada ao nosso provedor de IA, Z.ai. Não guardamos esse conteúdo. Analise só conversas das quais você participa.';

  @override
  String get consentAgree => 'Aceitar e analisar';

  @override
  String get consentCancel => 'Agora não';

  @override
  String get errorTitle => 'Algo deu errado';

  @override
  String get errorRetry => 'Tentar de novo';

  @override
  String reportYouAnd(String name) {
    return 'Você e $name';
  }

  @override
  String reportMessages(int count) {
    return '$count mensagens';
  }

  @override
  String get sectionWarmth => 'Calor da relação';

  @override
  String get sectionBalance => 'Equilíbrio';

  @override
  String get sectionEmotionCurve => 'Curva emocional · por mês';

  @override
  String get sectionTopics => 'Sobre o que vocês falam';

  @override
  String get sectionPersonalities => 'Personalidades no chat';

  @override
  String get sectionFullReading => 'A leitura completa';

  @override
  String get sectionMilestones => 'Marcos';

  @override
  String get sectionAdvice => 'Para levar com você';

  @override
  String get labelYou => 'Você';

  @override
  String get labelMessagesSent => 'Mensagens enviadas';

  @override
  String get labelWhoTextsFirst => 'Quem puxa assunto';

  @override
  String get labelYourReplyTime => 'SEU TEMPO DE RESPOSTA';

  @override
  String labelTheirReplyTime(String name) {
    return 'TEMPO DE RESPOSTA DE $name';
  }

  @override
  String get curveNotEnough => 'Ainda não há meses suficientes para uma curva';

  @override
  String get shareTitle => 'Compartilhe a história de vocês';

  @override
  String get shareSubtitle => 'Os nomes viram iniciais automaticamente.';

  @override
  String get shareAction => 'Compartilhar imagem';

  @override
  String get sharePreparing => 'Preparando…';

  @override
  String shareFailed(String error) {
    return 'Falha ao compartilhar: $error';
  }

  @override
  String get shareCardBrand => 'CHAT REPORT';

  @override
  String get shareCardWarmth => 'CALOR DA RELAÇÃO';

  @override
  String get shareCardWatermark => 'FEITO COM CHAT REPORT';

  @override
  String shareCardYears(int count) {
    return '$count anos de mensagens';
  }

  @override
  String shareCardMonths(int count) {
    return '$count meses de mensagens';
  }

  @override
  String get shareCardOurChat => 'nossa conversa';

  @override
  String shareCardMessages(int late) {
    return 'mensagens · $late de madrugada';
  }

  @override
  String shareCardStarted(String initial) {
    return 'das conversas começadas por $initial';
  }

  @override
  String get shareCardWarmestMonth => 'foi o mês mais quente';

  @override
  String get shareText => 'Nossa conversa, lida pelo Chat Report';

  @override
  String parseUnrecognized(int count) {
    return 'Não reconhecemos o formato do arquivo (linhas lidas: $count)';
  }

  @override
  String parseTooFew(int count) {
    return 'Mensagens insuficientes ($count) — tente colar a conversa';
  }

  @override
  String errorAllChunksFailed(String detail) {
    return 'A análise falhou em todos os meses. $detail';
  }

  @override
  String get errorNoConnection =>
      'Não foi possível acessar o serviço de análise. Verifique sua conexão e tente de novo.';

  @override
  String get errorEmptyResponse =>
      'O serviço de análise retornou uma resposta vazia.';

  @override
  String get errorRateLimited =>
      'O serviço de análise está limitando as solicitações. Tente de novo daqui a pouco.';
}
