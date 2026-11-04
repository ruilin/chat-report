import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_key.dart';
import '../config/key_codec.dart';
import '../l10n/app_localizations.dart';

/// z.ai (Zhipu GLM) OpenAI 兼容接口客户端。
///
/// 分块阶段用 [flashModel]，汇总和专题分析用 [reportModel]。
/// 两个阶段都显式关闭思考输出，避免 reasoning token 吃掉 max_tokens。
///
/// 端点从 [zaiEndpoints] 依序尝试（连接类错误才切换下一个），
/// 首个成功的端点会被记住，后续请求直连它。
class ZaiClient {
  static const flashModel = 'glm-4.5-flash';

  /// 目前也用免费的 flash。限流或内容质量不够时改回付费的 glm-4.6（账户需有余额）
  static const reportModel = flashModel;
  /// 流式回答中途超过这么久没有新文字，就当连接卡住
  static const _streamIdle = Duration(seconds: 20);

  /// 跨实例记住可用端点，避免每次都先撞一遍不通的
  static String? _preferredEndpoint;

  /// key 以混淆形式编进包里，首次使用时还原（见 key_codec.dart）
  static final _apiKey = revealKey(zaiKeyData, zaiKeyPad);

  final http.Client _http;
  ZaiClient([http.Client? client]) : _http = client ?? http.Client();

  /// 流式请求：每来一段文字就用目前的全文回调 [onText]，返回完整回答。
  /// 超过 [firstTextTimeout] 还没有第一段文字就放弃，抛 [ZaiErrorKind.timedOut]。
  Future<String> completeStream({
    required String model,
    required String system,
    required String user,
    required Duration firstTextTimeout,
    required void Function(String text) onText,
    int maxTokens = 2048,
  }) async {
    final body = jsonEncode({
      'model': model,
      'thinking': {'type': 'disabled'},
      'max_tokens': maxTokens,
      'stream': true,
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
    var timedOut = false;
    for (final endpoint in candidates) {
      final abort = Completer<void>();
      Timer? watchdog;
      void watch(Duration wait) {
        watchdog?.cancel();
        watchdog = Timer(wait, () {
          timedOut = true;
          if (!abort.isCompleted) abort.complete();
        });
      }

      watch(firstTextTimeout);
      try {
        final req = http.AbortableRequest('POST', Uri.parse(endpoint),
            abortTrigger: abort.future)
          ..headers['Content-Type'] = 'application/json'
          ..headers['Authorization'] = 'Bearer $_apiKey'
          ..body = body;
        final resp = await _http.send(req);
        if (resp.statusCode != 200) {
          throw _httpError(resp.statusCode, await resp.stream.bytesToString());
        }
        _preferredEndpoint = endpoint;

        final text = StringBuffer();
        final lines =
            resp.stream.transform(utf8.decoder).transform(const LineSplitter());
        await for (final line in lines) {
          if (!line.startsWith('data:')) continue;
          final data = line.substring(5).trim();
          if (data == '[DONE]') break;
          final delta =
              jsonDecode(data)['choices']?[0]?['delta']?['content'] as String?;
          if (delta == null || delta.isEmpty) continue;
          text.write(delta);
          watch(_streamIdle);
          onText(text.toString());
        }
        if (text.isEmpty) {
          throw ZaiException('z.ai empty stream',
              kind: ZaiErrorKind.emptyResponse);
        }
        return text.toString();
      } on ZaiException {
        rethrow;
      } catch (e) {
        lastError = e;
        // ignore: avoid_print
        print('[zai] $endpoint stream failed: $e');
      } finally {
        watchdog?.cancel();
      }
    }
    throw ZaiException(
        'Stream failed after ${candidates.length} endpoint(s). Last error: $lastError',
        kind: timedOut ? ZaiErrorKind.timedOut : ZaiErrorKind.noConnection);
  }

  static ZaiException _httpError(int status, String body) =>
      ZaiException('z.ai HTTP $status: $body',
          statusCode: status,
          // z.ai 余额不足也返回 429（业务码 1113），等多久都不会恢复，不能按限流重试
          kind: status == 429 && !body.contains('"1113"')
              ? ZaiErrorKind.rateLimited
              : ZaiErrorKind.http);

  /// 要求模型输出 JSON 并解析；容忍 ```json 围栏与前后杂文。
  /// 也走流式：长回答（比如印地语）光生成就要一分多钟，只能按多久没出字判断是否卡住，
  /// 不能限制总时长。[firstTextTimeout] 留够排队时间，实测常要等半分钟以上。
  Future<Map<String, dynamic>> completeJson({
    required String model,
    required String system,
    required String user,
    int maxTokens = 2048,
    Duration firstTextTimeout = const Duration(seconds: 90),
  }) async {
    final raw = await completeStream(
        model: model,
        system: system,
        user: user,
        maxTokens: maxTokens,
        firstTextTimeout: firstTextTimeout,
        onText: (_) {});
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
    try {
      return jsonDecode(s.substring(start, end + 1)) as Map<String, dynamic>;
    } on FormatException catch (e) {
      throw ZaiException('Model returned broken JSON: $e',
          kind: ZaiErrorKind.emptyResponse);
    }
  }

  void dispose() => _http.close();
}

enum ZaiErrorKind { noConnection, emptyResponse, rateLimited, timedOut, http }

class ZaiException implements Exception {
  /// 技术描述，仅供日志；面向用户请用 [localize]
  final String message;
  final int? statusCode;
  final ZaiErrorKind kind;
  ZaiException(this.message, {this.statusCode, this.kind = ZaiErrorKind.http});

  /// 限流（可通过等待重试恢复）
  bool get isRateLimited => kind == ZaiErrorKind.rateLimited;

  /// 服务端迟迟没有回应，重新排队通常就好
  bool get isTimedOut => kind == ZaiErrorKind.timedOut;

  /// 回答是空的或 JSON 损坏，再生成一次通常就好
  bool get isBadResponse => kind == ZaiErrorKind.emptyResponse;

  String localize(L l) => switch (kind) {
        ZaiErrorKind.noConnection => l.errorNoConnection,
        ZaiErrorKind.emptyResponse => l.errorEmptyResponse,
        ZaiErrorKind.rateLimited => l.errorRateLimited,
        // 端点可达但返回 4xx/5xx（key 失效、额度用尽、服务故障）或一直不回应：
        // 不是用户网络的问题，别让用户去查 Wi-Fi
        ZaiErrorKind.http || ZaiErrorKind.timedOut => l.errorServiceUnavailable,
      };

  @override
  String toString() => message;
}
