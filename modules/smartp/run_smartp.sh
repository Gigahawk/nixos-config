#!/usr/bin/env bash

set -o pipefail
set +e

xmpp-alert echo "Starting drive test"

xmpp-alert lsblk -l -o NAME,SIZE,FSSIZE,FSUSE%,LABEL,MODEL,SERIAL

xmpp-alert smartp

if [[ $? -ne 0 ]]; then
    xmpp-alert echo "ERROR: DRIVE TEST FAILED"
    exit 1
fi

xmpp-alert echo "DRIVE TEST COMPLETED SUCCESSFULLY"
