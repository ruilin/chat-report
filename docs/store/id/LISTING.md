# Google Play 商店文案 — Bahasa Indonesia (id)

> 英文（默认语言）版见 [../en/LISTING.md](../en/LISTING.md)。本目录为印尼语商店页素材：文案（本文件）、宣传图；截图尚未本地化。
>
> 文案用口语化的 "kamu" 称呼，与 App 界面语气一致；功能名称与界面用语一致（`lib/l10n/app_id.arb`）。

---

## App name（上限 30 字符）

```
Chat Report: Analisis WhatsApp
```
> 🧪 试验（2026-11 起）：标题写全称 WhatsApp，用来观察「whatsapp chat analyzer」的搜索排名。Google 或 Meta 提出异议时改回 `Chat Report: Analisis Chat AI`。
> 30 字符。⚠️ **不要在此处写 "WhatsApp"** —— 属他人商标，Play 会以冒充/商标侵权驳回。

备选：`Chat Report: Analisis Hubungan`（30 字符）

---

## Short description（上限 80 字符）

```
Analisis chat WhatsApp-mu dengan AI: laporan hubungan, tanda bahaya, dll.
```
> 73 字符。

---

## Full description（上限 4000 字符）

```
Sebenarnya, ada apa di chat kamu?

Chat Report mengubah riwayat chat yang kamu ekspor jadi laporan beneran tentang hubungan kalian — bukan ramalan zodiak, tapi angka yang bisa kamu telusuri sampai ke pesan aslinya.

Berfungsi dengan chat yang diekspor dari WhatsApp.

YANG KAMU DAPAT

• Kehangatan hubungan — satu angka, 0 sampai 100, yang menggambarkan kondisi hubungan kalian saat ini
• Keseimbangan — siapa yang lebih sering kirim pesan, siapa yang mulai ngobrol duluan, dan seberapa cepat masing-masing membalas
• Kurva emosi — garis per bulan yang menandai bulan paling hangat dan masa-masa renggang kalian
• Yang kalian obrolin — topik yang benar-benar kalian bahas, diurutkan
• Kepribadian chat — tiga label seru untuk masing-masing dari kalian, diambil dari kebiasaan nyata
• Bacaan lengkap — ulasan panjang tentang ritme kalian, titik balik kalian, dan hal yang tampaknya paling dipedulikan masing-masing, lengkap dengan kutipan dan tanggal

LEBIH DALAM LAGI

Semua yang di atas gratis. Buka kunci satu laporan sekali saja untuk melihat analisis mendalamnya: sekali bayar, bukan langganan.

• Empat Penunggang Kuda — kritik, penghinaan, sikap defensif, dan menutup diri: empat kebiasaan yang oleh psikolog John Gottman dikaitkan dengan masalah hubungan, masing-masing dengan pesan aslinya
• Tanda bahaya / Tanda positif — apa yang perlu diwaspadai dan apa yang sudah berjalan baik
• Gaya kelekatan — apakah masing-masing cenderung mendekat atau menjauh
• Bahasa cinta — cara masing-masing menunjukkan dan mencari cinta
• Titik balik — momen ketika hubungan menghangat atau mendingin
• Bekal ke depan — tiga saran konkret untuk hubungan ini
• Pelatih AI — tanyakan apa saja tentang laporanmu; 3 pertanyaan pertama gratis

Setiap laporan menampilkan satu temuan analisis mendalam secara gratis, jadi kamu bisa menilainya sebelum membayar.

DARI ANGKA NYATA

Semua statistik — jumlah pesan, waktu balas, siapa yang chat duluan — dihitung di HP kamu dari file ekspormu sendiri. AI dipakai untuk menafsirkan angka-angka itu dan percakapan kalian, bukan untuk mengarangnya. Setiap kutipan disertai tanggal, jadi kamu bisa cek sendiri.

PRIVASI NOMOR SATU

• Tanpa akun, tanpa daftar
• Statistikmu dihitung di perangkatmu sendiri
• Saat kamu membagikan kartu laporan, nama otomatis disingkat jadi inisial
• Detailnya ada di kebijakan privasi kami

CARA PAKAI

1. Buka sebuah percakapan di WhatsApp dan pilih Ekspor chat (teks saja, tanpa media)
2. Pilih Chat Report di daftar berbagi, atau simpan filenya lalu buka dari aplikasi
3. Pilih mana yang kamu dan apa hubungan kalian
4. Laporanmu siap dalam satu-dua menit

Lagi buru-buru? Tempel percakapan apa saja langsung ke aplikasi untuk baca cepat gratis.

Masih ragu? Buka contoh laporan di aplikasi untuk lihat persis apa yang bakal kamu dapat — tanpa perlu ekspor.

COCOK BUAT SIAPA

Pasangan yang penasaran sama ritme hubungan mereka sendiri. Kamu yang lagi mencoba membaca hubungan tanpa status. Sahabat yang pengin rekap setahun penuh lelucon internal mereka. Siapa pun yang sedang menengok kembali satu bab yang sudah selesai.

PERLU DIINGAT

Chat Report menggambarkan pola dalam sebuah percakapan. Ini bukan terapi, bukan diagnosis, dan bukan vonis untuk siapa pun. Anggap saja cermin yang seru buat dibahas bareng, bukan papan skor.

Chat Report adalah aplikasi independen. Tidak berafiliasi, didukung, atau terhubung dengan WhatsApp maupun layanan pesan lainnya.
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
| Phone screenshots | 1080×1920（9:16） | `screenshot_1..8.png`（本目录，该语言真实界面 + 译文标题） |

> 截图重新生成：`tool/capture_shots.py <原图目录>` → `tool/gen_store_assets.py <原图目录>`。
