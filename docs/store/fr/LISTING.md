# Google Play 商店文案 — Français (fr-FR)

> 英文（默认语言）版见 [../en/LISTING.md](../en/LISTING.md)。本目录为法语版素材：文案（本文件）、宣传图；截图暂无法语版，见下方素材清单。
>
> 用 tutoiement（tu）。功能名称与 App 界面一致（取自 `lib/l10n/app_fr.arb`：Chaleur de la relation / Équilibre / Courbe des émotions / De quoi vous parlez / Personnalités de chat / L'analyse complète），完整说明首句即 `tagline`。
> 非逐字直译 —— 已按法语营销文案的习惯改写，日后修改请保持口吻与界面用词一致。

---

## App name（上限 30 字符）

```
Chat Report : Analyse chat IA
```
> 29 字符。⚠️ **不要在此处写 "WhatsApp"** —— 属他人商标，Play 会以冒充/商标侵权驳回。冒号、问号前的空格按法语排版用不换行空格（U+00A0，与 ARB 一致），每个计 1 字符。

备选：`Chat Report : Relation & IA`（27 字符）

---

## Short description（上限 80 字符）

```
Analyse ta discussion WhatsApp avec l'IA : rapport, signaux d'alerte et plus.
```
> 77 字符。

---

## Full description（上限 4000 字符）

```
Que racontent vraiment tes conversations ?

Chat Report transforme l'export d'une discussion en un vrai rapport sur ta relation — pas un horoscope, mais des chiffres que tu peux relier à de vrais messages.

Fonctionne avec les discussions exportées depuis WhatsApp.

CE QUE TU OBTIENS

• Chaleur de la relation — un score unique, de 0 à 100, qui dit où en est votre relation en ce moment
• Équilibre — qui écrit le plus, qui lance les conversations, et à quelle vitesse chacun répond
• Courbe des émotions — votre évolution mois par mois, avec votre mois le plus chaleureux et votre passage à vide
• De quoi vous parlez — les sujets qui reviennent vraiment entre vous, classés
• Personnalités de chat — trois étiquettes ludiques pour chacun de vous, tirées de vos vraies habitudes
• L'analyse complète — un long texte sur votre rythme, vos tournants et ce qui semble compter pour chacun, avec citations et dates

POUR ALLER PLUS LOIN

Tout ce qui précède est gratuit. Débloque un rapport une seule fois pour ouvrir son analyse approfondie : c'est un achat unique, pas un abonnement.

• Les quatre cavaliers — critique, mépris, attitude défensive et mur du silence : les quatre habitudes que le psychologue John Gottman associe aux difficultés de couple, chacune avec le message exact
• Signaux d'alerte / Signaux positifs — ce qu'il faut surveiller et ce qui fonctionne
• Styles d'attachement — comment chacun a tendance à se rapprocher ou à prendre ses distances
• Les langages de l'amour — comment chacun montre et recherche l'amour
• Tournants — les moments où la relation s'est réchauffée ou refroidie
• Pour la route — trois suggestions concrètes pour cette relation
• Coach IA — pose des questions sur ton propre rapport ; les 3 premières sont gratuites

Chaque rapport montre gratuitement un constat de l'analyse approfondie, pour que tu puisses juger avant de payer.

DES CHIFFRES, PAS DU BLABLA

Chaque statistique — nombre de messages, temps de réponse, qui écrit en premier — est calculée sur ton téléphone, à partir de ton propre export. L'IA sert à interpréter ces chiffres et vos échanges, jamais à les inventer. Les citations sont datées : tu peux vérifier par toi-même.

TA VIE PRIVÉE D'ABORD

• Pas de compte, pas d'inscription
• Tes statistiques sont calculées sur ton appareil
• Quand tu partages une carte du rapport, les noms sont automatiquement réduits aux initiales
• Les détails figurent dans notre politique de confidentialité

COMMENT ÇA MARCHE

1. Ouvre une conversation dans WhatsApp et choisis Exporter la discussion (texte seul, sans médias)
2. Choisis Chat Report dans la liste de partage, ou enregistre le fichier et ouvre-le depuis l'appli
3. Indique qui tu es et quel est votre lien
4. Ton rapport est prêt en une ou deux minutes

Pas le temps ? Colle une conversation directement dans l'appli pour une lecture rapide gratuite.

Tu hésites encore ? Ouvre l'exemple de rapport dans l'appli pour voir exactement ce que tu vas obtenir — sans rien exporter.

POUR QUI ?

Les couples curieux de leur propre rythme. Celles et ceux qui essaient de décoder une relation pas vraiment définie. Les meilleurs amis qui veulent le bilan de l'année de leurs private jokes. Et toutes les personnes qui repensent à un chapitre refermé.

CE QUE CE N'EST PAS

Chat Report décrit des tendances dans une conversation. Ce n'est pas une thérapie, pas un diagnostic, et pas un verdict sur qui que ce soit. Vois-le comme un miroir qui donne envie d'en parler, pas comme un tableau des scores.

Chat Report est une application indépendante. Elle n'est ni affiliée à WhatsApp ou à un autre service de messagerie, ni approuvée par eux, ni liée à eux.
```
> 2,835 字符，留有余量。最后一行免责声明与「Ce que ce n'est pas」段落**必须保留** —— 避免与消息服务方产生关联暗示。

---

## 其他字段

| 字段 | 填写内容 |
|---|---|
| App category | Lifestyle（备选 Social） |
| Tags | Relationship, Analytics, Personal |
| Contact email | **待填** —— 必须是能收信的地址 |
| Website | **待填**（可选，但建议有） |
| Privacy Policy URL | `https://ruilin.github.io/resource/chatreport-privacy.html` —— 暂无法语版隐私政策，先用英文版 |
| Default language | English (United States)（默认语言，非本文件） |

---

## 素材清单（均在本目录）

| 素材 | 规格 | 文件 |
|---|---|---|
| App icon | 512×512 PNG，无 alpha | `../play_icon_512.png`（语言无关） |
| Feature graphic | 1024×500 PNG | `feature_graphic.png` |
| Phone screenshots | 1080×1920（9:16，符合 Play 2:1 上限）| `screenshot_1..8.png`（本目录，该语言真实界面 + 译文标题） |

> 截图重新生成：`tool/capture_shots.py <原图目录>` → `tool/gen_store_assets.py <原图目录>`。
> **未提供**：平板截图（若不勾选平板支持则不需要）。
