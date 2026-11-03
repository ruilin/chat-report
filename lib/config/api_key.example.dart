// 示例：内含混淆后的占位 key "YOUR_ZAI_API_KEY"，可直接编译但无法调用接口。
// 真实 key 请运行 `dart run tool/obfuscate_key.dart` 生成 api_key.dart（已 gitignore）。
// key 以 XOR 混淆形式存放，运行时由 key_codec.dart 的 revealKey 还原。
const List<int> zaiKeyData = [146, 248, 7, 167, 178, 80, 89, 244, 101, 48, 187, 98, 216, 229, 214, 200];
const List<int> zaiKeyPad = [203, 183, 82, 245, 237, 10, 24, 189, 58, 113, 235, 43, 135, 174, 147, 145];

/// 依序尝试的接口端点（保留第二项可在开发期借 Mac 代理联网，见 README）。
const List<String> zaiEndpoints = [
  'https://api.z.ai/api/paas/v4/chat/completions',
  'http://127.0.0.1:8899/api/paas/v4/chat/completions',
];
