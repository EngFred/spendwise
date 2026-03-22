# ============================================================
# SpendWise — proguard-rules.pro
# Production-ready rules for all packages in use.
# ============================================================


# ── Flutter core ─────────────────────────────────────────────
# Flutter embeds its own engine. Don't touch it.
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.**


# ── Dart / Flutter reflection ─────────────────────────────────
# Dart AOT does not use reflection at runtime, but some Flutter
# platform plugins register themselves via JNI class lookups.
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod


# ── SQLite / Drift ────────────────────────────────────────────
# Drift uses sqlite3_flutter_libs which ships a native .so.
# The Java-side loader must survive shrinking.
-keep class com.almworks.sqlite4java.** { *; }
-keep class org.sqlite.** { *; }
-keep class io.github.nfdz.** { *; }
-dontwarn org.sqlite.**

# sqlite3_flutter_libs native loader
-keep class com.simolus.sqlite3_flutter_libs.** { *; }
-dontwarn com.simolus.sqlite3_flutter_libs.**


# ── WorkManager ───────────────────────────────────────────────
# WorkManager reflects on ListenableWorker subclasses by name.
# Keep everything it needs.
-keep class androidx.work.** { *; }
-keep class androidx.work.impl.** { *; }
-keepclassmembers class * extends androidx.work.ListenableWorker {
    public <init>(android.content.Context, androidx.work.WorkerParameters);
}
-dontwarn androidx.work.**


# ── Flutter WorkManager plugin ────────────────────────────────
-keep class be.tramckrijte.workmanager.** { *; }
-dontwarn be.tramckrijte.workmanager.**


# ── Flutter Local Notifications ───────────────────────────────
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# Notification channels use reflection on NotificationCompat
-keep class androidx.core.app.NotificationCompat** { *; }
-keep class androidx.core.app.NotificationManagerCompat { *; }


# ── Local Auth (biometrics) ───────────────────────────────────
-keep class io.flutter.plugins.localauth.** { *; }
-dontwarn io.flutter.plugins.localauth.**

# BiometricPrompt and related AndroidX classes
-keep class androidx.biometric.** { *; }
-dontwarn androidx.biometric.**


# ── Permission Handler ────────────────────────────────────────
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**


# ── Share Plus ────────────────────────────────────────────────
-keep class dev.fluttercommunity.plus.share.** { *; }
-dontwarn dev.fluttercommunity.plus.share.**

# FileProvider used for sharing files (CSV export)
-keep class androidx.core.content.FileProvider { *; }


# ── Path Provider ─────────────────────────────────────────────
-keep class io.flutter.plugins.pathprovider.** { *; }
-dontwarn io.flutter.plugins.pathprovider.**


# ── Shared Preferences ────────────────────────────────────────
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-dontwarn io.flutter.plugins.sharedpreferences.**


# ── Google Fonts ──────────────────────────────────────────────
# Google Fonts downloads fonts at runtime over HTTP(S) when not
# bundled. The networking classes must survive.
-keep class io.flutter.plugins.googlegooglefonts.** { *; }
-dontwarn io.flutter.plugins.googlegooglefonts.**


# ── Timezone ─────────────────────────────────────────────────
# The timezone package reads timezone data files from assets.
# No Java classes to keep, but suppress any lint warnings.
-dontwarn org.joda.time.**


# ── Kotlin stdlib ─────────────────────────────────────────────
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-keepclassmembers class **$WhenMappings {
    <fields>;
}
-keepclassmembers class kotlin.Lazy {
    <fields>;
}
-dontwarn kotlin.**


# ── Kotlin Coroutines ─────────────────────────────────────────
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}
-dontwarn kotlinx.coroutines.**


# ── AndroidX / Jetpack ────────────────────────────────────────
-keep class androidx.lifecycle.** { *; }
-dontwarn androidx.lifecycle.**
-keep class androidx.core.** { *; }
-dontwarn androidx.core.**


# ── Core library desugaring (coreLibraryDesugaringEnabled) ────
# Required because build.gradle has isCoreLibraryDesugaringEnabled = true
-keep class j$.** { *; }
-keep class j$.time.** { *; }
-dontwarn j$.**


# ── General safety rules ──────────────────────────────────────

# Keep all native method names (JNI)
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enums — R8 can strip enum fields incorrectly
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable implementations (used by Android platform channels)
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Suppress common benign warnings from transitive deps
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**
-dontwarn sun.misc.Unsafe