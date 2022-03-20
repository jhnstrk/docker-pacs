FROM ubuntu:20.04@sha256:adf73ca014822ad8237623d388cedf4d5346aa72c270c5acc01431cc93e18e2d AS builder

RUN apt-get update && \
    apt-get install -y \
    --no-install-recommends \
    zip

COPY assets/jboss-4.2.3.GA-jdk6.zip  /tmp/jboss.zip

RUN  \
    cd /opt && \
    unzip /tmp/jboss.zip && \
    rm /tmp/jboss.zip

COPY assets/dcm4chee-2.18.3-psql.zip  /tmp/dcm4chee.zip
COPY assets/dcm4chee-2.18.1-psql.zip  /tmp/dcm4chee-ref.zip

RUN  \
    cd /opt && \
    unzip /tmp/dcm4chee.zip && \
    mv dcm4chee-2* dcm4chee && \
    rm /tmp/dcm4chee.zip && \
    cd /tmp && \
    unzip /tmp/dcm4chee-ref.zip && \
    cp dcm4chee-2*/bin/install_jboss* /opt/dcm4chee/bin/ \
    && rm -r /tmp/dcm4chee-ref.zip /tmp/dcm4chee-2*

COPY assets/jdk-6u45-linux-x64.bin /tmp/jdk.bin

RUN chmod 755 /tmp/jdk.bin && \
    cd /opt && \
    /tmp/jdk.bin && \
    mv jdk1.6.0* jdk1.6.0 && \
    ln -s /opt/jdk1.6.0/bin/java /usr/bin/java && \
    rm /tmp/jdk.bin

COPY assets/libclib_jiio-1.2-b04-linux-x86-64.so \
    /opt/dcm4chee/bin/native/libclib_jiio.so

RUN cd /opt/dcm4chee/bin && \
   ./install_jboss.sh /opt/jboss-4.2.3.GA/

# Update JDBC for Postgres
RUN rm -v /opt/dcm4chee/server/default/lib/postgresql-*.jar
COPY assets/postgresql-42.2.25.jre6.jar /opt/dcm4chee/server/default/lib/

FROM ubuntu:20.04@sha256:adf73ca014822ad8237623d388cedf4d5346aa72c270c5acc01431cc93e18e2d

COPY --from=builder /opt/dcm4chee /opt/dcm4chee
COPY --from=builder /opt/jdk1.6.0 /opt/jdk1.6.0
RUN  ln -s /opt/jdk1.6.0/bin/java /usr/bin/java

RUN sed -i -e "s/PostgreSQL 7.2/PostgreSQL/" \
    -e 's/jdbc:postgresql:\/\/localhost\/pacsdb/jdbc:postgresql:\/\/db\/pacsdb?user=pacsuser\&amp;password=pacspassword/' \
    /opt/dcm4chee/server/default/deploy/pacs-postgres-ds.xml
# RUN sed -i -s /PostgreSQL 7.2/PostgreSQL/ /opt/dcm4chee/server/default/deploy/arr-psql-ds.xml
# RUN chmod 755 

CMD [ "/opt/dcm4chee/bin/run.sh" ]

EXPOSE 8080
EXPOSE 8443
EXPOSE 11112
EXPOSE 2575

