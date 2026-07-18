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

- [x] Offline download manager for recitations (settings → offline recitations)
- [x] `audio_service` foundation with lock-screen metadata and background session
- [x] Skip previous/next ayah from notification + reciter name on lock screen
- [x] Ayah range playlist (surah audio card + auto-advance)

## Phase 4

- [x] Multi-word ayah search (AND) with shared Arabic highlight widget
- [x] Memorization analytics snapshot on setup screen
- [x] Smart review plans based on weak ayahs

## Phase 5

- [x] Sync hardening: remote user ID fix, review items sync, pull on login/reconnect
- [x] Offline queue tests + review merge tests
- [x] HomeCubit / GoalsCubit / AuthCubit / offline recitation tests
