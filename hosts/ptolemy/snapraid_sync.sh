#!/usr/bin/env bash

set -o pipefail
set +e

xmpp-alert echo "Syncing SnapRAID array"

xmpp-alert snapraid sync

if [[ $? -ne 0 ]]; then
    xmpp-alert echo "ERROR: SYNC FAILED"
    exit 1
fi

xmpp-alert echo "Scrubbing SnapRAID array"

xmpp-alert snapraid scrub

if [[ $? -ne 0 ]]; then
    xmpp-alert echo "ERROR: SCRUB FAILED"
    exit 1
fi

xmpp-alert echo "Sync complete"
