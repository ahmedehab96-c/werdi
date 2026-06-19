#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT_DIR/config/supabase.env"
DEFINES_FILE="$ROOT_DIR/config/dart_defines.json"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/configure_supabase_remote.sh <SUPABASE_URL> <SUPABASE_ANON_KEY> [PROJECT_REF]

Example:
  ./scripts/configure_supabase_remote.sh \
    https://abcd1234.supabase.co \
    eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9... \
    abcd1234
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

SUPABASE_URL="${1:-}"
SUPABASE_ANON_KEY="${2:-}"
PROJECT_REF="${3:-}"

if [[ -z "$SUPABASE_URL" || -z "$SUPABASE_ANON_KEY" ]]; then
  if [[ -f "$ENV_FILE" ]]; then
    # shellcheck disable=SC1090
    source "$ENV_FILE"
  else
    usage
    exit 1
  fi
fi

if [[ -z "$PROJECT_REF" ]]; then
  PROJECT_REF="$(echo "$SUPABASE_URL" | sed -E 's#https://([^.]+)\.supabase\.co.*#\1#')"
fi

mkdir -p "$ROOT_DIR/config"
cat > "$DEFINES_FILE" <<EOF
{
  "SUPABASE_URL": "$SUPABASE_URL",
  "SUPABASE_ANON_KEY": "$SUPABASE_ANON_KEY"
}
EOF

cat > "$ENV_FILE" <<EOF
SUPABASE_URL=$SUPABASE_URL
SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
SUPABASE_PROJECT_REF=$PROJECT_REF
SUPABASE_ACCESS_TOKEN=${SUPABASE_ACCESS_TOKEN:-}
EOF

echo "Configured:"
echo "  - $DEFINES_FILE"
echo "  - $ENV_FILE"
echo
echo "Next:"
echo "  ./scripts/push_supabase_schema.sh"
echo "  flutter run --dart-define-from-file=config/dart_defines.json"
