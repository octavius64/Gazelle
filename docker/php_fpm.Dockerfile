FROM octavius64/php-gazelle:v1

ARG GAZELLE_DEBUG

RUN if [ "$GAZELLE_DEBUG" = "1" ]; then \
        mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini";\
    else \
        mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini";\
    fi

RUN sed -i 's/short_open_tag.*/short_open_tag = On/g' "$PHP_INI_DIR/php.ini"

COPY php_fpm_docker_entrypoint.sh /home/
RUN chmod +x /home/php_fpm_docker_entrypoint.sh

ENTRYPOINT []
CMD ["/home/php_fpm_docker_entrypoint.sh"]
