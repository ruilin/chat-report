# Flutter 引擎与插件的反射入口，混淆时保留
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# share_plus / file_selector / url_launcher 通过 Android 框架反射调用
-keep class androidx.core.content.FileProvider { *; }
-keep class androidx.lifecycle.DefaultLifecycleObserver
