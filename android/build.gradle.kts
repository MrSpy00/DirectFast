buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.1.4")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.2.20")
    }
}

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

// ============================================================
// CONSOLIDATED SUBPROJECTS CONFIGURATION
// Includes: build directory setup, namespace injection, and evaluation
// ============================================================
subprojects {
    // 1. Set custom build directory for each subproject
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // 2. POWER FIX: Auto-inject namespace for legacy Android library plugins
    // This runs during configuration, BEFORE evaluation
    // Fixes "Namespace not specified" error for AGP 8.0+
    plugins.withId("com.android.library") {
        extensions.configure<com.android.build.gradle.LibraryExtension> {
            // If namespace is not set, generate one intelligently
            if (namespace == null) {
                val fallbackNamespace = when {
                    // Try to use the project group if it's meaningful
                    project.group.toString().isNotEmpty() &&
                    project.group.toString() != "unspecified" &&
                    project.group.toString() != "null" -> {
                        project.group.toString()
                    }
                    // Specific known plugins with proper namespaces
                    project.name.contains("gal") -> "dev.fluttercommunity.plus.gal"
                    project.name.contains("image_gallery_saver") -> "io.flutter.plugins.imagegallerysaver"
                    project.name.contains("share_plus") -> "dev.fluttercommunity.plus.share"
                    project.name.contains("url_launcher") -> "io.flutter.plugins.urllauncher"
                    project.name.contains("clipboard") -> "com.example.clipboard"
                    project.name.contains("country_code_picker") -> "com.example.countrycodepicker"
                    // Generic fallback based on sanitized project name
                    else -> "io.flutter.plugins.${project.name.replace("-", "").replace("_", "").lowercase()}"
                }

                namespace = fallbackNamespace
                logger.lifecycle("⚡ Auto-injected namespace for '${project.name}': $fallbackNamespace")
            }
        }
    }

    // 3. Ensure app module is evaluated for all subprojects
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
