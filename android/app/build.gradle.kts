plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.engineerfred.spendwise"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.engineerfred.spendwise"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Debug keystore is intentional — this build is for direct
            // distribution, not the Play Store. If you later publish to
            // the Play Store, replace with a proper release signing config.
            signingConfig = signingConfigs.getByName("debug")

            // Enable R8 full-mode minification and resource shrinking.
            // ProGuard rules are in proguard-rules.pro.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            // Keep debug builds fast — no minification.
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    // // ── ABI splits ───────────────────────────────────────────
    // //
    // // Produces three separate APKs instead of one fat APK:
    // //   app-arm64-v8a-release.apk   ← all modern Android phones (2017+)
    // //   app-armeabi-v7a-release.apk ← older 32-bit devices
    // //   app-x86_64-release.apk      ← emulators
    // //
    // // For direct distribution to real devices, share the arm64-v8a APK.
    // // It covers virtually every phone made in the last 7+ years.
    // splits {
    //     abi {
    //         isEnable = true
    //         reset()
    //         include("arm64-v8a", "armeabi-v7a", "x86_64")
    //         isUniversalApk = false
    //     }
    // }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}