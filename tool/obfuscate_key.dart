// 生成 lib/config/api_key.dart：把 z.ai key 以 XOR 混淆形式写入，
// 安装包里不再出现明文 key。原理与局限见 lib/config/key_codec.dart。
//
// 用法（任选其一，key 不会被打印）：
//   dart run tool/obfuscate_key.dart          # 交互输入 key（不回显）
//   ZAI_API_KEY=xxx dart run tool/obfuscate_key.dart
//
// 若 api_key.dart 还是旧的明文格式（const String zaiApiKey = '...'），
// 不带参数运行会直接读出原 key 迁移，无需再次输入。
// 已有的 zaiEndpoints 列表会原样保留。
import 'dart:io';

import 'package:chat_report/config/key_codec.dart';

const _path = 'lib/config/api_key.dart';

const _defaultEndpoints = '''
const List<String> zaiEndpoints = [
  'https://api.z.ai/api/paas/v4/chat/completions',
  'http://127.0.0.1:8899/api/paas/v4/chat/completions',
];''';

void main(List<String> args) {
  final file = File(_path);
  final old = file.existsSync() ? file.readAsStringSync() : '';

  final key = _keyFromEnv() ?? _keyFromLegacy(old) ?? _keyFromPrompt();
  if (key == null || key.trim().isEmpty) {
    stderr.writeln('没有拿到 key，未写入。');
    exit(2);
  }

  final endpoints = RegExp(r'const List<String> zaiEndpoints = \[[\s\S]*?\];')
          .firstMatch(old)
          ?.group(0) ??
      _defaultEndpoints;

  final o = obscureKey(key.trim());
  file.writeAsStringSync('''
// 由 tool/obfuscate_key.dart 生成，勿手改（本文件已 gitignore）。
// key 以 XOR 混淆形式存放，运行时由 key_codec.dart 的 revealKey 还原。
const List<int> zaiKeyData = ${o.data};
const List<int> zaiKeyPad = ${o.pad};

/// 依序尝试的接口端点（保留第二项可在开发期借 Mac 代理联网，见 README）。
$endpoints
''');
  stdout.writeln('已写入 $_path（key 长度 ${key.trim().length}）。');
}

String? _keyFromEnv() {
  final v = Platform.environment['ZAI_API_KEY'];
  return (v != null && v.isNotEmpty) ? v : null;
}

String? _keyFromLegacy(String source) => RegExp(
        r'''const String zaiApiKey\s*=\s*['"]([^'"]+)['"]''')
    .firstMatch(source)
    ?.group(1);

String? _keyFromPrompt() {
  if (!stdin.hasTerminal) return null;
  stdout.write('z.ai API key: ');
  stdin.echoMode = false;
  try {
    return stdin.readLineSync();
  } finally {
    stdin.echoMode = true;
    stdout.writeln();
  }
}
