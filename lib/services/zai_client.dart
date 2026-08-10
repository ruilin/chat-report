import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_key.dart';
import '../l10n/app_localizations.dart';

/// z.ai (Zhipu GLM) OpenAI 兼容接口客户端。
///
/// 分块阶段用 [flashModel]（便宜、快），汇总阶段用 [proModel]。
/// 两个阶段都显式关闭思考输出，避免 reasoning token 吃掉 max_tokens。
///
/// 端点从 [zaiEndpoints] 依序尝试（连接类错误才切换下一个），
/// 首个成功的端点会被记住，后续请求直连它。
class ZaiClient {
  static const flashModel = 'glm-4.5-flash';
  static const proModel = 'glm-4.6';
  static const _timeout = Duration(seconds: 45);

  /// 跨实例记住可用端点，避免每次都先撞一遍不通的
  static String? _preferredEndpoint;

  final http.Client _http;
  ZaiClient([http.Client? client]) : _http = client ?? http.Client();

  Future<String> complete({
    required String model,
    required String system,
    required String user,
    int maxTokens = 2048,
  }) async {
    final body = jsonEncode({
      'model': model,
      'thinking': {'type': 'disabled'},
      'max_tokens': maxTokens,
      'messages': [
        {'role': 'system', 'content': system},
        {'role': 'user', 'content': user},
      ],
    });

    final candidates = [
      ?_preferredEndpoint,
      ...zaiEndpoints.where((e) => e != _preferredEndpoint),
    ];

    Object? lastError;
    for (final endpoint in candidates) {
      try {
        final resp = await _http
            .post(
              Uri.parse(endpoint),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $zaiApiKey',
              },
              body: body,
            )
            .timeout(_timeout);

        if (resp.statusCode != 200) {
          // HTTP 错误（4xx/5xx）说明端点可达，是请求本身的问题，不再换端点
          throw ZaiException('z.ai HTTP ${resp.statusCode}: ${resp.body}',
              statusCode: resp.statusCode,
              kind: resp.statusCode == 429
                  ? ZaiErrorKind.rateLimited
                  : ZaiErrorKind.http);
        }
        _preferredEndpoint = endpoint;
        final json = jsonDecode(utf8.decode(resp.bodyBytes));
        final content =
            json['choices']?[0]?['message']?['content'] as String?;
        if (content == null || content.isEmpty) {
          throw ZaiException('z.ai empty content: ${resp.body}',
              kind: ZaiErrorKind.emptyResponse);
        }
        return content;
      } on ZaiException {
        rethrow;
      } catch (e) {
        // 连接失败 / 超时 → 试下一个端点
        lastError = e;
        // ignore: avoid_print
        print('[zai] $endpoint unreachable: $e');
      }
    }
    throw ZaiException(
        'Unreachable after ${candidates.length} endpoint(s). Last error: $lastError',
        kind: ZaiErrorKind.noConnection);
  }

  /// 要求模型输出 JSON 并解析；容忍 ```json 围栏与前后杂文。
  Future<Map<String, dynamic>> completeJson({
    required String model,
    required String system,
    required String user,
    int maxTokens = 2048,
  }) async {
    final raw = await complete(
        model: model, system: system, user: user, maxTokens: maxTokens);
    return extractJson(raw);
  }

  static Map<String, dynamic> extractJson(String raw) {
    var s = raw.trim();
    final fence = RegExp(r'```(?:json)?\s*([\s\S]*?)```').firstMatch(s);
    if (fence != null) s = fence.group(1)!.trim();
    final start = s.indexOf('{');
    final end = s.lastIndexOf('}');
    if (start < 0 || end <= start) {
      throw ZaiException('Model did not return JSON: $raw',
          kind: ZaiErrorKind.emptyResponse);
    }
    return jsonDecode(s.substring(start, end + 1)) as Map<String, dynamic>;
  }

  void dispose() => _http.close();
}

enum ZaiErrorKind { noConnection, emptyResponse, rateLimited, http }

class ZaiException implements Exception {
  /// 技术描述，仅供日志；面向用户请用 [localize]
  final String message;
  final int? statusCode;
  final ZaiErrorKind kind;
  ZaiException(this.message, {this.statusCode, this.kind = ZaiErrorKind.http});

  /// 限流（可通过等待重试恢复）
  bool get isRateLimited => kind == ZaiErrorKind.rateLimited;

  String localize(L l) => switch (kind) {
        ZaiErrorKind.noConnection => l.errorNoConnection,
        ZaiErrorKind.emptyResponse => l.errorEmptyResponse,
        ZaiErrorKind.rateLimited => l.errorRateLimited,
        ZaiErrorKind.http => l.errorNoConnection,
      };

  @override
  String toString() => message;
}
