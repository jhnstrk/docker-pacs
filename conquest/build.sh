#!/bin/bash
set -eu

docker build -t conquest/pacs:latest  -f pacs.dockerfile --progress=plain .
# docker build -t dcm4chee2/db:latest    -f db.dockerfile .

docker build -t conquest/pacs:postgres-latest  -f pacs-postgres.dockerfile --progress=plain .

