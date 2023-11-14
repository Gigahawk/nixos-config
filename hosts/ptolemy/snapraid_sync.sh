#!/usr/bin/env bash

set -o pipefail
set +e

echo "Syncing SnapRAID array"

snapraid sync 2>&1 | tee /tmp/snapraid_sync.log

if [[ $? -ne 0 ]]; then
    echo "Error: sync failed, sending alert email"
    echo -e \
    "Content-Type: text/plain\r\nSubject: Snapraid Sync Fail\r\n\r\n\
    $(cat /tmp/snapraid_sync.log)" | sendmail jasperchan515@gmail.com
    exit 1
fi

echo "Scrubbing SnapRAID array"

snapraid scrub 2>&1 | tee /tmp/snapraid_scrub.log

if [[ $? -ne 0 ]]; then
    echo "Error: scrub failed, sending alert email"
    echo -e \
    "Content-Type: text/plain\r\nSubject: Snapraid Scrub Fail\r\n\r\n\
    $(cat /tmp/snapraid_scrub.log)" | sendmail jasperchan515@gmail.com
    exit 1
fi

echo "Sync complete, sending alert email"
echo -e \
"Content-Type: text/plain\r\nSubject: Snapraid Sync Pass\r\n\r\n\
Snapraid scrub logs:\r\n$(cat /tmp/snapraid_scrub.log)\r\n\r\n\
Snapraid sync logs:\r\n$(cat /tmp/snapraid_sync.log)" | sendmail jasperchan515@gmail.com
