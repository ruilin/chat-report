#!/usr/bin/env python3
"""生成各语言的 Google Play 宣传图（feature graphic，1024×500）。

设计：纸张米白底 + 大号本地化标语 + 两块**真实界面**（分享卡、情绪曲线卡）
轻微错落摆放。不用渐变、光晕、图标居中这类模板化手法——宣传图上的每样东西
都来自 App 本身，用户在报告页里能看到一模一样的东西。

流程：
  1. tool/capture_banner_src.sh <原图目录>   逐语言在真机上采集报告页 + 分享弹层
  2. python3 tool/gen_feature_graphic.py <原图目录>
     → 裁出两块界面 → 每种语言生成 HTML → Chrome 无头渲染 → docs/store/<语言>/feature_graphic.png

用 Chrome 渲染而不是 Pillow 画字：阿拉伯语连写、印地语天城文需要文字整形（raqm），
macOS 自带 Python 的 Pillow 没有；浏览器排版还顺带解决 RTL 镜像。
"""
import html
import json
import os
import subprocess
import sys
import tempfile

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
STORE = os.path.join(ROOT, "docs/store")
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
W, H = 1024, 500

# (原图子目录, docs/store 输出目录, ARB 文件后缀, CSS 字体栈)
LATIN = '-apple-system, "SF Pro Display", "Helvetica Neue", sans-serif'
LANGS = [
    ("en", "en", "en", LATIN),
    ("zh-Hans", "zh", "zh", '"PingFang SC", sans-serif'),
    ("zh-Hant", "zh-Hant", "zh_Hant", '"PingFang TC", sans-serif'),
    ("es", "es", "es", LATIN),
    ("pt-BR", "pt", "pt", LATIN),
    ("fr", "fr", "fr", LATIN),
    ("de", "de", "de", LATIN),
    ("it", "it", "it", LATIN),
    ("tr", "tr", "tr", LATIN),
    ("ar", "ar", "ar", '"SF Arabic", "Geeza Pro", sans-serif'),
    ("hi", "hi", "hi", '"Kohinoor Devanagari", "ITF Devanagari", sans-serif'),
    ("id", "id", "id", LATIN),
]


def lum(p):
    return 0.299 * p[0] + 0.587 * p[1] + 0.114 * p[2]


def crop_share_card(path):
    """分享弹层截图里的深色卡片：按行/列投影找深色像素占多数的区域"""
    img = Image.open(path).convert("RGB")
    w, h = img.size
    px = img.load()
    top, bottom = int(h * 0.3), int(h * 0.92)
    rows = [y for y in range(top, bottom)
            if sum(lum(px[x, y]) < 90 for x in range(0, w, 4)) > w / 4 * 0.5]
    if not rows:
        raise SystemExit(f"{path}: 没找到分享卡")
    y0, y1 = rows[0], rows[-1]
    mid = (y0 + y1) // 2
    cols = [x for x in range(w) if lum(px[x, mid]) < 90]
    return img.crop((cols[0], y0, cols[-1] + 1, y1 + 1))


def crop_curve_card(path):
    """报告页截图里的情绪曲线卡：沿卡片内侧一列找纯白背景段，取第二段
    （第一段是「互动平衡」卡；关系温度卡是浅粉色，不算）"""
    img = Image.open(path).convert("RGB")
    w, h = img.size
    px = img.load()
    x = int(w * 0.065)
    white = [all(c >= 253 for c in px[x, y]) for y in range(h)]
    segs, start = [], None
    for y, v in enumerate(white + [False]):
        if v and start is None:
            start = y
        elif not v and start is not None:
            if y - start > 150:
                segs.append((start, y))
            start = None
    if len(segs) < 2:
        raise SystemExit(f"{path}: 没找到情绪曲线卡（白色段 {segs}）")
    y0, y1 = segs[1]
    mid = (y0 + y1) // 2
    cols = [cx for cx in range(w) if all(c >= 253 for c in px[cx, mid])]
    return img.crop((cols[0], y0, cols[-1] + 1, y1))


def arb(suffix):
    with open(os.path.join(ROOT, f"lib/l10n/app_{suffix}.arb"), encoding="utf-8") as f:
        return json.load(f)


