# The same patched PHP runtime used by nongfu, pinned to the verified image.
ARG BASE_IMAGE=harbor-cn.lingmouai.com/web/nginx-php:v3.2.1@sha256:538e4244b012387a975448491a0f42a58bbd967c44083ca9cd421c08b2542ff7
FROM ${BASE_IMAGE} AS extension-build

SHELL ["/bin/sh", "-euc"]
ENV MAKEFLAGS=-j2

RUN test "$(php -r 'echo PHP_VERSION;')" = "8.4.27"; \
    apk add --no-cache --virtual .php84-build-deps \
        autoconf g++ gcc make pkgconf re2c linux-headers \
        libmemcached-dev zlib-dev libssh2-dev openssl-dev

RUN docker-php-ext-configure ftp --with-ftp-ssl; \
    docker-php-ext-install -j2 bcmath ftp; \
    docker-php-source delete

# Restore public headers while retaining the base image's igbinary binary.
RUN test "$(php -r 'echo phpversion("igbinary");')" = "3.2.16"; \
    curl -fsSL --retry 3 https://pecl.php.net/get/igbinary-3.2.16.tgz -o /tmp/igbinary.tgz; \
    tar -xzf /tmp/igbinary.tgz -C /tmp; \
    mkdir -p /usr/local/include/php/ext/igbinary/src/php7; \
    cp /tmp/igbinary-3.2.16/igbinary.h /tmp/igbinary-3.2.16/php_igbinary.h /usr/local/include/php/ext/igbinary/; \
    cp /tmp/igbinary-3.2.16/src/php7/igbinary.h /tmp/igbinary-3.2.16/src/php7/php_igbinary.h /usr/local/include/php/ext/igbinary/src/php7/; \
    rm -rf /tmp/igbinary.tgz /tmp/igbinary-3.2.16
RUN pecl install msgpack-3.0.1
RUN pecl install ast-1.1.3 ssh2-1.5.0
RUN pecl install xdebug-3.5.3
RUN pecl install --configureoptions \
        'enable-memcached-igbinary="yes" enable-memcached-msgpack="yes"' memcached-3.4.0; \
    docker-php-ext-enable msgpack ast ssh2 xdebug; \
    docker-php-ext-enable --ini-name zz-memcached.ini memcached

RUN mkdir -p /opt/php84/extensions /opt/php84/conf.d; \
    for extension in bcmath ftp igbinary msgpack ast ssh2 memcached xdebug; do \
        cp "$(php-config --extension-dir)/${extension}.so" /opt/php84/extensions/; \
    done; \
    for extension in bcmath ftp msgpack ast ssh2 xdebug; do \
        cp "/usr/local/etc/php/conf.d/docker-php-ext-${extension}.ini" /opt/php84/conf.d/; \
    done; \
    cp /usr/local/etc/php/conf.d/zz-memcached.ini /opt/php84/conf.d/

FROM ${BASE_IMAGE} AS runtime
SHELL ["/bin/sh", "-euc"]
ARG PUID=1000
ARG PGID=1000
ARG TZ=Asia/Shanghai
ENV TZ=${TZ}
RUN apk add --no-cache libmemcached libssh2; \
    addgroup -g "${PGID}" laradock; \
    adduser -D -u "${PUID}" -G laradock -s /bin/bash laradock; \
    ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime; \
    printf '%s\n' "${TZ}" > /etc/timezone

COPY --from=extension-build /opt/php84/extensions/ /usr/local/lib/php/extensions/no-debug-non-zts-20240924/
COPY --from=extension-build /opt/php84/conf.d/ /usr/local/etc/php/conf.d/
COPY --from=extension-build /usr/local/include/php/ext/ /usr/local/include/php/ext/
COPY --from=extension-build /usr/local/lib/php/.registry/ /usr/local/lib/php/.registry/
COPY php.ini /usr/local/etc/php/conf.d/99-laradock.ini
COPY xdebug.ini /usr/local/etc/php/conf.d/99-xdebug.ini

# Start only the selected PHP service, instead of the base image's Supervisor.
ENTRYPOINT ["docker-php-entrypoint"]
WORKDIR /var/www

FROM runtime AS fpm
COPY php-fpm.conf /usr/local/etc/php-fpm.conf
EXPOSE 9000
STOPSIGNAL SIGQUIT
CMD ["php-fpm", "--nodaemonize"]

FROM runtime AS workspace
ARG COMPOSER_VERSION=2.10.3
RUN apk add --no-cache git openssh-client vim less unzip zip coreutils; \
    curl -fsSL "https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar" -o /tmp/composer.phar; \
    curl -fsSL "https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar.sha256sum" -o /tmp/composer.sha256; \
    printf '%s  %s\n' "$(cut -d ' ' -f1 /tmp/composer.sha256)" /tmp/composer.phar | sha256sum -c -; \
    install -m 0755 /tmp/composer.phar /usr/local/bin/composer; \
    rm /tmp/composer.phar /tmp/composer.sha256; \
    mkdir -p /home/laradock/.composer; \
    printf '%s\n' 'export PATH="$HOME/.composer/vendor/bin:$PATH"' 'alias ll="ls -alF"' > /home/laradock/.bashrc; \
    chown -R laradock:laradock /home/laradock/.composer /home/laradock/.bashrc
COPY workspace.ini /usr/local/etc/php/conf.d/99-workspace.ini
ENV HOME=/home/laradock COMPOSER_HOME=/home/laradock/.composer
USER laradock
STOPSIGNAL SIGTERM
CMD ["sleep", "infinity"]
