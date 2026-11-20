# Google Play 商店文案 — Italiano (it-IT)

> 英文（默认语言）版见 [../en/LISTING.md](../en/LISTING.md)。本文件为意大利语（称「tu」）商店文案，按本地语感改写，非逐句直译。
>
> App 界面已有意大利语（`lib/l10n/app_it.arb`）；文案中的板块名、按钮名与界面用词一致（如 Calore della relazione / Incolla una conversazione / Guarda prima un report di esempio）。

---

## App name（上限 30 字符）

```
Chat Report: Analisi chat IA
```
> 28 字符。⚠️ **不要在此处写 "WhatsApp"** —— 属他人商标，Play 会以冒充/商标侵权驳回。

备选：`Chat Report: Analizza le chat`（29 字符）

---

## Short description（上限 80 字符）

```
Analizza la tua chat WhatsApp con l'IA: report, segnali d'allarme e altro.
```
> 74 字符。

---

## Full description（上限 4000 字符）

```
Cosa dicono davvero le tue chat?

Chat Report trasforma una chat esportata in un vero report sulla tua relazione. Niente oroscopi: solo numeri che puoi ricondurre a messaggi reali.

Funziona con le chat esportate da WhatsApp.

COSA OTTIENI

• Calore della relazione — un solo numero, da 0 a 100, che dice com'è la relazione in questo momento
• Equilibrio — chi scrive di più, chi avvia le conversazioni e quanto in fretta risponde ciascuno
• Curva emotiva — un andamento mese per mese che segna il vostro mese più caldo e il periodo più difficile
• Di cosa parlate — gli argomenti che riempiono davvero le vostre chat, in classifica
• Personalità in chat — tre etichette giocose per ciascuno, tratte da abitudini reali
• La lettura completa — un testo approfondito sul vostro ritmo, sui momenti di svolta e su ciò a cui ciascuno sembra tenere, con citazioni e date

PER ANDARE PIÙ A FONDO

Tutto quello che c'è sopra è gratis. Sblocca un report una sola volta per aprire la sua analisi approfondita: è un acquisto unico, non un abbonamento.

• I quattro cavalieri — critica, disprezzo, difensività e ostruzionismo: le quattro abitudini che lo psicologo John Gottman collega ai problemi di coppia, ognuna con il messaggio esatto
• Segnali d'allarme / Segnali positivi — a cosa fare attenzione e cosa sta funzionando
• Stili di attaccamento — come ciascuno tende ad avvicinarsi o a prendere le distanze
• I linguaggi dell'amore — come ciascuno dimostra e cerca amore
• Punti di svolta — i momenti in cui la relazione si è scaldata o raffreddata
• Per il futuro — tre suggerimenti concreti per questa relazione
• Coach IA — fai domande sul tuo report; le prime 3 sono gratis

Ogni report mostra gratis un risultato dell'analisi approfondita, così puoi valutarla prima di pagare.

NUMERI VERI, NON INVENTATI

Ogni statistica — numero di messaggi, tempi di risposta, chi scrive per primo — viene calcolata sul tuo telefono a partire dalla tua esportazione. L'IA serve a interpretare quei numeri e le vostre conversazioni, mai a inventarli. Le citazioni riportano la data, così puoi verificarle da te.

PRIMA DI TUTTO, LA PRIVACY

• Nessun account, nessuna registrazione
• Le tue statistiche vengono calcolate sul tuo dispositivo
• Quando condividi una card del report, i nomi vengono abbreviati automaticamente in iniziali
• I dettagli sono nella nostra informativa sulla privacy

COME FUNZIONA

1. Apri una conversazione in WhatsApp e scegli Esporta chat (solo testo, senza media)
2. Scegli Chat Report nell'elenco di condivisione, oppure salva il file e aprilo dall'app
3. Indica chi sei e che tipo di relazione è
4. Il tuo report è pronto in uno o due minuti

Vai di fretta? Incolla una conversazione direttamente nell'app per una lettura veloce gratuita.

Vuoi farti un'idea? Guarda prima un report di esempio nell'app e scopri esattamente cosa riceverai, senza esportare nulla.

PER CHI È

Coppie curiose del proprio ritmo. Chi cerca di decifrare una storia che non è ancora una storia. Migliori amici che vogliono il riassunto dell'anno delle battute che capiscono solo loro. Chiunque stia ripensando a un capitolo che si è chiuso.

COSA NON È

Chat Report descrive gli schemi di una conversazione. Non è terapia, non è una diagnosi e non è un verdetto su nessuno. Prendilo come uno specchio di cui vale la pena parlare, non come un tabellone dei punti.

Chat Report è un'app indipendente. Non è affiliata, approvata né collegata a WhatsApp o ad altri servizi di messaggistica.
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
| Phone screenshots | 1080×1920 | `screenshot_1..8.png`（本目录，该语言真实界面 + 译文标题） |

> 截图重新生成：`tool/capture_shots.py <原图目录>` → `tool/gen_store_assets.py <原图目录>`。
