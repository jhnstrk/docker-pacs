FROM postgres:11

COPY ./init-db-user.sh \
    /docker-entrypoint-initdb.d/30-init-db-user.sh
