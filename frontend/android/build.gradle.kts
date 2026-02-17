import com.android.build.gradle.BaseExtension
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

subprojects {
    afterEvaluate {
        // 1. Configure Android-specific settings
        val android = extensions.findByName("android") as? com.android.build.gradle.BaseExtension
        android?.apply {
            compileSdkVersion(36)
            buildToolsVersion("36.0.0")

            if (namespace == null) {
                namespace = project.group.toString().ifEmpty { "com.example.${project.name}" }
            }

            defaultConfig {
                targetSdk = 36
            }

            // Fixes the "source value 8 is obsolete" warning
            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
        }

        // 2. Configure Kotlin-specific settings for all subprojects
        tasks.withType<KotlinCompile>().configureEach {
            kotlinOptions {
                jvmTarget = "17"
            }
        }
    }
}