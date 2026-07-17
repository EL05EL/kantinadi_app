plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.kantinadi_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.kantinadi_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Menyediakan signingConfigs (debug default)
    signingConfigs {
        // Biarkan kosong – konfigurasi debug otomatis tersedia
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")   // gunakan kunci debug
            isMinifyEnabled = false                             // nonaktifkan R8
            isShrinkResources = false                           // jangan buang resource
        }
    }
}

flutter {
    source = "../.."
}