# Werdi Release Checklist (Android + iOS)

This project now builds successfully for release on both platforms.

## Build Validation Status

- `flutter analyze`: PASS
- `flutter test`: PASS
- Android release bundle: `build/app/outputs/bundle/release/app-release.aab`
- Android release apk (for QA): `build/app/outputs/flutter-apk/app-release.apk`
- iOS release archive (unsigned): `build/ios/archive/Runner.xcarchive`

## Completed in Codebase

- App icons generated for Android and iOS from `assets/images/logo.png`.
- iOS launch image assets populated to pass asset validation.
- Sensitive Android permissions removed:
  - `android.permission.RECORD_AUDIO`
  - `android.permission.WRITE_EXTERNAL_STORAGE`
  - `android.permission.SCHEDULE_EXACT_ALARM`
- Default tafsir source now prefers Egyptian source labels.

## Manual Steps Before Store Submission

## 1) Android Play Store

- Create upload keystore (one-time) and keep it safe.
- Create `android/key.properties` (do not commit):

```properties
storeFile=/absolute/path/to/your-upload-keystore.jks
storePassword=YOUR_STORE_PASSWORD
keyAlias=YOUR_KEY_ALIAS
keyPassword=YOUR_KEY_PASSWORD
```

- Build signed AAB:
  - `flutter build appbundle --release`
- Upload `app-release.aab` to Play Console internal testing first.
- Fill Play Console metadata:
  - App description
  - Screenshots (phone/tablet)
  - Privacy Policy URL
  - Data safety form
  - Content rating
  - Target audience

## 2) iOS App Store / TestFlight

- Open `ios/Runner.xcworkspace` in Xcode.
- In Signing & Capabilities:
  - Select your Apple Team
  - Confirm Bundle ID: `com.werdi.app` (or your production ID)
  - Enable Automatic Signing
- Build/archive from Xcode and upload to App Store Connect, or use:
  - `flutter build ipa --release` (with signing configured)
- In App Store Connect, complete:
  - App Privacy section
  - Screenshots (iPhone + iPad if supported)
  - App description, keywords, support URL, marketing URL
  - Age rating

## 3) Pre-Release QA Gate (Recommended)

- Smoke test login/register/guest flow.
- Quran browsing/search/tafsir/audio.
- Memorization/review/tasmee3 sessions.
- Notifications scheduling and delivery.
- Theme and language switching.
- RTL/LTR layout checks.
- Cold start + resume behavior.

## Store-Ready Command Set

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build appbundle --release
flutter build apk --release
flutter build ipa --release --no-codesign
```

## Notes

- iOS release without code signing is already verified in this repository.
- Final App Store upload requires valid Apple certificates/profiles and App Store Connect setup.
- Final Play Store upload requires your upload keystore and Play Console release track setup.
