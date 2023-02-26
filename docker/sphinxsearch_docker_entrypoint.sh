#!/bin/bash

set -eo pipefail

echo 'Generating sphinx.conf from config...'
cat /home/sphinx.conf | sed "s/<MYSQL_PASSWORD>/"$MYSQL_PASSWORD"/g" > /etc/sphinxsearch/sphinx.conf

function rotate_indices() {
    while ! nc -z 127.0.0.1 9306; do sleep 3; done
    sleep 1
    echo 'The server is online, rotating indexes now...'
    indexer -c /etc/sphinxsearch/sphinx.conf --rotate --all
}

bash /home/wait_db_ready.sh

if [ "$(ls /var/lib/sphinxsearch/*.sph | wc -l)" == "0" ]; then
    echo 'No indexes present, creating them now'
    indexer -c /etc/sphinxsearch/sphinx.conf --all
else
    echo 'Indexes already present, will rotate them soon...'
    rotate_indices &
fi

echo 'Launching searchd'
exec /usr/bin/searchd -c /etc/sphinxsearch/sphinx.conf --console --pidfile
