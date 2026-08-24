# Flutter's Gradle plugin contributes the core Flutter keep rules automatically.
# Keep Flutter embedding and plugin entry points used via reflection.
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Plugins used by this app (platform channels / reflection safety).
-keep class xyz.luan.audioplayers.** { *; }
-keep class dev.fluttercommunity.plus.sensors.** { *; }
-keep class com.llfbandit.** { *; }
