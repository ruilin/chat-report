#!/usr/bin/env python3
"""生成 Google Play 上架素材：应用图标 512、各语言带标题的手机截图。

宣传图（feature graphic）按语言另由 tool/gen_feature_graphic.py 生成。

原始手机截图 1080×2340（1:2.17）超出 Play 的 2:1 宽高比上限，
本脚本重新构图为 1080×1920（9:16）并加标题带。

截图按语言各出一套 → docs/store/<语言>/screenshot_1..8.png。
图标为语言无关，放 docs/store/。
用 Chrome 渲染标题：阿拉伯语、印地语需要文字整形（见 gen_feature_graphic.py）。

用法：python3 tool/gen_store_assets.py <原始截图根目录> [语言目录...]
     原始截图由 tool/render_store_shots.dart 渲染（不需要模拟器），或由 tool/capture_shots.py 在设备上采集
"""
import html
import os
import sys
import tempfile

from PIL import Image

from gen_feature_graphic import LANGS, render

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "docs/store")
W, H = 1080, 1920

# (原图文件名, 深色底, 各语言标题)
# 标题必须与画面内容一致（Play 会以"误导性截图"驳回）
# 各语言按本地语感改写，板块名、「缩写为首字母」等说法与该语言的界面用词一致
SHOTS = [
    ("3_report_top.png", False, {
        "en": "Warmth score — and who texts first",
        "zh": "关系温度分，谁更主动一目了然",
        "zh-Hant": "關係溫度分，誰更主動一目了然",
        "es": "La calidez de la relación y quién escribe primero",
        "pt": "O calor da relação e quem puxa assunto",
        "fr": "La chaleur de la relation et qui écrit en premier",
        "de": "Beziehungswärme – und wer zuerst schreibt",
        "it": "Il calore della relazione e chi scrive per primo",
        "tr": "İlişki sıcaklığı ve ilk kimin yazdığı",
        "ar": "دفء العلاقة ومَن يبدأ أولًا",
        "hi": "रिश्ते की गर्माहट और पहले मैसेज कौन करता है",
        "id": "Kehangatan hubungan dan siapa yang chat duluan"}),
    ("7_horsemen.png", False, {
        "en": "Spot the Four Horsemen in your fights",
        "zh": "吵架里的四骑士，一条条找出来",
        "zh-Hant": "吵架裡的四騎士，一條條找出來",
        "es": "Detecta los cuatro jinetes en sus discusiones",
        "pt": "Encontre os quatro cavaleiros nas brigas",
        "fr": "Repère les quatre cavaliers dans vos disputes",
        "de": "Die vier Reiter in euren Streits erkennen",
        "it": "Scopri i quattro cavalieri nei vostri litigi",
        "tr": "Tartışmalarınızdaki Dört Atlı'yı gör",
        "ar": "اكتشف الفرسان الأربعة في خلافاتكما",
        "hi": "झगड़ों में चार घुड़सवार पहचानें",
        "id": "Temukan Empat Penunggang Kuda di pertengkaran"}),
    ("8_love.png", False, {
        "en": "Attachment styles and love languages",
        "zh": "依恋风格和爱的语言，一目了然",
        "zh-Hant": "依附風格和愛的語言，一目了然",
        "es": "Estilos de apego y lenguajes del amor",
        "pt": "Estilos de apego e linguagens do amor",
        "fr": "Styles d'attachement et langages de l'amour",
        "de": "Bindungsstile und Sprachen der Liebe",
        "it": "Stili di attaccamento e linguaggi dell'amore",
        "tr": "Bağlanma stilleri ve sevgi dilleri",
        "ar": "أنماط التعلق ولغات الحب",
        "hi": "लगाव की शैलियाँ और प्यार की भाषाएँ",
        "id": "Gaya kelekatan dan bahasa cinta"}),
    ("9_coach.png", False, {
        "en": "Ask the AI coach about your chat",
        "zh": "有疑问，随时问 AI 教练",
        "zh-Hant": "有疑問，隨時問 AI 教練",
        "es": "Pregúntale al coach de IA sobre tu chat",
        "pt": "Pergunte ao coach de IA sobre sua conversa",
        "fr": "Pose tes questions au coach IA",
        "de": "Frag den KI-Coach zu eurem Chat",
        "it": "Chiedi al coach IA della tua chat",
        "tr": "Sohbetin hakkında yapay zekâ koçuna sor",
        "ar": "اسأل مدرب الذكاء الاصطناعي عن محادثتك",
        "hi": "अपनी चैट के बारे में AI कोच से पूछें",
        "id": "Tanya pelatih AI tentang chat kamu"}),
    ("4_report_mid.png", False, {
        "en": "A month-by-month emotion curve",
        "zh": "逐月情绪曲线，起落都看得见",
        "zh-Hant": "逐月情緒曲線，起落都看得見",
        "es": "La curva emocional, mes a mes",
        "pt": "A curva emocional, mês a mês",
        "fr": "La courbe des émotions, mois par mois",
        "de": "Die Gefühlskurve, Monat für Monat",
        "it": "La curva emotiva, mese per mese",
        "tr": "Ay ay duygu eğrisi",
        "ar": "منحنى المشاعر شهرًا بشهر",
        "hi": "हर महीने का इमोशन कर्व",
        "id": "Kurva emosi dari bulan ke bulan"}),
    ("5_report_deep.png", False, {
        "en": "AI reads between the lines",
        "zh": "AI 读出聊天里的言外之意",
        "zh-Hant": "AI 讀出對話裡的言外之意",
        "es": "La IA lee entre líneas",
        "pt": "A IA lê nas entrelinhas",
        "fr": "L'IA lit entre les lignes",
        "de": "KI liest zwischen den Zeilen",
        "it": "L'IA legge tra le righe",
        "tr": "Yapay zekâ satır aralarını okur",
        "ar": "الذكاء الاصطناعي يقرأ ما بين السطور",
        "hi": "AI पढ़ता है अनकही बातें",
        "id": "AI membaca yang tersirat"}),
    ("6_share.png", True, {
        "en": "Share it — names become initials",
        "zh": "一键分享，姓名自动缩写",
        "zh-Hant": "一鍵分享，姓名自動縮寫",
        "es": "Compártelo: los nombres quedan en iniciales",
        "pt": "Compartilhe: os nomes viram iniciais",
        "fr": "Partage : les noms deviennent des initiales",
        "de": "Teilen – Namen werden zu Initialen",
        "it": "Condividi: i nomi diventano iniziali",
        "tr": "Paylaş: isimler baş harflere kısalır",
        "ar": "شاركه: تُختصر الأسماء إلى أحرفها الأولى",
        "hi": "शेयर करें: नाम इनिशियल्स में बदल जाते हैं",
        "id": "Bagikan: nama jadi inisial"}),
    ("2_guide.png", False, {
        "en": "Import in a few taps — guided",
        "zh": "分步引导，几步就能导入",
        "zh-Hant": "逐步引導，幾步就能匯入",
        "es": "Impórtalo en pocos toques, paso a paso",
        "pt": "Importe em poucos toques, passo a passo",
        "fr": "Importe en quelques gestes, étape par étape",
        "de": "Mit wenigen Tipps importiert, Schritt für Schritt",
        "it": "Importa in pochi tocchi, passo dopo passo",
        "tr": "Adım adım, birkaç dokunuşla yükle",
        "ar": "استورد بخطوات قليلة خطوة بخطوة",
        "hi": "कुछ ही टैप में इम्पोर्ट, स्टेप-बाय-स्टेप",
        "id": "Impor dengan beberapa ketukan, langkah demi langkah"}),
]


