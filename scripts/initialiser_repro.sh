#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

dc() {
  docker compose --env-file .env --env-file .env.repro "$@"
}

sql() {
  dc exec -T db psql -U postgres -d retail_admin \
    -v ON_ERROR_STOP=1 "$@"
}

attendre() {
  for tentative in {1..30}; do
    if dc exec -T db pg_isready -U postgres -d retail_admin \
      >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  echo "ERREUR : PostgreSQL ne répond pas."
  return 1
}

echo "=== Démarrage de retailops_repro ==="
dc up -d --build --wait

existant=$(sql -At -c \
  "SELECT COUNT(*) FROM pg_namespace WHERE nspname = 'retail';")

if [ "$existant" != "0" ]; then
  echo "ARRÊT : le schéma retail existe déjà dans le test."
  echo "Aucune donnée n'a été supprimée."
  exit 1
fi

echo "=== Tables, import, contrôles et rôles ==="
for fichier in 01_schema.sql 02_import.sql 03_controles.sql \
               05_roles.sql 10_index.sql; do
  sql -f "/sql/projet/$fichier"
done

echo "=== Certificat TLS propre au test ==="
certdir=$(mktemp -d)
trap 'rm -rf "$certdir"' EXIT

openssl req -new -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "$certdir/server.key" \
  -out "$certdir/server.crt" -subj "/CN=localhost"

dc cp "$certdir/server.crt" db:/var/lib/postgresql/data/server.crt
dc cp "$certdir/server.key" db:/var/lib/postgresql/data/server.key
dc cp config/pg_hba.conf db:/var/lib/postgresql/data/pg_hba.conf

dc exec -T -u root db chown postgres:postgres \
  /var/lib/postgresql/data/server.crt \
  /var/lib/postgresql/data/server.key \
  /var/lib/postgresql/data/pg_hba.conf
dc exec -T -u root db chmod 600 /var/lib/postgresql/data/server.key
dc exec -T -u postgres db mkdir -p /backups/wal
dc exec -T -u postgres db test -w /backups/wal

echo "=== Configuration et redémarrage ==="
sql -c "ALTER SYSTEM SET ssl = 'on';"
sql -c "ALTER SYSTEM SET shared_preload_libraries = 'pgaudit';"
sql -f /sql/projet/12_wal.sql

dc restart db
attendre

sql -f /sql/projet/07_audit.sql
sql -f /sql/projet/08_volumes.sql
sql -c "SHOW ssl;" -c "SHOW archive_mode;" \
    -c "SELECT extname, extversion FROM pg_extension WHERE extname='pgaudit';"

echo "Installation terminée dans retailops_repro."
echo "Les mots de passe analyst_login et app_login restent à définir."
