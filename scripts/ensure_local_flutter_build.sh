#!/usr/bin/env bash
# Redirect Flutter's build/ off iCloud Desktop/Documents so CodeSign works.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CACHE_ROOT="${WERDI_FLUTTER_BUILD_CACHE:-$HOME/Library/Caches/werdi-flutter}"
LOCAL_BUILD="$CACHE_ROOT/build"

mkdir -p "$LOCAL_BUILD"
cd "$ROOT"

if [[ -L build ]]; then
  current="$(readlink build || true)"
  if [[ "$current" == "$LOCAL_BUILD" ]]; then
    exit 0
  fi
  rm -f build
elif [[ -d build ]] || [[ -e build ]]; then
  # Do not copy iCloud build trees (slow / xattr polluted). Discard and relink.
  rm -rf build
fi

ln -sfn "$LOCAL_BUILD" build
echo "Werdi: build/ → $LOCAL_BUILD (off iCloud)"
