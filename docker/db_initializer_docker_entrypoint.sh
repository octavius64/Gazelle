#!/bin/bash

echo 'Trying to connect to the DB to see if it is online'

echo 'use sys;' | mysql -u root -p --host="$MYSQL_HOST" --password="$MYSQL_ROOT_PASSWORD"
while [ $? -ne 0 ]; do
    echo 'MySQL not online yet, waiting for it...'
    echo 'use sys;' | mysql -u root -p --host="$MYSQL_HOST" --password="$MYSQL_ROOT_PASSWORD"
    sleep 5
done

set -eo pipefail

# Now that MySQL is online, check if it already has the DB
NUM_TABLES=`echo 'use gazelle; show tables;' | mysql -u root -p --host="$MYSQL_HOST" --password="$MYSQL_ROOT_PASSWORD" | wc -l`

echo Found $NUM_TABLES tables in gazelle

if [ "$NUM_TABLES" == "0" ]; then
    echo 'DB is empty, populating it now'...
    echo 'drop database gazelle;' | mysql -u root -p --host="$MYSQL_HOST" --password="$MYSQL_ROOT_PASSWORD"
    cat gazelle.sql | mysql -u root -p --host="$MYSQL_HOST" --password="$MYSQL_ROOT_PASSWORD"
fi

echo 'DB is now ready!'

set +e
set +o pipefail

echo 'Setting up the named pipe to signal that the DB is ready'
mkfifo /db_initializer_pipe/db_ready
chmod 777 /db_initializer_pipe/db_ready
while true
do
    yes > /db_initializer_pipe/db_ready
done
