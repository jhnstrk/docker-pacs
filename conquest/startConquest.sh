#!/bin/bash
# Script to run DICOM server
set -eu
service apache2 restart

cd /opt/conquest
./dgate -v -w/opt/conquest
