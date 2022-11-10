#!/usr/bin/env bash

# Prepare a "devnet" directory holding credentials, a dummy topology and
# "up-to-date" genesis files. If the directory exists, it is wiped out.
set -e

BASEDIR=$(realpath .)
TARGETDIR="devnet"
STARTTIME=$(date +%s)
SYSTEMSTART=$(date -u +%FT%TZ)
NODE_SOCKET_PATH="$(pwd)/$TARGETDIR/ipc/node.socket"
PROTOCOL_PARAMS_PATH="$(pwd)/$TARGETDIR/pparams.json"

[ -d "$TARGETDIR" ] && { echo "Cleaning up directory $TARGETDIR" ; sudo rm -r $TARGETDIR ; }

cp -af "$BASEDIR/config/devnet/" "$TARGETDIR"
cp -af "$BASEDIR/config/credentials" "$TARGETDIR"
mkdir $TARGETDIR/wallet-db
echo '{"Producers": []}' > "$TARGETDIR/topology.json"
sed -i "s/\"startTime\": [0-9]*/\"startTime\": $STARTTIME/" "$TARGETDIR/genesis-byron.json" && \
sed -i "s/\"scSlotZeroTime\": [0-9]*/\"scSlotZeroTime\": ${STARTTIME}000/" "$TARGETDIR/pci-config.json" && \
sed -i "s/scSlotZeroTime: [0-9]*/scSlotZeroTime: ${STARTTIME}000/" "$TARGETDIR/perun-pab.yaml" && \
sed -i "s+pscSocketPath: .*+pscSocketPath: ${NODE_SOCKET_PATH}+" "$TARGETDIR/perun-pab.yaml" && \
sed -i "s+pscProtocolParametersJsonPath: .*+pscProtocolParametersJsonPath: ${PROTOCOL_PARAMS_PATH}+" "$TARGETDIR/perun-pab.yaml" && \
sed -i "s/\"systemStart\": \".*\"/\"systemStart\": \"$SYSTEMSTART\"/" "$TARGETDIR/genesis-shelley.json"

find $TARGETDIR -type f -exec chmod 0400 {} \;
mkdir "$TARGETDIR/ipc"
echo "Prepared devnet, you can start the cluster now"
echo "The start-time is $STARTTIME" 
