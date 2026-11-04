#!/usr/bin/env python3
"""逐语言采集商店截图原图：首页、导入引导、报告页三屏、分享弹层。

需已安装 debug 版（报告页靠长按 logo 的示例报告入口）。靠无障碍节点定位，
不写死坐标：各语言文案长短不同，报告页各板块的位置也不同，RTL 还会左右镜像。

默认用模拟器：不占用手机，状态栏也干净（demo 模式），并断网避免污染线上埋点。
  avdmanager create avd -n chatreport-shots -k "system-images;android-36;google_apis_playstore;arm64-v8a"
  （config.ini 改 1080×2340、density 450，与主力测试机一致）
  emulator -avd chatreport-shots -no-window -port 5580
  adb -s emulator-5580 install -r build/app/outputs/flutter-apk/app-debug.apk

用法：python3 tool/capture_shots.py <输出目录> [--serial emulator-5580] [语言...]
之后：python3 tool/gen_store_assets.py <输出目录>
"""
import argparse
import html
import json
import os
import re
import subprocess
import time

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PKG = "com.ruilin.chatreport"
# (Android 语言标签, ARB 文件后缀)
LOCALES = [
    ("en", "en"), ("zh-Hans", "zh"), ("zh-Hant", "zh_Hant"), ("es", "es"),
    ("pt-BR", "pt"), ("fr", "fr"), ("de", "de"), ("it", "it"), ("tr", "tr"),
    ("ar", "ar"), ("hi", "hi"), ("id", "id"),
]
# 报告页板块滚到这个 y，刚好在固定的顶栏下方
SECTION_TOP = 236
# 板块之间的间距
SECTION_GAP = 40
# 分享按钮没有文字节点；顶栏固定，直接用它的中心坐标（RTL 下左右镜像）
SHARE_XY = (1012, 146)
SHARE_XY_RTL = (68, 146)
SCREEN_MID = 540


class Device:
    def __init__(self, serial):
        self.serial = serial

    def adb(self, *args, **kw):
        return subprocess.run(["adb", "-s", self.serial, *args], check=True,
                              capture_output=True, **kw).stdout

    def shell(self, cmd):
        return self.adb("shell", cmd).decode("utf-8", "replace")

    def nodes(self):
        """当前界面带文字的无障碍节点：[(文字, (x0, y0, x1, y1))]"""
        xml = self.adb("exec-out", "uiautomator dump /dev/tty").decode("utf-8", "replace")
        found = []
        for text, bounds in re.findall(
                r'(?:text|content-desc)="([^"]+)"[^>]*?bounds="([^"]+)"', xml):
            x0, y0, x1, y1 = map(int, re.findall(r"\d+", bounds))
            found.append((html.unescape(text), (x0, y0, x1, y1)))
        return found

    def find(self, needle):
        for text, box in self.nodes():
            if needle in text:
                return box
        return None

    def wait_for(self, needle, timeout=45):
        deadline = time.time() + timeout
        while time.time() < deadline:
            box = self.find(needle)
            if box:
                return box
            time.sleep(1)
        raise SystemExit(f"等不到界面元素：{needle}")

    def shot(self, path):
        with open(path, "wb") as f:
            f.write(self.adb("exec-out", "screencap -p"))

    def tap(self, box):
        self.shell(f"input tap {(box[0] + box[2]) // 2} {(box[1] + box[3]) // 2}")

    def drag(self, dy):
        """手指拖动 dy 像素后停一下再抬起：松手速度为 0，列表不会惯性滑动"""
        y0 = 1300 if dy < 0 else 500
        y1 = y0 + dy
        mv = f"input motionevent MOVE {SCREEN_MID} {y1}"
        self.shell(f"input motionevent DOWN {SCREEN_MID} {y0}; {mv}; sleep 0.4; {mv}; "
                   f"input motionevent UP {SCREEN_MID} {y1}")
        time.sleep(0.6)

    def scroll_to(self, label, y=SECTION_TOP):
        """把含 label 的板块顶部滚到 y（列表到底时停在到底的位置）"""
        last = None
        for _ in range(20):
            box = self.find(label)
            if box is None:
                self.drag(-1000)
                continue
            delta = box[1] - y
            if abs(delta) <= 6 or box[1] == last:
                return
            last = box[1]
            self.drag(max(-1000, min(1000, -delta)))
        raise SystemExit(f"滚动不到板块：{label}")

    def scroll_past(self, label):
        """把含 label 的板块滚出去，让它的下一个板块顶到 SECTION_TOP。
        下一个板块比一屏还长时读不到文字节点，只能靠上一个板块定位"""
        park = 700
        for _ in range(20):
            box = self.find(label)
            if box is None:
                self.drag(-1000)
                continue
            if abs(box[3] - park) <= 6:
                break
            self.drag(max(-1000, min(1000, park - box[3])))
        else:
            raise SystemExit(f"滚动不到板块：{label}")
        self.drag(SECTION_TOP - park - SECTION_GAP)

    def scroll_top(self):
        for _ in range(8):
            self.drag(1000)

    def clean_status_bar(self):
        self.shell("svc wifi disable; svc data disable; "
                   "settings put global sysui_demo_allowed 1")
        demo = "am broadcast -a com.android.systemui.demo -e command"
        for args in ("enter", "clock -e hhmm 1200",
                     "battery -e level 100 -e plugged false",
                     "network -e wifi show -e level 4 -e fully true",
                     "network -e mobile hide", "notifications -e visible false"):
            self.shell(f"{demo} {args}")


