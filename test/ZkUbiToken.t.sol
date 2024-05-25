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
        token = new ZkUbiToken("Zk Ubi", "zkUbi", 5000e18, 0.05e11);
        deal(alice, 1 ether);
        token.approveUser(alice);
    }

    function test_alice_balance_approaches_target() public {
        vm.warp(365 days);
        uint256 balance1 = token.totalAmount(alice);
        vm.warp(2 * 365 days);
        uint256 balance2 = token.totalAmount(alice);
        vm.warp(3 * 365 days);
        uint256 balance3 = token.totalAmount(alice);
        assertLt(balance1, balance2);
        assertLt(balance2, balance3);
    }

    function test_erc20_transfer() public {
        vm.startPrank(alice);
        vm.expectRevert();
        token.transfer(address(this), 100e18);
        vm.warp(365 days);
        token.transfer(address(this), 100e18);
        assertGt(token.balanceOf(address(this)), token.balanceOf(alice));
    }
}
