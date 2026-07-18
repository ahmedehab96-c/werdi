# Privacy Policy — Werdi (وردي)

**Last updated:** July 12, 2026  
**Package:** `com.werdi.app`  
**Public URL:** https://github.com/ahmedehab96-c/werdi/blob/main/PRIVACY.md

Werdi is a Quran memorization, revision, and Mushaf reading app. You can use the core features **without creating an account**. Optional sign-in is available only when cloud sync is configured by the developer.

---

## 1. Data stored on your device

The following are stored locally on your phone (SQLite / app preferences):

- Memorization progress and daily goals
- Review items and smart review plans
- Bookmarks and last-read position
- Reading preferences (font size, theme, language)
- Offline downloaded recitations and cached tafsir (when you choose to download them)
- Reminder / notification preferences
- Achievement progress

Uninstalling the app removes this local data.

---

## 2. Microphone (Tasmee3)

- Werdi requests **microphone permission** only for the optional **Tasmee3** (voice self-test) feature.
- Speech recognition runs to compare your recitation with the ayah text.
- We do **not** upload your voice recordings to Werdi servers for storage or advertising.
- You can deny or revoke microphone permission in system settings; other features continue to work.

---

## 3. Notifications

- Werdi may request **notification permission** for optional daily reminders.
- Reminders are scheduled on-device.
- You can disable them in the app settings or system settings.

---

## 4. Optional account & cloud sync (Supabase)

If the release is built with Supabase credentials:

- You may optionally register / sign in with **email and password**.
- We may sync: bookmarks, review items, and progress summaries associated with your account.
- Auth tokens are stored securely on the device (`flutter_secure_storage`).
- If cloud sync is **not** configured, the app stays fully local and no account data is sent.

You can use Werdi without signing in.

---

## 5. Network requests (third parties)

Depending on features you use, the app may contact:

| Service | Purpose |
|---------|---------|
| MP3Quran / everyayah CDN | Stream or download Quran audio |
| AlQuran Cloud API | Tafsir / edition metadata |
| Google Fonts | App typography |
| Supabase (optional) | Auth and progress sync when enabled |

These services receive only what is needed for the request (for example: which ayah audio URL to fetch). We do not sell personal data.

---

## 6. Data we do not sell

- We do not sell your personal data.
- We do not use your Quran progress for advertising profiles.
- We do not store voice audio on Werdi-operated servers.

---

## 7. Children’s privacy

Werdi is a general education / religious learning app. It is not directed at children under 13. If you believe a child has provided account data through optional sign-in, contact us to request deletion.

---

## 8. Your choices

- Use the app without an account (local mode).
- Deny microphone or notification permissions.
- Sign out (when signed in) and stop cloud sync.
- Clear app data or uninstall to remove local storage.
- Open a GitHub issue for privacy requests: https://github.com/ahmedehab96-c/werdi/issues

---

## 9. Changes

We may update this policy when features change. The “Last updated” date at the top will be revised. Continued use after an update means you accept the revised policy.

---

## 10. Contact

Privacy questions: open an issue on  
https://github.com/ahmedehab96-c/werdi/issues  
or contact the developer via the Google Play listing.
