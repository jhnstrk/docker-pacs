#!/bin/bash
set -eux

PG_PACS_DATABASE=pacsdb

# Check var is set, error out if not
check_env_is_set() {
  if [ -z "${!1}"]; then
    echo "ERROR: $1 is not set" 1>&2
    exit 1
  fi
}

check_env_is_set PG_PACS_USER
check_env_is_set PG_PACS_PASSWORD
check_env_is_set PG_PACS_DATABASE

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "postgres" <<-EOSQL
    CREATE USER "$PG_PACS_USER" WITH PASSWORD '$PG_PACS_PASSWORD'
      LOGIN INHERIT;
    CREATE DATABASE "$PG_PACS_DATABASE";
    GRANT ALL PRIVILEGES ON DATABASE "$PG_PACS_DATABASE" TO "$PG_PACS_USER";
EOSQL

echo $(pwd)
psql -v ON_ERROR_STOP=1 --username "$PG_PACS_USER" --dbname "$PG_PACS_DATABASE" < /docker-entrypoint-initdb.d/pacsdb/create.psql
