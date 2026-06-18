# Werdi Quran Platform Roadmap

This roadmap upgrades Werdi incrementally to a full production Quran platform
without breaking current functionality.

## Phase 1 (implemented)

- Add migration-ready stack dependencies:
  - `flutter_riverpod`, `freezed_annotation`, `drift`, `sqlite3_flutter_libs`
  - codegen tooling (`build_runner`, `freezed`, `drift_dev`, `json_serializable`)
- Add Riverpod bridge providers in `lib/core/di/app_providers.dart`.
- Keep current `AppInjector` architecture intact for backward compatibility.
- Introduce trusted Quran text pipeline:
  - `TrustedQuranRemoteService` (`Quran.com` primary, `Tanzil` fallback)
  - `LocalQuranCacheService` (Hive surah cache, offline read fallback)
  - Integrate into `QuranRepositoryImpl.getSurahVerses(...)`.

## Phase 2

- Add Drift database schema for:
  - ayahs, bookmarks, memorization progress, revision items, sync queue.
- Move local repositories from SharedPreferences to Drift.

## Phase 3

- Add `audio_service` with lock-screen controls and background playback.
- Add offline download manager for recitations.

## Phase 4

- Migrate feature state from Cubit to Riverpod incrementally:
  settings -> review -> memorization -> quran.

## Phase 5

- Production search (ayah text + word search + highlighting).
- Advanced memorization/revision analytics and smart plans.
- Full sync hardening and QA coverage.
