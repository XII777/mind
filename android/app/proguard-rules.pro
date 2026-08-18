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
