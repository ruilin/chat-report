#!/usr/bin/env bash
# 原上传密钥的密码找不回时用：生成新的上传密钥，供 Play Console「重置上传密钥」。
# 新密码交互输入、不回显、不打印；不会覆盖旧密钥文件。
#
# 产物：
#   ~/.android-keystores/chat-report-upload-<日期>.jks   新上传密钥（务必备份 + 记下密码）
#   android/key.properties                               指向新密钥（已 gitignore）
#   ~/.android-keystores/chat-report-upload-certificate.pem  上传到 Play Console 的证书
# 最后顺带生成混淆后的 api_key.dart（同 tool/setup_release.sh）。
#
# 用法：tool/new_upload_key.sh
set -euo pipefail
cd "$(dirname "$0")/.."

KS="$HOME/.android-keystores/chat-report-upload-$(date +%Y%m%d).jks"
PEM="$HOME/.android-keystores/chat-report-upload-certificate.pem"
[ -e "$KS" ] && { echo "已存在 $KS，为避免覆盖已退出"; exit 1; }
mkdir -p "$(dirname "$KS")"

while :; do
  read -rsp "设置新密码（至少 6 位）：" PW; echo
  read -rsp "再输入一次：" PW2; echo
  if [ "$PW" != "$PW2" ]; then echo "两次不一致，重来"; continue; fi
  if [ "${#PW}" -lt 6 ]; then echo "太短了，重来"; continue; fi
  break
done
export PW

# CN 含 "Chat Report"：tool/release.sh 靠它确认是 release key 签的
keytool -J-Duser.language=en -genkeypair -v \
  -keystore "$KS" -alias upload \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -storepass:env PW -keypass:env PW \
  -dname "CN=Chat Report, O=Chat Report" >/dev/null 2>&1
chmod 600 "$KS"

keytool -J-Duser.language=en -export -rfc \
  -keystore "$KS" -alias upload -storepass:env PW \
  -file "$PEM" >/dev/null 2>&1

umask 077
cat > android/key.properties <<EOF
storePassword=$PW
keyPassword=$PW
keyAlias=upload
storeFile=$KS
EOF

echo "✓ 新上传密钥：$KS"
echo "✓ 证书（上传给 Play）：$PEM"
echo "✓ 已写入 android/key.properties"
echo "⚠️  现在就把新密钥文件和密码备份到密码管理器"

echo
echo "接下来输入 z.ai API key（不回显）："
dart run tool/obfuscate_key.dart
