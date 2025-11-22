import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.stockone"
    compileSdk = 34  // SDK estável e menos suscetível a erros

    defaultConfig {
        applicationId = "com.example.stockone"
        minSdk = 23
        targetSdk = 34
        versionCode = 4
        versionName = "2.0.0"
    }

    buildFeatures {
        buildConfig = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // 🔑 Configuração da keystore
    val keystorePropertiesFile = file("../key.properties")
    val keystoreProperties = Properties()
    if (keystorePropertiesFile.exists()) {
        keystoreProperties.load(FileInputStream(keystorePropertiesFile))
        println("✅ key.properties encontrado e carregado")
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                val storeFileObj = file(keystoreProperties["storeFile"] as String)
                if (storeFileObj.exists()) {
                    storeFile = storeFileObj
                    storePassword = keystoreProperties["storePassword"] as String
                    keyAlias = keystoreProperties["keyAlias"] as String
                    keyPassword = keystoreProperties["keyPassword"] as String
                    println("✅ Keystore encontrada em ${storeFileObj.absolutePath}")
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
    implementation(platform("com.google.firebase:firebase-bom:34.3.0")) // Firebase BOM
    implementation("com.google.firebase:firebase-analytics")            // Firebase Analytics
    implementation("com.google.firebase:firebase-core")                 // Core Firebase
}
