# Release notes（Play Console「此版本的新变化」）

**上限 500 字符 / 每种语言**，中英需**分别**填写。
位置：Play Console → *Release → 选轨道 → Create new release → Release notes*。

Play 在商店页的「What's new / 新变化」区块展示这段文字，是用户看到的第一句更新说明。

---

## v1.0.0（versionCode 1）— 首个版本

### English (en-US)

```
First release.

Chat Report turns an exported chat history into a real report about your relationship: a warmth score, who starts conversations and who replies faster, a month-by-month emotion curve, your top topics, chat personality tags, and a long-form reading with quotes and dates.

Every statistic is computed on your device. Text sent for AI interpretation is deleted as soon as your report is ready. Shared cards show initials only.
```

### 简体中文 (zh-CN)

```
首个版本。

Chat Report 把一份导出的聊天记录，变成关于这段关系的真报告：关系温度分、谁更主动、谁回得更快、逐月情绪曲线、话题分布、聊天人格标签，以及一篇附原文金句与日期的深度解读。

所有统计都在你的手机上算出；送去做 AI 解读的文本在报告生成后即刻删除；分享卡片只显示姓名首字母。

（应用界面目前为英文。）
```

---

## 写法要点

**首个版本**：介绍这个 App 是什么 + 最有说服力的一两个差异点（此处是"数字可追溯"与"隐私"）。
不要写"首次发布，欢迎使用"这种零信息量的话。

**后续版本**：写用户能感知的变化，不写内部重构。

| 别写 | 改写成 |
|---|---|
| 修复若干已知问题 | 修复了部分手机上导入 .txt 失败的问题 |
| 优化性能 | 分析速度提升约 40%，长对话不再超时 |
| UI 调整 | 报告页新增可点击的月份，查看当月摘要 |
| 升级依赖 / 重构代码 | （用户无感的改动就别写，留空比凑字数好） |

**与商店描述的分工**：描述讲"这个 App 是什么"（长期不变），版本日志讲"这次变了什么"（每次都换）。
别把描述整段复制过来。

**不要在此处出现 "WhatsApp"** —— 与应用名、描述保持一致口径，统一用「exported chat history / 导出的聊天记录」。

---

## 后续版本模板

复制下面这段，替换内容即可：

```
### vX.Y.Z（versionCode N）

**English (en-US)**
```
What's new:
• <用户能感知的变化一>
• <用户能感知的变化二>

<可选：一句话说明为什么这次更新值得装>
```

**简体中文 (zh-CN)**
```
本次更新：
• <用户能感知的变化一>
• <用户能感知的变化二>
```
```

> 提醒：每次上传 versionCode 必须递增（`pubspec.yaml` 里的 `version: 1.0.1+2`，
> `+` 后面就是 versionCode）。

---

## v1.1.0（versionCode 2）— 多语言

### English (en-US)

```
The app now speaks your language.

Chat Report is available in English, Simplified Chinese and Traditional Chinese — and your report is written in the same language as the app, not just the buttons. On Android 13 and later you can pick the language per app in system settings.
```

### 简体中文 (zh-CN)

```
应用现在会说你的语言了。

Chat Report 新增简体中文与繁体中文界面 —— 而且报告正文也会用同一种语言撰写，不只是按钮翻译。Android 13 及以上可在系统设置里为本应用单独选择语言。
```

### 繁體中文 (zh-TW / zh-HK)

```
應用程式現在會說你的語言了。

Chat Report 新增繁體中文與簡體中文介面 —— 而且報告內文也會以同一種語言撰寫，不只是按鈕翻譯。Android 13 以上可在系統設定中為本應用程式單獨選擇語言。
```

---

## v1.1.0（versionCode 15）— 写给 TA 的话 + 新外观

线上是 versionCode 13。这一版新增「写给 TA 的话」，换了图标、主色和分享卡片。

下面整段可以直接贴进 Play Console 的 Release notes 输入框（带语言标签，一次填完 13 个语言代码）。
每种语言都在 500 字符以内。

