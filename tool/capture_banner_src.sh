#!/usr/bin/env bash
# 逐语言采集宣传图用的真实界面原图：报告页（取情绪曲线卡）+ 分享弹层（取分享卡）。
# 需已安装 debug 版：报告页靠长按 logo 的示例报告入口（该入口带分享按钮）。
# 用法：tool/capture_banner_src.sh <输出目录> [设备序列号] [语言...]
#   之后：python3 tool/gen_feature_graphic.py <输出目录>
# 采集期间别动手机；每种语言前会确认 Chat Report 在前台，否则中止。
set -euo pipefail

OUT="${1:?usage: capture_banner_src.sh <outdir> [serial] [locales...]}"
SERIAL="${2:-R5CYA0Y4GRA}"
shift $(( $# >= 2 ? 2 : 1 ))
LOCALES=("$@")
[ ${#LOCALES[@]} -eq 0 ] && LOCALES=(en zh-Hans zh-Hant es pt-BR fr de it tr ar hi id)

ADB="${ADB:-adb}"
PKG=com.ruilin.chatreport
A=("$ADB" -s "$SERIAL")

restore() { "${A[@]}" shell cmd locale set-app-locales $PKG --locales "" >/dev/null 2>&1 || true; }
trap restore EXIT

for LOC in "${LOCALES[@]}"; do
  mkdir -p "$OUT/$LOC"
  "${A[@]}" shell cmd locale set-app-locales $PKG --locales "$LOC" >/dev/null
  "${A[@]}" shell am force-stop $PKG
  "${A[@]}" shell am start -n $PKG/.MainActivity >/dev/null; sleep 6
  focus=$("${A[@]}" shell dumpsys window | grep -m1 mCurrentFocus)
  case "$focus" in *chatreport*) ;; *) echo "$LOC: Chat Report 不在前台（$focus），中止"; exit 1;; esac

  # RTL 下 logo 与分享按钮左右互换
  if [ "$LOC" = ar ]; then LX=820; SX=57; else LX=260; SX=1023; fi
  "${A[@]}" shell input swipe $LX 222 $LX 222 1000; sleep 3
  "${A[@]}" exec-out screencap -p > "$OUT/$LOC/report.png"
  "${A[@]}" shell input tap $SX 175; sleep 3
  "${A[@]}" exec-out screencap -p > "$OUT/$LOC/share.png"
  "${A[@]}" shell input keyevent BACK; sleep 1.5
  "${A[@]}" shell input keyevent BACK; sleep 1
  echo "$LOC ✓"
done
