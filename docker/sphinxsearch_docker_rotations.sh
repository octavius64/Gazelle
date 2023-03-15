#!/bin/bash

# There are 2 index rotations: cheap and expensive.
# cheap rotation runs every minute, and the expensive one runs every 12 hours.

function cheap_rotation_loop() {
    while ! nc -z 127.0.0.1 9306; do sleep 3; done
    echo 'The server is online, starting the cheap rotation loop...'
    sleep 10
    while true; do
        echo "cheap rotation"
        indexer -c /etc/sphinxsearch/sphinx.conf --rotate delta requests_delta log_delta > /dev/null
        echo "cheap rotation exit code: $?"
        sleep 60
    done
}

ROTATE_TIMESTAMP_FILE=/var/lib/sphinxsearch/gazelle_rotate_timestamp

# If this file does not exist, that means this volume is new and we just created a new index
if [ ! -f "$ROTATE_TIMESTAMP_FILE" ]; then
    date +%s > "$ROTATE_TIMESTAMP_FILE"
fi

function expensive_rotation_loop() {
    while ! nc -z 127.0.0.1 9306; do sleep 3; done
    echo 'The server is online, starting the expensive rotation loop...'
    sleep 60
    while true; do
        expr "(" $(date +%s) - $(cat "$ROTATE_TIMESTAMP_FILE") ")" ">" 43200 > /dev/null
        if [ "$?" == "0" ]; then
            echo "expensive rotation"
            date +%s > "$ROTATE_TIMESTAMP_FILE"
            indexer -c /etc/sphinxsearch/sphinx.conf --rotate --all > /dev/null
            echo "expensive rotation exit code: $?"
        fi
        sleep 60
    done
}

cheap_rotation_loop &
expensive_rotation_loop &

# Never exit
while true; do
    sleep 1000
done
