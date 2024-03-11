# 多php版本示例

## 1、docker-compose.yml
可以复制 php-fpm 的配置，然后小修改就行，比如下面的 `php-fpm-74` 配置，修改的地方有中文备注。
共修改两处：args. LARADOCK_PHP_VERSION 和 volumes. ./php-fpm/php7.4.ini

```yaml
### PHP-FPM-7.4 ##############################################
    php-fpm-74:
      build:
        context: ./php-fpm
        args:
          - CHANGE_SOURCE=${CHANGE_SOURCE}
          - BASE_IMAGE_TAG_PREFIX=${PHP_FPM_BASE_IMAGE_TAG_PREFIX}
          - LARADOCK_PHP_VERSION=7.4 （这个地方注意手动修改或者添加变量！！！）
          - LARADOCK_PHALCON_VERSION=${PHALCON_VERSION}
          - INSTALL_BZ2=${PHP_FPM_INSTALL_BZ2}
          - INSTALL_ENCHANT=${PHP_FPM_INSTALL_ENCHANT}
          - INSTALL_GMP=${PHP_FPM_INSTALL_GMP}
          - INSTALL_GNUPG=${PHP_FPM_INSTALL_GNUPG}
          - INSTALL_XDEBUG=${PHP_FPM_INSTALL_XDEBUG}
          - INSTALL_PCOV=${PHP_FPM_INSTALL_PCOV}
          - INSTALL_PHPDBG=${PHP_FPM_INSTALL_PHPDBG}
          - INSTALL_BLACKFIRE=${INSTALL_BLACKFIRE}
          - INSTALL_SSH2=${PHP_FPM_INSTALL_SSH2}
          - INSTALL_SOAP=${PHP_FPM_INSTALL_SOAP}
          - INSTALL_XSL=${PHP_FPM_INSTALL_XSL}
          - INSTALL_SMB=${PHP_FPM_INSTALL_SMB}
          - INSTALL_IMAP=${PHP_FPM_INSTALL_IMAP}
          - INSTALL_MONGO=${PHP_FPM_INSTALL_MONGO}
          - INSTALL_AMQP=${PHP_FPM_INSTALL_AMQP}
          - INSTALL_CASSANDRA=${PHP_FPM_INSTALL_CASSANDRA}
          - INSTALL_GEARMAN=${PHP_FPM_INSTALL_GEARMAN}
          - INSTALL_MSSQL=${PHP_FPM_INSTALL_MSSQL}
          - INSTALL_BCMATH=${PHP_FPM_INSTALL_BCMATH}
          - INSTALL_PHPREDIS=${PHP_FPM_INSTALL_PHPREDIS}
          - INSTALL_MEMCACHED=${PHP_FPM_INSTALL_MEMCACHED}
          - INSTALL_OPCACHE=${PHP_FPM_INSTALL_OPCACHE}
          - INSTALL_EXIF=${PHP_FPM_INSTALL_EXIF}
          - INSTALL_AEROSPIKE=${PHP_FPM_INSTALL_AEROSPIKE}
          - INSTALL_OCI8=${PHP_FPM_INSTALL_OCI8}
          - INSTALL_MYSQLI=${PHP_FPM_INSTALL_MYSQLI}
          - INSTALL_PGSQL=${PHP_FPM_INSTALL_PGSQL}
          - INSTALL_PG_CLIENT=${PHP_FPM_INSTALL_PG_CLIENT}
          - INSTALL_POSTGIS=${PHP_FPM_INSTALL_POSTGIS}
          - INSTALL_INTL=${PHP_FPM_INSTALL_INTL}
          - INSTALL_GHOSTSCRIPT=${PHP_FPM_INSTALL_GHOSTSCRIPT}
          - INSTALL_LDAP=${PHP_FPM_INSTALL_LDAP}
          - INSTALL_PHALCON=${PHP_FPM_INSTALL_PHALCON}
          - INSTALL_SWOOLE=${PHP_FPM_INSTALL_SWOOLE}
          - INSTALL_TAINT=${PHP_FPM_INSTALL_TAINT}
          - INSTALL_IMAGE_OPTIMIZERS=${PHP_FPM_INSTALL_IMAGE_OPTIMIZERS}
          - INSTALL_IMAGEMAGICK=${PHP_FPM_INSTALL_IMAGEMAGICK}
          - INSTALL_CALENDAR=${PHP_FPM_INSTALL_CALENDAR}
          - INSTALL_FAKETIME=${PHP_FPM_INSTALL_FAKETIME}
          - INSTALL_IONCUBE=${PHP_FPM_INSTALL_IONCUBE}
          - INSTALL_APCU=${PHP_FPM_INSTALL_APCU}
          - INSTALL_CACHETOOL=${PHP_FPM_INSTALL_CACHETOOL}
          - INSTALL_YAML=${PHP_FPM_INSTALL_YAML}
          - INSTALL_RDKAFKA=${PHP_FPM_INSTALL_RDKAFKA}
          - INSTALL_GETTEXT=${PHP_FPM_INSTALL_GETTEXT}
          - INSTALL_ADDITIONAL_LOCALES=${PHP_FPM_INSTALL_ADDITIONAL_LOCALES}
          - INSTALL_MYSQL_CLIENT=${PHP_FPM_INSTALL_MYSQL_CLIENT}
          - INSTALL_PING=${PHP_FPM_INSTALL_PING}
          - INSTALL_SSHPASS=${PHP_FPM_INSTALL_SSHPASS}
          - INSTALL_MAILPARSE=${PHP_FPM_INSTALL_MAILPARSE}
          - INSTALL_PCNTL=${PHP_FPM_INSTALL_PCNTL}
          - ADDITIONAL_LOCALES=${PHP_FPM_ADDITIONAL_LOCALES}
          - INSTALL_FFMPEG=${PHP_FPM_FFMPEG}
          - INSTALL_AUDIOWAVEFORM=${PHP_FPM_AUDIOWAVEFORM}
          - INSTALL_WKHTMLTOPDF=${PHP_FPM_INSTALL_WKHTMLTOPDF}
          - INSTALL_XHPROF=${PHP_FPM_INSTALL_XHPROF}
          - INSTALL_XMLRPC=${PHP_FPM_INSTALL_XMLRPC}
          - INSTALL_PHPDECIMAL=${PHP_FPM_INSTALL_PHPDECIMAL}
          - INSTALL_ZOOKEEPER=${PHP_FPM_INSTALL_ZOOKEEPER}
          - INSTALL_SSDB=${PHP_FPM_INSTALL_SSDB}
          - INSTALL_TRADER=${PHP_FPM_INSTALL_TRADER}
          - DOWNGRADE_OPENSSL_TLS_AND_SECLEVEL=${PHP_DOWNGRADE_OPENSSL_TLS_AND_SECLEVEL}
          - PUID=${PHP_FPM_PUID}
          - PGID=${PHP_FPM_PGID}
          - IMAGEMAGICK_VERSION=${PHP_FPM_IMAGEMAGICK_VERSION}
          - LOCALE=${PHP_FPM_DEFAULT_LOCALE}
          - PHP_FPM_NEW_RELIC=${PHP_FPM_NEW_RELIC}
          - PHP_FPM_NEW_RELIC_KEY=${PHP_FPM_NEW_RELIC_KEY}
          - PHP_FPM_NEW_RELIC_APP_NAME=${PHP_FPM_NEW_RELIC_APP_NAME}
          - INSTALL_DOCKER_CLIENT=${PHP_FPM_INSTALL_DOCKER_CLIENT}
          - http_proxy
          - https_proxy
          - no_proxy
      volumes:
        - ./php-fpm/php7.4.ini:/usr/local/etc/php/php.ini（这个地方的 .ini 文件改成 7.4 的！！！）
        - ${APP_CODE_PATH_HOST}:${APP_CODE_PATH_CONTAINER}${APP_CODE_CONTAINER_FLAG}
        - docker-in-docker:/certs/client
      ports:
        - "9004:9003"
      expose:
        - "9000"
      extra_hosts:
        - "dockerhost:${DOCKER_HOST_IP}"
      environment:
        - PHP_IDE_CONFIG=${PHP_IDE_CONFIG}
        - DOCKER_HOST=tcp://docker-in-docker:2376
        - DOCKER_TLS_VERIFY=1
        - DOCKER_TLS_CERTDIR=/certs
        - DOCKER_CERT_PATH=/certs/client
        - FAKETIME=${PHP_FPM_FAKETIME}
      depends_on:
        - workspace
      networks:
        - backend
      links:
        - docker-in-docker
```

