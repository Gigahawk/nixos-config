#!/usr/bin/env bash

set -o pipefail
set +e

xmpp-alert echo "Starting extended drive test"

xmpp-alert lsblk -l -o NAME,SIZE,FSSIZE,FSUSE%,LABEL,MODEL,SERIAL

if ! xmpp-alert smartp -t long; then
  xmpp-alert echo "ERROR: EXTENDED DRIVE TEST FAILED"
  exit 1
fi

xmpp-alert echo "EXTENDED DRIVE TEST COMPLETED SUCCESSFULLY"
