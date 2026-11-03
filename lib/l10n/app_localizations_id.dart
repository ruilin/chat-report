// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class LId extends L {
  LId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Chat Report';

  @override
  String get tagline => 'Sebenarnya, ada apa di chat kamu?';

  @override
  String get homeImportTitle => 'Impor file ekspor chat';

  @override
  String get homeImportSubtitle => 'Laporan hubungan lengkap';

  @override
  String get homeImportHint =>
      'Ada panduan langkah demi langkah — cuma sekitar 30 detik  →';

  @override
  String get homePasteTitle => 'Tempel percakapan';

  @override
  String get homePasteSubtitle => 'Baca cepat · gratis · 30 detik';

  @override
  String get homePrivacy =>
      'Analisis berjalan di HP kamu. Chat kamu tidak pernah disimpan — langsung dihapus begitu laporanmu siap.';

  @override
  String get pasteSheetTitle => 'Tempel percakapan';

  @override
  String get pasteSheetSubtitle =>
      'Salin pesan dari chat mana pun, lalu tempel di sini.';

  @override
  String get pasteSheetHint => '[21/03/24, 21.41] Sam: hai, masih bangun?…';

  @override
  String get pasteSheetAction => 'Baca chat ini';

  @override
  String get guideTitle => 'Ekspor chat kamu';

  @override
  String get guideSubtitle => 'Cuma sekitar 30 detik di WhatsApp.';

  @override
  String get guideStep1Title => 'Buka WhatsApp';

  @override
  String get guideStep1Detail => 'Masuk ke chat yang mau kamu analisis.';

  @override
  String get guideStep2Title => 'Ketuk menu ⋮ → Lainnya → Ekspor chat';

  @override
  String get guideStep2Detail => 'Di iPhone: ketuk nama kontak → Ekspor Chat.';

  @override
  String get guideStep3Title => 'Pilih \"Tanpa media\"';

  @override
  String get guideStep3Detail =>
      'Teks saja — file lebih kecil, analisis lebih cepat.';

  @override
  String get guideStep4Title => 'Simpan file .txt, lalu balik ke sini';

  @override
  String get guideStep4Detail =>
      'Simpan ke File / Unduhan, lalu balik ke sini dan pilih.';

  @override
  String get guideOpenWhatsApp => 'Buka WhatsApp';

  @override
  String get guidePickFile => 'File sudah ada — pilih';

  @override
  String get guidePrivacy =>
      'File ekspor tidak keluar dari HP kamu sampai kamu ketuk Analisis.';

  @override
  String get guideOpenFailed => 'Gagal membuka WhatsApp — sudah terpasang?';

  @override
  String get setupTitle => 'Ini chat sama siapa?';

  @override
  String get setupSubtitle => 'File ekspor kamu ketemu — kelihatannya oke.';

  @override
  String setupChatWith(String name) {
    return 'Chat dengan $name';
  }

  @override
  String setupMessageCount(int count, String range) {
    return '$count pesan · $range';
  }

  @override
  String get setupWhichIsYou => 'Yang mana kamu?';

  @override
  String get setupRelationship => 'Hubungan';

  @override
  String get setupAnalyze => 'Analisis chat kita';

  @override
  String get setupPrivacy => 'Nama disamarkan di semua yang kamu bagikan.';

  @override
  String get relPartner => '💘 Pasangan';

  @override
  String get relCrush => '👀 Gebetan';

  @override
  String get relFriend => '🫶 Teman';

  @override
  String get relEx => '🌧 Mantan';

  @override
  String get relFamily => '🏡 Keluarga';

  @override
  String get analyzing => 'MENGANALISIS';

  @override
  String get quip1 => 'Merasakan naik-turunnya mood…';

  @override
  String get quip2 => 'Menghitung chat tengah malam…';

  @override
  String get quip3 => 'Melihat siapa yang duluan bilang selamat tidur…';

  @override
  String get quip4 => 'Membaca yang tersirat…';

  @override
  String stageReading(int count) {
    return 'Membaca $count pesan';
  }

  @override
  String get stageCounting => 'Menghitung siapa yang chat duluan';

  @override
  String get stageBetweenLines => 'Membaca yang tersirat';

  @override
  String get stageWriting => 'Menulis laporanmu';

  @override
  String get analyzingPrivacy =>
      'Chat langsung dihapus dari server kami begitu proses ini selesai.';

  @override
  String get errorTitle => 'Ada yang salah';

  @override
  String get errorRetry => 'Coba lagi';

  @override
  String reportYouAnd(String name) {
    return 'Kamu & $name';
  }

  @override
  String reportMessages(int count) {
    return '$count pesan';
  }

  @override
  String get sectionWarmth => 'Kehangatan hubungan';

  @override
  String get sectionBalance => 'Keseimbangan';

  @override
  String get sectionEmotionCurve => 'Kurva emosi · per bulan';

  @override
  String get sectionTopics => 'Yang kalian obrolin';

  @override
  String get sectionPersonalities => 'Kepribadian chat';

  @override
  String get sectionFullReading => 'Bacaan lengkap';

  @override
  String get sectionMilestones => 'Momen penting';

  @override
  String get sectionAdvice => 'Bekal ke depan';

  @override
  String get labelYou => 'Kamu';

  @override
  String get labelMessagesSent => 'Pesan terkirim';

  @override
  String get labelWhoTextsFirst => 'Siapa yang chat duluan';

  @override
  String get labelYourReplyTime => 'WAKTU BALASMU';

  @override
  String labelTheirReplyTime(String name) {
    return 'WAKTU BALAS $name';
  }

  @override
  String get curveNotEnough => 'Belum cukup bulan untuk bikin kurva';

  @override
  String get shareTitle => 'Bagikan ceritamu';

  @override
  String get shareSubtitle => 'Nama otomatis disingkat jadi inisial.';

  @override
  String get shareAction => 'Bagikan gambar';

  @override
  String get sharePreparing => 'Menyiapkan…';

  @override
  String shareFailed(String error) {
    return 'Gagal membagikan: $error';
  }

  @override
  String get shareCardBrand => 'CHAT REPORT';

  @override
  String get shareCardWarmth => 'KEHANGATAN HUBUNGAN';

  @override
  String get shareCardWatermark => 'DIBUAT DENGAN CHAT REPORT';

  @override
  String shareCardYears(int count) {
    return '$count tahun chatting';
  }

  @override
  String shareCardMonths(int count) {
    return '$count bulan chatting';
  }

  @override
  String get shareCardOurChat => 'chat kita';

  @override
  String shareCardMessages(int late) {
    return 'pesan · $late tengah malam';
  }

  @override
  String shareCardStarted(String initial) {
    return 'obrolan dimulai oleh $initial';
  }

  @override
  String get shareCardWarmestMonth => 'jadi bulan paling hangat';

  @override
  String get shareText => 'Chat kita, dibaca oleh Chat Report';

  @override
  String parseUnrecognized(int count) {
    return 'Format ekspor tidak dikenali (cuma $count baris yang terbaca)';
  }

  @override
  String parseTooFew(int count) {
    return 'Pesannya kurang banyak ($count) — coba pakai opsi tempel aja';
  }

  @override
  String errorAllChunksFailed(String detail) {
    return 'Analisis gagal untuk semua bulan. $detail';
  }

  @override
  String get errorNoConnection =>
      'Gagal terhubung ke layanan analisis. Cek koneksi kamu lalu coba lagi.';

  @override
  String get errorEmptyResponse => 'Layanan analisis mengirim respons kosong.';

  @override
  String get errorRateLimited =>
      'Layanan analisis lagi kebanjiran permintaan. Coba lagi sebentar lagi.';
}
