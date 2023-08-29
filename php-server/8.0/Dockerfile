FROM php:8.0.10-fpm

LABEL maintainer="Ari Satrio <arisatrioputra03@gmail.com>"

ARG SSH_PRIVATE_KEY
ENV LIBRDKAFKA_VERSION 1.6.2
ENV PHP_RDKAFKA_VERSION 6.0.1

RUN set -eux; \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    # install build-time dependencies
    apt-get install -y --no-install-recommends \
        autoconf \
        libonig-dev \
        libxml2-dev \
        zlib1g-dev \
        libzip-dev \
        libldap2-dev \
        libmagickwand-dev \
        libfreetype6-dev  \
        libjpeg62-turbo-dev \
        libpng-dev \
        libwebp-dev \
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
        ssh \
        git \
        vim  \
        curl \
        nginx \
        supervisor \
        libzip4 \
        libmagickcore-6.q16-6 \
        libmagickcore-6.q16-6-extra \
        libfreetype6  \
        libjpeg62-turbo \
        libpng16-16 \
        libwebp6 \
    ; \
    \
    git clone --depth 1 --branch v$LIBRDKAFKA_VERSION https://github.com/edenhill/librdkafka.git librdkafka \
        && cd librdkafka \
        && ./configure \
        && make \
        && make install \
        && cd .. \
        && rm -rf librdkafka \
    ; \
    \
    # configure php extensions
    docker-php-ext-configure \
        gd --enable-gd --with-webp --with-freetype --with-jpeg \
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
        mbstring \
        pcntl \
        dom \
        gd \
    ; \
    \
    # install other extensions via PECL
    pecl install -o -f \
        redis \
        imagick \
        apfd \
        rdkafka-$PHP_RDKAFKA_VERSION \
    ; \
    \
    # enable php extensions installed via PECL
    docker-php-ext-enable \
        redis \
        imagick \
        apfd \
        rdkafka \
    ; \
    \
    rm -rf /usr/local/etc/php-fpm.d/*; \
    rm -rf /var/lib/apt/lists/*; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    \
    mkdir -p /var/log/app; 

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
COPY ./8.0/nginx.conf /etc/nginx/nginx.conf
COPY ./8.0/app.conf /etc/supervisor/conf.d/app.conf.stub
COPY ./8.0/www.conf /usr/local/etc/php-fpm.d/default.conf
COPY ./8.0/prepare-entrypoint.sh /root/prepare-entrypoint.sh
COPY ./8.0/entrypoint.sh /root/entrypoint.sh
COPY ./8.0/foreground /root/foreground

RUN chmod +x /root/prepare-entrypoint.sh \
    && chmod +x /root/entrypoint.sh \
    && chmod +x /root/foreground/* \
    && sed -i -- "s/logfile=.* ;/logfile=\/dev\/null ;/g" /etc/supervisor/supervisord.conf

EXPOSE 80
ENTRYPOINT ["/root/entrypoint.sh"]
