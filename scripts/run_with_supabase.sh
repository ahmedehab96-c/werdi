#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFINES_FILE="$ROOT_DIR/config/dart_defines.json"

if [[ ! -f "$DEFINES_FILE" ]]; then
  echo "Missing $DEFINES_FILE"
  echo "Run: ./scripts/configure_supabase_remote.sh <URL> <ANON_KEY>"
  exit 1
fi

cd "$ROOT_DIR"
flutter run --dart-define-from-file="$DEFINES_FILE" "$@"
