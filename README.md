# Cardano Devnet for testing Perun Channels

This sets up a private testnet including a `cardano-node` instance, a `cardano-wallet` instance with two pre-funded wallets and a `chain-index` instance.

## Preparation

### Installing Haskell

This is thoroughly explained in the [perun-cardano-contract](https://github.com/perun-network/perun-cardano-contract) repository.

### Installing the Chain-Index

First, clone the [plutus-apps](https://github.com/input-output-hk/plutus-apps) repository and checkout the tag `v0.1.0`

Inside the `plutus-apps` directory, create a file called `cabal.project.local` with the following contents:

```
package cardano-crypto-praos
  flags: -external-libsodium-vrf
optimization: 2
tests: False
```

Then, navigate to the `plutus-chain-index` directory inside `plutus-apps` and install the Chain Index:

`cabal install exe:plutus-chain-index`

### Installing other tools

Make sure you have the following tools installed:

`docker`, `docker-compose`, `date`, `jq`

## Setting up the devnet

Navigate to the `cdevnet` directory and execute `./prepare-devnet.sh`  
This sets up the configs and genesis files for the devnet. It will also tell you the start-time. **Copy the start-time for later**.

Next, execute `docker-compose up` to start the node running the devnet and the wallet server. You can watch the state of the chain using `./watch-chain.sh`

To create the wallets, execute `./create-wallets.sh`  
This will create two wallets (Alice and Bob) via the wallet server. These wallets are deterministic on devnet restart. You can find information about the wallets in the corresponding files in the `cdevnet` directory, especially the addresses and walletids might be important.

To fund the wallets, execute `./seed-devnet.sh` which adds some Ada to each wallet.

Now you can start the chain-index, using `./start-chain-index.sh`   
Note that for some reason the chain-index does not seem to sync past the genesis block (0%). We don't know the reason for this yet.

To install the perun-pab application, navigate to the `perun-cardano-contract` directory, open the `perun-pab.yaml` config and paste the start-time you received after executing `./prepare-devnet` earlier into the `scSlotZeroTime` value. Now install the `perun-pab` using 

`cabal install perun-pab`

Finally, you can start the `perun-pab` by executing first 

`sudo perun-pab --config plutus-pab.yaml migrate`

and then

`perun-pab --config plutus-pab.yaml --passphrase 0123456789 webserver`

To interact with the Perun app, use 

`cabal run perun-client`
