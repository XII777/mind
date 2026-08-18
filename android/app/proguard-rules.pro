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

# Flutter's deferred-components support references Play Core classes
# that aren't used by this app (no dynamic feature delivery). Safe to
# ignore rather than bundle the whole Play Core library.
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.**
