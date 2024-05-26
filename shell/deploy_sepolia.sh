#!/bin/bash

# To load the variables in the .env file
source .env

# Set balance of deployer to 1 ETH
cast rpc anvil_setBalance 0xfBA76DB02CF2460172d508d2adC61cc24eC90Dd4 1000000000000000000

# To deploy and verify our contract
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast -vvvv --verify
