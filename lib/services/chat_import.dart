import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';

/// 一个待导入的文件：显示名用来认类型，内容在 [path]
class ImportFile {
  final String name;
  final String path;

  const ImportFile({required this.name, required this.path});
}

/// 从导出的文件里取出聊天文本。
///
/// WhatsApp 给的可能是一个 .txt，可能是 .zip（里面是 `_chat.txt` 或
/// 「WhatsApp Chat with X.txt」），带媒体导出时还会夹着图片和视频。
class ChatImport {
  /// 纯文字导出很少超过几 MB，再大多半是带了媒体
  static const maxBytes = 64 * 1024 * 1024;

  /// 找不到聊天文本时返回 null
  static Future<String?> textFrom(List<ImportFile> files) async {
    final loaded = <(ImportFile, Uint8List)>[];
    for (final f in files) {
      try {
        final file = File(f.path);
        if (await file.length() > maxBytes) continue;
        loaded.add((f, await file.readAsBytes()));
      } catch (e) {
        // 读不了的跳过，看其他文件
        // ignore: avoid_print
        print('[import] unreadable file: $e');
      }
    }
    return textFromBytes([for (final (f, bytes) in loaded) (f.name, bytes)]);
  }

  /// 同 [textFrom]，直接给内容。先找 .txt，再到压缩包里找
  static String? textFromBytes(List<(String name, Uint8List bytes)> files) {
    final texts = <(String, Uint8List)>[];
    final zips = <Uint8List>[];
    for (final (name, bytes) in files) {
      if (_isZip(bytes)) {
        zips.add(bytes);
      } else if (name.toLowerCase().endsWith('.txt') || files.length == 1) {
        // 只分享了一个文件时，没有 .txt 后缀也当文本试一试
        texts.add((name, bytes));
      }
    }
    for (final bytes in zips) {
      try {
        for (final entry in ZipDecoder().decodeBytes(bytes).files) {
          if (!entry.isFile || entry.size > maxBytes) continue;
          if (!entry.name.toLowerCase().endsWith('.txt')) continue;
          texts.add((entry.name, entry.content));
        }
      } catch (e) {
        // 压缩包坏了或被截断，看其他文件
        // ignore: avoid_print
        print('[import] unreadable zip: $e');
      }
    }
    if (texts.isEmpty) return null;
    texts.sort((a, b) => _score(b).compareTo(_score(a)));
    final text = decode(texts.first.$2);
    return text.trim().isEmpty ? null : text;
  }

  /// 聊天文本一般就叫 _chat.txt 或「WhatsApp Chat with X.txt」；都不像时取最大的
  static int _score((String, Uint8List) file) {
    final name = file.$1.toLowerCase();
    final named = name.contains('chat') || name.contains('whatsapp');
    return (named ? 1 << 40 : 0) + file.$2.length;
  }

  static bool _isZip(Uint8List bytes) =>
      bytes.length >= 4 &&
      bytes[0] == 0x50 &&
      bytes[1] == 0x4B &&
      bytes[2] == 0x03 &&
      bytes[3] == 0x04;

  /// WhatsApp 导出是 UTF-8。个别字节坏了不该让整份聊天读不出来
  static String decode(Uint8List bytes) {
    if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xFE) {
      return String.fromCharCodes(bytes.buffer
          .asUint16List(bytes.offsetInBytes + 2, (bytes.length - 2) ~/ 2));
    }
    final hasBom = bytes.length >= 3 &&
        bytes[0] == 0xEF &&
        bytes[1] == 0xBB &&
        bytes[2] == 0xBF;
    return utf8.decode(hasBom ? Uint8List.sublistView(bytes, 3) : bytes,
        allowMalformed: true);
  }
}
