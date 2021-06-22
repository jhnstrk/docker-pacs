#!/bin/bash
# Script to run DICOM server
set -eu
exec supervisord -c /opt/conquest/supervisord.conf
