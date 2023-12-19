#!/usr/bin/env bash

set -o pipefail
set +e

xmpp-alert echo "Starting extended drive test"

xmpp-alert lsblk -l -o NAME,SIZE,FSSIZE,FSUSE%,LABEL,MODEL,SERIAL

xmpp-alert smartp -t long

if [[ $? -ne 0 ]]; then
    xmpp-alert echo "ERROR: EXTENDED DRIVE TEST FAILED"
    exit 1
fi

xmpp-alert echo "EXTENDED DRIVE TEST COMPLETED SUCCESSFULLY"
