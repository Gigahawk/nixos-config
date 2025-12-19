#!/usr/bin/env bash

set -o pipefail
set +e

xmpp-alert echo "Starting drive test"

xmpp-alert lsblk -l -o NAME,SIZE,FSSIZE,FSUSE%,LABEL,MODEL,SERIAL

if ! xmpp-alert smartp; then
  xmpp-alert echo "ERROR: DRIVE TEST FAILED"
  exit 1
fi

xmpp-alert echo "DRIVE TEST COMPLETED SUCCESSFULLY"
