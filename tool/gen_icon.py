#!/usr/bin/env python3
"""生成 Chat Report 的 App 图标（iOS + Android，含 Android 自适应图标 + 商店 512 图标）。

设计：艳粉渐变底（印度常见的 rani pink）+ 白色对话气泡 + 气泡里一条走势线，
线的尽头是一颗心。一眼读出「聊天 + 分析 + 感情」，48px 下轮廓仍可辨。

用法：python3 tool/gen_icon.py
"""
import json
import math
import os

from PIL import Image, ImageChops, ImageDraw

# ── 品牌色（PINK 与 lib/theme.dart 的 UColors.rose 一致）──────────────
PINK = (214, 20, 112)      # #D61470 气泡里的线和心
PINK_TOP = (240, 52, 134)  # #F03486 底色左上
PINK_END = (196, 6, 98)    # #C40662 底色右下
WHITE = (255, 255, 255)

SS = 4  # 超采样倍数，先大后缩，边缘更平滑
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# 自适应图标：108dp 画布里只有中间 72dp 会露出来
ADAPTIVE = 72 / 108


def gradient(size, t0=0.0, t1=1.0):
    """对角渐变：左上 PINK_TOP → 右下 PINK_END。

    t0/t1 是画布两个角对应的渐变位置；自适应背景比露出的部分大一圈，
    所以要往两头多延伸一点，露出来的那块才和普通图标一样。
    """
    n = 64  # 渐变很平滑，小图算好再放大就够
    img = Image.new("RGB", (n, n))
    px = img.load()
    for y in range(n):
        for x in range(n):
            t = t0 + (t1 - t0) * (x + y) / (2 * (n - 1))
            px[x, y] = tuple(
                max(0, min(255, round(PINK_TOP[i] + (PINK_END[i] - PINK_TOP[i]) * t)))
                for i in range(3)
            )
    return img.resize((size, size), Image.BICUBIC)


def bezier(p0, p1, p2, p3, n=28):
    out = []
    for i in range(n + 1):
        t = i / n
        a, b, c, d = (1 - t) ** 3, 3 * (1 - t) ** 2 * t, 3 * (1 - t) * t * t, t ** 3
        out.append((
            a * p0[0] + b * p1[0] + c * p2[0] + d * p3[0],
            a * p0[1] + b * p1[1] + c * p2[1] + d * p3[1],
        ))
    return out


# 心形的左半边（半宽为 1，中心在原点），右半边镜像
_HEART_HALF = [
    ((0, 0.93), (-0.16, 0.80), (-1.0, 0.30), (-1.0, -0.38)),
    ((-1.0, -0.38), (-1.0, -0.72), (-0.78, -0.95), (-0.50, -0.95)),
    ((-0.50, -0.95), (-0.26, -0.95), (-0.07, -0.80), (0, -0.60)),
]


def heart(cx, cy, half_width, rot=0.0):
    left = []
    for seg in _HEART_HALF:
        left += bezier(*seg)
    pts = left + [(-x, y) for x, y in reversed(left)]
    cs, sn = math.cos(rot), math.sin(rot)
    return [
        (cx + (x * cs - y * sn) * half_width, cy + (x * sn + y * cs) * half_width)
        for x, y in pts
    ]


class Canvas:
    """按 1024 的设计坐标画图。g 是以中心为原点的整体缩放（自适应前景用）。"""

    def __init__(self, size, background, g=1.0):
        self.px = size * SS
        self.k = self.px / 1024
        self.g = g
        self.img = (
            background.resize((self.px, self.px), Image.BICUBIC).convert("RGBA")
            if background
            else Image.new("RGBA", (self.px, self.px), (0, 0, 0, 0))
        )

    def at(self, p):
        return (
            (512 + (p[0] - 512) * self.g) * self.k,
            (512 + (p[1] - 512) * self.g) * self.k,
        )

    def length(self, v):
        return v * self.g * self.k

    def fill(self, pts, color):
        ImageDraw.Draw(self.img).polygon([self.at(p) for p in pts], fill=color + (255,))

    def rounded_rect(self, x0, y0, x1, y1, radius, color):
        a, b = self.at((x0, y0)), self.at((x1, y1))
        ImageDraw.Draw(self.img).rounded_rectangle(
            [a[0], a[1], b[0], b[1]], radius=self.length(radius), fill=color + (255,)
        )

    def line(self, pts, width, color):
        """圆头、圆角的折线"""
        d = ImageDraw.Draw(self.img)
        p = [self.at(q) for q in pts]
        w = self.length(width)
        d.line(p, fill=color + (255,), width=round(w), joint="curve")
        for q in p:
            d.ellipse([q[0] - w / 2, q[1] - w / 2, q[0] + w / 2, q[1] + w / 2],
                      fill=color + (255,))

    def out(self, size):
        # 先转成预乘 alpha 再缩小，透明边缘才不会发黑
        return self.img.convert("RGBa").resize((size, size), Image.LANCZOS).convert("RGBA")


