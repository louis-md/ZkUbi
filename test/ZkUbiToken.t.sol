// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ZkUbiToken} from "../src/ZkUbiToken.sol";
import {SD59x18, sd} from "@prb/math/src/SD59x18.sol";
import {UD60x18, ud} from "@prb/math/src/UD60x18.sol";

contract CounterTest is Test {
    ZkUbiToken public token;
    address public alice = address(1);
    uint256 public constant TARGET_BALANCE = 5000e18;
    uint256 public constant PERCENT_CLOSER_PER_DAY_E18 = 0.05e15;

    function setUp() public {
        token = new ZkUbiToken(TARGET_BALANCE, PERCENT_CLOSER_PER_DAY_E18);
        deal(alice, 1 ether);
        token.approveUser(alice);
    }

    function test_alice_balance_works_at_zero() public {
        vm.warp(1);
        assertEq(token.totalAmount(alice), 0);
    }

    function test_alice_balance_approaches_target_from_zero() public {
        vm.warp(1);
        uint256 aliceT0 = token.totalAmount(alice);
        assertEq(aliceT0, 0);

        vm.warp(1000 seconds);
        uint256 aliceT1000s = token.totalAmount(alice);

        vm.warp(1 days);
        uint256 aliceT1d = token.totalAmount(alice);

        vm.warp(1 weeks);
        uint256 aliceT1w = token.totalAmount(alice);

        vm.warp(365 days);
        uint256 aliceT1y = token.totalAmount(alice);

        // assertGt(aliceT1000s, aliceT0);
        assertGt(aliceT1d, aliceT1000s);
        assertGt(aliceT1w, aliceT1d);
        assertGt(aliceT1y, aliceT1w);

        assertLt(aliceT1y, TARGET_BALANCE);
    }
    
    function test_alice_can_still_get_total_balance_at_eol() public {
        vm.warp(365 * 200 days);
        uint256 aliceT = token.totalAmount(alice);
        assertGt(aliceT, 0);
        console.log("%e", aliceT);
        assertLt(TARGET_BALANCE - aliceT, 250e18); // should be pretty close at this point
    }

    function test_alice_earns_faster_with_larger_percent() public {
        vm.warp(1);
        ZkUbiToken fast_token = new ZkUbiToken(
            TARGET_BALANCE,
            PERCENT_CLOSER_PER_DAY_E18 * 2
        );
        fast_token.approveUser(alice);
        vm.warp(1000 seconds);

        uint256 alice_slow = token.totalAmount(alice);
        uint256 alice_fast = fast_token.totalAmount(alice);
        assertGt(alice_fast, alice_slow);
    }

    function test_alice_earns_faster_with_larger_target() public {
        vm.warp(1);
        ZkUbiToken fast_token = new ZkUbiToken(
            TARGET_BALANCE * 2,
            PERCENT_CLOSER_PER_DAY_E18
        );
        fast_token.approveUser(alice);
        vm.warp(1000 seconds);

        uint256 alice_slow = token.totalAmount(alice);
        uint256 alice_fast = fast_token.totalAmount(alice);
        assertGt(alice_fast, alice_slow);
    }
}
