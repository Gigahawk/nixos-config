#!/bin/bash

BACKUP_DIR="/home/inventree/backup"
MEDIA_DIR="/home/inventree/data/media"
BACKUP_FILE="$BACKUP_DIR/data.json"

echo "Initializing backup repo"
cd $BACKUP_DIR
git init
git config --global --add safe.directory $BACKUP_DIR
git config --global user.name "Inventree Backup"
git config --global user.email "inventreebackup@local"
git config --global init.defaultBranch master

while true; do
    t=$(date +%s)
    echo "running backup"
    dt=$(date '+%d/%m/%Y %H:%M:%S')
    # Delete file first otherwise export-records will hang
    echo "Exporting database records"
    rm -f "$BACKUP_FILE"
    invoke export-records -f "$BACKUP_FILE"
    echo "Copying media folder"
    cp -r "$MEDIA_DIR" .
    echo "Committing"
    git add "$BACKUP_FILE"
    git add "$(basename $MEDIA_DIR)"
    git commit -m "backup: create backup at ${dt}"
    echo "Backup complete"
    sleep 60
done