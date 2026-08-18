#!/usr/bin/env bash
set -e
echo "Applying APK size reduction changes..."
mkdir -p "android/app"
cat > "android/app/build.gradle" << 'HOSTS_EOF'
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}

def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
if (flutterVersionCode == null) {
    flutterVersionCode = '1'
}

def flutterVersionName = localProperties.getProperty('flutter.versionName')
if (flutterVersionName == null) {
    flutterVersionName = '1.0'
}

android {

    namespace "com.peace.mind"
    compileSdkVersion flutter.compileSdkVersion
    ndkVersion '27.0.12077973'

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        // You can update the following values to match your application needs.
        // For more information, see: https://docs.flutter.dev/deployment/android#reviewing-the-gradle-build-configuration.
        applicationId "com.peace.mind"
        minSdkVersion defaultMinSdkVersion
        targetSdkVersion flutter.targetSdkVersion
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }


    signingConfigs {
        release {
            if (System.getenv("KEYSTORE_FILE") != null) {
                storeFile file(System.getenv("KEYSTORE_FILE"))
                storePassword System.getenv("STORE_PASSWORD")
                keyAlias System.getenv("KEY_ALIAS")
                keyPassword System.getenv("KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            /// 'full' debug symbol level bundles unstripped native debug
            /// info and significantly bloats APK size; not needed for a
            /// typical release build.
            ndk {
                debugSymbolLevel 'none'
            }
            resValue "string", "app_name", "Mindful"
            signingConfig signingConfigs.release

            /// Shrinks + obfuscates Kotlin/Java code and strips unused
            /// resources, cutting APK size significantly.
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'

            // If you see "SigningConfig 'release' is missing required property 'storeFile'",  
            // it means your release keystore is not set up due to missing environment variables.  
            // To fix this locally, either:  
            // 1. Use `signingConfig signingConfigs.debug` (but DO NOT commit this change).  
            // 2. Set the following environment variables to keep signing secure:  
            //    - KEYSTORE_FILE  
            //    - STORE_PASSWORD  
            //    - KEY_ALIAS  
            //    - KEY_PASSWORD  
            // Avoid pushing any local changes to this Gradle file, as it may break CI/CD.  
        }

        debug {
            applicationIdSuffix ".debug"
            resValue "string", "app_name", "Mindful Debug"
            signingConfig System.getenv("KEYSTORE_FILE") != null ? signingConfigs.release : signingConfigs.debug
        }

        profile {
            // app_links library is causing error so commenting it out
            // applicationIdSuffix ".profile"
            resValue "string", "app_name", "Mindful Profile"
            signingConfig System.getenv("KEYSTORE_FILE") != null ? signingConfigs.release : signingConfigs.debug
        }
    }
    buildFeatures {
        viewBinding true
    }
}

flutter {
    source '../..'
}

dependencies {
    implementation 'androidx.work:work-runtime:2.10.1'
    implementation 'androidx.appcompat:appcompat:1.7.1'
}

HOSTS_EOF
echo "  wrote android/app/build.gradle"
mkdir -p "android/app"
cat > "android/app/proguard-rules.pro" << 'HOSTS_EOF'
-keep class androidx.lifecycle.DefaultLifecycleObserver
-keepattributes LineNumberTable,SourceFile
-renamesourcefileattribute SourceFile

# Flutter engine / plugin registrant
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep this app's own classes (accessibility service, receivers, models
# passed over platform channels) from being stripped/renamed.
-keep class com.peace.mind.** { *; }

# Gson / JSON model classes used by plugins that (de)serialize over
# platform channels
-keepattributes Signature
-keepattributes *Annotation*
-keep class * extends java.lang.annotation.Annotation { *; }HOSTS_EOF
echo "  wrote android/app/proguard-rules.pro"
mkdir -p ".github/workflows"
cat > ".github/workflows/build-apk.yml" << 'HOSTS_EOF'
name: Build APK

on:
  workflow_dispatch:
  push:
    branches: [ main ]

permissions:
  contents: write

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Java
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
          cache: true

      - name: Decode keystore
        run: echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/app/release-key.jks

      - name: Install dependencies
        run: flutter pub get

      - name: Build split-per-ABI release APKs
        env:
          KEYSTORE_FILE: release-key.jks
          STORE_PASSWORD: ${{ secrets.STORE_PASSWORD }}
          KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
          KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
        run: flutter build apk --release --split-per-abi

      - name: Upload APK artifacts
        uses: actions/upload-artifact@v4
        with:
          name: mindful-release-apks
          path: build/app/outputs/flutter-apk/*.apk
          retention-days: 30

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          tag_name: build-${{ github.run_number }}
          name: Build ${{ github.run_number }}
          files: build/app/outputs/flutter-apk/*.apk
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
HOSTS_EOF
echo "  wrote .github/workflows/build-apk.yml"
echo ""
echo "Done. Git status:"
git status --short
