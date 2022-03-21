#!/bin/bash
set -eux

PG_CONQUEST_DATABASE=conquestdb

# Check var is set, error out if not
check_env_is_set() {
  if [ -z "${!1}"]; then
    echo "ERROR: $1 is not set" 1>&2
    exit 1
  fi
}

check_env_is_set PG_CONQUEST_USER
check_env_is_set PG_CONQUEST_PASSWORD
check_env_is_set PG_CONQUEST_DATABASE

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "postgres" <<-EOSQL
    CREATE USER "$PG_CONQUEST_USER" WITH PASSWORD '$PG_CONQUEST_PASSWORD'
      LOGIN INHERIT;
    CREATE DATABASE "$PG_CONQUEST_DATABASE";
    GRANT ALL PRIVILEGES ON DATABASE "$PG_CONQUEST_DATABASE" TO "$PG_CONQUEST_USER";
EOSQL
