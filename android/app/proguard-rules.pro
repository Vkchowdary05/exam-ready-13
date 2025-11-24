# ---------- ML KIT ----------
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# Specific language models
-keep class com.google.mlkit.vision.text.chinese.** { *; }
-keep class com.google.mlkit.vision.text.japanese.** { *; }
-keep class com.google.mlkit.vision.text.korean.** { *; }
-keep class com.google.mlkit.vision.text.devanagari.** { *; }

# ---------- FLUTTER ----------
-keep class io.flutter.plugin.** { *; }

# ---------- FIREBASE ----------
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Kotlin Metadata
-keepclassmembers class kotlin.Metadata { *; }
