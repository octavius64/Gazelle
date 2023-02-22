#!/bin/bash

set -eo pipefail

echo 'Generating sphinx.conf from config...'
cat /home/sphinx.conf | sed "s/<MYSQL_PASSWORD>/"$MYSQL_PASSWORD"/g" > /etc/sphinxsearch/sphinx.conf

/db_initializer_pipe/wait_db_ready.sh

echo 'Running indexer'
indexer -c /etc/sphinxsearch/sphinx.conf --all

echo 'Launching searchd'
exec /usr/bin/searchd -c /etc/sphinxsearch/sphinx.conf --console
