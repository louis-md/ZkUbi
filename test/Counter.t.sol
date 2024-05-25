// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ZkToken} from "../src/ZkUbiToken.sol";

contract CounterTest is Test {
    ZkToken public token;
    address public alice = address(1);

    function setUp() public {
        token = new ZkToken(1e18, 0.05e18);
        deal(alice, 1 ether);
        token.approveUser(alice);
    }

    function test_ln_fn() public {
        assertEq(token.ln(1e18), 0);
        assertEq(token.ln(2e18), 693147180559945309);
        assertEq(token.ln(3e18), 109861228866748869);
    }

    function test_decay_constant() public {
        console.log('%e', token.decayConstant());
        ZkToken token2 = new ZkToken(100, 0.5e18);
        console.log('%e', token2.decayConstant());
    }

    function test_alice_balance_approaches() public {
        vm.warp(100);
        console.log(token.totalAmount(alice));
        // uint256 expectedAliceBalanceAtInfinity = 100 / token.decayConstant()
    }
}
