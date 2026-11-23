// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class LTr extends L {
  LTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Chat Report';

  @override
  String get tagline => 'Sohbetlerin aslında ne anlatıyor?';

  @override
  String get homeImportTitle => 'Dışa aktarılan sohbeti yükle';

  @override
  String get homeImportSubtitle => 'Tam ilişki raporu';

  @override
  String get homeImportHint =>
      'Adım adım rehber içeride — yaklaşık 30 saniye  →';

  @override
  String get homePasteTitle => 'Bir sohbet yapıştır';

  @override
  String get homePasteSubtitle => 'Hızlı okuma · ücretsiz · 30 saniye';

  @override
  String get homePrivacy =>
      'İstatistikler telefonunda hesaplanır. Raporunu yazmak için mesajların yapay zekâ sağlayıcımıza gönderilir — onları asla saklamayız.';

  @override
  String get homeSampleTitle => 'Önce örnek bir rapora göz at';

  @override
  String get homeSampleSubtitle =>
      'Kurgusal bir sohbetten · dışa aktarma gerekmez';

  @override
  String get sampleBanner =>
      'Bu, Alex ile Mia arasındaki kurgusal bir sohbetten oluşturulmuş örnek bir rapor. Seninki kendi mesajlarından oluşturulur.';

  @override
  String get sampleCta => 'Kendi sohbetimi analiz et';

  @override
  String get pasteSheetTitle => 'Bir sohbet yapıştır';

  @override
  String get pasteSheetSubtitle =>
      'Herhangi bir sohbetten mesajları kopyala ve buraya yapıştır.';

  @override
  String get pasteSheetHint => '[21.03.24, 21:41] Sam: hey, uyanık mısın?…';

  @override
  String get pasteSheetAction => 'Bu sohbeti oku';

  @override
  String get guideTitle => 'Sohbetini dışa aktar';

  @override
  String get guideSubtitle => 'WhatsApp\'ta yaklaşık 30 saniye sürer.';

  @override
  String get guideStep1Title => 'WhatsApp\'ı aç';

  @override
  String get guideStep1Detail => 'Analiz etmek istediğin sohbete git.';

  @override
  String get guideStep2Title => '⋮ menüsüne dokun → Diğer → Sohbeti dışa aktar';

  @override
  String get guideStep2Detail =>
      'iPhone\'da: kişinin adına dokun → Sohbeti Dışa Aktar.';

  @override
  String get guideStep3Title => '“Medya olmadan” seçeneğini seç';

  @override
  String get guideStep3Detail =>
      'Sadece metin — daha küçük dosya, daha hızlı analiz.';

  @override
  String get guideStep4Title => 'Paylaşım listesinde Chat Report\'u seç';

  @override
  String get guideStep4Detail =>
      'Göremiyor musun? Dosyayı kaydet, sonra aşağıdan seç.';

  @override
  String get guideOpenWhatsApp => 'WhatsApp\'ı aç';

  @override
  String get guidePickFile => 'Dosya hazır — seç';

  @override
  String get guidePrivacy =>
      'Sen “Analiz et” butonuna dokunmadan dosya telefonundan çıkmaz.';

  @override
  String get guideOpenFailed => 'WhatsApp açılamadı — yüklü mü?';

  @override
  String get shareImportNoChat =>
      'Paylaştığın içerikte sohbet bulunamadı. WhatsApp\'ta Sohbeti dışa aktar\'ı kullan ve \"Medya olmadan\" seçeneğini seç.';

  @override
  String get setupTitle => 'Bu sohbet kiminle?';

  @override
  String get setupSubtitle =>
      'Dışa aktarımını bulduk — her şey yolunda görünüyor.';

  @override
  String setupChatWith(String name) {
    return '$name ile sohbet';
  }

  @override
  String setupMessageCount(int count, String range) {
    return '$count mesaj · $range';
  }

  @override
  String get setupWhichIsYou => 'Hangisi sensin?';

  @override
  String get setupRelationship => 'İlişki';

  @override
  String get setupAnalyze => 'Analiz et';

  @override
  String get setupPrivacy => 'Paylaştığın her şeyde isimler anonimleştirilir.';

  @override
  String get relPartner => '💘 Sevgili';

  @override
  String get relCrush => '👀 Crush';

  @override
  String get relFriend => '🫶 Arkadaş';

  @override
  String get relEx => '🌧 Eski sevgili';

  @override
  String get relFamily => '🏡 Aile';

  @override
  String get analyzing => 'ANALİZ EDİLİYOR';

  @override
  String get quip1 => 'Duygu dalgalanmalarını hissediyoruz…';

  @override
  String get quip2 => 'Gece yarısı mesajlarını sayıyoruz…';

  @override
  String get quip3 => 'İlk kimin iyi geceler dediğine bakıyoruz…';

  @override
  String get quip4 => 'Satır aralarını okuyoruz…';

  @override
  String stageReading(int count) {
    return '$count mesaj okunuyor';
  }

  @override
  String get stageCounting => 'Kimin önce yazdığı hesaplanıyor';

  @override
  String get stageBetweenLines => 'Satır araları okunuyor';

  @override
  String get stageWriting => 'Raporun yazılıyor';

  @override
  String get analyzingPrivacy =>
      'Mesajların yalnızca bu raporu yazmak için yapay zekâ sağlayıcımıza gönderilir. Onları saklamayız.';

  @override
  String get consentTitle => 'Analizden önce';

  @override
  String get consentBody =>
      'Mesaj sayıları ve yanıt süreleri telefonunda hesaplanır. Raporunu yazmak için bu sohbetin metni (karşı tarafın mesajları ve isimler dahil) şifreli bağlantıyla yapay zekâ sağlayıcımız Z.ai\'ye gönderilir. Bunu saklamayız. Yalnızca dahil olduğun sohbetleri analiz et.';

  @override
  String get consentAgree => 'Kabul et ve analiz et';

  @override
  String get consentCancel => 'Şimdi değil';

  @override
  String get errorTitle => 'Bir şeyler ters gitti';

  @override
  String get errorRetry => 'Tekrar dene';

  @override
  String reportYouAnd(String name) {
    return 'Sen & $name';
  }

  @override
  String reportMessages(int count) {
    return '$count mesaj';
  }

  @override
  String get sectionWarmth => 'İlişki sıcaklığı';

  @override
  String get sectionBalance => 'Denge';

  @override
  String get sectionEmotionCurve => 'Duygu eğrisi · aylara göre';

  @override
  String get sectionTopics => 'Neler konuşuyorsunuz';

  @override
  String get sectionPersonalities => 'Sohbet kişilikleri';

  @override
  String get sectionFullReading => 'Detaylı yorum';

  @override
  String get sectionMilestones => 'Dönüm noktaları';

  @override
  String get sectionAdvice => 'Yol azığı';

  @override
  String get labelYou => 'Sen';

  @override
  String get labelMessagesSent => 'Gönderilen mesajlar';

  @override
  String get labelWhoTextsFirst => 'İlk kim yazıyor';

  @override
  String get labelYourReplyTime => 'SENİN YANIT SÜREN';

  @override
  String labelTheirReplyTime(String name) {
    return '$name · YANIT SÜRESİ';
  }

  @override
  String get curveNotEnough => 'Eğri için henüz yeterli ay yok';

  @override
  String get shareTitle => 'Hikayeni paylaş';

  @override
  String get shareSubtitle =>
      'İsimler otomatik olarak baş harflere kısaltılır.';

  @override
  String get shareAction => 'Görseli paylaş';

  @override
  String get sharePreparing => 'Hazırlanıyor…';

  @override
  String shareFailed(String error) {
    return 'Paylaşılamadı: $error';
  }

  @override
  String get shareCardBrand => 'CHAT REPORT';

  @override
  String get shareCardWarmth => 'İLİŞKİ SICAKLIĞI';

  @override
  String get shareCardWatermark => 'CHAT REPORT İLE YAPILDI';

  @override
  String get shareCardScan => 'Tara, kendi sohbetini analiz et';

  @override
  String get shareFormatTall => 'Durum ve hikâyeler için dikey format';

  @override
  String shareCardYears(int count) {
    return '$count yıllık mesajlaşma';
  }

  @override
  String shareCardMonths(int count) {
    return '$count aylık mesajlaşma';
  }

  @override
  String get shareCardOurChat => 'sohbetimiz';

  @override
  String shareCardMessages(int late) {
    return 'mesaj · $late tanesi gece yarısı';
  }

  @override
  String shareCardStarted(String initial) {
    return 'sohbeti $initial başlattı';
  }

  @override
  String get shareCardWarmestMonth => 'en sıcak aydı';

  @override
  String get shareText => 'Sohbetimiz, Chat Report\'un gözünden';

  @override
  String parseUnrecognized(int count) {
    return 'Dışa aktarma biçimi tanınamadı (yalnızca $count satır okunabildi)';
  }

  @override
  String parseTooFew(int count) {
    return 'Yeterli mesaj yok ($count) — bunun yerine yapıştırmayı dene';
  }

  @override
  String errorAllChunksFailed(String detail) {
    return 'Hiçbir ay analiz edilemedi. $detail';
  }

  @override
  String get errorNoConnection =>
      'Analiz hizmetine ulaşılamadı. Bağlantını kontrol edip tekrar dene.';

  @override
  String get errorServiceUnavailable =>
      'Analiz hizmeti şu anda kullanılamıyor. Lütfen daha sonra tekrar dene.';

  @override
  String get errorEmptyResponse => 'Analiz hizmeti boş yanıt döndü.';

  @override
  String get errorRateLimited =>
      'Analiz hizmeti şu an çok fazla istek alıyor. Birazdan tekrar dene.';

  @override
  String get unlockTitle => 'Tam raporun kilidini aç';

  @override
  String get unlockSubtitle =>
      'Her bulgunun ardındaki mesajlarla derin analiz, kişisel öneriler ve bu rapor için yapay zekâ koçu.';

  @override
  String get deepDiveTitle => 'Derin analiz';

  @override
  String get attachmentAnxious => 'Kaygılı eğilim';

  @override
  String get attachmentAvoidant => 'Kaçıngan eğilim';

  @override
  String get attachmentSecure => 'Güvenli eğilim';

  @override
  String get attachmentMixed => 'Karma';

  @override
  String get deepDiveMissing =>
      'Derin analiz bu kez oluşturulamadı. Yeniden denemek için bu sohbeti tekrar analiz edin.';

  @override
  String get deepDiveGenerating =>
      'Derin analizin hâlâ yazılıyor. Genellikle yaklaşık bir dakika sürer.';

  @override
  String get deepDiveSubtitle =>
      'Ücretsiz raporun değinmediği konular. Her bulgu, dayandığı mesajın kendisiyle birlikte gelir.';

  @override
  String get sectionConflict => 'Kavgalar ve barışmalar';

  @override
  String get sectionFourHorsemen => 'Dört Atlı';

  @override
  String get fourHorsemenIntro =>
      'Psikolog John Gottman, bu dört tartışma biçiminin ilişkilere en çok zarar verdiğini buldu.';

  @override
  String get fourHorsemenNone =>
      'Bu mesajlarda Dört Atlı\'nın belirgin bir işareti yok.';

  @override
  String get horsemanCriticism => 'Eleştiri';

  @override
  String get horsemanContempt => 'Küçümseme';

  @override
  String get horsemanDefensiveness => 'Savunmacılık';

  @override
  String get horsemanStonewalling => 'Duvar örme';

  @override
  String get antidoteCriticism =>
      'Bunun yerine dene: karşı tarafın nesinin yanlış olduğunu değil, durumu ve neye ihtiyacın olduğunu konuş.';

  @override
  String get antidoteContempt =>
      'Bunun yerine dene: neyi takdir ettiğini söyle, şikâyetlerini alay etmeden dile getir.';

  @override
  String get antidoteDefensiveness =>
      'Bunun yerine dene: sorunun en azından küçük bir kısmını üstlen.';

  @override
  String get antidoteStonewalling =>
      'Bunun yerine dene: sakinleşmek için kısa bir ara ver, sonra konuşmaya dön.';

  @override
  String get sectionLoveLanguages => 'Sevgi dilleri';

  @override
  String get loveLanguagesNote =>
      'Sevgi dilleri popüler bir yaklaşımdır, bilimsel bir test değildir. Bir başlangıç noktası olarak düşün.';

  @override
  String get loveWords => 'Onaylayıcı sözler';

  @override
  String get loveTime => 'Kaliteli zaman';

  @override
  String get loveGifts => 'Hediye almak';

  @override
  String get loveActs => 'Hizmet davranışları';

  @override
  String get loveTouch => 'Fiziksel temas';

  @override
  String get sectionRedFlags => 'Kırmızı bayraklar';

  @override
  String get sectionGreenFlags => 'Yeşil bayraklar';

  @override
  String get sectionAttachment => 'Bağlanma stilleri';

  @override
  String get sectionTurningPoints => 'Dönüm noktaları';

  @override
  String deepDiveBuy(String price) {
    return '$price ile kilidi aç';
  }

  @override
  String get deepDiveOneTime =>
      'Bu rapor için tek seferlik ödeme. Abonelik değildir.';

  @override
  String get deepDiveUnavailable =>
      'Satın alma şu anda kullanılamıyor. Lütfen daha sonra tekrar dene.';

  @override
  String get deepDivePending =>
      'Ödemen beklemede. Tamamlandığında bu raporun kilidi açılacak.';

  @override
  String get deepDiveFailed => 'Satın alma tamamlanmadı. Lütfen tekrar dene.';

  @override
  String get deepDiveUseCredit => 'Önceden ödediğin krediyle kilidi aç';

  @override
  String get deepDiveDisclaimer =>
      'Düşünmen için bir yapay zeka yorumu, teşhis değildir.';

  @override
  String get deepDiveNoRedFlags =>
      'Bu mesajlarda belirgin bir kırmızı bayrak yok.';

  @override
  String get deepDiveNoGreenFlags =>
      'Bu mesajlarda belirgin bir yeşil bayrak yok.';

  @override
  String get attachmentLoopLabel => 'Aranızdaki döngü';

  @override
  String get sampleDeepDiveHint => 'Kendi raporun bu bölümü içerecek.';

  @override
  String get samplePaidHint =>
      'Bu bölüm ücretlidir. Kendi raporunda bir bulguyu ücretsiz görürsün, kalanının kilidini açabilirsin.';

  @override
  String get previewLabel => 'Ücretsiz önizleme';

  @override
  String get savedTitle => 'Raporlarım';

  @override
  String savedSubtitle(int count) {
    return 'Bu telefonda $count rapor kayıtlı';
  }

  @override
  String get savedNote =>
      'Raporlar yalnızca bu telefonda saklanır. Uygulamayı kaldırınca silinir.';

  @override
  String get savedEmpty => 'Henüz kayıtlı rapor yok.';

  @override
  String get savedDeleteTitle => 'Bu rapor silinsin mi?';

  @override
  String get savedDeleteBody =>
      'Geri getirilemez. Kilidini ödeme yaparak açtıysan bu da kaybolur.';

  @override
  String get savedDeleteConfirm => 'Sil';

  @override
  String get savedDeleteCancel => 'Sakla';

  @override
  String get savedUnlockedBadge => 'Derin analizin kilidi açıldı';

  @override
  String get coachEntryTitle => 'Yapay zeka koçuna sor';

  @override
  String get coachEntrySubtitle => 'Bu raporla ilgili istediğini sor';

  @override
  String get coachTitle => 'Yapay zeka koçu';

  @override
  String get coachDisclaimer =>
      'Koç bir yapay zekâdır: hata yapabilir ve profesyonel yardımın yerini tutmaz.';

  @override
  String get coachHint => 'Bu ilişki hakkında sor…';

  @override
  String get coachSlow =>
      'Yapay zekâ her zamankinden yavaş. Yeniden deneniyor…';

  @override
  String get coachSend => 'Gönder';

  @override
  String get coachSuggest1 => 'Neden hep aynı şey için kavga ediyoruz?';

  @override
  String get coachSuggest2 => 'Zor bir konuyu nasıl açabilirim?';

  @override
  String get coachSuggest3 => 'Önce neyi geliştirmeliyim?';

  @override
  String coachLeft(int count) {
    return '$count soru hakkın kaldı';
  }

  @override
  String get coachOutTitle => 'Ücretsiz soruların bitti';

  @override
  String get coachOutBody =>
      'Sormaya devam etmek için bu raporun kilidini aç. Derin analiz ve kişisel öneriler de dahil.';

  @override
  String get coachReportTitle => 'Bu yanıtı bildir';

  @override
  String get coachReportOffensive => 'Rahatsız edici veya uygunsuz';

  @override
  String get coachReportHarmful => 'Zararlı veya güvensiz tavsiye';

  @override
  String get coachReportWrong => 'Yanlış veya uydurma';

  @override
  String get coachReportThanks => 'Teşekkürler, bildirimini aldık.';

  @override
  String draftsEntryTitle(String name) {
    return '$name için yaz';
  }

  @override
  String get draftsEntrySubtitle =>
      'Yapay zekâ bir mesaj taslağı yazar. Sen düzenler ve kendin gönderirsin.';

  @override
  String get draftNote =>
      'Bunlar yapay zekâ taslakları. Bir şey göndermeden önce kendi cümlelerinle yaz.';

  @override
  String get draftAppreciate => 'Takdirini söyle';

  @override
  String get draftAppreciateHint => 'Karşı tarafın iyi yaptığı somut bir şey';

  @override
  String get draftRepair => 'Kavgadan sonra onar';

  @override
  String get draftRepairHint =>
      'Hep tartıştığınız konuyu sakince açmanın bir yolu';

  @override
  String get draftAsk => 'İhtiyacını iste';

  @override
  String get draftAskHint => 'Suçlamadan, açık bir rica';

  @override
  String get draftWrite => 'Taslak yaz';

  @override
  String get draftWriting => 'Yazılıyor…';

  @override
  String get draftAgain => 'Başka bir tane';

  @override
  String get draftCopy => 'Kopyala';

  @override
  String get draftSend => 'Gönder';

  @override
  String get draftCopied => 'Kopyalandı';

  @override
  String get draftLocked => 'Bunları kullanmak için raporun kilidini aç.';

  @override
  String get draftExNote =>
      'Burada eski sevgiliye mesaj taslağı yazmıyoruz. Kendi düşüncelerini toparlamak için yapay zekâ koçunu dene.';

  @override
  String get draftUnsafe =>
      'Bu sohbette endişe verici şeyler var, bu yüzden mesaj taslağı yazmak doğru adım değil. Kendini güvende hissetmiyorsan güvendiğin birine ya da yerel bir yardım hattına ulaş.';
}
