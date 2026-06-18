# Werdi (وِردي)

A Flutter application for memorizing, reviewing, and reciting the Holy Qur'an, with
progress tracking, achievements, and audio recitation. Arabic‑first (RTL) with full
English support, light/dark themes, and a responsive layout for mobile, tablet,
desktop, and web.

## Architecture

The project follows a scalable, feature‑based Clean Architecture with a clear
separation between presentation, domain, and data layers. State is managed with
`flutter_bloc` (Cubits), navigation with `go_router`, and dependencies are wired
through a single composition root.

```
lib/
├── app.dart                 # Root widget (MaterialApp.router, theme/locale wiring)
├── main.dart                # Entry point + bootstrap
├── app/state/               # Global app state (theme, locale cubits)
├── core/                    # Cross‑cutting building blocks
│   ├── animations/          # Reusable animation extensions
│   ├── constants/           # App‑wide constants & asset paths
│   ├── di/                  # AppInjector — composition root
│   ├── extensions/          # Context/utility extensions
│   ├── network/             # API client
│   ├── security/            # Token storage
│   ├── services/            # Bootstrap, preferences, reminders, logging
│   ├── theme/               # Design system tokens (see below)
│   └── widgets/             # Shared, reusable UI components (App* widgets)
├── features/                # One folder per feature, each with:
│   └── <feature>/
│       ├── data/            # Repositories impl, services
│       ├── domain/          # Models, repository contracts
│       └── presentation/    # Cubit + state, pages, widgets
├── l10n/                    # Localization (ar/en ARB + generated)
├── routes/                  # Route names + GoRouter config
└── shared/                  # Cross‑feature repositories (audio, progress)
```

### Features

`splash`, `onboarding`, `auth` (login / register / forgot password),
`home` (dashboard), `quran` (browse, search, surah details, bookmarks, audio),
`memorization`, `review`, `tasmee3` (recitation sessions), `achievements`,
`profile`, and `settings`.

### Dependency injection

All concrete implementations are constructed in `core/di/app_injector.dart`. The
injector exposes interface‑typed gateways so the rest of the app depends on
abstractions, not implementations. A `useLaravelBackend` flag in `AppConstants`
switches between the Laravel backend and local/no‑op implementations.

## Design system

A single source of truth for visual styling lives in `core/theme/`:

| Token file          | Purpose                                            |
| ------------------- | -------------------------------------------------- |
| `app_colors.dart`   | Brand palette + light/dark/semantic color tokens   |
| `app_typography.dart` | Google Fonts text themes (light/dark)            |
| `app_spacing.dart`  | 4pt spacing scale + semantic aliases               |
| `app_radius.dart`   | Border‑radius tokens (button, input, card, …)      |
| `app_shadows.dart`  | Elevation shadows                                  |
| `app_elevation.dart`| Elevation levels                                   |
| `app_durations.dart`| Motion/animation durations                         |
| `app_theme.dart`    | Material 3 `ThemeData` for light & dark            |

Reusable presentation components (prefixed `App*`, e.g. `AppScaffold`,
`AppButton`, `AppSurfaceCard`, `AppEmptyState`, `AppLoadingState`) compose these
tokens so screens stay consistent and declarative.

## Getting started

```bash
flutter pub get
flutter run
```

### Localization

ARB files live in `lib/l10n/` (`intl_ar.arb`, `intl_en.arb`). Generation is
configured via `l10n.yaml` and runs automatically on build (`generate: true`).

### Quality checks

```bash
flutter analyze   # static analysis (flutter_lints)
flutter test      # unit/widget tests
```

### Release & publishing

For production release workflows and store submission prep, see:
- `RELEASE_CHECKLIST.md`
- `STORE_METADATA_TEMPLATE.md`
- `android/key.properties.example`
- `scripts/release_android.sh`
- `scripts/release_ios.sh`

## Tech stack

Flutter (Material 3) · flutter_bloc · go_router · flutter_screenutil ·
google_fonts · dio · hive · shared_preferences · just_audio ·
flutter_local_notifications · flutter_secure_storage.
