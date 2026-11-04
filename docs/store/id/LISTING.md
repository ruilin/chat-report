# Google Play 商店文案 — Bahasa Indonesia (id)

> 英文（默认语言）版见 [../en/LISTING.md](../en/LISTING.md)。本目录为印尼语商店页素材：文案（本文件）、宣传图；截图尚未本地化。
>
> 文案用口语化的 "kamu" 称呼，与 App 界面语气一致；功能名称与界面用语一致（`lib/l10n/app_id.arb`）。

---

## App name（上限 30 字符）

```
Chat Report: Analisis Chat
```
> 26 字符。⚠️ **不要在此处写 "WhatsApp"** —— 属他人商标，Play 会以冒充/商标侵权驳回。

备选：`Chat Report: Analisis Hubungan`（30 字符）

---

## Short description（上限 80 字符）

```
Impor file ekspor chat, dapatkan laporan AI soal hubunganmu dalam 30 detik.
```
> 75 字符。

---

## Full description（上限 4000 字符）

```
Sebenarnya, ada apa di chat kamu?

Chat Report mengubah riwayat chat yang kamu ekspor jadi laporan beneran tentang hubungan kalian — bukan ramalan zodiak, tapi angka yang bisa kamu telusuri sampai ke pesan aslinya.

YANG KAMU DAPAT

• Kehangatan hubungan — satu angka, 0 sampai 100, yang menggambarkan kondisi hubungan kalian saat ini
• Keseimbangan — siapa yang lebih sering kirim pesan, siapa yang mulai ngobrol duluan, dan seberapa cepat masing-masing membalas
• Kurva emosi — garis per bulan yang menandai bulan paling hangat dan masa-masa renggang kalian
• Yang kalian obrolin — topik yang benar-benar kalian bahas, diurutkan
• Kepribadian chat — tiga label seru untuk masing-masing dari kalian, diambil dari kebiasaan nyata
• Bacaan lengkap — ulasan panjang tentang ritme kalian, titik balik kalian, dan hal yang tampaknya paling dipedulikan masing-masing, lengkap dengan kutipan dan tanggal

DARI ANGKA NYATA

Semua statistik — jumlah pesan, waktu balas, siapa yang chat duluan — dihitung di HP kamu dari file ekspormu sendiri. AI dipakai untuk menafsirkan angka-angka itu dan percakapan kalian, bukan untuk mengarangnya. Setiap kutipan disertai tanggal, jadi kamu bisa cek sendiri.

PRIVASI NOMOR SATU

• File chat kamu dibaca dan dihitung sepenuhnya di perangkatmu
• Untuk menulis laporanmu, teks chat dikirim ke penyedia AI kami lewat koneksi terenkripsi — kamu ditanya dulu, dan kami tidak pernah menyimpannya
• Tidak ada yang disimpan di server kami, dan kamu tidak perlu bikin akun
• Saat kamu membagikan kartu laporan, nama otomatis disingkat jadi inisial — dan ini tidak bisa dimatikan

CARA PAKAI

1. Buka aplikasi pesan kamu dan ekspor percakapan sebagai file .txt (teks saja, tanpa media)
2. Buka Chat Report dan pilih file-nya — aplikasi akan memandumu langkah demi langkah
3. Pilih yang mana kamu dan apa hubungan kalian
4. Dapatkan laporanmu dalam sekitar 30 detik

Lagi buru-buru? Tempel percakapan apa saja langsung ke aplikasi untuk baca cepat gratis.

Masih ragu? Buka contoh laporan di aplikasi untuk lihat persis apa yang bakal kamu dapat — tanpa perlu ekspor.

COCOK BUAT SIAPA

Pasangan yang penasaran sama ritme hubungan mereka sendiri. Kamu yang lagi mencoba membaca hubungan tanpa status. Sahabat yang pengin rekap setahun penuh lelucon internal mereka. Siapa pun yang sedang menengok kembali satu bab yang sudah selesai.

PERLU DIINGAT

Chat Report menggambarkan pola dalam sebuah percakapan. Ini bukan terapi, bukan diagnosis, dan bukan vonis untuk siapa pun. Anggap saja cermin yang seru buat dibahas bareng, bukan papan skor.

Chat Report tidak berafiliasi dengan, tidak didukung oleh, dan tidak terhubung dengan layanan pesan mana pun.
```
> 2,672 字符，留有大量余量。最后一行免责声明与"它不是什么"段落**必须保留** —— 避免与消息服务方产生关联暗示。

---

## 其他字段

| 字段 | 填写内容 |
|---|---|
| App category | Lifestyle（备选 Social）—— 全局设置，与英文一致 |
| Tags | Relationship, Analytics, Personal —— 全局设置，与英文一致 |
| Contact email | **待填** —— 与英文页相同，必须是能收信的地址 |
| Website | **待填**（可选，但建议有） |
| Privacy Policy URL | `https://ruilin.github.io/resource/chatreport-privacy.html` —— 暂无印尼语版隐私政策，沿用英文版 |
| Default language | English (United States)（默认语言，非本文件） |

---

## 素材清单

| 素材 | 规格 | 文件 |
|---|---|---|
| App icon | 512×512 PNG，无 alpha | `../play_icon_512.png`（语言无关） |
| Feature graphic | 1024×500 PNG | `feature_graphic.png`（本目录，已存在） |
| Phone screenshots | 1080×1920（9:16） | `screenshot_1..6.png`（本目录，该语言真实界面 + 译文标题） |

> 截图重新生成：`tool/capture_shots.py <原图目录>` → `tool/gen_store_assets.py <原图目录>`。
