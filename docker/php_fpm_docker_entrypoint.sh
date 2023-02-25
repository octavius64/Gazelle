#!/bin/sh

echo "Setting up /gazelle_log_pipe/log"
mkfifo /gazelle_log_pipe/log
chmod 666 /gazelle_log_pipe/log

# Keeping a file descriptor open on this named pipe will prevent the reader
# from getting an EOF every time PHP closes the file
exec 3> /gazelle_log_pipe/log

echo "Starting php-fpm"
exec docker-php-entrypoint php-fpm
