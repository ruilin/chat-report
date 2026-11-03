# Google Play 商店文案 — Italiano (it-IT)

> 英文（默认语言）版见 [../en/LISTING.md](../en/LISTING.md)。本文件为意大利语（称「tu」）商店文案，按本地语感改写，非逐句直译。
>
> App 界面已有意大利语（`lib/l10n/app_it.arb`）；文案中的板块名、按钮名与界面用词一致（如 Calore della relazione / Incolla una conversazione / Guarda prima un report di esempio）。

---

## App name（上限 30 字符）

```
Chat Report: Analisi chat
```
> 25 字符。⚠️ **不要在此处写 "WhatsApp"** —— 属他人商标，Play 会以冒充/商标侵权驳回。

备选：`Chat Report: Analizza le chat`（29 字符）

---

## Short description（上限 80 字符）

```
Importa una chat e in 30 secondi ricevi un report con IA sulla tua relazione.
```
> 77 字符。

---

## Full description（上限 4000 字符）

```
Cosa dicono davvero le tue chat?

Chat Report trasforma una chat esportata in un vero report sulla tua relazione. Niente oroscopi: solo numeri che puoi ricondurre a messaggi reali.

COSA OTTIENI

• Calore della relazione — un solo numero, da 0 a 100, che dice com'è la relazione in questo momento
• Equilibrio — chi scrive di più, chi avvia le conversazioni e quanto in fretta risponde ciascuno
• Curva emotiva — un andamento mese per mese che segna il vostro mese più caldo e il periodo più difficile
• Di cosa parlate — gli argomenti che riempiono davvero le vostre chat, in classifica
• Personalità in chat — tre etichette giocose per ciascuno, tratte da abitudini reali
• La lettura completa — un testo approfondito sul vostro ritmo, sui momenti di svolta e su ciò a cui ciascuno sembra tenere, con citazioni e date

NUMERI VERI, NON INVENTATI

Ogni statistica — numero di messaggi, tempi di risposta, chi scrive per primo — viene calcolata sul tuo telefono a partire dalla tua esportazione. L'IA serve a interpretare quei numeri e le vostre conversazioni, mai a inventarli. Le citazioni riportano la data, così puoi verificarle da te.

PRIMA DI TUTTO, LA PRIVACY

• Il file della chat viene letto ed elaborato interamente sul tuo dispositivo
• Per scrivere il report, il testo della chat viene inviato al nostro fornitore di IA tramite una connessione crittografata: prima ti chiediamo il permesso, e non lo conserviamo mai
• Sui nostri server non resta nulla, e non serve creare un account
• Quando condividi una scheda del report, i nomi vengono abbreviati in automatico alle iniziali, e non c'è modo di disattivarlo

COME FUNZIONA

1. Apri la tua app di messaggistica ed esporta una conversazione come file .txt (solo testo, senza media)
2. Apri Chat Report e seleziona il file: l'app ti guida passo passo
3. Indica quale sei tu e che tipo di relazione è
4. Ricevi il tuo report in circa 30 secondi

Vai di fretta? Incolla una conversazione direttamente nell'app per una lettura veloce gratuita.

Vuoi farti un'idea? Guarda prima un report di esempio nell'app e scopri esattamente cosa riceverai, senza esportare nulla.

PER CHI È

Coppie curiose del proprio ritmo. Chi cerca di decifrare una storia che non è ancora una storia. Migliori amici che vogliono il riassunto dell'anno delle battute che capiscono solo loro. Chiunque stia ripensando a un capitolo che si è chiuso.

COSA NON È

Chat Report descrive gli schemi di una conversazione. Non è terapia, non è una diagnosi e non è un verdetto su nessuno. Prendilo come uno specchio di cui vale la pena parlare, non come un tabellone dei punti.

Chat Report non è affiliato, approvato né collegato in alcun modo ad alcun servizio di messaggistica.
```
> 2,707 字符，留有余量。最后一行免责声明与「COSA NON È」段落**必须保留** —— 避免与消息服务方产生关联暗示。

---

## 其他字段

| 字段 | 填写内容 |
|---|---|
| App category | Lifestyle（备选 Social） |
| Tags | Relationship, Analytics, Personal |
| Contact email | **待填** —— 必须是能收信的地址（与英文版相同） |
| Website | **待填**（可选，但建议有） |
| Privacy Policy URL | `https://ruilin.github.io/resource/chatreport-privacy.html` —— 暂无意大利语版隐私政策，先沿用英文版 |
| Default language | English (United States)（默认语言，非本文件） |

---

## 素材清单

| 素材 | 规格 | 文件 |
|---|---|---|
| App icon | 512×512 PNG，无 alpha | `../play_icon_512.png`（语言无关） |
| Feature graphic | 1024×500 PNG | `feature_graphic.png`（本目录，已生成） |
| Phone screenshots | 1080×1920 | **暂无意大利语截图** —— Play 会回退显示英文版 `../en/screenshot_1..6.png` |

> 本地化截图可用 `tool/capture_shots.sh` + `tool/gen_store_assets.py` 生成，但这两个脚本目前只覆盖 en / zh / zh-Hant，需先扩展到 it 才能出意大利语截图。
