#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

echo "Dans PostgreSQL, saisir successivement :"
echo '\password analyst_login'
echo '\password app_login'
echo '\q'

docker compose --env-file .env --env-file .env.repro \
  exec db psql -U postgres -d retail_admin
