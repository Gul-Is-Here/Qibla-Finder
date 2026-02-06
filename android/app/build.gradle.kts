import java.util.Properties
import java.io.FileInputStream
plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
android {
    namespace = "com.qibla_compass_offline.app"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.qibla_compass_offline.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // InMobi requires multidex for API < 21
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            // Enable ProGuard/R8 with custom rules
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

// InMobi SDK and ALL Required Dependencies (as per InMobi Documentation)
dependencies {
    // InMobi SDK - Latest Kotlin version
    implementation("com.inmobi.monetization:inmobi-ads-kotlin:11.1.1")
    
    // ExoPlayer - Required for video ads
    implementation("androidx.media3:media3-exoplayer:1.4.1")
    
    // OkHttp - Required for HTTP/2 network communication
    implementation("com.squareup.okhttp3:okhttp:3.14.9")
    implementation("com.squareup.okio:okio:3.7.0")
    
    // Kotlin Coroutines - Required for async operations
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.10.1")
    
    // Kotlin Dependencies - Required for Native Ads module
    implementation("androidx.core:core-ktx:1.5.0")
    implementation("org.jetbrains.kotlin:kotlin-stdlib:2.1.21")
    
    // Google Play Services - Required for ad targeting
    implementation("com.google.android.gms:play-services-ads-identifier:18.0.1")
    implementation("com.google.android.gms:play-services-location:21.0.1")
    implementation("com.google.android.gms:play-services-basement:18.3.0")
    
    // Chrome Custom Tab - CRITICAL: Required for URL redirects (ads will fail without this!)
    implementation("androidx.browser:browser:1.8.0")
    
    // Picasso - CRITICAL: Required for loading ad assets (interstitial will fail without this!)
    implementation("com.squareup.picasso:picasso:2.8")
    
    // AppSet ID - For better targeting
    implementation("com.google.android.gms:play-services-appset:16.0.2")
    implementation("com.google.android.gms:play-services-tasks:18.0.2")
    
    // Multidex support
    implementation("androidx.multidex:multidex:2.0.1")
    
    // RecyclerView (for native ads)
    implementation("androidx.recyclerview:recyclerview:1.3.2")
}

flutter {
    source = "../.."
}
