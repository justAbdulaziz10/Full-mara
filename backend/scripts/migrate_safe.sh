#!/usr/bin/env bash
set -euo pipefail
alembic upgrade head || { echo "❌ Migration failed, rolling back"; alembic downgrade -1; exit 1; }
echo "✅ Migration ok"
