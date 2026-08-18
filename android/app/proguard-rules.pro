-keep class androidx.lifecycle.DefaultLifecycleObserver
-keepattributes LineNumberTable,SourceFile
-renamesourcefileattribute SourceFile

# Flutter engine / plugin registrant
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep this app's own classes (accessibility service, receivers, models
# passed over platform channels) from being stripped/renamed.
-keep class com.peace.mind.** { *; }

# Gson / JSON model classes used by plugins that (de)serialize over
# platform channels
-keepattributes Signature
-keepattributes *Annotation*
-keep class * extends java.lang.annotation.Annotation { *; }
