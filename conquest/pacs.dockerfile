FROM ubuntu:20.04@sha256:adf73ca014822ad8237623d388cedf4d5346aa72c270c5acc01431cc93e18e2d AS builder

RUN apt-get update && \
    # Prevent timezone (tzdata) prompts
    DEBIAN_FRONTEND=noninteractive  \
    apt-get install -y zip \
    build-essential \
    gettext-base \
    sudo \
    g++ \
    apache2 \
    p7zip-full \
    liblua5.1-0 \
    lua5.1 \
    lua5.1-dev \
    lua-socket

RUN a2enmod cgi
RUN service apache2 restart

COPY assets/dicomserver150b.zip  /tmp/dicomserver.zip

RUN  mkdir /opt/conquest && \
    cd /opt/conquest && \
    unzip /tmp/dicomserver.zip && \
    rm /tmp/dicomserver.zip

WORKDIR /opt/conquest

RUN mkdir -p /usr/local/man/man1

RUN chmod 755 ./maklinux && \
    /bin/echo -e '3\ny\nn\n\n' | ./maklinux

# Please choose DB type
# 1) mariadb
# 2) postgres
# 3) sqlite
# 4) dbase
# 5) precompiled
# 6) Quit
#...
# Regenerate the database?
# Install as service?

# Remove stuff we don't need
RUN rm -rf *.exe *.dll *.bat
RUN rm -rf install install32 install64 linux/dgate src clibs
RUN ls -fs dgate /usr/lib/cgi-bin/dgate.exe

FROM ubuntu:20.04@sha256:adf73ca014822ad8237623d388cedf4d5346aa72c270c5acc01431cc93e18e2d

RUN apt-get update && \
    # Prevent timezone (tzdata) prompts
    DEBIAN_FRONTEND=noninteractive  \
    apt-get install -y \
    apache2 \
    p7zip-full \
    liblua5.1-0 \
    lua5.1 \
    lua-socket \
    php libapache2-mod-php \
    php-sqlite3 \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

RUN a2enmod cgi
RUN service apache2 restart

COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/lib/cgi-bin /usr/lib/cgi-bin
COPY --from=builder /opt/conquest /opt/conquest
COPY --from=builder /var/www/html/ /var/www/html/

WORKDIR /opt/conquest

RUN sed -i \
    -e 's/^\$folder = .*;/\$folder = "\/usr\/lib\/cgi-bin\/newweb";/' \
    -e 's/^\$exe = .*;/\$exe = ".\/dgate";/' \
    /var/www/html/dgate.php

COPY apache_dgate.conf /etc/apache2/sites-available/dgate.conf 
RUN a2enmod rewrite
RUN a2dissite 000-default
RUN a2ensite dgate

# Expose port 80 (http) and 5678 (for DICOM query/retrieve/send)
EXPOSE 80 5678

COPY ./startConquest.sh /opt/conquest/startConquest.sh
COPY ./supervisord.conf /opt/conquest/supervisord.conf
COPY ./supervisor-exit-event-listener  /usr/local/bin/supervisor-exit-event-listener

# Start apache and ConQuest
# The server should then be running and localhost/cgi-bin/dgate should provide a working web interface.
CMD ["startConquest.sh"]
