#!/usr/bin/env bash
# 按语言逐一采集商店截图原图（需已安装 debug 版：报告页靠长按 logo 的 mock 入口）
# 用法：tool/capture_shots.sh <输出目录> [设备序列号]
set -euo pipefail

OUT="${1:?usage: capture_shots.sh <outdir> [serial]}"
SERIAL="${2:-R5CXA19KDYL}"
ADB="$HOME/Library/Android/sdk/platform-tools/adb"
PKG=com.ruilin.chatreport
A=("$ADB" -s "$SERIAL")

"${A[@]}" shell input keyevent KEYCODE_WAKEUP >/dev/null; sleep 1

for LOC in en zh-Hans zh-Hant; do
  DIR="$OUT/$LOC"; mkdir -p "$DIR"
  "${A[@]}" shell cmd locale set-app-locales $PKG --locales "$LOC" >/dev/null 2>&1
  "${A[@]}" shell am force-stop $PKG
  "${A[@]}" shell am start -n $PKG/.MainActivity >/dev/null 2>&1; sleep 6

  "${A[@]}" exec-out screencap -p > "$DIR/1_home.png"

  # 引导弹层
  "${A[@]}" shell input tap 540 510; sleep 3
  "${A[@]}" exec-out screencap -p > "$DIR/2_guide.png"
  "${A[@]}" shell input keyevent KEYCODE_BACK; sleep 2

  # mock 报告（长按 logo）
  "${A[@]}" shell input swipe 260 220 260 220 900; sleep 4
  "${A[@]}" exec-out screencap -p > "$DIR/3_report_top.png"
  "${A[@]}" shell input swipe 540 1600 540 800 400; sleep 2
  "${A[@]}" exec-out screencap -p > "$DIR/4_report_mid.png"
  "${A[@]}" shell input swipe 540 1600 540 700 400; sleep 2
  "${A[@]}" exec-out screencap -p > "$DIR/5_report_deep.png"

  # 回到顶部开分享弹层
  "${A[@]}" shell input swipe 540 800 540 1900 300; sleep 1
  "${A[@]}" shell input swipe 540 800 540 1900 300; sleep 2
  "${A[@]}" shell input tap 1000 180; sleep 4
  "${A[@]}" exec-out screencap -p > "$DIR/6_share.png"

  echo "captured $LOC → $DIR"
done
