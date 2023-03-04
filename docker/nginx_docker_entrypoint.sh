#!/bin/bash

set -eo pipefail

echo 'Generating config.php from config.template...'

cp /home/config.template /gazelle-config-php/config.php

sed -i "s/<GAZELLE_ENCKEY>/"$GAZELLE_ENCKEY"/g" /gazelle-config-php/config.php
sed -i "s/<GAZELLE_REPORT_PASSWORD>/"$GAZELLE_REPORT_PASSWORD"/g" /gazelle-config-php/config.php
sed -i "s/<GAZELLE_RSS_KEY>/"$GAZELLE_RSS_KEY"/g" /gazelle-config-php/config.php
sed -i "s/<GAZELLE_SCHEDULE_KEY>/"$GAZELLE_SCHEDULE_KEY"/g" /gazelle-config-php/config.php
sed -i "s/<GAZELLE_SITE_PASSWORD>/"$GAZELLE_SITE_PASSWORD"/g" /gazelle-config-php/config.php
sed -i "s/<GAZELLE_SITE_SALT>/"$GAZELLE_SITE_SALT"/g" /gazelle-config-php/config.php
sed -i "s/<MYSQL_PASSWORD>/"$MYSQL_PASSWORD"/g" /gazelle-config-php/config.php
sed -i "s/<GAZELLE_SITE_HOST>/"$GAZELLE_SITE_HOST"/g" /gazelle-config-php/config.php
sed -i "s/<OCELOT_SITE_HOST>/"$OCELOT_SITE_HOST"/g" /gazelle-config-php/config.php

if [ "$GAZELLE_DEBUG" == "1" ]; then
    sed -i "s/<DEBUG_WARNINGS>/true/g" /gazelle-config-php/config.php
    sed -i "s/<DEBUG_MODE>/true/g" /gazelle-config-php/config.php
    sed -i "s|<DEBUG_LOG_FILE_PATH>|/gazelle_log_pipe/log|g" /gazelle-config-php/config.php
else
    sed -i "s/<DEBUG_WARNINGS>/false/g" /gazelle-config-php/config.php
    sed -i "s/<DEBUG_MODE>/false/g" /gazelle-config-php/config.php
    sed -i "s|<DEBUG_LOG_FILE_PATH>|/dev/null|g" /gazelle-config-php/config.php
fi

echo 'Updating nginx conf...'
sed -i "s/<GAZELLE_SITE_HOST>/"$GAZELLE_SITE_HOST"/g" /etc/nginx/conf.d/default.conf
sed -i "s/<OCELOT_SITE_HOST>/"$OCELOT_SITE_HOST"/g" /etc/nginx/conf.d/default.conf

if [ "$(cat /home/fullchain.pem | wc -c)" == "0" ]; then
    echo 'No cert given, generating a self signed one...'
    rm /home/fullchain.pem
    rm /home/privkey.pem
    printf "US\nNY\nNY\nOctavius\nNone\noctavius\noctavius\n" | \
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /home/privkey.pem -out /home/fullchain.pem
fi

echo 'Waiting for sphinxsearch...'
while ! nc -z sphinxsearch 9306; do sleep 3; done

echo 'Starting nginx...'
exec /docker-entrypoint.sh nginx -g "daemon off;"
