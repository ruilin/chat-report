// 发版前检查：解包后的产物里不能出现明文 z.ai key。
//
// 用法：dart run tool/check_key_leak.dart <解包目录>
// 由 tool/release.sh 调用；发现明文即以退出码 1 中止发版。
import 'dart:io';

import 'package:chat_report/config/api_key.dart';
import 'package:chat_report/config/key_codec.dart';

void main(List<String> args) {
  if (args.length != 1) {
    stderr.writeln('用法: dart run tool/check_key_leak.dart <解包目录>');
    exit(2);
  }
  final needle = revealKey(zaiKeyData, zaiKeyPad).codeUnits;
  final hits = <String>[];
  for (final entity in Directory(args.first).listSync(recursive: true)) {
    if (entity is File && _contains(entity.readAsBytesSync(), needle)) {
      hits.add(entity.path);
    }
  }
  if (hits.isEmpty) {
    stdout.writeln('  明文 key     : 未发现 ✓');
  } else {
    stderr.writeln('  ⚠️  以下文件含明文 key：\n    ${hits.join('\n    ')}');
    exit(1);
  }
}

bool _contains(List<int> haystack, List<int> needle) {
  outer:
  for (var i = 0; i <= haystack.length - needle.length; i++) {
    for (var j = 0; j < needle.length; j++) {
      if (haystack[i + j] != needle[j]) continue outer;
    }
    return true;
  }
  return false;
}
