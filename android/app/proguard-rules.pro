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
