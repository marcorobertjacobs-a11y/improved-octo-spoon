#!/usr/bin/env bash
set -euo pipefail

DB_PATH="${1:-membership.db}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"

sqlite3 "$DB_PATH" < "$REPO_ROOT/database/membership_schema.sql"
sqlite3 "$DB_PATH" < "$REPO_ROOT/database/seed_membership_data.sql"

printf 'Created membership database at %s\n' "$DB_PATH"
