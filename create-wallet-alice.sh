#!/usr/bin/env bash

curl -X POST http://localhost:8090/v2/wallets \
-d "$(cat ./w-alice.json)" \
-H "Content-Type: application/json"

