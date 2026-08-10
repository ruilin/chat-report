#!/usr/bin/env python3
"""生成 Chat Report 的 App 图标（iOS + Android，含 Android 自适应图标）。

设计：深紫渐变底（呼应分享卡）+ 奶白对话气泡 + 气泡内玫瑰红情绪曲线。
一眼读出「聊天 + 分析报告」，48px 下轮廓仍可辨。

用法：python3 tool/gen_icon.py
"""
import json
import os

from PIL import Image, ImageDraw

# ── 品牌色（与 lib/theme.dart 一致）────────────────────────────────────
INK = (43, 30, 46)        # #2B1E2E
PLUM = (74, 41, 55)       # #4A2937
CREAM = (251, 247, 244)   # #FBF7F4
ROSE = (224, 82, 110)     # #E0526E
BLUE = (61, 143, 191)     # #3D8FBF

SS = 4  # 超采样倍数，先大后缩，边缘更平滑
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def gradient_bg(size):
    """对角渐变：左上 INK → 右下 PLUM"""
    img = Image.new("RGB", (size, size))
    px = img.load()
    for y in range(size):
        for x in range(size):
            t = (x + y) / (2 * (size - 1))
            px[x, y] = tuple(
                round(INK[i] + (PLUM[i] - INK[i]) * t) for i in range(3)
            )
    return img


def draw_logo(draw, box, scale):
    """在 box=(x0,y0,x1,y1) 区域内画气泡 + 曲线。scale 为 1024 基准的缩放。"""
    x0, y0, x1, y1 = box
    w, h = x1 - x0, y1 - y0

    # 对话气泡本体（圆角矩形）
    bw, bh = w * 0.86, h * 0.62
    bx0 = x0 + (w - bw) / 2
    by0 = y0 + h * 0.10
    bx1, by1 = bx0 + bw, by0 + bh
    radius = bh * 0.30
    draw.rounded_rectangle([bx0, by0, bx1, by1], radius=radius, fill=CREAM)

    # 气泡尾巴（左下三角，与本体同色自然融合）
    tail_x = bx0 + bw * 0.20
    draw.polygon(
        [
            (tail_x, by1 - bh * 0.08),
            (tail_x + bw * 0.24, by1 - bh * 0.08),
            (tail_x - bw * 0.02, by1 + bh * 0.30),
        ],
        fill=CREAM,
    )

    # 气泡内情绪曲线：多折点走势线（明确读作图表，而非对勾）
    pad_x, pad_y = bw * 0.15, bh * 0.24
    cx0, cy0 = bx0 + pad_x, by0 + pad_y
    cw, ch = bw - pad_x * 2, bh - pad_y * 2
    pts = [
        (cx0 + cw * 0.00, cy0 + ch * 0.52),
        (cx0 + cw * 0.22, cy0 + ch * 0.22),  # 小高点
        (cx0 + cw * 0.46, cy0 + ch * 0.78),  # 低谷
        (cx0 + cw * 0.70, cy0 + ch * 0.44),
        (cx0 + cw * 1.00, cy0 + ch * 0.03),  # 终点最高
    ]
    lw = max(2, round(bh * 0.105))
    draw.line(pts, fill=ROSE, width=lw, joint="curve")
    # 圆头收尾
    for p in (pts[0], pts[-1]):
        r = lw / 2
        draw.ellipse([p[0] - r, p[1] - r, p[0] + r, p[1] + r], fill=ROSE)
    # 终点强调（呼应曲线图上的终点着重色）
    r = lw * 1.15
    p = pts[-1]
    draw.ellipse([p[0] - r, p[1] - r, p[0] + r, p[1] + r], fill=ROSE)
    r2 = lw * 0.42
    draw.ellipse([p[0] - r2, p[1] - r2, p[0] + r2, p[1] + r2], fill=CREAM)


def render_icon(size, with_bg=True, inset=0.0):
    """inset: 四周留白比例（Android 自适应前景需要 ~0.17 安全区）"""
    s = size * SS
    if with_bg:
        img = gradient_bg(s).convert("RGBA")
    else:
        img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    pad = s * inset
    draw_logo(draw, (pad, pad, s - pad, s - pad), s / 1024)
    return img.resize((size, size), Image.LANCZOS)


def main():
    # ── iOS：按 Contents.json 逐个尺寸产出（Apple 要求无 alpha）────────
    ios_dir = os.path.join(ROOT, "ios/Runner/Assets.xcassets/AppIcon.appiconset")
    contents = json.load(open(os.path.join(ios_dir, "Contents.json")))
    done = set()
    for entry in contents["images"]:
        fn = entry.get("filename")
        if not fn or fn in done:
            continue
        px = round(float(entry["size"].split("x")[0]) * float(entry["scale"][0]))
        render_icon(px).convert("RGB").save(os.path.join(ios_dir, fn))
        done.add(fn)
    print(f"iOS: {len(done)} icons")

    # ── Android 传统 mipmap ──────────────────────────────────────────
    android_sizes = {
        "mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192,
    }
    for dpi, px in android_sizes.items():
        d = os.path.join(ROOT, f"android/app/src/main/res/mipmap-{dpi}")
        os.makedirs(d, exist_ok=True)
        render_icon(px).convert("RGB").save(os.path.join(d, "ic_launcher.png"))
        # 自适应前景：108dp 画布，内容限制在中心 72dp 安全区
        render_icon(round(px * 108 / 48), with_bg=False, inset=0.19).save(
            os.path.join(d, "ic_launcher_foreground.png")
        )
    print(f"Android: {len(android_sizes)} × (legacy + adaptive foreground)")

    # ── Android 自适应图标声明 ────────────────────────────────────────
    anydpi = os.path.join(ROOT, "android/app/src/main/res/mipmap-anydpi-v26")
    os.makedirs(anydpi, exist_ok=True)
    for name in ("ic_launcher.xml", "ic_launcher_round.xml"):
        with open(os.path.join(anydpi, name), "w") as f:
            f.write(
                '<?xml version="1.0" encoding="utf-8"?>\n'
                '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
                '    <background android:drawable="@color/ic_launcher_background"/>\n'
                '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
                "</adaptive-icon>\n"
            )
    values = os.path.join(ROOT, "android/app/src/main/res/values")
    os.makedirs(values, exist_ok=True)
    with open(os.path.join(values, "ic_launcher_background.xml"), "w") as f:
        f.write(
            '<?xml version="1.0" encoding="utf-8"?>\n'
            "<resources>\n"
            '    <color name="ic_launcher_background">#33232F</color>\n'
            "</resources>\n"
        )
    print("Android adaptive icon XML written")

    # 预览图
    prev = os.path.join(ROOT, "docs")
    os.makedirs(prev, exist_ok=True)
    render_icon(512).convert("RGB").save(os.path.join(prev, "icon_preview.png"))
    print("preview → docs/icon_preview.png")


if __name__ == "__main__":
    main()
