#!/bin/bash

set -eo pipefail

echo 'Generating sphinx.conf from config...'
cat /home/sphinx.conf | sed "s/<MYSQL_PASSWORD>/"$MYSQL_PASSWORD"/g" > /etc/sphinxsearch/sphinx.conf

bash /home/wait_db_ready.sh

if [ "$(ls /var/lib/sphinxsearch/*.sph | wc -l)" == "0" ]; then
    echo 'No indexes present, creating them now'
    indexer -c /etc/sphinxsearch/sphinx.conf --all
else
    echo 'Indexes already present, skipping init'
fi

/home/sphinxsearch_docker_rotations.sh &

echo 'Launching searchd'
exec /usr/bin/searchd -c /etc/sphinxsearch/sphinx.conf --console --pidfile
