#!/usr/bin/env python3
"""生成 Google Play 上架素材：应用图标 512、宣传图 1024×500、带标题的手机截图。

原始手机截图 1080×2340（1:2.17）超出 Play 的 2:1 宽高比上限，
本脚本重新构图为 1080×1920（9:16）并加标题带。

截图按语言各出一套：英文（默认）→ docs/store/en/，简体 → zh/，繁体 → zh-Hant/。
图标与宣传图为语言无关，放 docs/store/。

用法：python3 tool/gen_store_assets.py <原始截图根目录>
     该目录下需有 en/ zh-Hans/ zh-Hant/ 三个子目录（由 tool/capture_shots.sh 生成）
"""
import os
import sys

from PIL import Image, ImageDraw, ImageFont

INK = (43, 30, 46)
PLUM = (74, 41, 55)
CREAM = (251, 247, 244)
ROSE = (224, 82, 110)
MUTED = (138, 122, 142)

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "docs/store")

# 系统字体（macOS）
FONT_BOLD = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"
FONT_SERIF = "/System/Library/Fonts/Supplemental/Georgia Bold Italic.ttf"
FONT_REG = "/System/Library/Fonts/Supplemental/Arial.ttf"
# 简体中文粗黑（Hiragino Sans GB W6 在 .ttc 的 index 2）
FONT_ZH_BOLD = ("/System/Library/Fonts/Hiragino Sans GB.ttc", 2)


def font(path, size, index=0):
    try:
        return ImageFont.truetype(path, size, index=index)
    except OSError:
        return ImageFont.load_default(size)


def gradient(size, c1, c2, diagonal=True):
    w, h = size
    img = Image.new("RGB", size)
    px = img.load()
    for y in range(h):
        for x in range(w):
            t = (x / w + y / h) / 2 if diagonal else y / h
            px[x, y] = tuple(round(c1[i] + (c2[i] - c1[i]) * t) for i in range(3))
    return img


def rounded(img, radius):
    mask = Image.new("L", img.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, img.size[0] - 1, img.size[1] - 1], radius=radius, fill=255
    )
    out = img.convert("RGBA")
    out.putalpha(mask)
    return out


def wrap(draw, text, fnt, max_w, cjk=False):
    """英文按词换行；中文逐字换行（无空格分词）"""
    if cjk:
        lines, cur = [], ""
        for ch in text:
            if draw.textlength(cur + ch, font=fnt) <= max_w:
                cur += ch
            else:
                lines.append(cur)
                cur = ch
        if cur:
            lines.append(cur)
        return lines

    words, lines, cur = text.split(), [], ""
    for w in words:
        trial = f"{cur} {w}".strip()
        if draw.textlength(trial, font=fnt) <= max_w:
            cur = trial
        else:
            if cur:
                lines.append(cur)
            cur = w
    if cur:
        lines.append(cur)
    return lines


