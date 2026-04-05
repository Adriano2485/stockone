import java.util.Properties
import java.io.FileInputStream

plugins {
id("com.android.application") 
id("kotlin-android")
id("dev.flutter.flutter-gradle-plugin")
id("com.google.gms.google-services")
}

android {
namespace = "com.dusso40.stockone"
compileSdk = 36
ndkVersion = "27.0.12077973"

buildFeatures {
buildConfig = true // necessário para Firebase
}

compileOptions {
sourceCompatibility = JavaVersion.VERSION_11
targetCompatibility = JavaVersion.VERSION_11
}

kotlinOptions {
jvmTarget = JavaVersion.VERSION_11.toString()
}

defaultConfig {
applicationId = "com.dusso40.stockone"
minSdk = 23
targetSdk = 36
versionCode = 35 // se quiser, pode usar flutter.versionCode
versionName = "2.0.3" // se quiser, pode usar flutter.versionName
}

// Configuração da keystore
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
