#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT_DIR/config/supabase.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing $ENV_FILE"
  echo "Run: ./scripts/configure_supabase_remote.sh <URL> <ANON_KEY>"
  exit 1
fi

# shellcheck disable=SC1090
source "$ENV_FILE"

if [[ -z "${SUPABASE_PROJECT_REF:-}" ]]; then
  echo "SUPABASE_PROJECT_REF is required in config/supabase.env"
  exit 1
fi

cd "$ROOT_DIR"

if [[ -n "${SUPABASE_ACCESS_TOKEN:-}" ]]; then
  echo "Linking remote project via Supabase CLI..."
  npx supabase link --project-ref "$SUPABASE_PROJECT_REF" --password "${SUPABASE_DB_PASSWORD:-}" || true
  npx supabase db push
  echo "Schema pushed with Supabase CLI."
  exit 0
fi

echo "SUPABASE_ACCESS_TOKEN not set. Applying schema via SQL file fallback..."
echo "Open Supabase SQL Editor and run:"
echo "  docs/supabase_schema.sql"
echo
echo "Or set SUPABASE_ACCESS_TOKEN in config/supabase.env and rerun this script."
