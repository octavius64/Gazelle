#!/bin/bash

set -eo pipefail

echo 'Generating config.php from config.template...'
cat /home/config.template | \
    sed "s/<GAZELLE_ENCKEY>/"$GAZELLE_ENCKEY"/g" | \
    sed "s/<GAZELLE_REPORT_PASSWORD>/"$GAZELLE_REPORT_PASSWORD"/g" | \
    sed "s/<GAZELLE_RSS_KEY>/"$GAZELLE_RSS_KEY"/g" | \
    sed "s/<GAZELLE_SCHEDULE_KEY>/"$GAZELLE_SCHEDULE_KEY"/g" | \
    sed "s/<GAZELLE_SITE_PASSWORD>/"$GAZELLE_SITE_PASSWORD"/g" | \
    sed "s/<GAZELLE_SITE_SALT>/"$GAZELLE_SITE_SALT"/g" | \
    sed "s/<MYSQL_PASSWORD>/"$MYSQL_PASSWORD"/g" > \
    /gazelle-config-php/config.php

mv /gazelle-config-php/config.php /home/config.template
if [ "$GAZELLE_DEBUG" == "1" ]; then
    cat /home/config.template | \
        sed "s/<DEBUG_WARNINGS>/true/g" | \
        sed "s/<DEBUG_MODE>/true/g" | \
        sed "s|<DEBUG_LOG_FILE_PATH>|/gazelle_log_pipe/log|g" > \
        /gazelle-config-php/config.php
else
    cat /home/config.template | \
        sed "s/<DEBUG_WARNINGS>/false/g" | \
        sed "s/<DEBUG_MODE>/false/g" | \
        sed "s|<DEBUG_LOG_FILE_PATH>|/dev/null|g" > \
        /gazelle-config-php/config.php
fi

rm /home/config.template

echo 'Waiting for sphinxsearch...'
while ! nc -z sphinxsearch 9306; do sleep 3; done

echo 'Starting nginx...'
exec /docker-entrypoint.sh nginx -g "daemon off;"
