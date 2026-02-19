plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.sendmeoutlet.today.sendme_outlet"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.sendmeoutlet.today.sendme_outlet"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "app"
    productFlavors {
        create("sendme") {
            dimension = "app"
            applicationId = "today.sendme.outlet"
            versionCode = 1
            versionName = "1.0.0"
            resValue("string", "app_name", "SendMe Outlet")
            resValue("string", "google_services_file", "sendme/google-services.json")
        }
        create("sendme6") {
            dimension = "app"
            applicationId = "today.sendme6app.outlet"
            versionCode = 1
            versionName = "1.0.0"
            resValue("string", "app_name", "SendMe6 Outlet")
        }
        create("eatoz") {
            dimension = "app"
            applicationId = "com.eatozfood_outlet"
            versionCode = 1
            versionName = "1.0.0"
            resValue("string", "app_name", "Eatoz Outlet")
        }
        create("sendmelebanon") {
            dimension = "app"
            applicationId = "today.sendmelebanondev.outlet"
            versionCode = 1
            versionName = "1.0.0"
            resValue("string", "app_name", "SendMe Horeca Outlet")
        }
        create("sendmetalabetak") {
            dimension = "app"
            applicationId = "today.talabetak.outlet"
            versionCode = 1
            versionName = "1.0.0"
            resValue("string", "app_name", "SendMeTalabetak Outlet")
        }
        create("sendmeshrirampur") {
            dimension = "app"
            applicationId = "today.sendmeshrirampur.outlet"
            versionCode = 1
            versionName = "1.0.0"
            resValue("string", "app_name", "SendMe Shrirampur Outlet")
        }
        create("tyeb") {
            dimension = "app"
            applicationId = "today.tyeb.outlet"
            versionCode = 1
            versionName = "1.0.0"
            resValue("string", "app_name", "Tyeb Outlet")
        }
        create("hopshop") {
            dimension = "app"
            applicationId = "today.hopshop.outlet"
            versionCode = 1
            versionName = "1.0.0"
            resValue("string", "app_name", "Hopshop Outlet")
        }
        create("sendmetest") {
            dimension = "app"
            applicationId = "today.sendmetest.outlet"
            versionCode = 1
            versionName = "1.0.0"
            resValue("string", "app_name", "SendMe Test Outlet")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:1.2.2")
}
