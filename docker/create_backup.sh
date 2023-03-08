#!/bin/bash

set -eo pipefail

if [ "$(id -u)" != "0" ]; then
    echo "You must be root!"
    exit 1
fi

cd "$(dirname "$0")"
BACKUP_NAME=gazelle_backup_$(uuidgen)

echo tar mysql_data...
tar --numeric-owner -cf mysql_data.tar mysql_data

echo copying all files into "$BACKUP_NAME"...
mkdir "$BACKUP_NAME"
mv mysql_data.tar "$BACKUP_NAME"
cp secrets config whitelist_ips.txt "$BACKUP_NAME"
echo "Git commit:" > "$BACKUP_NAME/git_version_info"
echo "$(git rev-parse HEAD)" >> "$BACKUP_NAME/git_version_info"
echo "Current time:" >> "$BACKUP_NAME/git_version_info"
echo "$(date)" >> "$BACKUP_NAME/git_version_info"

echo compressing everything...
tar -czf "$BACKUP_NAME.tar.gz" "$BACKUP_NAME"

echo removing the backup folder...
rm -rf "$BACKUP_NAME"

echo Created backup: "$BACKUP_NAME.tar.gz"
