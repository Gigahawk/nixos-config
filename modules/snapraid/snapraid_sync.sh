#!/usr/bin/env bash

set -o pipefail
set +e

xmpp-alert echo "Syncing SnapRAID array"

# Hopefully this won't come back to bite me, postgres seems to always
# leave behind zero files even when stopped regularly?
if ! xmpp-alert snapraid sync --force-zero; then
  xmpp-alert echo "ERROR: SYNC FAILED"
  exit 1
fi

xmpp-alert echo "Scrubbing SnapRAID array"

if ! xmpp-alert snapraid scrub; then
  xmpp-alert echo "ERROR: SCRUB FAILED"
  exit 1
fi

xmpp-alert echo "SYNC COMPLETED SUCCESSFULLY"
