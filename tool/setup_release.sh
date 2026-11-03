#!/usr/bin/env bash
# 本机发版前的一次性配置：写 android/key.properties（签名）+ 生成混淆后的 api_key.dart。
# 密码和 key 都是交互输入、不回显、不打印；两个产物都已 gitignore。
#
# 用法：tool/setup_release.sh [keystore 路径]
#   默认 keystore：~/.android-keystores/chat-report-upload.jks
set -euo pipefail
cd "$(dirname "$0")/.."

KS="${1:-$HOME/.android-keystores/chat-report-upload.jks}"
[ -f "$KS" ] || { echo "找不到 keystore：$KS"; exit 1; }

read -rsp "keystore 密码：" STORE_PW; echo
export STORE_PW
LISTING=$(keytool -J-Duser.language=en -list -keystore "$KS" -storepass:env STORE_PW 2>&1) || {
  echo "keytool 打不开 keystore：$(printf '%s\n' "$LISTING" | grep -m1 -i 'error\|exception' || printf '%s\n' "$LISTING" | tail -1)"
  echo "（通常是 keystore 密码不对；可以再运行一次重试）"
  exit 1
}
ALIASES=$(printf '%s\n' "$LISTING" | awk -F, '/PrivateKeyEntry/ {print $1}')
[ -n "$ALIASES" ] || { echo "keystore 能打开，但里面没有私钥条目："; printf '%s\n' "$LISTING" | tail -5; exit 1; }

if [ "$(printf '%s\n' "$ALIASES" | wc -l | tr -d ' ')" -eq 1 ]; then
  ALIAS="$ALIASES"
else
  printf '%s\n' "$ALIASES"
  read -rp "选用哪个 alias：" ALIAS
fi

read -rsp "key 密码（和 keystore 密码相同就直接回车）：" KEY_PW; echo
KEY_PW="${KEY_PW:-$STORE_PW}"

umask 077
cat > android/key.properties <<EOF
storePassword=$STORE_PW
keyPassword=$KEY_PW
keyAlias=$ALIAS
storeFile=$KS
EOF
echo "✓ 已写入 android/key.properties（alias：$ALIAS）"

echo
echo "接下来输入 z.ai API key（不回显）："
dart run tool/obfuscate_key.dart
