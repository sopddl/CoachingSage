#!/bin/sh
# Xcode Cloud pre-xcodebuild script
#
# Filet 1 : schema drift DTO ↔ migrations locales. Placeholder tant que
# les premières migrations et DTO Supabase ne sont pas en place (Epic 2+).
#
# Filet 2 : drift migrations locales ↔ remote Supabase — pas lancé en CI
# (nécessite un link CLI et credentials que Xcode Cloud n'a pas).

set -e

if [ "${CI_XCODEBUILD_ACTION:-}" = "test-without-building" ]; then
  echo "⏭️  Skip pre-xcodebuild : action=test-without-building"
  exit 0
fi

REPO_ROOT="${CI_PRIMARY_REPOSITORY_PATH:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$REPO_ROOT"

if [ -f scripts/check_schema_drift.py ]; then
  echo "🔍 CI filet 1 — schema drift (DTO ↔ migrations locales)..."
  python3 scripts/check_schema_drift.py
  echo "✅ CI filet 1 passed."
else
  echo "⏭️  Skip schema drift check : scripts/check_schema_drift.py absent (à créer en Epic 2+)"
fi
