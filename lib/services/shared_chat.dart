import 'dart:io';

import 'package:flutter/services.dart';

import 'chat_import.dart';

/// 别的 App 分享过来的内容（见 MainActivity.kt）
class SharedChat {
  /// 已拷进缓存目录的文件，用完要 [cleanUp]
  final List<ImportFile> files;

  /// 直接分享的一段文字
  final String? text;

  /// 对方一共分享了几个文件，包括被跳过的图片和视频
  final int itemCount;

  const SharedChat({required this.files, this.text, this.itemCount = 0});

  /// 聊天原文不留在手机上，读完就删
  Future<void> cleanUp() async {
    for (final f in files) {
      try {
        await File(f.path).delete();
      } catch (_) {
        // 缓存目录里的文件，删不掉系统也会清
      }
    }
  }
}

/// 接收从 WhatsApp「导出聊天」分享过来的文件
class SharedChatInbox {
  static const _channel = MethodChannel('com.ruilin.chatreport/share');

  /// App 已经开着时又收到分享
  static void listen(void Function() onArrived) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'arrived') onArrived();
    });
  }

  static void stopListening() => _channel.setMethodCallHandler(null);

  /// 取走等待处理的分享，没有则返回 null。每份分享只会被取走一次
  static Future<SharedChat?> take() async {
    try {
      final data = await _channel.invokeMapMethod<String, dynamic>('take');
      if (data == null) return null;
      return SharedChat(
        files: [
          for (final f in (data['files'] as List? ?? const []))
            if (f is Map)
              ImportFile(
                  name: f['name']?.toString() ?? '',
                  path: f['path']?.toString() ?? ''),
        ],
        text: data['text'] as String?,
        itemCount: (data['count'] as num?)?.toInt() ?? 0,
      );
    } on MissingPluginException {
      // 测试环境或其他平台没有这个通道
      return null;
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print('[share] take failed: $e');
      return null;
    }
  }
}
