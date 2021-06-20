#!/bin/bash
set -eu

docker run -it --rm -p 127.0.0.1:8180:80/tcp \
    -p 127.0.0.1:5678:5678/tcp \
    conquest/pacs:latest /bin/bash