## 2、nginx 的 sites 配置
如下面的配置，要修改的地方有中文备注。
只需要修改 `fastcgi_pass` 的端口号就行。


```nginx
server {
    charset utf-8;
    client_max_body_size 128M;

    listen 80;
    listen [::]:80;

    # For https
    # listen 443 ssl;
    # listen [::]:443 ssl ipv6only=on;
    # ssl_certificate /etc/nginx/ssl/default.crt;
    # ssl_certificate_key /etc/nginx/ssl/default.key;

    server_name henkel.com;
    root /var/www/henkel-api/web;
    index index.php index.html index.htm;

    access_log /var/log/nginx/henkel_access.log;
    error_log /var/log/nginx/henkel_error.log;

    location / {
         try_files $uri $uri/ /index.php$is_args$args;
    }

    location ~ \.php$ {
        try_files $uri /index.php =404;
        fastcgi_pass php-fpm-74:9000; （修改这个地方）
        fastcgi_index index.php;
        fastcgi_buffers 16 16k;
        fastcgi_buffer_size 32k;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        #fixes timeouts
        fastcgi_read_timeout 600;
        include fastcgi_params;
    }

    location ~ /\.(ht|svn|git) {
        deny all;
    }
}
```

## 3、启动容器
```shell
#!/bin/bash

docker-compose up -d mysql redis php-fpm-74 nginx
```