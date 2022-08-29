#!/usr/bin/env bash

# Prepare a "devnet" directory holding credentials, a dummy topology and
# "up-to-date" genesis files. If the directory exists, it is wiped out.
set -e

BASEDIR=$(realpath .)
TARGETDIR="devnet"

[ -d "$TARGETDIR" ] && { echo "Cleaning up directory $TARGETDIR" ; sudo rm -r $TARGETDIR ; }

cp -af "$BASEDIR/config/devnet/" "$TARGETDIR"
cp -af "$BASEDIR/config/credentials" "$TARGETDIR"
echo '{"Producers": []}' > "$TARGETDIR/topology.json"
sed -i "s/\"startTime\": [0-9]*/\"startTime\": $(date +%s)/" "$TARGETDIR/genesis-byron.json" && \
sed -i "s/\"systemStart\": \".*\"/\"systemStart\": \"$(date -u +%FT%TZ)\"/" "$TARGETDIR/genesis-shelley.json"

find $TARGETDIR -type f -exec chmod 0400 {} \;
mkdir "$TARGETDIR/ipc"
echo "Prepared devnet, you can start the cluster now"

