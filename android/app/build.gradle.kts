import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")

    // Plugin do Google Services para Firebase
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.stockone"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // compatível com todos os plugins

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.stockone"
        minSdk = 23 // atualizado para compatibilidade Firebase
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // 🔑 Configuração da keystore
    val keystorePropertiesFile = file("../key.properties")
    val keystoreProperties = Properties()

    if (keystorePropertiesFile.exists()) {
        keystoreProperties.load(FileInputStream(keystorePropertiesFile))
        println("✅ key.properties encontrado e carregado")
    } else {
        println("⚠️ key.properties NÃO encontrado em ${keystorePropertiesFile.absolutePath}")
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                val storePath = keystoreProperties["storeFile"] as String
                val storeFileObj = file(storePath)
                if (storeFileObj.exists()) {
                    storeFile = storeFileObj
                    storePassword = keystoreProperties["storePassword"] as String
                    keyAlias = keystoreProperties["keyAlias"] as String
                    keyPassword = keystoreProperties["keyPassword"] as String
                    println("✅ Keystore encontrada em $storePath")
                } else {
                    println("⚠️ Keystore NÃO encontrada em $storePath")
                }
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
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

dependencies {
    // 🔹 Firebase BoM para alinhar versões compatíveis
    implementation(platform("com.google.firebase:firebase-bom:34.3.0"))

    // 🔹 Firebase Analytics (opcional)
    implementation("com.google.firebase:firebase-analytics")
}
