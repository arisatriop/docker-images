FROM php:7.3.30-fpm

LABEL maintainer="Ari Satrio <arisatrioputra03@gmail.com>"

COPY ./assets/oracle/oracle-instantclient-basic-10.2.0.5-1.x86_64.rpm /root/
COPY ./assets/oracle/oracle-instantclient-sqlplus-10.2.0.5-1.x86_64.rpm /root/
COPY ./assets/oracle/oracle-instantclient-devel-10.2.0.5-1.x86_64.rpm /root/

RUN set -eux; \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    # install build-time dependencies
    apt-get install -y --no-install-recommends \
        autoconf \
        alien \
        libonig-dev \
        libxml2-dev \
        zlib1g-dev \
        libzip-dev \
        libldap2-dev \
    ; \
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark > /dev/null; \
    \
    \
    ln -snf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime; \
    echo "Asia/Jakarta" > /etc/timezone; \
    \
    # install runtime dependencies
    apt-get install -y --no-install-recommends \
        ca-certificates \
        parallel \
        nano  \
        vim  \
        curl \
        nginx \
        supervisor \
        libzip4 \
        libaio1 \
    ; \
    \
    # install oracle
    alien -i /root/oracle-instantclient-basic-10.2.0.5-1.x86_64.rpm; \
    alien -i /root/oracle-instantclient-sqlplus-10.2.0.5-1.x86_64.rpm; \
    alien -i /root/oracle-instantclient-devel-10.2.0.5-1.x86_64.rpm; \
    echo /usr/lib/oracle/10.2.0.5/client64/lib/ > /etc/ld.so.conf.d/oracle-instantclient.conf; \
    ldconfig; \
    \
    # configure php extensions
    docker-php-ext-configure  \
      oci8 --with-oci8="instantclient,/usr/lib/oracle/10.2.0.5/client64/lib" \
    ; \
    \
    # install php extensions
    docker-php-ext-install \
        zip \
        ldap \
        pdo \
        bcmath \
        pdo_mysql \
        iconv \
        exif \
        mysqli \
        oci8 \
        mbstring \
        pcntl \
        dom \
    ; \
    \
    # install other extensions via PECL
    pecl install -o -f \
        redis \
        apfd \
    ; \
    \
    # enable php extensions installed via PECL
    docker-php-ext-enable \
        redis \
        apfd \
    ; \
    \
    rm -f /root/oracle-instantclient-*; \
    rm -rf /usr/local/etc/php-fpm.d/*; \
    rm -rf /var/lib/apt/lists/*; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    \
    mkdir -p /var/log/app/queue

COPY ./assets/oracle/tnsnames.ora /usr/lib/oracle/10.2.0.5/client64/network/admin/
COPY ./7.3-ora/nginx.conf /etc/nginx/nginx.conf
COPY ./7.3-ora/app.conf /etc/supervisor/conf.d/app.conf.stub
COPY ./7.3-ora/www.conf /usr/local/etc/php-fpm.d/default.conf
COPY ./7.3-ora/prepare-entrypoint.sh /root/prepare-entrypoint.sh
COPY ./7.3-ora/entrypoint.sh /root/entrypoint.sh
COPY ./7.3-ora/foreground /root/foreground

RUN chmod +x /root/prepare-entrypoint.sh \
    && chmod +x /root/entrypoint.sh \
    && chmod +x /root/foreground/* \
    && sed -i -- "s/logfile=.* ;/logfile=\/dev\/null ;/g" /etc/supervisor/supervisord.conf

EXPOSE 80
ENTRYPOINT ["/root/entrypoint.sh"]
