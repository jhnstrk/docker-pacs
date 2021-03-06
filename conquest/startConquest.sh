#!/bin/bash
# Script to run DICOM server
set -eu

export CONQUEST_AETITLE="${CONQUEST_AETITLE:-CONQUESTSRV1}"
export CONQUEST_PORT="${CONQUEST_PORT:-5678}"
export PG_CONQUEST_HOST="${PG_CONQUEST_HOST:-localhost}"
export PG_CONQUEST_DATABASE="${PG_CONQUEST_DATABASE:-conquest}"
export PG_CONQUEST_USER="${PG_CONQUEST_USER:-postgres}"
export PG_CONQUEST_PASSWORD="${PG_CONQUEST_PASSWORD:-postgres}"

export CONQUEST=/opt/conquest
export CONQUESTTEMP=$CONQUEST/temp
export IP=127.0.0.1  # $(hostname -I | xargs)

echo "Initializing settings for $CONQUEST_AETITLE:$CONQUEST_PORT"
echo "Postgres: $PG_CONQUEST_USER@$PG_CONQUEST_HOST/$PG_CONQUEST_DATABASE"

envsubst < $CONQUEST/dicom.template.ini \
         > /opt/conquest/dicom.ini
envsubst < $CONQUEST/dicom.cgi-bin.template.ini \
         > /usr/lib/cgi-bin/dicom.ini
envsubst < $CONQUEST/dicom.newweb.template.ini \
         > /usr/lib/cgi-bin/newweb/dicom.ini

if [ ! -z "${INIT_DATABASE:-}" ];  then
  ./dgate -v -r
  exit $?
fi

exec supervisord -c /opt/conquest/supervisord.conf
