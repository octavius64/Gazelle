#!/bin/bash

set -eo pipefail

source secrets

SECRET_NAMES=(
    GAZELLE_ENCKEY
    GAZELLE_HOST
    GAZELLE_REPORT_PASSWORD
    GAZELLE_RSS_KEY
    GAZELLE_SCHEDULE_KEY
    GAZELLE_SITE_PASSWORD
    GAZELLE_SITE_SALT
    MYSQL_PASSWORD
    MYSQL_ROOT_PASSWORD
)

ERROR_IN_SECRETS=0

for SECRET_NAME in "${SECRET_NAMES[@]}"; do
    if [[ -z "${!SECRET_NAME}" ]]; then
        echo $SECRET_NAME is empty
        ERROR_IN_SECRETS=1
    elif [[ `expr length "${!SECRET_NAME}"` -ne "32" ]]; then
        echo $SECRET_NAME must be 32 characters long
        ERROR_IN_SECRETS=1
    else
        export "$SECRET_NAME"="${!SECRET_NAME}"
    fi
done

if [[ "$ERROR_IN_SECRETS" == "1" ]]; then
    exit 1
fi

exec docker compose --project-name gazelle "$@"
