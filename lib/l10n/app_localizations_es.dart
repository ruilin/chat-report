// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class LEs extends L {
  LEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Chat Report';

  @override
  String get tagline => '¿Qué dicen de verdad tus chats?';

  @override
  String get homeImportTitle => 'Importa un chat exportado';

  @override
  String get homeImportSubtitle => 'Informe completo de tu relación';

  @override
  String get homeImportHint => 'Con guía paso a paso — unos 30 segundos  →';

  @override
  String get homePasteTitle => 'Pega una conversación';

  @override
  String get homePasteSubtitle => 'Lectura rápida · gratis · 30 segundos';

  @override
  String get homePrivacy =>
      'Las estadísticas se calculan en tu teléfono. Para escribir tu informe, tus mensajes se envían a nuestro proveedor de IA; nunca los guardamos.';

  @override
  String get pasteSheetTitle => 'Pega una conversación';

  @override
  String get pasteSheetSubtitle =>
      'Copia mensajes de cualquier chat y pégalos aquí.';

  @override
  String get pasteSheetHint =>
      '[21/03/24, 21:41] Sam: hola, ¿estás despierto?…';

  @override
  String get pasteSheetAction => 'Leer este chat';

  @override
  String get guideTitle => 'Exporta tu chat';

  @override
  String get guideSubtitle => 'En WhatsApp tarda unos 30 segundos.';

  @override
  String get guideStep1Title => 'Abre WhatsApp';

  @override
  String get guideStep1Detail => 'Entra al chat que quieres analizar.';

  @override
  String get guideStep2Title => 'Toca el menú ⋮ → Más → Exportar chat';

  @override
  String get guideStep2Detail =>
      'En iPhone: toca el nombre del contacto → Exportar chat.';

  @override
  String get guideStep3Title => 'Elige \"Sin archivos\"';

  @override
  String get guideStep3Detail =>
      'Solo texto — archivo más ligero, análisis más rápido.';

  @override
  String get guideStep4Title => 'Guarda el .txt y vuelve';

  @override
  String get guideStep4Detail =>
      'Guárdalo en Archivos / Descargas, vuelve aquí y elígelo.';

  @override
  String get guideOpenWhatsApp => 'Abrir WhatsApp';

  @override
  String get guidePickFile => 'Ya tengo el archivo — elegirlo';

  @override
  String get guidePrivacy =>
      'El archivo no sale de tu teléfono hasta que tocas Analizar.';

  @override
  String get guideOpenFailed =>
      'No se pudo abrir WhatsApp. ¿Lo tienes instalado?';

  @override
  String get setupTitle => '¿Con quién es este chat?';

  @override
  String get setupSubtitle => 'Encontramos tu archivo — todo bien.';

  @override
  String setupChatWith(String name) {
    return 'Chat con $name';
  }

  @override
  String setupMessageCount(int count, String range) {
    return '$count mensajes · $range';
  }

  @override
  String get setupWhichIsYou => '¿Quién eres tú?';

  @override
  String get setupRelationship => 'Relación';

  @override
  String get setupAnalyze => 'Analizar nuestro chat';

  @override
  String get setupPrivacy =>
      'Los nombres se anonimizan en todo lo que compartas.';

  @override
  String get relPartner => '💘 Pareja';

  @override
  String get relCrush => '👀 Crush';

  @override
  String get relFriend => '🫶 Amistad';

  @override
  String get relEx => '🌧 Ex';

  @override
  String get relFamily => '🏡 Familia';

  @override
  String get analyzing => 'ANALIZANDO';

  @override
  String get quip1 => 'Sintiendo los cambios de humor…';

  @override
  String get quip2 => 'Contando los mensajes de madrugada…';

  @override
  String get quip3 => 'Viendo quién dice buenas noches primero…';

  @override
  String get quip4 => 'Leyendo entre líneas…';

  @override
  String stageReading(int count) {
    return 'Leyendo $count mensajes';
  }

  @override
  String get stageCounting => 'Contando quién escribe primero';

  @override
  String get stageBetweenLines => 'Leyendo entre líneas';

  @override
  String get stageWriting => 'Escribiendo tu informe';

  @override
  String get analyzingPrivacy =>
      'Tus mensajes se envían a nuestro proveedor de IA solo para escribir este informe. No los guardamos.';

  @override
  String get consentTitle => 'Antes de analizar';

  @override
  String get consentBody =>
      'Los conteos y tiempos de respuesta se calculan en tu teléfono. Para escribir tu informe, el texto de este chat —incluidos los mensajes y nombres de la otra persona— se envía por una conexión cifrada a nuestro proveedor de IA, Z.ai. No lo guardamos. Analiza solo chats en los que participas.';

  @override
  String get consentAgree => 'Aceptar y analizar';

  @override
  String get consentCancel => 'Ahora no';

  @override
  String get errorTitle => 'Algo salió mal';

  @override
  String get errorRetry => 'Reintentar';

  @override
  String reportYouAnd(String name) {
    return 'Tú y $name';
  }

  @override
  String reportMessages(int count) {
    return '$count mensajes';
  }

  @override
  String get sectionWarmth => 'Calidez de la relación';

  @override
  String get sectionBalance => 'Equilibrio';

  @override
  String get sectionEmotionCurve => 'Curva emocional · por mes';

  @override
  String get sectionTopics => 'De qué hablan';

  @override
  String get sectionPersonalities => 'Personalidades en el chat';

  @override
  String get sectionFullReading => 'La lectura completa';

  @override
  String get sectionMilestones => 'Momentos clave';

  @override
  String get sectionAdvice => 'Para el camino';

  @override
  String get labelYou => 'Tú';

  @override
  String get labelMessagesSent => 'Mensajes enviados';

  @override
  String get labelWhoTextsFirst => 'Quién escribe primero';

  @override
  String get labelYourReplyTime => 'TU TIEMPO DE RESPUESTA';

  @override
  String labelTheirReplyTime(String name) {
    return 'TIEMPO DE RESPUESTA DE $name';
  }

  @override
  String get curveNotEnough => 'Aún no hay suficientes meses para una curva';

  @override
  String get shareTitle => 'Comparte su historia';

  @override
  String get shareSubtitle =>
      'Los nombres se acortan a iniciales automáticamente.';

  @override
  String get shareAction => 'Compartir imagen';

  @override
  String get sharePreparing => 'Preparando…';

  @override
  String shareFailed(String error) {
    return 'No se pudo compartir: $error';
  }

  @override
  String get shareCardBrand => 'CHAT REPORT';

  @override
  String get shareCardWarmth => 'CALIDEZ DE LA RELACIÓN';

  @override
  String get shareCardWatermark => 'HECHO CON CHAT REPORT';

  @override
  String shareCardYears(int count) {
    return '$count años de mensajes';
  }

  @override
  String shareCardMonths(int count) {
    return '$count meses de mensajes';
  }

  @override
  String get shareCardOurChat => 'nuestro chat';

  @override
  String shareCardMessages(int late) {
    return 'mensajes · $late de madrugada';
  }

  @override
  String shareCardStarted(String initial) {
    return 'de las charlas iniciadas por $initial';
  }

  @override
  String get shareCardWarmestMonth => 'fue el mes más cálido';

  @override
  String get shareText => 'Nuestro chat, leído por Chat Report';

  @override
  String parseUnrecognized(int count) {
    return 'No se reconoció el formato del archivo (líneas leídas: $count)';
  }

  @override
  String parseTooFew(int count) {
    return 'No hay suficientes mensajes ($count) — prueba a pegar la conversación';
  }

  @override
  String errorAllChunksFailed(String detail) {
    return 'El análisis falló en todos los meses. $detail';
  }

  @override
  String get errorNoConnection =>
      'No se pudo conectar con el servicio de análisis. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get errorEmptyResponse =>
      'El servicio de análisis devolvió una respuesta vacía.';

  @override
  String get errorRateLimited =>
      'El servicio de análisis está limitando las solicitudes. Inténtalo de nuevo en un momento.';
}
