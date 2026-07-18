#!/usr/bin/env bash
# Remove FinderInfo / resource-fork xattrs that break `codesign` on iCloud paths.
set -euo pipefail

strip_path() {
  local path="$1"
  if [[ -e "$path" ]]; then
    xattr -cr "$path" 2>/dev/null || true
  fi
}

# Xcode build products
if [[ -n "${TARGET_BUILD_DIR:-}" ]]; then
  strip_path "${TARGET_BUILD_DIR}"
  if [[ -n "${WRAPPER_NAME:-}" ]]; then
    strip_path "${TARGET_BUILD_DIR}/${WRAPPER_NAME}"
  fi
  strip_path "${TARGET_BUILD_DIR}/Flutter.framework"
  strip_path "${TARGET_BUILD_DIR}/App.framework"
fi

# Flutter assemble output
if [[ -n "${FLUTTER_APPLICATION_PATH:-}" ]]; then
  strip_path "${FLUTTER_APPLICATION_PATH}/build"
  strip_path "${FLUTTER_APPLICATION_PATH}/build/ios"
fi

# Project-relative fallback when invoked from repo scripts/
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
strip_path "$ROOT/build"
strip_path "$ROOT/ios/Flutter"
