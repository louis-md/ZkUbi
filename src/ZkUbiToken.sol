// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import { SD59x18 } from "prb-math/src/SD59x18.sol";
import { UD60x18 } from "@prb/math/src/UD60x18.sol";

contract ZkToken {
    // Variables
    uint256 public k; // Rate of addition per unit time (e.g., per day)
    uint256 public decayConstant; // Half-life period in the same time units as rate of addition

    mapping(address user => uint256) balances;
    mapping(address user => uint256 timestamp) lastUpdate;

    constructor(uint256 tokensPerSecond, uint256 percentLossPerYearE18) {
        k = tokensPerSecond;
        decayConstant = calculateDecayConstant(percentLossPerYearE18);
    }

    // Function to calculate the decay constant (lambda) given a percentage loss per year
    function calculateDecayConstant(
        uint256 percentLossPerYearE18
    ) public pure returns (uint256) {
        // Convert the percentage loss per year to a decimal
        uint256 p = percentLossPerYearE18; 

        // Calculate 1 - p
        uint256 oneMinusP = (10 ** 18 - p);

        // Calculate the natural logarithm of (1 - p) using a series approximation or a predefined library
        int256 lnOneMinusP = ln(oneMinusP); // Assuming ln() returns value in 18 decimal format

        // Since Solidity does not support floating point arithmetic, we'll keep precision using integers
        uint256 lambda = uint256(-lnOneMinusP);

        return lambda;
    }

    // Function to calculate natural logarithm using a series approximation (Taylor series or other method)
    // This is a placeholder function, and a real implementation would be needed for accurate results
    function ln(uint256 x) public pure returns (int256) {
        // Placeholder implementation of natural logarithm
        // Use a series approximation or a mathematical library for accurate results
        // Example using a simple Taylor series expansion (not accurate for all ranges)
        int256 result = 0;
        uint256 num = 1;

        while (num < 20) {
            int256 sign = num % 2 == 0 ? int8(1) : int8(-1);
            // Increase for better accuracy
            result += sign * int256(((x - 1e18) ** num) / num );
            num++;
        }
        return result;
    }

    function approveUser(address user) public {
        balances[user] = 0;
        lastUpdate[user] = block.timestamp;
    }

    // Function to calculate the total amount at time t
    function totalAmount(address account) public view returns (uint256) {
        uint256 N0 = balances[account];
        uint256 lambda = decayConstant;
        uint256 timeElapsed = block.timestamp - lastUpdate[account];

        uint256 decayPart = N0 * expNeg(lambda * timeElapsed);
        uint256 additionPart = (((k * 1e5) / lambda) *
            (1e5 - expNeg(lambda * timeElapsed))) / 1e5;

        return decayPart + additionPart;
    }

    // Helper function to calculate e^(-x) using a series expansion approximation
    function expNeg(uint256 x) internal pure returns (uint256) {
        // Taylor series expansion for e^(-x) = 1 - x + x^2/2! - x^3/3! + ...
        uint256 sum = 1e5; // 1 * 1e5 to maintain precision
        uint256 term = 1e5; // First term is 1 * 1e5

        for (uint8 i = 1; i < 10; i++) {
            term = (term * x) / (i * 1e5);
            sum -= term;
        }
        return sum;
    }

    // Function to get the current total amount
    function currentTotalAmount(address account) public view returns (uint256) {
        return totalAmount(account);
    }
}