def page(lang_dir, strings, font_stack, share_png, curve_png):
    rtl = lang_dir == "ar"
    headline = html.escape(strings["tagline"])
    if lang_dir.startswith("zh"):
        # 中文无空格，浏览器会在词中间断行；固定在全角逗号后换行
        headline = headline.replace("，", "，<br>", 1)
    # 卡片倾斜方向随阅读方向镜像
    tilt_share, tilt_curve = (4, -3) if rtl else (-4, 3)
    return f"""<!doctype html>
<html lang="{lang_dir}" dir="{'rtl' if rtl else 'ltr'}"><head><meta charset="utf-8">
<style>
  html, body {{ margin: 0; width: {W}px; height: {H}px; overflow: hidden; }}
  body {{
    background: #FBF7F4;
    font-family: {font_stack};
    color: #2B1E2E;
    display: flex; align-items: center;
    padding: 0 60px; box-sizing: border-box; gap: 28px;
    position: relative;
  }}
  /* 极淡的纸张颗粒，避免纯色底的「数码感」 */
  body::before {{
    content: ""; position: absolute; inset: 0; opacity: .05; pointer-events: none;
    background-image: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='160' height='160'><filter id='n'><feTurbulence type='fractalNoise' baseFrequency='.9' numOctaves='2' stitchTiles='stitch'/></filter><rect width='100%' height='100%' filter='url(%23n)'/></svg>");
  }}
  .copy {{ flex: 0 0 430px; position: relative; }}
  .brand {{
    font-family: Palatino, Georgia, serif; font-style: italic; font-weight: 700;
    font-size: 27px; color: #E0526E; margin-bottom: 18px; direction: ltr;
    display: inline-block;
  }}
  h1 {{
    margin: 0; font-size: 50px; line-height: 1.12; font-weight: 800;
    letter-spacing: -.5px;
    text-wrap: balance;  /* 避免最后一行只剩一个词 */
  }}
  :lang(ar) h1, :lang(hi) h1 {{ letter-spacing: 0; line-height: 1.35; font-size: 46px; }}
  :lang(zh) h1, :lang(zh-Hant) h1 {{ letter-spacing: 1px; font-size: 52px; }}
  .sub {{ margin-top: 18px; font-size: 20px; color: #8A7A8E; font-weight: 500; }}
  .shots {{ flex: 1; position: relative; height: 100%; }}
  .shots img {{ position: absolute; box-shadow: 0 18px 40px rgba(43,30,46,.18), 0 2px 6px rgba(43,30,46,.10); }}
  /* 曲线卡在后、右侧略出血；分享卡在前偏左，露出曲线的四月低谷和七月峰值 */
  .curve {{
    width: 340px; border-radius: 16px; top: 62px; inset-inline-start: 196px;
    transform: rotate({tilt_curve}deg);
  }}
  .share {{
    width: 250px; border-radius: 15px; top: 118px; inset-inline-start: -6px;
    transform: rotate({tilt_share}deg);
  }}
</style></head>
<body>
  <div class="copy">
    <div class="brand">Chat Report</div>
    <h1>{headline}</h1>
    <div class="sub">{html.escape(strings["homeImportSubtitle"])}</div>
  </div>
  <div class="shots">
    <img class="curve" src="{curve_png}">
    <img class="share" src="{share_png}">
  </div>
</body></html>"""


def render(html_path, out_png, w=W, h=H):
    shot = out_png + ".2x.png"
    subprocess.run(
        [CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars",
         "--force-device-scale-factor=2", f"--window-size={w},{h}",
         f"--screenshot={shot}", "file://" + html_path],
        check=True, capture_output=True)
    # 2 倍渲染再缩回目标尺寸，文字边缘更干净；Play 要求无 alpha
    Image.open(shot).convert("RGB").resize((w, h), Image.LANCZOS).save(out_png)
    os.remove(shot)


def main():
    if len(sys.argv) < 2:
        raise SystemExit(__doc__)
    src = sys.argv[1]
    only = set(sys.argv[2:])
    work = tempfile.mkdtemp(prefix="feature_graphic_")
    for raw_dir, out_dir, arb_suffix, fonts in LANGS:
        if only and out_dir not in only:
            continue
        share = crop_share_card(os.path.join(src, raw_dir, "share.png"))
        curve = crop_curve_card(os.path.join(src, raw_dir, "report.png"))
        share_png = os.path.join(work, f"{out_dir}_share.png")
        curve_png = os.path.join(work, f"{out_dir}_curve.png")
        share.save(share_png)
        curve.save(curve_png)

        html_path = os.path.join(work, f"{out_dir}.html")
        with open(html_path, "w", encoding="utf-8") as f:
            f.write(page(out_dir, arb(arb_suffix), fonts,
                         "file://" + share_png, "file://" + curve_png))
        os.makedirs(os.path.join(STORE, out_dir), exist_ok=True)
        out = os.path.join(STORE, out_dir, "feature_graphic.png")
        render(html_path, out)
        print(f"  {out_dir}/feature_graphic.png ✓")
    print(f"（中间文件：{work}）")


if __name__ == "__main__":
    main()
