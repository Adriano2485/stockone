pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // Atualizado para 8.9.1 para compatibilidade com dependências recentes
    id("com.android.application") version "8.9.1" apply false
    id("com.android.library") version "8.9.1" apply false
    // Atualizado para Kotlin 1.9.24
    id("org.jetbrains.kotlin.android") version "1.9.24" apply false
    // Google Services para Firebase
    id("com.google.gms.google-services") version "4.4.3" apply false
}

include(":app")
