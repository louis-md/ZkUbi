// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ZkUbiToken} from "../src/ZkUbiToken.sol";
import {SD59x18, sd} from "@prb/math/src/SD59x18.sol";
import {UD60x18, ud} from "@prb/math/src/UD60x18.sol";

contract CounterTest is Test {
    ZkUbiToken public token;
    address public alice = address(1);

    function setUp() public {
        token = new ZkUbiToken(5000e18, 0.05e11);
        deal(alice, 1 ether);
        token.approveUser(alice);
    }

    function test_alice_balance_approaches_target() public {
        vm.warp(365 days);
        console.log("%e", token.totalAmount(alice));
        vm.warp(2 * 365 days);
        console.log("%e", token.totalAmount(alice));
        vm.warp(3 * 365 days);
        console.log("%e", token.totalAmount(alice));
    }
}
