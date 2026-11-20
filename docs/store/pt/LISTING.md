# Google Play 商店文案 — Português do Brasil (pt-BR)

> 英文（默认语言）版见 [../en/LISTING.md](../en/LISTING.md)。本文件为巴西葡萄牙语（称「você」）商店文案，按本地语感改写，非逐句直译。
>
> App 界面已有葡语（`lib/l10n/app_pt.arb`）；文案中的板块名、按钮名与界面用词一致（如 Calor da relação / Cole uma conversa / Veja antes um relatório de exemplo）。

---

## App name（上限 30 字符）

```
Chat Report: Análise chat IA
```
> 28 字符。⚠️ **不要在此处写 "WhatsApp"** —— 属他人商标，Play 会以冒充/商标侵权驳回。

备选：`Chat Report: Raio-X do chat`（27 字符；「Raio-X」是巴西常见的营销说法，更口语）

---

## Short description（上限 80 字符）

```
Analise sua conversa do WhatsApp com IA: relatório, sinais de alerta e mais.
```
> 76 字符。

---

## Full description（上限 4000 字符）

```
O que suas conversas dizem de verdade?

O Chat Report transforma o histórico exportado de uma conversa em um relatório de verdade sobre a sua relação. Nada de horóscopo: são números que você consegue rastrear até mensagens reais.

Funciona com conversas exportadas do WhatsApp.

O QUE VOCÊ RECEBE

• Calor da relação — um único número, de 0 a 100, que mostra como a relação está agora
• Equilíbrio — quem manda mais mensagens, quem puxa assunto e com que rapidez cada um responde
• Curva emocional — uma linha mês a mês que marca o mês mais quente de vocês e a fase difícil
• Sobre o que vocês falam — os assuntos que realmente rolam entre vocês, em ordem
• Personalidades no chat — três etiquetas divertidas para cada um, tiradas de hábitos reais
• A leitura completa — um texto aprofundado sobre o ritmo de vocês, os momentos de virada e o que cada um parece valorizar, com citações e datas

PARA IR MAIS FUNDO

Tudo acima é grátis. Desbloqueie um relatório uma única vez para abrir a análise a fundo: é uma compra única, não uma assinatura.

• Os quatro cavaleiros — crítica, desprezo, defensividade e bloqueio: os quatro hábitos que o psicólogo John Gottman associou a problemas no relacionamento, cada um com a mensagem exata
• Sinais de alerta / Sinais positivos — no que prestar atenção e o que está funcionando
• Estilos de apego — como cada um tende a se aproximar ou a se afastar
• As linguagens do amor — como cada um demonstra e busca amor
• Pontos de virada — os momentos em que a relação esquentou ou esfriou
• Para levar com você — três sugestões concretas para esta relação
• Coach de IA — faça perguntas sobre o seu próprio relatório; as 3 primeiras são grátis

Todo relatório mostra grátis uma descoberta da análise a fundo, para você avaliar antes de pagar.

FEITO DE NÚMEROS REAIS

Cada estatística — número de mensagens, tempo de resposta, quem puxa assunto primeiro — é calculada no seu celular, a partir da sua própria exportação. A IA interpreta esses números e as conversas de vocês, mas nunca os inventa. As citações vêm com data para você conferir por conta própria.

PRIVACIDADE EM PRIMEIRO LUGAR

• Sem conta e sem cadastro
• Suas estatísticas são calculadas no seu aparelho
• Ao compartilhar um cartão do relatório, os nomes são abreviados automaticamente para iniciais
• Os detalhes estão na nossa política de privacidade

COMO USAR

1. Abra uma conversa no WhatsApp e escolha Exportar conversa (só texto, sem mídia)
2. Escolha o Chat Report na lista de compartilhamento, ou salve o arquivo e abra pelo app
3. Diga quem é você e qual é a relação
4. Seu relatório fica pronto em um ou dois minutos

Está com pressa? Cole qualquer conversa direto no app e tenha uma leitura rápida grátis.

Ainda na dúvida? Veja antes um relatório de exemplo no app e descubra exatamente o que você vai receber — sem exportar nada.

PARA QUEM É

Casais curiosos sobre o próprio ritmo. Quem está tentando entender um rolo. Melhores amigos que querem uma retrospectiva do ano das piadas internas. Qualquer pessoa olhando para trás, para um capítulo que terminou.

O QUE ISTO NÃO É

O Chat Report descreve padrões em uma conversa. Não é terapia, não é diagnóstico e não é um veredito sobre ninguém. Encare como um espelho que rende uma boa conversa, não como um placar.

O Chat Report é um app independente. Não é afiliado, endossado nem conectado ao WhatsApp ou a qualquer outro serviço de mensagens.
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
| Phone screenshots | 1080×1920 | `screenshot_1..8.png`（本目录，该语言真实界面 + 译文标题） |

> 截图重新生成：`tool/capture_shots.py <原图目录>` → `tool/gen_store_assets.py <原图目录>`。
