#!/bin/sh

# The named pipe will have data once the DB is ready.

DB_READY_PIPE=/db_initializer_pipe/db_ready

echo 'Waiting for the DB to come online...'

while [ ! -e "$DB_READY_PIPE" ]
do
    sleep 1
done

cat "$DB_READY_PIPE" | fold -w 1 | head -n1
