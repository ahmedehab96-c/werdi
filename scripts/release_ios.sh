#!/usr/bin/env bash
set -euo pipefail

echo "==> iOS release pipeline (Werdi)"
echo "Note: requires Apple signing configured in Xcode (Team + certs + profiles)."

echo "==> flutter clean"
flutter clean

echo "==> flutter pub get"
flutter pub get

echo "==> flutter analyze"
flutter analyze

echo "==> flutter test"
flutter test

echo "==> Building iOS archive (signed IPA)"
flutter build ipa --release

echo "Done."
echo "Archive / IPA output under build/ios/"
