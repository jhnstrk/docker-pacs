FROM postgres:11 AS builder

RUN apt-get update && \
    apt-get install -y zip && \
    rm -rf /var/lib/apt/lists/*

COPY assets/dcm4chee-2.18.3-psql.zip  /tmp/dcm4chee.zip

RUN  \
    cd /tmp && \
    unzip /tmp/dcm4chee.zip && \
    mv dcm4chee-2* dcm4chee && \
    rm /tmp/dcm4chee.zip

FROM postgres:11

ENV POSTGRES_USER pacsuser
ENV POSTGRES_PASSWORD pacspassword
ENV POSTGRES_DB pacsdb

# Note the suffix changes to .sql
COPY --from=builder /tmp/dcm4chee/sql/create.psql \
   /docker-entrypoint-initdb.d/create.sql

# The index name conflicts with a table of same name.
RUN sed -i -e \
  's/^CREATE INDEX published_study /CREATE INDEX published_study_study_fk /' \
  /docker-entrypoint-initdb.d/create.sql
