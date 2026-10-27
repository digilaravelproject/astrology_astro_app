# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# Foreground Task
-keep class com.pravera.flutter_foreground_task.** { *; }
-dontwarn com.pravera.flutter_foreground_task.**

# Overlay Window
-keep class flutter.overlay.window.flutter_overlay_window.** { *; }
-dontwarn flutter.overlay.window.flutter_overlay_window.**

# WebRTC
-keep class org.webrtc.** { *; }
-dontwarn org.webrtc.**

# Generic keeping of models if needed
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses

# ─── cached_network_image & flutter_cache_manager ───────────────────────────
# These are required in release mode; R8 strips native Java components
# causing CachedNetworkImage to silently fail (gray placeholder).
-keep class com.baseflow.cachemanager.** { *; }
-dontwarn com.baseflow.cachemanager.**

# SQLite / sqflite (used internally by flutter_cache_manager for disk cache)
-keep class io.flutter.plugins.sqflite.** { *; }
-dontwarn io.flutter.plugins.sqflite.**
-keep class org.sqlite.** { *; }
-dontwarn org.sqlite.**
-keep class org.sqlite.database.** { *; }
-dontwarn org.sqlite.database.**

# OkHttp (used by flutter_cache_manager for network downloads)
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okio.** { *; }

# Glide (image loading backend sometimes used by cached_network_image)
-keep public class * implements com.bumptech.glide.module.GlideModule
-keep class * extends com.bumptech.glide.module.AppGlideModule { <init>(...); }
-keep public enum com.bumptech.glide.load.ImageHeaderParser$** {
  **[] $VALUES;
  public *;
}
-dontwarn com.bumptech.glide.**

# Dio & http (used by the app for API calls; keep to prevent response parsing issues)
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enums (required for correct JSON parsing in release)
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable implementations
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
}