def capture(dev, loc, l, out):
    os.makedirs(out, exist_ok=True)
    label = lambda key: l[key].split(" · ")[0].upper()

    dev.shell(f"cmd locale set-app-locales {PKG} --locales {loc}")
    dev.shell(f"am force-stop {PKG}; am start -n {PKG}/.MainActivity")
    box = dev.wait_for(l["homeImportTitle"])
    time.sleep(1)
    dev.shot(f"{out}/1_home.png")

    dev.tap(box)
    dev.wait_for(l["guideStep1Title"])
    time.sleep(1.5)  # 等弹层动画结束
    dev.shot(f"{out}/2_guide.png")
    dev.shell("input keyevent BACK")
    time.sleep(1.5)

    # 长按 logo 打开示例报告
    title = dev.wait_for(l["appTitle"])
    x, y = (title[0] + title[2]) // 2, (title[1] + title[3]) // 2
    dev.shell(f"input swipe {x} {y} {x} {y} 1000")
    dev.wait_for(label("sectionWarmth"))
    time.sleep(1.5)  # 等温度计数动画结束
    dev.shot(f"{out}/3_report_top.png")

    dev.scroll_to(label("sectionEmotionCurve"))
    time.sleep(1)
    dev.shot(f"{out}/4_report_mid.png")

    dev.scroll_past(label("sectionPersonalities"))
    time.sleep(1)
    dev.shot(f"{out}/5_report_deep.png")

    dev.scroll_top()
    x, y = SHARE_XY_RTL if loc == "ar" else SHARE_XY
    dev.shell(f"input tap {x} {y}")
    dev.wait_for(l["shareTitle"])
    time.sleep(2)
    dev.shot(f"{out}/6_share.png")


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("outdir")
    ap.add_argument("--serial", default="emulator-5580")
    ap.add_argument("locales", nargs="*", help="如 en ar；默认全部")
    args = ap.parse_args()

    dev = Device(args.serial)
    if args.serial.startswith("emulator"):
        dev.clean_status_bar()
    try:
        for loc, suffix in LOCALES:
            if args.locales and loc not in args.locales:
                continue
            with open(os.path.join(ROOT, f"lib/l10n/app_{suffix}.arb"), encoding="utf-8") as f:
                strings = json.load(f)
            capture(dev, loc, strings, os.path.join(args.outdir, loc))
            print(f"{loc} ✓", flush=True)
    finally:
        dev.shell(f"cmd locale set-app-locales {PKG} --locales ''")


if __name__ == "__main__":
    main()
