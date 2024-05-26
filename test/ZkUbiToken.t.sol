// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ZkUbiToken} from "../src/ZkUbiToken.sol";
import {ETHBerlinTicketValidator} from "../src/ETHBerlinTicketValidator.sol";
import {SD59x18, sd} from "@prb/math/src/SD59x18.sol";
import {UD60x18, ud} from "@prb/math/src/UD60x18.sol";
import {Solarray} from "../lib/solarray/src/Solarray.sol";

contract CounterTest is Test, ETHBerlinTicketValidator {
    ZkUbiToken public token;
    address public alice = address(1);
    uint256 public constant TARGET_BALANCE = 5000e18;
    uint256 public constant PERCENT_CLOSER_PER_DAY_E18 = 0.05e15;

    function makeLegitProof() public pure returns ( ProofArgs memory ) {
uint256[][] memory _pb = new uint256[][](2);
_pb[0] = Solarray.uint256s(
            4269171868699686351997104177918724918403813719230430606796770690205626652810, 10299669899260070753143712055893325767683751130535362038716882993299416151771);
            _pb[1] = Solarray.uint256s( 4511140433750937370312031283746442094241945034101459390715252937091195756201, 8773233091987590793205385307779054840731201670648285183010967978540735659671);
    ProofArgs calldata ETHTicket1 = ProofArgs({
        _pA: Solarray.uint256s(4467093033559842922465645304888238964657327569023994300949316867333103894321, 15829763550633220576203790558902714359192019883219691222287393381879742778249),
        _pb: _pb,
       
        _pc: Solarray.uint256s(16783742207230598747856876962989466931021288358561364185757831231769875049620, 21444346333869189335412868753460449983732846558509809089770445514950369149640),
        _pubSignals: Solarray.uint256s(21888242871839275222246405745257275088548364400416034343698204186575808495616, 111560146890584288369567824893314450802, 306575440601642857491888074988475892684, 21888242871839275222246405745257275088548364400416034343698204186575808495616, 21888242871839275222246405745257275088548364400416034343698204186575808495616, 21888242871839275222246405745257275088548364400416034343698204186575808495616, 21888242871839275222246405745257275088548364400416034343698204186575808495616, 21888242871839275222246405745257275088548364400416034343698204186575808495616, 21888242871839275222246405745257275088548364400416034343698204186575808495616, 63954201399831292932599197935019682410099566786308050100311021299852214440, 21888242871839275222246405745257275088548364400416034343698204186575808495616, 21888242871839275222246405745257275088548364400416034343698204186575808495616, 14805218201037874193584061752697414132103356971759018136201926162397367701016, 13908133709081944902758389525983124100292637002438232157513257158004852609027, 7654374482676219729919246464135900991450848628968334062174564799457623790084, 111560146890584288369567824893314450802, 21888242871839275222246405745257275088548364400416034343698204186575808495616, 21888242871839275222246405745257275088548364400416034343698204186575808495616, 21888242871839275222246405745257275088548364400416034343698204186575808495616, 21888242871839275222246405745257275088548364400416034343698204186575808495616, 21888242871839275222246405745257275088548364400416034343698204186575808495616, 21888242871839275222246405745257275088548364400416034343698204186575808495616, 21888242871839275222246405745257275088548364400416034343698204186575808495616, 21888242871839275222246405745257275088548364400416034343698204186575808495616, 21888242871839275222246405745257275088548364400416034343698204186575808495616, 21888242871839275222246405745257275088548364400416034343698204186575808495616, 21888242871839275222246405745257275088548364400416034343698204186575808495616, 21888242871839275222246405745257275088548364400416034343698204186575808495616, 21888242871839275222246405745257275088548364400416034343698204186575808495616, 21888242871839275222246405745257275088548364400416034343698204186575808495616, 21888242871839275222246405745257275088548364400416034343698204186575808495616, 21888242871839275222246405745257275088548364400416034343698204186575808495616, 21888242871839275222246405745257275088548364400416034343698204186575808495616, 21888242871839275222246405745257275088548364400416034343698204186575808495616, 21888242871839275222246405745257275088548364400416034343698204186575808495616, 1, 720999590401511008612783530177585267514664088210, 720999590401511008612783530177585267514664088210)
    });
    return ETHTicket1;
    }

    function setUp() public {
        vm.warp(1);
        token = new ZkUbiToken("Zk Ubi", "zkUbi", TARGET_BALANCE, PERCENT_CLOSER_PER_DAY_E18);
        deal(alice, 1 ether);
        token.grantUbi(alice);
    }

    function test_alice_balance_works_at_zero() public {
        vm.warp(1);
        assertEq(token.balanceOf(alice), 0);
    }

    function test_nonUbiReceiver_balance_always_at_zero() public {
        vm.warp(1);
        assertEq(token.balanceOf(address(this)), 0, "t1s");
        vm.warp(1 days);
        assertEq(token.balanceOf(address(this)), 0, "t1d");
        vm.warp(1 weeks);
        assertEq(token.balanceOf(address(this)), 0, "t1w");
        vm.warp(365 days);
        assertEq(token.balanceOf(address(this)), 0, "t1y");
    }

    function test_alice_balance_approaches_target_from_zero() public {
        uint256 aliceT0 = token.balanceOf(alice);
        assertEq(aliceT0, 0, "should be 0");

        vm.warp(1000 seconds);
        uint256 aliceT1000s = token.balanceOf(alice);

        vm.warp(1 days);
        uint256 aliceT1d = token.balanceOf(alice);

        vm.warp(1 weeks);
        uint256 aliceT1w = token.balanceOf(alice);

        vm.warp(365 days);

        uint256 aliceT1y = token.balanceOf(alice);

        // assertGt(aliceT1000s, aliceT0);
        assertGt(aliceT1d, aliceT1000s);
        assertGt(aliceT1w, aliceT1d);
        assertGt(aliceT1y, aliceT1w);

        assertLt(aliceT1y, TARGET_BALANCE);
    }

    function test_alice_can_still_get_total_balance_at_eol() public {
        vm.warp(365 * 200 days);
        uint256 aliceT = token.balanceOf(alice);
        assertGt(aliceT, 0);
        console.log("%e", aliceT);
        assertLt(TARGET_BALANCE - aliceT, 250e18); // should be pretty close at this point
    }

    function test_alice_earns_faster_with_larger_percent() public {
        vm.warp(1);
        ZkUbiToken fast_token = new ZkUbiToken("Zk Ubi", "zkUbi", TARGET_BALANCE, PERCENT_CLOSER_PER_DAY_E18 * 2);
        fast_token.grantUbi(alice);
        vm.warp(1000 seconds);

        uint256 alice_slow = token.balanceOf(alice);
        uint256 alice_fast = fast_token.balanceOf(alice);
        assertGt(alice_fast, alice_slow);
    }

    function test_alice_earns_faster_with_larger_target() public {
        vm.warp(1);
        ZkUbiToken fast_token = new ZkUbiToken("Zk Ubi", "zkUbi", TARGET_BALANCE * 2, PERCENT_CLOSER_PER_DAY_E18);
        fast_token.grantUbi(alice);
        vm.warp(1000 seconds);

        uint256 alice_slow = token.balanceOf(alice);
        uint256 alice_fast = fast_token.balanceOf(alice);
        assertGt(alice_fast, alice_slow);

        uint256 balance1 = token.balanceOf(alice);
        vm.warp(2 * 365 days);
        uint256 balance2 = token.balanceOf(alice);
        vm.warp(3 * 365 days);
        uint256 balance3 = token.balanceOf(alice);
        assertLt(balance1, balance2);
        assertLt(balance2, balance3);
    }

    function test_nonUbiReceiver_decreases_balance_then_becomes_ubiReceiver() public {
        vm.warp(365 days);
        vm.prank(alice);
        token.transfer(address(this), 10e18);

        assertEq(token.balanceOf(address(this)), 10e18, "balance(this) should be 10e18");

        uint256 balance1 = token.balanceOf(address(this));
        vm.warp(2 * 365 days);
        uint256 balance2 = token.balanceOf(address(this));
        assertGt(balance1, balance2, "balance should decrease");

        token.grantUbi(address(this));

        vm.warp(3 * 365 days);
        uint256 balance3 = token.balanceOf(address(this));
        assertLt(balance2, balance3, "balance should increase");
    }

    function test_erc20_transfer() public {
        vm.startPrank(alice);
        vm.expectRevert();
        token.transfer(address(this), 100e18);
        vm.warp(2 * 365 days);
        token.transfer(address(this), 100e18);
        assertGt(token.balanceOf(address(this)), token.balanceOf(alice));
    }

    function test_erc20_transferFrom() public {
        vm.expectRevert();
        token.transferFrom(alice, address(this), 100e18);
        vm.warp(2 * 365 days);
        vm.expectRevert();
        token.transferFrom(alice, address(this), 100e18);
        vm.prank(alice);
        token.approve(address(this), 100e18);
        token.transferFrom(alice, address(this), 100e18);
        assertGt(token.balanceOf(address(this)), token.balanceOf(alice));
    }
}
