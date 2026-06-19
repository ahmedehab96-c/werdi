# Supabase Setup for Werdi

This project no longer uses the Laravel backend. All cloud data (auth, bookmarks, progress, achievements) is stored in Supabase.

## 1) Create a Supabase project

1. Go to [https://supabase.com](https://supabase.com)
2. Create a new project
3. Copy:
   - Project URL
   - `anon` public API key

## 2) Run database schema

Open **SQL Editor** in Supabase and run:

`docs/supabase_schema.sql`

This creates:
- `profiles`
- `user_progress`
- `bookmarks`
- `achievements`
- Row Level Security (RLS) policies
- Auto profile/progress creation on signup

## 3) Configure Flutter app

Run the app with dart defines:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

For release builds:

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

If `SUPABASE_URL` or `SUPABASE_ANON_KEY` are missing, the app runs in local-only mode (offline cache on device).

## 4) Auth settings in Supabase

In Supabase Dashboard → Authentication:
- Enable Email provider
- Configure Site URL / redirect URLs for password reset if needed

## 5) GitHub Actions (optional)

Add repository secrets:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

Then pass them in CI build commands as `--dart-define`.

## 6) Migration from Laravel

Existing local Drift cache on devices is preserved. After login with Supabase, bookmarks/progress sync from cloud and continue offline-first.

The old Laravel backend folder (`werdi_backend`) is no longer required for the mobile app.
