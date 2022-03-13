#!/bin/bash
set -eux

docker build -t dcm4chee2/pacs:latest  -f pacs.dockerfile .
docker build -t dcm4chee2/db:latest    -f db.dockerfile .

