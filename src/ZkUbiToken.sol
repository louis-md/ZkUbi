// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract ZkToken {
    // Variables
    uint256 public k; // Rate of addition per unit time (e.g., per day)
    uint256 public T; // Half-life period in the same time units as rate of addition

    mapping(address user => uint256) balances;
    mapping(address user => uint256 timestamp) lastUpdate;

    constructor(uint256 _N0, uint256 _k, uint256 _T) {
        k = _k;
        T = _T;
    }

    // Function to calculate the decay constant
    function decayConstant() internal view returns (uint256) {
        return (693147 / T); // Approximation of ln(2) * 1e5 / T to avoid floating point operations
    }

    // Function to calculate the total amount at time t
    function totalAmount(address account) public view returns (uint256) {
        uint256 N0 = balances[account];
        uint256 lambda = decayConstant();
        uint256 timeElapsed = block.timestamp - lastUpdate[account];

        uint256 decayPart = N0 * expNeg(lambda * timeElapsed);
        uint256 additionPart = (k * 1e5 / lambda) * (1e5 - expNeg(lambda * timeElapsed)) / 1e5;

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
