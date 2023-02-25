FROM php:8.1-fpm

COPY external/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions memcache mcrypt gd mysqli

# Pick dev or prod config here
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

RUN sed -i 's/short_open_tag.*/short_open_tag = On/g' "$PHP_INI_DIR/php.ini"

COPY php_fpm_docker_entrypoint.sh /home/
RUN chmod +x /home/php_fpm_docker_entrypoint.sh

ENTRYPOINT []
CMD /home/php_fpm_docker_entrypoint.sh
