plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // O Flutter Gradle Plugin deve ser aplicado após os plugins do Android e Kotlin.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.celiapp"
    compileSdk = 35 // Versão mais recente recomendada
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.celiapp"
        minSdk = 23 // Firebase exige pelo menos 23
        targetSdk = 35 // Sempre use a versão mais recente suportada
        versionCode = 1 // Número de versão do app
        versionName = "1.0.0" // Nome da versão do app
    }

    buildTypes {
        release {
            // Usa as configurações padrão de otimização do Android
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")

            // Assina com a chave de debug por enquanto, para rodar o app em modo release
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

