#!/usr/bin/env bash
set -euo pipefail

echo "==> Android release pipeline (Werdi)"

if [[ ! -f "android/key.properties" ]]; then
  echo "ERROR: android/key.properties not found."
  echo "Copy android/key.properties.example to android/key.properties and fill it."
  exit 1
fi

echo "==> flutter clean"
flutter clean

echo "==> flutter pub get"
flutter pub get

echo "==> flutter analyze"
flutter analyze

echo "==> flutter test"
flutter test

echo "==> Building Play Store AAB"
flutter build appbundle --release

echo "==> Building QA APK"
flutter build apk --release

echo "Done."
echo "AAB: build/app/outputs/bundle/release/app-release.aab"
echo "APK: build/app/outputs/flutter-apk/app-release.apk"
