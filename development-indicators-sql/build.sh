#!/usr/bin/env bash
# DATABASE_URL=postgresql://user:pass@host:5432/db ./build.sh
set -euo pipefail
cd "$(dirname "$0")"
: "${DATABASE_URL:?Set DATABASE_URL to a PostgreSQL connection string}"
for f in sql/01_schema.sql sql/02_load.sql sql/03_quality_checks.sql sql/04_views.sql sql/05_analysis.sql; do
  echo "==> $f"
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -q -f "$f"
done
