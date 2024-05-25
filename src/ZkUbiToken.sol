// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import {SD59x18, sd} from "@prb/math/src/SD59x18.sol";
import {UD60x18, ud, convert as udconvert} from "@prb/math/src/UD60x18.sol";
import {console} from "forge-std/Test.sol";

contract ZkUbiToken {
    uint256 public targetBalance;
    uint256 public percentCloserPerDayE18;

    // Variables
    UD60x18 public k; // Rate of addition per unit time (e.g., per day)
    UD60x18 public decayConstant; // Half-life period in the same time units as rate of addition

    mapping(address user => uint256) balances;
    mapping(address user => uint256 timestamp) lastUpdate;

    constructor(uint256 _targetBalance, uint256 _percentCloserPerDayE18) {
        targetBalance = _targetBalance;
        percentCloserPerDayE18 = _percentCloserPerDayE18;
    }

    function approveUser(address user) public {
        balances[user] = 0;
        lastUpdate[user] = block.timestamp;
    }

    // Function to calculate the total amount at time t
    function totalAmount(address account) public view returns (uint256) {
        uint256 N0 = balances[account];
        uint256 timeElapsed = block.timestamp - lastUpdate[account];
        if (timeElapsed == 0) {
            return N0;
        }
        bool goingUp = N0 < targetBalance;
        uint256 distanceToGo = goingUp
            ? targetBalance - N0
            : N0 - targetBalance;

        UD60x18 percentToShrinkPerDayE18 = ud(1e18) - ud(percentCloserPerDayE18);

        UD60x18 nDays = udconvert(timeElapsed) / udconvert(1 days);
        UD60x18 percentCloserNow =
            percentToShrinkPerDayE18
            .pow(nDays);

        UD60x18 newDistance = ud(distanceToGo).mul(percentCloserNow);

        return
            goingUp
                ? targetBalance - newDistance.intoUint256()
                : targetBalance + newDistance.intoUint256();
    }

    // Function to get the current total amount
    function currentTotalAmount(address account) public view returns (uint256) {
        return totalAmount(account);
    }
}
