#!/bin/bash

set -eo pipefail

# Arg 1 - file which contains IP addresses
function print_nginx_whitelist() {
    CONTENTS=$(cat "$1" | { grep -P '^\s*\d' || test $? = 1; } | perl -pe "s/\s*(\d\S+)\s*/allow \1;\n/g")
    if [ "$CONTENTS" != "" ]; then
        echo "$CONTENTS"
        echo 'deny all;'
    fi
}

# Arg 1 - file which contains IP addresses
function print_php_whitelist() {
    cat "$1" | { grep -P '^\s*\d' || test $? = 1; } | perl -pe "s/\s*(\d\S+)\s*/'\1',/g"
}

# Arg 1 - file to do the replacement in
# Arg 2 - file which contains the IP addresses
# Arg 3 - output file
# Arg 4 - function to use to output the whitelist 
function populate_ip_whitelist() {
    IP_WHITELIST_LINE=$(grep -n "<ALLOWED_PROXY_SUBNETS>" "$1" | cut -f1 -d:)
    IP_WHITELIST_LINE_BEFORE=$(expr "$IP_WHITELIST_LINE" - 1)
    IP_WHITELIST_LINE_AFTER=$(expr "$IP_WHITELIST_LINE" + 1)

    head -n"$IP_WHITELIST_LINE_BEFORE" "$1" > "$3"
    "$4" "$2" >> "$3"
    tail --lines=+"$IP_WHITELIST_LINE_AFTER" "$1" >> "$3"
}

echo 'Generating config.php from config.template...'
populate_ip_whitelist /home/config.template /home/whitelist_ips.txt \
    /gazelle-config-php/config.php print_php_whitelist

sed -i "s/<GAZELLE_ENCKEY>/"$GAZELLE_ENCKEY"/g" /gazelle-config-php/config.php
sed -i "s/<GAZELLE_REPORT_PASSWORD>/"$GAZELLE_REPORT_PASSWORD"/g" /gazelle-config-php/config.php
sed -i "s/<GAZELLE_RSS_KEY>/"$GAZELLE_RSS_KEY"/g" /gazelle-config-php/config.php
sed -i "s/<GAZELLE_SCHEDULE_KEY>/"$GAZELLE_SCHEDULE_KEY"/g" /gazelle-config-php/config.php
sed -i "s/<GAZELLE_SITE_PASSWORD>/"$GAZELLE_SITE_PASSWORD"/g" /gazelle-config-php/config.php
sed -i "s/<GAZELLE_SITE_SALT>/"$GAZELLE_SITE_SALT"/g" /gazelle-config-php/config.php
sed -i "s/<MYSQL_PASSWORD>/"$MYSQL_PASSWORD"/g" /gazelle-config-php/config.php
sed -i "s/<GAZELLE_SITE_HOST>/"$GAZELLE_SITE_HOST"/g" /gazelle-config-php/config.php

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
populate_ip_whitelist /home/nginx.conf /home/whitelist_ips.txt \
    /etc/nginx/conf.d/default.conf print_nginx_whitelist
sed -i "s/<GAZELLE_SITE_HOST>/"$GAZELLE_SITE_HOST"/g" /etc/nginx/conf.d/default.conf

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
