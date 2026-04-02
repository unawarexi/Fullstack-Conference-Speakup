# Keep rules for SpeakUp Conference App

# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# LiveKit / WebRTC
-keep class org.webrtc.** { *; }
-keep class livekit.** { *; }

# Hive
-keep class ** extends com.google.protobuf.GeneratedMessageLite { *; }

# Keep annotations
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes Signature
-keepattributes Exceptions

# Gson / JSON
-keepattributes EnclosingMethod
-keep class com.google.gson.** { *; }