```
<en-US>
What's new:
• Write to them: the AI drafts a message from your report — a thank-you, a way to make up, or something you'd like to ask for. You edit it and send it yourself.
• A brighter look: new icon and colours.
• A redesigned share card that reads at a glance.
</en-US>
<zh-CN>
本次更新：
• 新增「写给 TA 的话」：AI 根据报告起草一条消息——感谢、和好，或提一个请求。你来改，再由你自己发出去。
• 全新图标和配色，更明亮。
• 分享卡片重新设计，一眼就能看清。
</zh-CN>
<zh-TW>
本次更新：
• 新增「寫給 TA 的話」：AI 根據報告起草一則訊息——感謝、和好，或提出一個請求。你來改，再由你自己發出去。
• 全新圖示與配色，更明亮。
• 分享卡片重新設計，一眼就能看清。
</zh-TW>
<zh-HK>
本次更新：
• 新增「寫給 TA 的話」：AI 根據報告起草一則訊息——感謝、和好，或提出一個請求。你來改，再由你自己發出去。
• 全新圖示與配色，更明亮。
• 分享卡片重新設計，一眼就能看清。
</zh-HK>
<es-419>
Novedades:
• Escríbele: la IA redacta un mensaje a partir de tu informe: para agradecer, para reconciliarse o para pedir algo. Tú lo editas y lo envías.
• Un aspecto más luminoso: nuevo ícono y nuevos colores.
• Tarjeta para compartir rediseñada, más fácil de leer de un vistazo.
</es-419>
<pt-BR>
Novidades:
• Escreva para a pessoa: a IA redige uma mensagem a partir do seu relatório — para agradecer, fazer as pazes ou pedir algo. Você edita e envia.
• Visual mais vivo: novo ícone e novas cores.
• Cartão de compartilhamento redesenhado, mais fácil de ler de relance.
</pt-BR>
<fr-FR>
Nouveautés :
• Lui écrire : l'IA rédige un message à partir de ton rapport — pour remercier, se réconcilier ou demander quelque chose. Tu le modifies et tu l'envoies toi-même.
• Un look plus lumineux : nouvelle icône et nouvelles couleurs.
• Une carte de partage repensée, lisible d'un coup d'œil.
</fr-FR>
<de-DE>
Neu in dieser Version:
• Schreib ihr oder ihm: Die KI entwirft aus deinem Bericht eine Nachricht – zum Danken, zum Versöhnen oder für eine Bitte. Du passt sie an und schickst sie selbst.
• Frischerer Look: neues Icon und neue Farben.
• Neu gestaltete Karte zum Teilen, auf einen Blick lesbar.
</de-DE>
<it-IT>
Novità:
• Scrivile o scrivigli: l'IA prepara un messaggio a partire dal tuo report: per ringraziare, fare pace o chiedere qualcosa. Tu lo modifichi e lo invii.
• Un aspetto più luminoso: nuova icona e nuovi colori.
• Scheda da condividere ridisegnata, leggibile a colpo d'occhio.
</it-IT>
<tr-TR>
Yenilikler:
• Ona yaz: Yapay zekâ raporundan yola çıkarak bir mesaj taslağı yazar; teşekkür etmek, barışmak ya da bir şey istemek için. Sen düzenler ve kendin gönderirsin.
• Daha canlı bir görünüm: yeni simge ve yeni renkler.
• Yeniden tasarlanan paylaşım kartı, bir bakışta okunur.
</tr-TR>
<ar>
الجديد في هذا الإصدار:
• اكتب له أو لها: يكتب الذكاء الاصطناعي مسودة رسالة من تقريرك؛ للشكر أو للمصالحة أو لطلب شيء. وأنت تعدّلها وترسلها بنفسك.
• مظهر أكثر إشراقًا: أيقونة جديدة وألوان جديدة.
• بطاقة مشاركة بتصميم جديد تُقرأ بنظرة واحدة.
</ar>
<hi-IN>
इस अपडेट में नया:
• उन्हें लिखें: AI आपकी रिपोर्ट से एक मैसेज का ड्राफ़्ट लिखता है — शुक्रिया कहने, सुलह करने या कुछ माँगने के लिए। आप उसे बदलकर खुद भेजते हैं।
• ज़्यादा चमकदार लुक: नया आइकन और नए रंग।
• नया शेयर कार्ड, जो एक नज़र में पढ़ा जा सके।
</hi-IN>
<id>
Yang baru:
• Tulis untuk dia: AI menulis draf pesan dari laporanmu — untuk berterima kasih, berbaikan, atau meminta sesuatu. Kamu mengeditnya dan mengirimnya sendiri.
• Tampilan lebih cerah: ikon dan warna baru.
• Kartu berbagi dengan desain baru, terbaca sekilas.
</id>
```
