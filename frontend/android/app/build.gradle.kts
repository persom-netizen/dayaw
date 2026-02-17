plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.dayaw_frontend"
    compileSdk = flutter.compileSdkVersion
    
    // REPLACE the flutter.ndkVersion line with the one below:
    ndkVersion = "27.0.12077973" 

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
    applicationId = "com.example.dayaw_frontend"
    
    // Replace 'flutter.minSdkVersion' with 26
    minSdk = 26 
    
    targetSdk = flutter.targetSdkVersion
    versionCode = flutter.versionCode
    versionName = flutter.versionName
}

    buildTypes {
        release {
            // ⚡ for now use debug keys so release runs without keystore setup
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false       // disable shrinking for faster build
            isShrinkResources = false
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
