package com.ruilin.chatreport

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.provider.OpenableColumns
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.InputStream
import java.io.OutputStream

/**
 * 除了正常启动，还接收别的 App 分享过来的聊天导出（WhatsApp「导出聊天」）。
 *
 * 这里只把分享来的文件拷进缓存目录并交给 Dart，认文件、解压、解析都在 Dart 里做。
 * 内容 URI 的读取权限只在这个 Activity 存活期间有效，所以要在这里读出来。
 */
class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null

    /** 还没被 Dart 取走的分享 */
    private var pendingShare: Intent? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // 进程被回收后恢复、或从「最近任务」重新打开时，系统会把旧的分享 Intent 再给一次，不能重复导入
        val replayed = savedInstanceState != null ||
            (intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY) != 0
        if (!replayed && isShare(intent)) pendingShare = intent
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (!isShare(intent)) return
        pendingShare = intent
        channel?.invokeMethod("arrived", null)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).also {
            it.setMethodCallHandler { call, result ->
                if (call.method == "take") take(result) else result.notImplemented()
            }
        }
    }

    private fun isShare(intent: Intent?) =
        intent?.action == Intent.ACTION_SEND || intent?.action == Intent.ACTION_SEND_MULTIPLE

    private fun take(result: MethodChannel.Result) {
        val share = pendingShare
        pendingShare = null
        if (share == null) {
            result.success(null)
            return
        }
        // 文件可能有几十 MB，不能在主线程上拷
        Thread {
            val payload = try {
                readShare(share)
            } catch (e: Exception) {
                Log.w(TAG, "reading share failed", e)
                mapOf("files" to emptyList<Map<String, String>>(), "text" to null, "count" to 0)
            }
            runOnUiThread { result.success(payload) }
        }.start()
    }

    private fun readShare(share: Intent): Map<String, Any?> {
        val uris = sharedUris(share)
        // 只记形式不记内容，用来确认各版本 WhatsApp 实际怎么分享
        Log.i(TAG, "share action=${share.action} type=${share.type} items=${uris.size}")

        val dir = File(cacheDir, "shared_chat")
        dir.deleteRecursively()
        dir.mkdirs()

        val files = ArrayList<Map<String, String>>()
        for ((index, uri) in uris.withIndex()) {
            val name = displayName(uri) ?: uri.lastPathSegment ?: "file$index"
            val mime = contentResolver.getType(uri) ?: ""
            Log.i(TAG, "item $index ext=${name.substringAfterLast('.', "")} mime=$mime")
            // 带媒体导出时会夹着大量图片和视频，只拷可能是聊天文本的
            if (uris.size > 1 && !looksLikeChat(name, mime)) continue
            try {
                val target = File(dir, "$index.bin")
                val input = contentResolver.openInputStream(uri) ?: continue
                input.use { source -> target.outputStream().use { copyLimited(source, it) } }
                files.add(mapOf("path" to target.absolutePath, "name" to name))
            } catch (e: Exception) {
                Log.w(TAG, "item $index could not be read: ${e.javaClass.simpleName}")
            }
        }
        val text = share.getCharSequenceExtra(Intent.EXTRA_TEXT)?.toString()
        return mapOf("files" to files, "text" to text, "count" to uris.size)
    }

    private fun looksLikeChat(name: String, mime: String): Boolean {
        val lower = name.lowercase()
        return lower.endsWith(".txt") || lower.endsWith(".zip") ||
            mime.startsWith("text/") || mime.contains("zip") || mime == "application/txt"
    }

    @Suppress("DEPRECATION")
    private fun sharedUris(share: Intent): List<Uri> {
        val found = LinkedHashSet<Uri>()
        if (share.action == Intent.ACTION_SEND_MULTIPLE) {
            share.getParcelableArrayListExtra<Uri>(Intent.EXTRA_STREAM)?.let { found.addAll(it) }
        } else {
            share.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)?.let { found.add(it) }
        }
        // 有的 App 只把文件放在 clipData 里
        share.clipData?.let { clip ->
            for (i in 0 until clip.itemCount) clip.getItemAt(i).uri?.let { found.add(it) }
        }
        return found.toList()
    }

    private fun displayName(uri: Uri): String? = try {
        contentResolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)
            ?.use { cursor -> if (cursor.moveToFirst()) cursor.getString(0) else null }
    } catch (e: Exception) {
        null
    }

    private fun copyLimited(source: InputStream, target: OutputStream) {
        val buffer = ByteArray(64 * 1024)
        var total = 0L
        while (true) {
            val read = source.read(buffer)
            if (read < 0) break
            total += read
            if (total > MAX_BYTES) throw IllegalStateException("shared file too large")
            target.write(buffer, 0, read)
        }
    }

    companion object {
        private const val CHANNEL = "com.ruilin.chatreport/share"
        private const val TAG = "ChatReportShare"

        /** 纯文字的聊天导出很少超过几 MB，超过这个大小多半是带了媒体的压缩包 */
        private const val MAX_BYTES = 64L * 1024 * 1024
    }
}
