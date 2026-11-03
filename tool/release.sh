#!/usr/bin/env bash
# 出一个可上传 Play 的 AAB。**每次都先递增 versionCode**，避免被 Play 以
# "Version code N has already been used" 打回。
#
# 用法：
#   tool/release.sh              # versionCode +1，versionName 不变（同版本重新打包）
#   tool/release.sh --patch      # 1.1.0 → 1.1.1
#   tool/release.sh --minor      # 1.1.0 → 1.2.0
#   tool/release.sh --major      # 1.1.0 → 2.0.0
set -euo pipefail
cd "$(dirname "$0")/.."

echo "── 递增版本号 ─────────────────────────────"
python3 tool/bump_version.py "$@"
VERSION=$(python3 tool/bump_version.py --show)
NAME="${VERSION%+*}"; CODE="${VERSION#*+}"

echo
echo "── 静态检查 + 测试 ────────────────────────"
flutter analyze
flutter test

echo
echo "── 构建 AAB ───────────────────────────────"
# --obfuscate 混淆 Dart 符号名；符号表留在本地，用来还原线上崩溃堆栈（勿上传/勿删）
SYMBOLS="build/symbols/$NAME+$CODE"
flutter build appbundle --release --obfuscate --split-debug-info="$SYMBOLS"

AAB=build/app/outputs/bundle/release/app-release.aab

echo
echo "── 校验产物 ───────────────────────────────"
ACTUAL_CODE=$(unzip -p "$AAB" base/manifest/AndroidManifest.xml \
  | strings | grep -oE "versionCode[^0-9]*[0-9]+" | grep -oE "[0-9]+$" || true)
SIGNER=$(keytool -printcert -jarfile "$AAB" 2>/dev/null \
  | grep -m1 -E "Owner|所有者" | sed 's/.*: //')

UNPACKED=$(mktemp -d)
unzip -o -q "$AAB" -d "$UNPACKED"
dart run tool/check_key_leak.dart "$UNPACKED"
rm -rf "$UNPACKED"

echo "  versionName : $NAME"
echo "  versionCode : $CODE"
echo "  签名主体     : $SIGNER"
echo "  体积         : $(du -h "$AAB" | cut -f1)"
echo "  路径         : $AAB"
echo "  符号表       : $SYMBOLS"

case "$SIGNER" in
  *"Chat Report"*) ;;
  *) echo "  ⚠️  签名主体不是 release key —— 检查 android/key.properties 是否存在"; exit 1;;
esac

echo
echo "✅ 可上传。别忘了在 Play Console 填 Release notes（见 docs/store/RELEASE_NOTES.md）"
