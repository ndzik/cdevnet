#!/bin/bash

watch sudo docker compose exec cardano-node cardano-cli query utxo --testnet-magic 42  --whole-utxo
