#!/usr/bin/env bash

# Seed a "devnet" by distributing some Ada to commit and also some marked as
# "fuel" for the Hydra Head.
set -eo pipefail

SCRIPT_DIR=$(realpath $(dirname $(realpath $0)))
NETWORK_ID=42

CCLI_PATH=
DEVNET_DIR=/data
if [[ -n ${1} ]] && $(${1} version > /dev/null); then
    CCLI_PATH=${1}
    echo >&2 "Using provided cardano-cli"
    DEVNET_DIR=${SCRIPT_DIR}/devnet
fi

# Invoke cardano-cli in running cardano-node container or via provided cardano-cli
function ccli() {
  ccli_ ${@} --testnet-magic ${NETWORK_ID}
}
function ccli_() {
  if [[ -x ${CCLI_PATH} ]]; then
      cardano-cli ${@}
  else
      docker-compose exec cardano-node cardano-cli ${@}
  fi
}

function seedAddr() {
    AMOUNT=${1}
    ADDR=${2}
    ACTOR=${3}
    echo >&2 "Seeding a UTXO from faucet to ${ADDR} with ${AMOUNT}Ł"

    # Determine faucet address and just the **first** txin addressed to it
    FAUCET_ADDR=$(ccli address build --payment-verification-key-file ${DEVNET_DIR}/credentials/faucet.vk)
    FAUCET_TXIN=$(ccli query utxo --address ${FAUCET_ADDR} --out-file /dev/stdout | jq -r 'keys[0]')

    ccli transaction build --babbage-era --cardano-mode \
        --change-address ${FAUCET_ADDR} \
        --tx-in ${FAUCET_TXIN} \
        --tx-out ${ADDR}+${AMOUNT} \
        --out-file ${DEVNET_DIR}/seed-${ACTOR}.draft >&2
    ccli transaction sign \
        --tx-body-file ${DEVNET_DIR}/seed-${ACTOR}.draft \
        --signing-key-file ${DEVNET_DIR}/credentials/faucet.sk \
        --out-file ${DEVNET_DIR}/seed-${ACTOR}.signed >&2
    SEED_TXID=$(ccli_ transaction txid --tx-file ${DEVNET_DIR}/seed-${ACTOR}.signed | tr -d '\r')
    SEED_TXIN="${SEED_TXID}#0"
    ccli transaction submit --tx-file ${DEVNET_DIR}/seed-${ACTOR}.signed >&2

    echo -n >&2 "Waiting for utxo ${SEED_TXIN}.."

    while [[ "$(ccli query utxo --tx-in "${SEED_TXIN}" --out-file /dev/stdout | jq ".\"${SEED_TXIN}\"")" = "null" ]]; do
        sleep 1
        echo -n >&2 "."
    done
    echo >&2 "Done"
}

seedAddr 420133769 "addr_test1qztsvp5a9eyz69sjehcx95xjlxanmvq6kp600slwkaqme4942h69cylfad4g5cec9g0jqc2a4m4w3nrxw3hnluwc9gjqsqct8a" "alice"
seedAddr 420133769 "addr_test1qz6s5sm2uqprg0fse8wafpsg5ylquw9k0pdywysusr85tl75964jffqeqy3r7p7xx9x8t9pl3l6xlv2mznwpyh7allqsngkfvy" "bob"
