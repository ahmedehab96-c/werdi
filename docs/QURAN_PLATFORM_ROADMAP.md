# Werdi Quran Platform Roadmap

This roadmap upgrades Werdi incrementally to a full production Quran platform
without breaking current functionality.

## Stack (current)

- **State management:** `flutter_bloc` (Cubit pattern) + `equatable`
- **DI / services:** `AppInjector` (service locator)
- **Navigation:** `go_router`
- **Local DB:** `drift` + `sqlite3_flutter_libs`
- **Remote (optional):** `supabase_flutter`

Not used: Riverpod, Provider, GetX, MobX.

## Phase 1 (implemented)

- Drift database + trusted Quran text pipeline
- `LocalQuranCacheService` (Drift cache, offline read fallback)
- Integrate into `QuranRepositoryImpl.getSurahVerses(...)`

## Phase 2 (implemented)

- Drift schema for ayahs, bookmarks, memorization progress, revision items
- Local repositories migrated from SharedPreferences to Drift where applicable

## Phase 3

- Add `audio_service` with lock-screen controls and background playback
- Add offline download manager for recitations

## Phase 4

- Production search (ayah text + word search + highlighting)
- Advanced memorization/revision analytics and smart plans

## Phase 5

- Full sync hardening and QA coverage