def page(lang, font_stack, caption, shot_png, dark):
    bg, fg = ("#2B1E2E", "#FBF7F4") if dark else ("#FBF7F4", "#2B1E2E")
    rtl = lang == "ar"
    cap = html.escape(caption)
    if lang.startswith("zh"):
        # 中文无空格，浏览器会在词中间断行；固定在全角逗号后换行
        cap = cap.replace("，", "，<br>", 1)
    return f"""<!doctype html>
<html lang="{lang}" dir="{'rtl' if rtl else 'ltr'}"><head><meta charset="utf-8">
<style>
  html, body {{ margin: 0; width: {W}px; height: {H}px; overflow: hidden; }}
  body {{ background: {bg}; color: {fg}; font-family: {font_stack}; }}
  h1 {{
    position: absolute; inset: 0 70px auto; height: 300px; margin: 0;
    display: flex; align-items: center; justify-content: center;
    text-align: center; font-size: 62px; line-height: 1.2; font-weight: 800;
    text-wrap: balance;
  }}
  :lang(ar) h1, :lang(hi) h1 {{ font-size: 58px; line-height: 1.35; }}
  img {{
    position: absolute; top: 300px; left: 50%; height: 1580px;
    transform: translateX(-50%); border-radius: 36px;
    box-shadow: 0 18px 40px rgba(43,30,46,.18), 0 2px 6px rgba(43,30,46,.10);
  }}
</style></head>
<body><h1>{cap}</h1><img src="file://{shot_png}"></body></html>"""


def make_play_icon(dest):
    """512×512 商店图标（无 alpha）"""
    icon = Image.open(os.path.join(ROOT, "docs/icon_preview.png")).convert("RGB")
    icon.resize((512, 512), Image.LANCZOS).save(dest)
    return dest


def main():
    src_dir = sys.argv[1] if len(sys.argv) > 1 else None
    only = set(sys.argv[2:])
    os.makedirs(OUT, exist_ok=True)

    make_play_icon(os.path.join(OUT, "play_icon_512.png"))
    print("icon ✓（宣传图见 tool/gen_feature_graphic.py）")

    if not src_dir:
        print("（未提供截图目录，跳过截图合成）")
        return

    work = tempfile.mkdtemp(prefix="store_shots_")
    for raw_dir, out_dir, _, fonts in LANGS:
        if only and out_dir not in only:
            continue
        for i, (fn, dark, caps) in enumerate(SHOTS, 1):
            src = os.path.join(src_dir, raw_dir, fn)
            if not os.path.exists(src):
                raise SystemExit(f"缺原图：{src}")
            html_path = os.path.join(work, f"{out_dir}_{i}.html")
            with open(html_path, "w", encoding="utf-8") as f:
                f.write(page(out_dir, fonts, caps[out_dir], os.path.abspath(src), dark))
            render(html_path, os.path.join(OUT, out_dir, f"screenshot_{i}.png"), W, H)
        print(f"  {out_dir}/screenshot_1..{len(SHOTS)}.png ✓")


if __name__ == "__main__":
    main()
