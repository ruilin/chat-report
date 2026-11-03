import 'dart:convert';
import 'dart:math';

/// API key 的 XOR 混淆编解码。
///
/// 作用只是让安装包里搜不到明文 key（strings / grep 一类的直接提取）。
/// 这不是真正的加密：客户端运行时必须还原出 key，逆向或抓包仍能拿到。
/// 真正的保护要靠后端代理把 key 留在服务器上。
/// 生成 api_key.dart 见 tool/obfuscate_key.dart。
String revealKey(List<int> data, List<int> pad) => utf8.decode(
    [for (var i = 0; i < data.length; i++) data[i] ^ pad[i % pad.length]]);

/// 用随机 pad 混淆 [key]，pad 与密文等长
({List<int> data, List<int> pad}) obscureKey(String key, [Random? random]) {
  final rng = random ?? Random.secure();
  final bytes = utf8.encode(key);
  final pad = [for (var i = 0; i < bytes.length; i++) rng.nextInt(256)];
  return (
    data: [for (var i = 0; i < bytes.length; i++) bytes[i] ^ pad[i]],
    pad: pad,
  );
}
