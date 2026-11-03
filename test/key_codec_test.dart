import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:chat_report/config/key_codec.dart';

void main() {
  test('obscured key round-trips', () {
    const key = 'sk-test.0123456789abcdefABCDEF';
    final o = obscureKey(key, Random(7));
    expect(revealKey(o.data, o.pad), key);
  });

  test('obscured bytes do not contain the plaintext', () {
    const key = 'sk-test.0123456789abcdefABCDEF';
    final o = obscureKey(key, Random(7));
    // 混淆后的字节序列里不应再出现明文（发版检查同理）
    expect(String.fromCharCodes(o.data), isNot(contains(key)));
    expect(o.data, isNot(utf8.encode(key)));
  });
}
