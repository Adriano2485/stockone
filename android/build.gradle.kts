// build.gradle.kts (nível do projeto)

import org.gradle.api.tasks.Delete
import org.gradle.api.file.Directory

buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // Android Gradle Plugin
        classpath("com.android.tools.build:gradle:8.7.3")

        // Google Services
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
val newBuildDir: Directory =
    rootProject.layout.buildDirectory.dir("../../build").get()

rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {

    val newSubprojectBuildDir: Directory =
        newBuildDir.dir(project.name)

    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // Garante que os subprojetos sejam avaliados corretamente
    project.evaluationDependsOn(":app")
}

// Limpar build
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
