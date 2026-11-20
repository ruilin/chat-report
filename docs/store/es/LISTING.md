# Google Play 商店文案 — Español latinoamericano (es-419)

> 英文（默认语言）版见 [../en/LISTING.md](../en/LISTING.md)。本文件为拉美西班牙语（中性用语、称「tú」）商店文案，按本地语感改写，非逐句直译。
>
> App 界面已有西语（`lib/l10n/app_es.arb`）；文案中的板块名、按钮名与界面用词一致（如 Calidez de la relación / Pega una conversación / Mira primero un informe de ejemplo）。

---

## App name（上限 30 字符）

```
Chat Report: Análisis chat IA
```
> 29 字符（正好到上限）。⚠️ **不要在此处写 "WhatsApp"** —— 属他人商标，Play 会以冒充/商标侵权驳回。

备选：`Chat Report: Lee tus chats`（26 字符）

---

## Short description（上限 80 字符）

```
Analiza tu chat de WhatsApp con IA: informe, señales de alerta y más.
```
> 69 字符。

---

## Full description（上限 4000 字符）

```
¿Qué dicen de verdad tus chats?

Chat Report convierte el historial exportado de un chat en un informe de verdad sobre tu relación. Nada de horóscopos: son números que puedes rastrear hasta mensajes reales.

Funciona con chats exportados de WhatsApp.

LO QUE RECIBES

• Calidez de la relación — un solo número, del 0 al 100, que resume cómo se siente la relación hoy
• Equilibrio — quién envía más mensajes, quién empieza las conversaciones y qué tan rápido responde cada uno
• Curva emocional — una línea mes a mes que marca su mes más cálido y su mala racha
• De qué hablan — los temas que de verdad llenan sus charlas, en orden
• Personalidades en el chat — tres etiquetas divertidas para cada uno, sacadas de hábitos reales
• La lectura completa — un texto a fondo sobre su ritmo, sus momentos decisivos y lo que a cada uno parece importarle, con citas y fechas

PARA IR MÁS A FONDO

Todo lo anterior es gratis. Desbloquea un informe una sola vez para abrir su análisis a fondo: es un pago único, no una suscripción.

• Los cuatro jinetes — crítica, desprecio, actitud defensiva y evasión: los cuatro hábitos que el psicólogo John Gottman relacionó con los problemas de pareja, cada uno con el mensaje exacto
• Señales de alerta / Señales positivas — a qué prestar atención y qué está funcionando
• Estilos de apego — cómo tiende cada uno a acercarse o a tomar distancia
• Los lenguajes del amor — cómo demuestra y busca amor cada uno
• Puntos de inflexión — los momentos en que la relación se acercó o se enfrió
• Para el camino — tres sugerencias concretas para esta relación
• Coach de IA — haz preguntas sobre tu propio informe; las 3 primeras son gratis

Cada informe muestra gratis un hallazgo del análisis a fondo, para que lo valores antes de pagar.

NÚMEROS REALES, NO INVENTADOS

Cada estadística —cantidad de mensajes, tiempos de respuesta, quién escribe primero— se calcula en tu teléfono a partir de tu propio archivo exportado. La IA interpreta esos números y sus conversaciones; nunca los inventa. Las citas llevan fecha para que puedas comprobarlas por tu cuenta.

TU PRIVACIDAD, PRIMERO

• Sin cuenta y sin registro
• Tus estadísticas se calculan en tu dispositivo
• Al compartir una tarjeta del informe, los nombres se acortan automáticamente a iniciales
• Los detalles están en nuestra política de privacidad

CÓMO USARLO

1. Abre una conversación en WhatsApp y elige Exportar chat (solo texto, sin archivos)
2. Elige Chat Report en la lista para compartir, o guarda el archivo y ábrelo desde la app
3. Indica quién eres y qué tipo de relación es
4. Tu informe estará listo en uno o dos minutos

¿Tienes prisa? Pega una conversación directamente en la app y obtén gratis una lectura rápida.

¿Aún no te decides? Mira primero un informe de ejemplo en la app y descubre exactamente lo que vas a recibir, sin exportar nada.

PARA QUIÉN ES

Parejas con curiosidad por su propio ritmo. Quien intenta descifrar un «casi algo». Mejores amigos que quieren el resumen del año de sus chistes internos. Cualquiera que esté mirando atrás a una etapa que ya terminó.

LO QUE ESTO NO ES

Chat Report describe patrones en una conversación. No es terapia, no es un diagnóstico y no es un veredicto sobre nadie. Tómalo como un espejo del que vale la pena hablar, no como un marcador.

Chat Report es una app independiente. No está afiliada, respaldada ni conectada con WhatsApp ni con ningún otro servicio de mensajería.
```
> 2,658 字符，留有余量。最后一行免责声明与「LO QUE ESTO NO ES」段落**必须保留** —— 避免与消息服务方产生关联暗示。

---

## 其他字段

| 字段 | 填写内容 |
|---|---|
| App category | Lifestyle（备选 Social） |
| Tags | Relationship, Analytics, Personal |
| Contact email | **待填** —— 必须是能收信的地址（与英文版相同） |
| Website | **待填**（可选，但建议有） |
| Privacy Policy URL | `https://ruilin.github.io/resource/chatreport-privacy.html` —— 暂无西语版隐私政策，先沿用英文版 |
| Default language | English (United States)（默认语言，非本文件） |

---

## 素材清单

| 素材 | 规格 | 文件 |
|---|---|---|
| App icon | 512×512 PNG，无 alpha | `../play_icon_512.png`（语言无关） |
| Feature graphic | 1024×500 PNG | `feature_graphic.png`（本目录，已生成） |
| Phone screenshots | 1080×1920 | `screenshot_1..8.png`（本目录，该语言真实界面 + 译文标题） |

> 截图重新生成：`tool/capture_shots.py <原图目录>` → `tool/gen_store_assets.py <原图目录>`。