def draw_logo(c):
    # 对话气泡
    x0, y0, x1, y1, r = 162, 222, 862, 690, 160
    c.rounded_rect(x0, y0, x1, y1, r, WHITE)

    # 气泡左下的小尾巴（两条边带一点弧度）
    bx, tw, th = x0 + r * 0.55, 120, 120
    tip = (bx - tw * 0.10, y1 + th)
    c.fill(
        bezier((bx, y1 - 40), (bx, y1 + th * 0.35), (bx - tw * 0.02, y1 + th * 0.75), tip, 16)
        + bezier(tip, (bx + tw * 0.45, y1 + th * 0.55), (bx + tw * 0.85, y1 + th * 0.15),
                 (bx + tw, y1 - 8), 16),
        WHITE,
    )

    # 走势线：有起有落，最后往上走（明确读作图表，而非对勾）
    c.line([(286, 524), (390, 426), (490, 562), (594, 472)], 50, PINK)
    # 线的尽头是一颗心
    c.fill(heart(700, 388, 100, rot=0.14), PINK)


def render_icon(size):
    """完整图标：底色 + 图案（iOS、Android 传统图标、商店图标）"""
    c = Canvas(size, gradient(256))
    draw_logo(c)
    return c.out(size).convert("RGB")


def render_foreground(size):
    """自适应前景：透明底，图案缩到中间 72dp 的范围里"""
    c = Canvas(size, None, g=ADAPTIVE)
    draw_logo(c)
    return c.out(size)


def render_background(size):
    """自适应背景：铺满 108dp，中间露出的那块和普通图标的底色一样"""
    extra = (1 / ADAPTIVE - 1) / 2
    return gradient(size, -extra, 1 + extra)


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
        render_icon(px).save(os.path.join(ios_dir, fn))
        done.add(fn)
    print(f"iOS: {len(done)} icons")

    # ── Android 传统 mipmap + 自适应前景/背景 ─────────────────────────
    res = os.path.join(ROOT, "android/app/src/main/res")
    android_sizes = {
        "mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192,
    }
    for dpi, px in android_sizes.items():
        d = os.path.join(res, f"mipmap-{dpi}")
        os.makedirs(d, exist_ok=True)
        render_icon(px).save(os.path.join(d, "ic_launcher.png"))
        layer = round(px * 108 / 48)
        render_foreground(layer).save(os.path.join(d, "ic_launcher_foreground.png"))
        render_background(layer).save(os.path.join(d, "ic_launcher_background.png"))
    print(f"Android: {len(android_sizes)} × (legacy + adaptive foreground + background)")

    # ── Android 自适应图标声明 ────────────────────────────────────────
    anydpi = os.path.join(res, "mipmap-anydpi-v26")
    os.makedirs(anydpi, exist_ok=True)
    for name in ("ic_launcher.xml", "ic_launcher_round.xml"):
        with open(os.path.join(anydpi, name), "w") as f:
            f.write(
                '<?xml version="1.0" encoding="utf-8"?>\n'
                '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
                '    <background android:drawable="@mipmap/ic_launcher_background"/>\n'
                '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
                "</adaptive-icon>\n"
            )
    print("Android adaptive icon XML written")

    # ── 预览图 + 商店图标（512，无 alpha）─────────────────────────────
    icon = render_icon(512)
    icon.save(os.path.join(ROOT, "docs/icon_preview.png"))
    store = os.path.join(ROOT, "docs/store")
    os.makedirs(store, exist_ok=True)
    icon.save(os.path.join(store, "play_icon_512.png"))
    print("preview → docs/icon_preview.png")
    print("store   → docs/store/play_icon_512.png")


if __name__ == "__main__":
    main()
