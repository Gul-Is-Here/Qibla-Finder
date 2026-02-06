# Flutter specific ProGuard rules

# Keep Flutter classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Google Play Core (for Flutter deferred components)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
-keep interface com.google.android.play.core.** { *; }

# Keep Google Mobile Ads
-keep class com.google.android.gms.** { *; }
-keep class com.google.ads.** { *; }
-dontwarn com.google.android.gms.**

# ══════════════════════════════════════════════════════════════════════════════
# InMobi SDK ProGuard Rules (as per official documentation)
# ══════════════════════════════════════════════════════════════════════════════
-keepattributes SourceFile,LineNumberTable
-keep class com.inmobi.** { *; }
-keep public class com.google.android.gms.**
-dontwarn com.google.android.gms.**
-dontwarn com.squareup.picasso.**
-keep class com.google.android.gms.ads.identifier.AdvertisingIdClient{
     public *;
}
-keep class com.google.android.gms.ads.identifier.AdvertisingIdClient$Info{
     public *;
}

# skip the Picasso library classes
-keep class com.squareup.picasso.** {*;}
-dontwarn com.squareup.okhttp.**

# skip Moat classes
-keep class com.moat.** {*;}
-dontwarn com.moat.**

# skip IAB classes
-keep class com.iab.** {*;}
-dontwarn com.iab.**

# skip Kotlin property metadata
-keep class kotlin.Metadata { *; }

# ══════════════════════════════════════════════════════════════════════════════
# OkHttp (required by InMobi)
# ══════════════════════════════════════════════════════════════════════════════
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase

# Missing class rules for R8
-dontwarn org.conscrypt.Conscrypt
-dontwarn org.conscrypt.OpenSSLProvider

# ══════════════════════════════════════════════════════════════════════════════
# Picasso (required by InMobi for images)
# ══════════════════════════════════════════════════════════════════════════════
-keep class com.squareup.picasso.** { *; }
-keepclasseswithmembers class * {
    @com.squareup.picasso.* <fields>;
}
-keepclasseswithmembers class * {
    @com.squareup.picasso.* <methods>;
}

# ══════════════════════════════════════════════════════════════════════════════
# IronSource / LevelPlay SDK ProGuard Rules
# ══════════════════════════════════════════════════════════════════════════════
-keepclassmembers class com.ironsource.sdk.controller.IronSourceWebView$JSInterface {
    public *;
}
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}
-keep public class com.google.android.gms.ads.** { public *; }
-keep class com.ironsource.adapters.** { *; }
-dontwarn com.ironsource.mediationsdk.**
-dontwarn com.ironsource.adapters.**
-keepattributes JavascriptInterface
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keep class com.unity3d.mediation.** { *; }
-keep class com.ironsource.** { *; }

# ══════════════════════════════════════════════════════════════════════════════
# Keep native methods
# ══════════════════════════════════════════════════════════════════════════════
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelables
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    !private <fields>;
    !private <methods>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}
