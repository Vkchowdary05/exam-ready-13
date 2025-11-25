allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Change build directory path
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

// Clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// Add buildscript dependencies
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // ✅ Google Services plugin for Firebase
        classpath("com.google.gms:google-services:4.4.2")
    }
}
