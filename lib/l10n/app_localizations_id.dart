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
      'Statistik dihitung di HP kamu. Untuk menulis laporanmu, pesanmu dikirim ke penyedia AI kami — kami tidak pernah menyimpannya.';

  @override
  String get homeSampleTitle => 'Lihat contoh laporan dulu';

  @override
  String get homeSampleSubtitle => 'Dari chat rekaan · tanpa perlu ekspor';

  @override
  String get sampleBanner =>
      'Ini contoh laporan dari chat rekaan antara Alex dan Mia. Laporanmu akan dibuat dari pesanmu sendiri.';

  @override
  String get sampleCta => 'Analisis chat-ku';

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
  String get guideStep4Title => 'Pilih Chat Report di daftar berbagi';

  @override
  String get guideStep4Detail =>
      'Tidak muncul? Simpan filenya, lalu pilih di bawah.';

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
  String get shareImportNoChat =>
      'Tidak ada chat yang ditemukan dari yang kamu bagikan. Di WhatsApp, gunakan Ekspor chat dan pilih \"Tanpa media\".';

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
      'Pesanmu dikirim ke penyedia AI kami hanya untuk menulis laporan ini. Kami tidak menyimpannya.';

  @override
  String get consentTitle => 'Sebelum dianalisis';

  @override
  String get consentBody =>
      'Jumlah pesan dan waktu balas dihitung di HP kamu. Untuk menulis laporanmu, teks chat ini — termasuk pesan dan nama orang lain — dikirim lewat koneksi terenkripsi ke penyedia AI kami, Z.ai. Kami tidak menyimpannya. Analisis hanya chat yang kamu ikuti.';

  @override
  String get consentAgree => 'Setuju & analisis';

  @override
  String get consentCancel => 'Nanti saja';

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
  String get shareCardScan => 'Pindai untuk menganalisis obrolanmu';

  @override
  String get shareFormatTall => 'Format tegak untuk Status dan Story';

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
  String get errorServiceUnavailable =>
      'Layanan analisis sedang tidak tersedia. Coba lagi nanti ya.';

  @override
  String get errorEmptyResponse => 'Layanan analisis mengirim respons kosong.';

  @override
  String get errorRateLimited =>
      'Layanan analisis lagi kebanjiran permintaan. Coba lagi sebentar lagi.';

  @override
  String get unlockTitle => 'Buka laporan lengkap';

  @override
  String get unlockSubtitle =>
      'Analisis mendalam dengan pesan persis di balik setiap temuan, saran pribadi, dan pelatih AI untuk laporan ini.';

  @override
  String get deepDiveTitle => 'Analisis mendalam';

  @override
  String get attachmentAnxious => 'Cenderung cemas';

  @override
  String get attachmentAvoidant => 'Cenderung menghindar';

  @override
  String get attachmentSecure => 'Cenderung aman';

  @override
  String get attachmentMixed => 'Campuran';

  @override
  String get deepDiveMissing =>
      'Analisis mendalam gagal dibuat kali ini. Analisis ulang obrolan ini untuk mencoba lagi.';

  @override
  String get deepDiveGenerating =>
      'Analisis mendalammu masih ditulis. Biasanya butuh sekitar satu menit.';

  @override
  String get deepDiveSubtitle =>
      'Hal yang tidak dibahas laporan gratis. Setiap temuan disertai pesan persis yang mendasarinya.';

  @override
  String get sectionConflict => 'Pertengkaran dan berbaikan';

  @override
  String get sectionFourHorsemen => 'Empat Penunggang Kuda';

  @override
  String get fourHorsemenIntro =>
      'Psikolog John Gottman menemukan bahwa empat cara bertengkar ini paling merusak hubungan.';

  @override
  String get fourHorsemenNone =>
      'Tidak ada tanda jelas Empat Penunggang Kuda dalam pesan-pesan ini.';

  @override
  String get horsemanCriticism => 'Kritik';

  @override
  String get horsemanContempt => 'Penghinaan';

  @override
  String get horsemanDefensiveness => 'Sikap defensif';

  @override
  String get horsemanStonewalling => 'Menutup diri';

  @override
  String get antidoteCriticism =>
      'Coba sebagai gantinya: bicarakan situasinya dan apa yang kamu butuhkan, bukan apa yang salah dari dirinya.';

  @override
  String get antidoteContempt =>
      'Coba sebagai gantinya: sampaikan apa yang kamu hargai, dan utarakan keluhan tanpa mengejek.';

  @override
  String get antidoteDefensiveness =>
      'Coba sebagai gantinya: akui setidaknya sebagian kecil masalahnya.';

  @override
  String get antidoteStonewalling =>
      'Coba sebagai gantinya: ambil jeda sebentar untuk menenangkan diri, lalu lanjutkan obrolan.';

  @override
  String get sectionLoveLanguages => 'Bahasa cinta';

  @override
  String get loveLanguagesNote =>
      'Bahasa cinta adalah kerangka populer, bukan tes ilmiah. Anggap saja sebagai titik awal.';

  @override
  String get loveWords => 'Kata-kata penegasan';

  @override
  String get loveTime => 'Waktu berkualitas';

  @override
  String get loveGifts => 'Menerima hadiah';

  @override
  String get loveActs => 'Tindakan melayani';

  @override
  String get loveTouch => 'Sentuhan fisik';

  @override
  String get sectionRedFlags => 'Tanda bahaya';

  @override
  String get sectionGreenFlags => 'Tanda positif';

  @override
  String get sectionAttachment => 'Gaya kelekatan';

  @override
  String get sectionTurningPoints => 'Titik balik';

  @override
  String deepDiveBuy(String price) {
    return 'Buka seharga $price';
  }

  @override
  String get deepDiveOneTime =>
      'Pembayaran sekali untuk laporan ini. Bukan langganan.';

  @override
  String get deepDiveUnavailable =>
      'Pembelian belum tersedia saat ini. Coba lagi nanti.';

  @override
  String get deepDivePending =>
      'Pembayaranmu masih tertunda. Laporan ini terbuka setelah pembayaran selesai.';

  @override
  String get deepDiveFailed => 'Pembelian tidak selesai. Silakan coba lagi.';

  @override
  String get deepDiveUseCredit => 'Buka dengan kredit yang sudah dibayar';

  @override
  String get deepDiveDisclaimer =>
      'Bacaan AI untuk bahan renungan, bukan diagnosis.';

  @override
  String get deepDiveNoRedFlags =>
      'Tidak ada tanda bahaya yang jelas dalam pesan-pesan ini.';

  @override
  String get deepDiveNoGreenFlags =>
      'Tidak ada tanda positif yang jelas dalam pesan-pesan ini.';

  @override
  String get attachmentLoopLabel => 'Pola di antara kalian';

  @override
  String get sampleDeepDiveHint =>
      'Laporanmu sendiri akan mencakup bagian ini.';

  @override
  String get samplePaidHint =>
      'Bagian ini berbayar. Laporanmu sendiri menampilkan satu temuan gratis, dan sisanya bisa kamu buka.';

  @override
  String get previewLabel => 'Pratinjau gratis';

  @override
  String get savedTitle => 'Laporan saya';

  @override
  String savedSubtitle(int count) {
    return '$count tersimpan di ponsel ini';
  }

  @override
  String get savedNote =>
      'Laporan hanya disimpan di ponsel ini. Menghapus aplikasi akan menghapusnya.';

  @override
  String get savedEmpty => 'Belum ada laporan tersimpan.';

  @override
  String get savedDeleteTitle => 'Hapus laporan ini?';

  @override
  String get savedDeleteBody =>
      'Laporan tidak bisa dipulihkan. Jika kamu membayar untuk membukanya, akses itu juga hilang.';

  @override
  String get savedDeleteConfirm => 'Hapus';

  @override
  String get savedDeleteCancel => 'Simpan';

  @override
  String get savedUnlockedBadge => 'Analisis mendalam terbuka';

  @override
  String get coachEntryTitle => 'Tanya pelatih AI';

  @override
  String get coachEntrySubtitle => 'Tanyakan apa saja tentang laporan ini';

  @override
  String get coachTitle => 'Pelatih AI';

  @override
  String get coachDisclaimer =>
      'Pelatih ini adalah AI: bisa salah dan tidak menggantikan bantuan profesional.';

  @override
  String get coachHint => 'Tanya tentang hubungan ini…';

  @override
  String get coachSlow => 'AI lebih lambat dari biasanya. Mencoba lagi…';

  @override
  String get coachSend => 'Kirim';

  @override
  String get coachSuggest1 =>
      'Kenapa kami selalu bertengkar soal hal yang sama?';

  @override
  String get coachSuggest2 => 'Bagaimana cara membahas hal yang sulit?';

  @override
  String get coachSuggest3 => 'Apa yang sebaiknya kuperbaiki dulu?';

  @override
  String coachLeft(int count) {
    return 'Sisa $count pertanyaan';
  }

  @override
  String get coachOutTitle => 'Pertanyaan gratismu sudah habis';

  @override
  String get coachOutBody =>
      'Buka kunci laporan ini untuk terus bertanya. Termasuk analisis mendalam dan saran pribadi.';

  @override
  String get coachReportTitle => 'Laporkan jawaban ini';

  @override
  String get coachReportOffensive => 'Menyinggung atau tidak pantas';

  @override
  String get coachReportHarmful => 'Saran berbahaya atau tidak aman';

  @override
  String get coachReportWrong => 'Salah atau dibuat-buat';

  @override
  String get coachReportThanks => 'Terima kasih, laporanmu sudah kami terima.';

  @override
  String draftsEntryTitle(String name) {
    return 'Tulis untuk $name';
  }

  @override
  String get draftsEntrySubtitle =>
      'AI menulis draf pesan. Kamu mengeditnya dan mengirimnya sendiri.';

  @override
  String get draftNote =>
      'Ini draf dari AI. Tulis ulang dengan kata-katamu sendiri sebelum mengirim apa pun.';

  @override
  String get draftAppreciate => 'Sampaikan apresiasi';

  @override
  String get draftAppreciateHint =>
      'Satu hal spesifik yang dia lakukan dengan baik';

  @override
  String get draftRepair => 'Berbaikan setelah bertengkar';

  @override
  String get draftRepairHint =>
      'Pembuka yang tenang untuk hal yang selalu kalian ributkan';

  @override
  String get draftAsk => 'Minta yang kamu butuhkan';

  @override
  String get draftAskHint => 'Permintaan yang jelas, tanpa menyalahkan';

  @override
  String get draftWrite => 'Tulis draf';

  @override
  String get draftWriting => 'Menulis…';

  @override
  String get draftAgain => 'Coba yang lain';

  @override
  String get draftCopy => 'Salin';

  @override
  String get draftSend => 'Kirim';

  @override
  String get draftCopied => 'Tersalin';

  @override
  String get draftLocked => 'Buka kunci laporan ini untuk memakainya.';

  @override
  String get draftExNote =>
      'Di sini kami tidak menulis pesan untuk mantan. Untuk menata pikiranmu sendiri, coba pelatih AI.';

  @override
  String get draftUnsafe =>
      'Ada hal yang mengkhawatirkan di chat ini, jadi menulis draf pesan bukan langkah yang tepat. Jika kamu merasa tidak aman, hubungi orang yang kamu percaya atau layanan bantuan setempat.';
}
