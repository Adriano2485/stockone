// build.gradle.kts (nível do projeto)

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Define a versão do Android Gradle Plugin (AGP) aqui, evitando conflito
        classpath("com.android.tools.build:gradle:8.9.1")
        classpath("com.google.gms:google-services:4.4.3")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Redireciona o build para fora do diretório do projeto
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    // Garante que os subprojetos (como :app) sejam avaliados corretamente
    project.evaluationDependsOn(":app")
}

// Tarefa para limpar o build
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
