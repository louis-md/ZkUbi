// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./helpers/WithFileHelpers.s.sol";
import {ZkUbiToken} from "src/ZkUbiToken.sol";

/// @dev holds action like deploying the system and creating some traction for testnet
contract Deploy is Script, WithFileHelpers {
    // Config
    uint256 public constant TARGET_BALANCE = 5000e18;
    uint256 public constant PERCENT_CLOSER_PER_DAY_E18 = 0.05e15;

    function setUp() public {
        setNetwork("sepolia");
    }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PK");
        vm.startBroadcast(deployerPrivateKey);

        // deploy the ZkUbiToken
        ZkUbiToken zkUbiToken = new ZkUbiToken("Zk Ubi", "zkUbi", TARGET_BALANCE, PERCENT_CLOSER_PER_DAY_E18);

        vm.stopBroadcast();

        _writeJson("zkUbiToken", address(zkUbiToken));
    }
}
