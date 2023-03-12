#!/bin/bash

echo "Setting up /gazelle_log_pipe/log"
mkfifo /gazelle_log_pipe/log
chmod 666 /gazelle_log_pipe/log

# Keeping a file descriptor open on this named pipe will prevent the reader
# from getting an EOF every time PHP closes the file
exec 3> /gazelle_log_pipe/log

function schedule_runner() {
    echo "Starting schedule_runner loop..."
    # Initial sleep because the DB might not be ready yet. Also it's a low
    # priority task, so no need to run it at the very beginning and overload things.
    sleep 60
    while true; do
        echo "Running schedule.php"
        php /var/www/html/schedule.php $GAZELLE_SCHEDULE_KEY
        echo "Exit status for schedule.php: $?"
        sleep 600
    done
}

function peerupdate_runner() {
    echo "Starting peerupdate_runner loop..."
    # Offset initial sleep from schedule_runner to not overload the server
    # by running 2 tasks at the same time.
    sleep 30
    while true; do
        echo "Running peerupdate.php"
        php /var/www/html/peerupdate.php $GAZELLE_SCHEDULE_KEY
        echo "Exit status for peerupdate.php: $?"
        sleep 600
    done
}

schedule_runner &
peerupdate_runner &

echo "Starting php-fpm"
exec docker-php-entrypoint php-fpm