def make_screenshot(src_path, caption, dest, dark=False, lang="en"):
    """1080×1920：顶部标题带 + 居中手机截图"""
    W, H = 1080, 1920
    bg = INK if dark else CREAM
    fg = CREAM if dark else INK
    canvas = Image.new("RGB", (W, H), bg)
    draw = ImageDraw.Draw(canvas)

    # 标题
    cjk = lang.startswith("zh")
    fnt = (font(*FONT_ZH_BOLD[:1], 60, index=FONT_ZH_BOLD[1])
           if cjk else font(FONT_BOLD, 64))
    lines = wrap(draw, caption, fnt, W - 140, cjk=cjk)
    y = 110
    for ln in lines:
        tw = draw.textlength(ln, font=fnt)
        draw.text(((W - tw) / 2, y), ln, font=fnt, fill=fg)
        y += 78

    # 截图（等比缩放后放入剩余空间，圆角）
    shot = Image.open(src_path).convert("RGB")
    top = y + 60
    avail_h = H - top - 40
    scale = min((W - 200) / shot.width, avail_h / shot.height)
    sw, sh = round(shot.width * scale), round(shot.height * scale)
    shot = shot.resize((sw, sh), Image.LANCZOS)
    shot = rounded(shot, 36)
    canvas.paste(shot, ((W - sw) // 2, top), shot)

    canvas.save(dest)
    return dest


def make_feature_graphic(dest):
    """1024×500 宣传图"""
    W, H = 1024, 500
    canvas = gradient((W, H), INK, PLUM)
    draw = ImageDraw.Draw(canvas)

    # 左侧图标
    icon = Image.open(os.path.join(ROOT, "docs/icon_preview.png")).convert("RGB")
    size = 210
    icon = rounded(icon.resize((size, size), Image.LANCZOS), 48)
    canvas.paste(icon, (78, (H - size) // 2), icon)

    # 右侧文案
    x = 78 + size + 62
    f_title = font(FONT_SERIF, 74)
    f_sub = font(FONT_REG, 32)
    draw.text((x, 168), "Chat Report", font=f_title, fill=CREAM)
    draw.text((x, 268), "What's really in your chats?", font=f_sub, fill=(200, 170, 185))

    # 品牌重音条
    draw.rounded_rectangle([x, 330, x + 96, 340], radius=5, fill=ROSE)

    canvas.save(dest)
    return dest


def make_play_icon(dest):
    """512×512 商店图标（无 alpha）"""
    icon = Image.open(os.path.join(ROOT, "docs/icon_preview.png")).convert("RGB")
    icon.resize((512, 512), Image.LANCZOS).save(dest)
    return dest


def main():
    src_dir = sys.argv[1] if len(sys.argv) > 1 else None
    os.makedirs(OUT, exist_ok=True)

    make_play_icon(os.path.join(OUT, "play_icon_512.png"))
    make_feature_graphic(os.path.join(OUT, "feature_graphic_1024x500.png"))
    print("icon + feature graphic ✓")

    if not src_dir:
        print("（未提供截图目录，跳过截图合成）")
        return

    # 标题必须与画面内容一致（Play 会以"误导性截图"驳回）
    # 繁体标题为台港用词改写，非简繁直转
    shots = [
        ("1_home.png", False, {
            "en": "Turn your chats into a real report",
            "zh": "把聊天记录变成一份真报告",
            "zh-Hant": "把聊天紀錄變成一份真報告"}),
        ("3_report_top.png", False, {
            "en": "Warmth score — and who texts first",
            "zh": "关系温度分，谁更主动一目了然",
            "zh-Hant": "關係溫度分，誰更主動一目了然"}),
        ("4_report_mid.png", False, {
            "en": "A month-by-month emotion curve",
            "zh": "逐月情绪曲线，起落都看得见",
            "zh-Hant": "逐月情緒曲線，起落都看得見"}),
        ("5_report_deep.png", False, {
            "en": "AI reads between the lines",
            "zh": "AI 读出聊天里的言外之意",
            "zh-Hant": "AI 讀出對話裡的言外之意"}),
        ("2_guide.png", False, {
            "en": "Import in 30 seconds — guided",
            "zh": "分步引导，30 秒导入完成",
            "zh-Hant": "逐步引導，30 秒匯入完成"}),
        ("6_share.png", True, {
            "en": "Share it — names stay private",
            "zh": "一键分享，姓名自动隐去",
            "zh-Hant": "一鍵分享，姓名自動隱去"}),
    ]
    # 原图目录名与 Play 语言目录名的映射（截图须用对应语言的真实界面）
    src_sub = {"en": "en", "zh": "zh-Hans", "zh-Hant": "zh-Hant"}
    for lang in ("en", "zh", "zh-Hant"):
        d = os.path.join(OUT, lang)
        os.makedirs(d, exist_ok=True)
        for i, (fn, dark, caps) in enumerate(shots, 1):
            src = os.path.join(src_dir, src_sub[lang], fn)
            if not os.path.exists(src):
                print(f"  skip {fn} (not found)")
                continue
            dest = os.path.join(d, f"screenshot_{i}.png")
            make_screenshot(src, caps[lang], dest, dark=dark, lang=lang)
        print(f"  {lang}/screenshot_1..{len(shots)}.png ✓")


if __name__ == "__main__":
    main()
