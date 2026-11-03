# Google Play 商店文案 — Türkçe (tr-TR)

> 英文（默认语言）版见 [../en/LISTING.md](../en/LISTING.md)。本目录为土耳其语版素材：文案（本文件）、宣传图；截图暂无土耳其语版，见下方素材清单。
>
> 用 sen。功能名称与 App 界面一致（取自 `lib/l10n/app_tr.arb`：İlişki sıcaklığı / Denge / Duygu eğrisi / Neler konuşuyorsunuz / Sohbet kişilikleri / Detaylı yorum），完整说明首句即 `tagline`。
> 非逐字直译 —— 已按土耳其语营销文案的习惯改写。全大写小标题已按土耳其语规则处理 i→İ、ı→I，日后修改请勿用通用 `upper()` 覆盖。

---

## App name（上限 30 字符）

```
Chat Report: Sohbet Analizi
```
> 27 字符。⚠️ **不要在此处写 "WhatsApp"** —— 属他人商标，Play 会以冒充/商标侵权驳回。

备选：`Chat Report – İlişki Analizi`（28 字符）

---

## Short description（上限 80 字符）

```
Sohbetini içe aktar, 30 saniyede ilişkine dair yapay zekâ raporunu al.
```
> 70 字符。

---

## Full description（上限 4000 字符）

```
Sohbetlerin aslında ne anlatıyor?

Chat Report, dışa aktarılmış bir sohbet geçmişini ilişkin hakkında gerçek bir rapora dönüştürür — burç yorumu değil, gerçek mesajlara kadar izini sürebileceğin rakamlar.

NELER GÖRECEKSİN

• İlişki sıcaklığı — ilişkinizin şu an nasıl göründüğünü özetleyen, 0 ile 100 arasında tek bir puan
• Denge — kim daha çok yazıyor, sohbeti kim başlatıyor, her biriniz ne kadar hızlı yanıt veriyor
• Duygu eğrisi — ay ay ilerleyen bir çizgi; en sıcak ayınızı ve zor döneminizi işaretler
• Neler konuşuyorsunuz — ikinizin gerçekte konuştuğu konular, sıralı
• Sohbet kişilikleri — gerçek alışkanlıklarınızdan çıkarılan, her biriniz için üç eğlenceli etiket
• Detaylı yorum — ritminizi, dönüm noktalarınızı ve her birinizin neyi önemsiyor göründüğünü anlatan uzun bir yazı; alıntılar ve tarihlerle

HER RAKAMIN BİR KAYNAĞI VAR

Her istatistik — mesaj sayıları, yanıt süreleri, ilk kimin yazdığı — telefonunda, kendi dışa aktardığın dosyadan hesaplanır. Yapay zekâ bu rakamları ve konuşmalarınızı yorumlamak için kullanılır, asla uydurmak için değil. Alıntılar tarihleriyle gelir, böylece kendin kontrol edebilirsin.

ÖNCE GİZLİLİK

• Sohbet dosyan tamamen cihazında okunur ve istatistikleri de yine cihazında hesaplanır
• Raporunu yazmak için sohbet metni şifreli bağlantıyla yapay zekâ sağlayıcımıza gönderilir — önce sana sorulur ve biz onu asla saklamayız
• Sunucularımızda hiçbir şey saklanmaz, hesap oluşturman da gerekmez
• Bir rapor kartını paylaştığında isimler otomatik olarak baş harflere kısaltılır — bu özellik kapatılamaz

NASIL KULLANILIR

1. Mesajlaşma uygulamanı aç ve bir sohbeti .txt dosyası olarak dışa aktar (yalnızca metin, medya olmadan)
2. Chat Report'u aç ve dosyayı seç — uygulama sana adım adım yol gösterir
3. Hangisinin sen olduğunu ve ilişkinizin türünü seç
4. Yaklaşık 30 saniyede raporunu al

Acelen mi var? Herhangi bir sohbeti doğrudan uygulamaya yapıştır, ücretsiz hızlı okumanı hemen al.

Henüz emin değil misin? Uygulamadaki örnek rapora göz at; hiçbir şey dışa aktarmadan tam olarak ne alacağını gör.

KİMLER İÇİN?

Kendi ritmini merak eden çiftler. Adı konmamış bir ilişkiyi çözmeye çalışanlar. Kendi aralarındaki esprilerin yıllık özetini isteyen en yakın arkadaşlar. Ve kapanmış bir sayfaya dönüp bakan herkes.

BİR NOT: CHAT REPORT NE DEĞİLDİR

Chat Report bir sohbetteki örüntüleri betimler. Terapi değildir, teşhis değildir, kimse hakkında bir hüküm de değildir. Onu bir skor tablosu olarak değil, üzerine konuşmaya değer bir ayna olarak gör.

Chat Report hiçbir mesajlaşma hizmetiyle bağlantılı değildir ve hiçbiri tarafından onaylanmamış veya desteklenmemiştir.
```
> 2,626 字符，留有余量。最后一行免责声明与「Chat Report ne değildir」段落**必须保留** —— 避免与消息服务方产生关联暗示。

---

## 其他字段

| 字段 | 填写内容 |
|---|---|
| App category | Lifestyle（备选 Social） |
| Tags | Relationship, Analytics, Personal |
| Contact email | **待填** —— 必须是能收信的地址 |
| Website | **待填**（可选，但建议有） |
| Privacy Policy URL | `https://ruilin.github.io/resource/chatreport-privacy.html` —— 暂无土耳其语版隐私政策，先用英文版 |
| Default language | English (United States)（默认语言，非本文件） |

---

## 素材清单（均在本目录）

| 素材 | 规格 | 文件 |
|---|---|---|
| App icon | 512×512 PNG，无 alpha | `../play_icon_512.png`（语言无关） |
| Feature graphic | 1024×500 PNG | `feature_graphic.png` |
| Phone screenshots | 1080×1920（9:16，符合 Play 2:1 上限）| **暂无土耳其语截图** —— Play 会回退显示英文版 `../en/screenshot_1..6.png` |

> 如需土耳其语截图：用 `tool/capture_shots.sh` + `tool/gen_store_assets.py` 生成，但这两个脚本目前只覆盖 en / zh / zh-Hant，需先加上 tr。
> **未提供**：平板截图（若不勾选平板支持则不需要）。
