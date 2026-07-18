# Google Play Console — Werdi readiness checklist

Use this while creating the app in Play Console. Check items as you complete them.

Package: `com.werdi.app` · Version: `1.0.1+11`

---

## A. Before first upload

- [ ] Google Play Developer account active ($25 one-time)
- [ ] Upload keystore exists and is backed up offline (never commit `.jks`)
- [ ] `android/key.properties` points to a real `storeFile` path
- [ ] Confirm release is **not** signed with debug key:
  ```bash
  cd werdi
  flutter clean && flutter pub get
  flutter analyze
  flutter test
  flutter build appbundle --release
  ```
- [ ] Output: `build/app/outputs/bundle/release/app-release.aab`
- [ ] Privacy policy public: https://github.com/ahmedehab96-c/werdi/blob/main/PRIVACY.md

---

## B. App creation & signing

- [ ] Create app: name **وردي**, type App, free
- [ ] App signing by Google Play (recommended) — upload your upload key once
- [ ] Upload AAB to **Internal testing** first (not Production)

---

## C. Store listing

Copy text from `docs/PLAY_STORE_LISTING.md`.

- [ ] App name
- [ ] Short description (AR + EN)
- [ ] Full description (AR + EN)
- [ ] App icon 512×512
- [ ] Feature graphic 1024×500
- [ ] Phone screenshots (≥2)
- [ ] Privacy policy URL
- [ ] Support email or GitHub issues URL

---

## D. Data safety (fill exactly)

### Data collected

| Data type | Collected? | Notes |
|-----------|------------|--------|
| App activity / progress | Yes (on device) | Memorization, review, goals |
| Audio files | Yes (on device) | Offline recitations you download |
| User credentials | Optional | Email/password only if Supabase sign-in is enabled |
| Approximate location | No | |
| Contacts / photos | No | |

### Permissions / sensitive access

| Permission | Why |
|------------|-----|
| Microphone | Optional Tasmee3 voice self-test only |
| Notifications | Optional daily reminders |
| Internet | Audio, tafsir, optional sync |
| Foreground service (media) | Background Quran playback |

### Answers for common Play questions

- **Is data encrypted in transit?** Yes (HTTPS) for network features.
- **Can users request deletion?** Yes — uninstall clears local data; for optional accounts open a GitHub issue / delete account via auth if configured.
- **Data sold?** No.
- **Data shared for advertising?** No.
- **Required for app?** Core features work offline/local; mic and account are optional.

Update Data safety if you ship a build **with** `SUPABASE_URL` / `SUPABASE_ANON_KEY` (declare account data). If you ship **without** those flags, say accounts are not collected.

---

## E. Content rating & audience

- [ ] Complete IARC questionnaire (Education / Religious reference content)
- [ ] Target age: generally **13+** (or All ages if questionnaire allows; avoid “Designed for children” unless you intend Kids policy)
- [ ] Not a news / gambling / dating app

---

## F. App content declarations

- [ ] Ads: **No** (unless you add AdMob later)
- [ ] In-app purchases: **No** (unless you add billing later)
- [ ] News app: No
- [ ] COVID / medical claims: No
- [ ] Government apps: No
- [ ] Data safety form submitted
- [ ] Target API level meets Play requirement (Flutter default `targetSdk`)

---

## G. Pre-release QA (device)

- [ ] Cold start → home loads
- [ ] Quran browse + search + bookmark
- [ ] Audio play / background / lock screen
- [ ] Memorization + mark difficult
- [ ] Smart review session
- [ ] Tasmee3 with mic allow + deny paths
- [ ] Offline recitation download
- [ ] Offline tafsir download + cancel
- [ ] Notifications opt-in
- [ ] Arabic / English switch
- [ ] Light / dark theme
- [ ] Optional auth (only if Supabase enabled in that build)

---

## H. Release tracks

1. [ ] Internal testing → invite yourself → install from Play
2. [ ] Closed testing (optional, small group)
3. [ ] Open testing (optional)
4. [ ] Production → staggered rollout 20% → 100%

---

## Build commands (release)

```bash
cd werdi
flutter clean
flutter pub get
flutter analyze
flutter test
# Local-only build (no Supabase):
flutter build appbundle --release
# With optional sync:
# flutter build appbundle --release \
#   --dart-define=SUPABASE_URL=https://YOUR.supabase.co \
#   --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

---

## Blockers to fix before Production

1. Real upload keystore + verified signed AAB  
2. Screenshots + feature graphic uploaded  
3. Data safety matches the **exact** build you upload (with or without Supabase)  
4. Privacy policy reflects optional account sync (already updated July 12, 2026)  
