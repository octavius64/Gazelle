FROM php:8.1-fpm

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions \
    /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions memcache mcrypt gd mysqli

RUN apt-get update && apt-get install -y procps && apt purge -y --auto-remove
