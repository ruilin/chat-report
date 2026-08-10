// 复制本文件为 api_key.dart（已 gitignore）并填入你的 z.ai API key。
const String zaiApiKey = 'YOUR_ZAI_API_KEY';

/// 依序尝试的接口端点（保留第二项可在开发期借 Mac 代理联网，见 README）。
const List<String> zaiEndpoints = [
  'https://api.z.ai/api/paas/v4/chat/completions',
  'http://127.0.0.1:8899/api/paas/v4/chat/completions',
];
