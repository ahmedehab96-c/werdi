#!/usr/bin/env bash
# Capture Play Store screenshots on the booted iOS simulator.
# Usage: ./scripts/capture_store_screenshots.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/docs/store_assets/screenshots"
DEVICE="${WERDI_SCREENSHOT_DEVICE:-5A6025B3-BFD3-4B06-9C7E-1D8A0B7CFA6A}"
mkdir -p "$OUT"

cd "$ROOT"
xcrun simctl spawn booted defaults write com.werdi.app "flutter.onboarding_completed" -string "1" 2>/dev/null || true

capture_route() {
  local name="$1"
  local route="$2"
  echo "==> $name ($route)"
  # Kill previous flutter run if any
  pkill -f "flutter run" 2>/dev/null || true
  sleep 1
  flutter run -d "$DEVICE" \
    --dart-define=SCREENSHOT_ROUTE="$route" \
    >"/tmp/werdi_shot_${name}.log" 2>&1 &
  local pid=$!
  for _ in $(seq 1 90); do
    if grep -q "Flutter run key commands" "/tmp/werdi_shot_${name}.log" 2>/dev/null; then
      break
    fi
    if grep -qE "Error launching|Could not build|CodeSign failed" "/tmp/werdi_shot_${name}.log" 2>/dev/null; then
      echo "Build/run failed for $name"
      tail -30 "/tmp/werdi_shot_${name}.log"
      kill "$pid" 2>/dev/null || true
      return 1
    fi
    sleep 2
  done
  sleep 2
  xcrun simctl io booted screenshot "$OUT/${name}.png"
  echo "saved $OUT/${name}.png"
  kill "$pid" 2>/dev/null || true
  pkill -f "flutter run" 2>/dev/null || true
  sleep 1
}

capture_route "01_home" "/home"
capture_route "02_quran" "/quran"
capture_route "03_memorization" "/memorization"
capture_route "04_goals" "/goals"
capture_route "05_profile" "/profile"
capture_route "06_review" "/review"
capture_route "07_tasmee3" "/tasmee3"
capture_route "08_settings" "/settings"

echo "Done. Screenshots in $OUT"
ls -la "$OUT"
