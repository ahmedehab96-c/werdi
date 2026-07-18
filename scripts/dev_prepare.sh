#!/usr/bin/env bash
# Always-safe prepare before Run / analyze.
# Regenerates l10n and keeps build/ off iCloud.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "Werdi prepare: $ROOT"

if [[ -f "scripts/ensure_local_flutter_build.sh" ]]; then
  bash "scripts/ensure_local_flutter_build.sh"
fi

flutter gen-l10n
flutter pub get

if [[ ! -f "lib/l10n/app_localizations.dart" ]]; then
  echo "error: lib/l10n/app_localizations.dart was not generated" >&2
  exit 1
fi

echo "Werdi prepare: ready (l10n + deps)"
