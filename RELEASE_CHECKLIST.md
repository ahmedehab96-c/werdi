# Werdi Release Checklist (Android + iOS)

## Build Validation

Run before every store upload:

```bash
cd werdi
flutter clean && flutter pub get
flutter analyze
flutter test
flutter build appbundle --release
flutter build apk --release   # optional QA sideload
```

Expected Android outputs:

- AAB: `build/app/outputs/bundle/release/app-release.aab`
- APK: `build/app/outputs/flutter-apk/app-release.apk`

## Completed in Codebase

- App icons from `assets/images/logo.png`
- Package `com.werdi.app`, version `1.0.1+11`
- Release minify + shrink resources
- Privacy policy: `PRIVACY.md` (public GitHub URL in app settings)
- Play listing copy: `docs/PLAY_STORE_LISTING.md`
- Play Console steps: `docs/PLAY_CONSOLE_CHECKLIST.md`
- **All-in-one remote release pack:** `docs/REMOTE_RELEASE.md` (نصوص المتجر + Data safety + Supabase + أوامر البناء)

## Permissions (current)

Declared and intentional:

- `INTERNET` — audio, tafsir, optional sync
- `RECORD_AUDIO` — optional Tasmee3 only
- `POST_NOTIFICATIONS` — optional reminders
- `FOREGROUND_SERVICE` / `MEDIA_PLAYBACK` — background audio
- `WAKE_LOCK`, `RECEIVE_BOOT_COMPLETED` — notifications / audio reliability

Not used: broad storage write, exact alarm (unless re-added later).

## Android Play Store

1. Keep upload keystore safe; never commit `*.jks` or `key.properties`.
2. Example `android/key.properties` (from `key.properties.example`):

```properties
storeFile=/absolute/path/to/your-upload-keystore.jks
storePassword=YOUR_STORE_PASSWORD
keyAlias=YOUR_KEY_ALIAS
keyPassword=YOUR_KEY_PASSWORD
```

3. Build signed AAB (must use release keystore, not debug).
4. Upload to **Internal testing** first.
5. Complete listing, Data safety, content rating — follow `docs/PLAY_CONSOLE_CHECKLIST.md`.

### Optional Supabase build

```bash
flutter build appbundle --release \
  --dart-define=SUPABASE_URL=https://YOUR.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

If you ship with Supabase, Data safety must declare account data. Local-only builds omit that.

## iOS App Store / TestFlight

- Bundle ID: `com.werdi.app`
- Privacy: align with `PRIVACY.md`
- Screenshots + App Privacy questionnaire in App Store Connect
- `flutter build ipa --release` (with signing) or archive from Xcode

## Pre-Release QA Gate

- Quran browse / search / tafsir / audio (foreground + background)
- Memorization / smart review / tasmee3 (mic allow + deny)
- Offline recitation + offline tafsir download/cancel
- Notifications, theme, language (AR/EN), RTL/LTR
- Cold start + resume
- Auth only if that build includes Supabase

## Notes

- Prefer Internal testing → Closed → Production with staged rollout.
- Privacy policy last updated: **July 12, 2026**.
