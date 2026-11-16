import java.io.FileInputStream
import java.io.InputStreamReader
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Datos de la clave de firma para Google Play. Están en android/key.properties,
// que NO se sube al repositorio (ver android/key.properties.example).
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hayClaveDeSubida = keystorePropertiesFile.exists()
if (hayClaveDeSubida) {
    keystoreProperties.load(InputStreamReader(FileInputStream(keystorePropertiesFile), Charsets.UTF_8))
}

android {
    namespace = "work.alcancia.peliculeitor"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "work.alcancia.peliculeitor"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (hayClaveDeSubida) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Con key.properties se firma con tu clave de subida (lo que pide Google Play).
            // Sin él, se usa la clave de depuración para poder probar con
            // `flutter run --release`, pero ese resultado NO sirve para Google Play.
            signingConfig = if (hayClaveDeSubida) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

// Al generar el App Bundle para Google Play (flutter build appbundle), si no
// está key.properties la compilación se para con un aviso, en vez de firmar
// con la clave de depuración sin decir nada.
tasks.matching { it.name == "bundleRelease" }.configureEach {
    val faltaClave = !hayClaveDeSubida
    val ruta = keystorePropertiesFile.absolutePath
    doFirst {
        if (faltaClave) {
            throw GradleException(
                "No se encuentra $ruta. Créalo a partir de " +
                    "android/key.properties.example para firmar con tu clave de subida."
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
