#!/bin/sh

GAZELLE_LOG_PIPE="/gazelle_log_pipe/log"

while [ ! -e "$GAZELLE_LOG_PIPE" ]; do
    echo "Waiting for "$GAZELLE_LOG_PIPE" ..."
    sleep 3
done

while true; do
    cat "$GAZELLE_LOG_PIPE"
    echo ""$GAZELLE_LOG_PIPE" EOF, re-opening..."
done
