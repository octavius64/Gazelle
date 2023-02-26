#!/bin/bash

set -eo pipefail

if [[ "$(stat -c '%u:%g' secrets)" != "0:0" ]]; then
    echo "The secrets file must be owned by root for better security"
    exit 1
fi

SECRETS_PERMS=$(stat -c '%a' secrets)

if [[ "$SECRETS_PERMS" != "000" ]] && [[ "$SECRETS_PERMS" != "400" ]] && [[ "$SECRETS_PERMS" != "600" ]]; then
    echo "The secrets file permissions are too open. 600 or stricter is allowed."
    exit 1
fi

source secrets

SECRET_NAMES=(
    GAZELLE_ENCKEY
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

source config

CONFIG_NAMES=(
    GAZELLE_DEBUG
)

ERROR_IN_CONFIG=0

for CONFIG_NAME in "${CONFIG_NAMES[@]}"; do
    if [[ -z "${!CONFIG_NAME}" ]]; then
        echo $CONFIG_NAME is empty
        ERROR_IN_CONFIG=1
    else
        export "$CONFIG_NAME"="${!CONFIG_NAME}"
    fi
done

if [[ "$GAZELLE_DEBUG" != "1" ]] && [[ "$GAZELLE_DEBUG" != "0" ]]; then
    echo GAZELLE_DEBUG can be 0 or 1
    ERROR_IN_CONFIG=1
fi

if [[ "$ERROR_IN_CONFIG" == "1" ]]; then
    exit 1
fi

exec docker compose --project-name gazelle -f docker-compose.yml "$@"
