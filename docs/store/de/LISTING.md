# Google Play 商店文案 — Deutsch (de-DE)

> 英文（默认语言）版见 [../en/LISTING.md](../en/LISTING.md)。本目录为德语版素材：文案（本文件）、宣传图；截图暂无德语版，见下方素材清单。
>
> 用 du。功能名称与 App 界面一致（取自 `lib/l10n/app_de.arb`：Beziehungswärme / Balance / Gefühlskurve / Worüber ihr redet / Chat-Persönlichkeiten / Die ganze Analyse），完整说明首句即 `tagline`。
> 非逐字直译 —— 已按德语营销文案的习惯改写。德语偏长，名称与简短说明已刻意压短，日后修改请先重新计数。

---

## App name（上限 30 字符）

```
Chat Report: Chat-Analyse
```
> 25 字符。⚠️ **不要在此处写 "WhatsApp"** —— 属他人商标，Play 会以冒充/商标侵权驳回。

备选：`Chat Report – Beziehungs-KI`（27 字符）

---

## Short description（上限 80 字符）

```
Chat importieren – in 30 Sekunden dein KI-Report über eure Beziehung.
```
> 69 字符。

---

## Full description（上限 4000 字符）

```
Was steckt wirklich in deinen Chats?

Chat Report macht aus einem exportierten Chatverlauf einen echten Report über eure Beziehung – kein Horoskop, sondern Zahlen, die sich auf echte Nachrichten zurückführen lassen.

DAS BEKOMMST DU

• Beziehungswärme – eine einzige Zahl von 0 bis 100, die zeigt, wo eure Beziehung gerade steht
• Balance – wer mehr schreibt, wer Gespräche anfängt und wie schnell ihr jeweils antwortet
• Gefühlskurve – euer Verlauf Monat für Monat, mit eurem wärmsten Monat und eurer Durststrecke
• Worüber ihr redet – die Themen, über die ihr wirklich sprecht, nach Rang sortiert
• Chat-Persönlichkeiten – drei verspielte Tags für jeden von euch, abgeleitet aus echten Gewohnheiten
• Die ganze Analyse – ein ausführlicher Text über euren Rhythmus, eure Wendepunkte und das, was euch jeweils wichtig zu sein scheint, mit Zitaten und Datum

ECHTE ZAHLEN STATT BAUCHGEFÜHL

Jede Statistik – Anzahl der Nachrichten, Antwortzeiten, wer zuerst schreibt – wird auf deinem Handy aus deinem eigenen Export berechnet. Die KI deutet diese Zahlen und eure Gespräche, erfindet sie aber nie. Zitate kommen mit Datum, damit du sie selbst nachprüfen kannst.

PRIVATSPHÄRE ZUERST

• Deine Chat-Datei wird komplett auf deinem Gerät eingelesen, und auch alle Statistiken werden dort berechnet
• Für deinen Report wird der Chattext über eine verschlüsselte Verbindung an unseren KI-Anbieter gesendet – wir fragen dich vorher, und wir speichern ihn nie
• Auf unseren Servern wird nichts gespeichert, und du brauchst kein Konto
• Wenn du eine Report-Karte teilst, werden Namen automatisch auf Initialen gekürzt – das lässt sich nicht abschalten

SO FUNKTIONIERT'S

1. Öffne deine Messaging-App und exportiere einen Chat als .txt-Datei (nur Text, ohne Medien)
2. Öffne Chat Report und wähle die Datei aus – die App führt dich Schritt für Schritt durch
3. Wähle, wer du bist und um welche Art von Beziehung es geht
4. Nach etwa 30 Sekunden ist dein Report fertig

Wenig Zeit? Füge eine Unterhaltung direkt in die App ein und hol dir einen kostenlosen Schnell-Check.

Noch unsicher? Schau dir in der App erst mal den Beispiel-Report an – dann weißt du genau, was dich erwartet, ganz ohne Export.

FÜR WEN?

Paare, die neugierig auf ihren eigenen Rhythmus sind. Alle, die aus einer Situationship schlau werden wollen. Beste Freunde, die einen Jahresrückblick ihrer Insider-Witze wollen. Und alle, die auf ein abgeschlossenes Kapitel zurückblicken.

WAS DAS NICHT IST

Chat Report beschreibt Muster in einem Gespräch. Es ist keine Therapie, keine Diagnose und kein Urteil über irgendwen. Sieh es als Spiegel, über den es sich zu reden lohnt – nicht als Punktetabelle.

Chat Report ist mit keinem Messaging-Dienst verbunden und wird von keinem solchen Dienst unterstützt oder empfohlen.
```
> 2,777 字符，留有余量。最后一行免责声明与「Was das nicht ist」段落**必须保留** —— 避免与消息服务方产生关联暗示。

---

## 其他字段

| 字段 | 填写内容 |
|---|---|
| App category | Lifestyle（备选 Social） |
| Tags | Relationship, Analytics, Personal |
| Contact email | **待填** —— 必须是能收信的地址 |
| Website | **待填**（可选，但建议有） |
| Privacy Policy URL | `https://ruilin.github.io/resource/chatreport-privacy.html` —— 暂无德语版隐私政策，先用英文版 |
| Default language | English (United States)（默认语言，非本文件） |

---

## 素材清单（均在本目录）

| 素材 | 规格 | 文件 |
|---|---|---|
| App icon | 512×512 PNG，无 alpha | `../play_icon_512.png`（语言无关） |
| Feature graphic | 1024×500 PNG | `feature_graphic.png` |
| Phone screenshots | 1080×1920（9:16，符合 Play 2:1 上限）| **暂无德语截图** —— Play 会回退显示英文版 `../en/screenshot_1..6.png` |

> 如需德语截图：用 `tool/capture_shots.sh` + `tool/gen_store_assets.py` 生成，但这两个脚本目前只覆盖 en / zh / zh-Hant，需先加上 de。
> **未提供**：平板截图（若不勾选平板支持则不需要）。
