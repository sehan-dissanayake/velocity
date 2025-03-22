pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    // Include Flutter's Gradle plugin from the SDK
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }

    plugins {
        id("com.android.application") version "8.7.0"
        id("com.android.library") version "8.7.0"
        id("org.jetbrains.kotlin.android") version "1.9.0"
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader")
}

dependencyResolutionManagement {
    // Change to PREFER_PROJECT_REPOS to allow flexibility if needed
    

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

include(":app")