# Google Play 商店文案 — Português do Brasil (pt-BR)

> 英文（默认语言）版见 [../en/LISTING.md](../en/LISTING.md)。本文件为巴西葡萄牙语（称「você」）商店文案，按本地语感改写，非逐句直译。
>
> App 界面已有葡语（`lib/l10n/app_pt.arb`）；文案中的板块名、按钮名与界面用词一致（如 Calor da relação / Cole uma conversa / Veja antes um relatório de exemplo）。

---

## App name（上限 30 字符）

```
Chat Report: Análise de chats
```
> 29 字符。⚠️ **不要在此处写 "WhatsApp"** —— 属他人商标，Play 会以冒充/商标侵权驳回。

备选：`Chat Report: Raio-X do chat`（27 字符；「Raio-X」是巴西常见的营销说法，更口语）

---

## Short description（上限 80 字符）

```
Importe uma conversa e receba em 30 segundos um relatório com IA da relação.
```
> 76 字符。

---

## Full description（上限 4000 字符）

```
O que suas conversas dizem de verdade?

O Chat Report transforma o histórico exportado de uma conversa em um relatório de verdade sobre a sua relação. Nada de horóscopo: são números que você consegue rastrear até mensagens reais.

O QUE VOCÊ RECEBE

• Calor da relação — um único número, de 0 a 100, que mostra como a relação está agora
• Equilíbrio — quem manda mais mensagens, quem puxa assunto e com que rapidez cada um responde
• Curva emocional — uma linha mês a mês que marca o mês mais quente de vocês e a fase difícil
• Sobre o que vocês falam — os assuntos que realmente rolam entre vocês, em ordem
• Personalidades no chat — três etiquetas divertidas para cada um, tiradas de hábitos reais
• A leitura completa — um texto aprofundado sobre o ritmo de vocês, os momentos de virada e o que cada um parece valorizar, com citações e datas

FEITO DE NÚMEROS REAIS

Cada estatística — número de mensagens, tempo de resposta, quem puxa assunto primeiro — é calculada no seu celular, a partir da sua própria exportação. A IA interpreta esses números e as conversas de vocês, mas nunca os inventa. As citações vêm com data para você conferir por conta própria.

PRIVACIDADE EM PRIMEIRO LUGAR

• O arquivo da conversa é lido e medido inteiramente no seu aparelho
• Para escrever o relatório, o texto da conversa é enviado ao nosso provedor de IA por uma conexão criptografada — pedimos sua permissão antes, e nunca guardamos esse conteúdo
• Nada fica salvo nos nossos servidores, e você não precisa criar conta
• Quando você compartilha um card do relatório, os nomes viram iniciais automaticamente — e não dá para desativar isso

COMO USAR

1. Abra seu app de mensagens e exporte uma conversa como arquivo .txt (só texto, sem mídia)
2. Abra o Chat Report e escolha o arquivo — o app guia você passo a passo
3. Diga qual é você e qual é a relação
4. Receba seu relatório em cerca de 30 segundos

Está com pressa? Cole qualquer conversa direto no app e tenha uma leitura rápida grátis.

Ainda na dúvida? Veja antes um relatório de exemplo no app e descubra exatamente o que você vai receber — sem exportar nada.

PARA QUEM É

Casais curiosos sobre o próprio ritmo. Quem está tentando entender um rolo. Melhores amigos que querem uma retrospectiva do ano das piadas internas. Qualquer pessoa olhando para trás, para um capítulo que terminou.

O QUE ISTO NÃO É

O Chat Report descreve padrões em uma conversa. Não é terapia, não é diagnóstico e não é um veredito sobre ninguém. Encare como um espelho que rende uma boa conversa, não como um placar.

O Chat Report não tem afiliação, endosso nem vínculo com nenhum serviço de mensagens.
```
> 2,632 字符，留有余量。最后一行免责声明与「O QUE ISTO NÃO É」段落**必须保留** —— 避免与消息服务方产生关联暗示。

---

## 其他字段

| 字段 | 填写内容 |
|---|---|
| App category | Lifestyle（备选 Social） |
| Tags | Relationship, Analytics, Personal |
| Contact email | **待填** —— 必须是能收信的地址（与英文版相同） |
| Website | **待填**（可选，但建议有） |
| Privacy Policy URL | `https://ruilin.github.io/resource/chatreport-privacy.html` —— 暂无葡语版隐私政策，先沿用英文版 |
| Default language | English (United States)（默认语言，非本文件） |

---

## 素材清单

| 素材 | 规格 | 文件 |
|---|---|---|
| App icon | 512×512 PNG，无 alpha | `../play_icon_512.png`（语言无关） |
| Feature graphic | 1024×500 PNG | `feature_graphic.png`（本目录，已生成） |
| Phone screenshots | 1080×1920 | `screenshot_1..6.png`（本目录，该语言真实界面 + 译文标题） |

> 截图重新生成：`tool/capture_shots.py <原图目录>` → `tool/gen_store_assets.py <原图目录>`。
