// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {ERC20} from "./ERC20.sol";
import {SD59x18, sd} from "@prb/math/src/SD59x18.sol";
import {UD60x18, ud, convert as udconvert} from "@prb/math/src/UD60x18.sol";
import {console} from "forge-std/Test.sol";

contract ZkUbiToken is ERC20 {
    event UpdatedBalance(address indexed account, uint256 balance);
    event ApprovedUser(address indexed user);

    uint256 public ubiTargetBalance;
    uint256 public percentCloserPerDayE18;

    // Variables
    UD60x18 public k; // Rate of addition per unit time (e.g., per day)
    UD60x18 public decayConstant; // Half-life period in the same time units as rate of addition

    mapping(address user => uint256 timestamp) lastUpdate;
    mapping(address user => bool) isUbiReceiver;

    constructor(string memory _name, string memory _symbol, uint256 _ubiTargetBalance, uint256 _percentCloserPerDayE18)
        ERC20(_name, _symbol)
    {
        ubiTargetBalance = _ubiTargetBalance;
        percentCloserPerDayE18 = _percentCloserPerDayE18;
    }

    /**
     * @notice Overwrite of balanceOf. Returns balance including the virtual approximation to the target balance.
     * @param account The address to check the balance of.
     */
    function balanceOf(address account) public view override returns (uint256) {
        if (lastUpdate[account] == 0) {
            return 0;
        }

        uint256 currentBalance = _balances[account];
        uint256 timeElapsed = block.timestamp - lastUpdate[account];
        if (timeElapsed == 0) {
            return currentBalance;
        }
        // Target balance is zero for non UBI receivers and
        uint256 _targetBalance = isUbiReceiver[account] ? ubiTargetBalance : 0;

        bool goingUp = currentBalance < _targetBalance;
        uint256 distanceToGo = goingUp ? _targetBalance - currentBalance : currentBalance - _targetBalance;

        UD60x18 percentToShrinkPerDayE18 = ud(1e18) - ud(percentCloserPerDayE18);

        UD60x18 nDays = udconvert(timeElapsed) / udconvert(1 days);
        UD60x18 percentCloserNow = percentToShrinkPerDayE18.pow(nDays);

        UD60x18 newDistance = ud(distanceToGo).mul(percentCloserNow);

        return goingUp ? _targetBalance - newDistance.intoUint256() : _targetBalance + newDistance.intoUint256();
    }

    function approveUser(address user) public {
        _updateBalance(user);
        isUbiReceiver[user] = true;
        emit ApprovedUser(user);
    }

    function _updateBalance(address account) internal {
        _balances[account] = balanceOf(account);
        lastUpdate[account] = block.timestamp;

        emit UpdatedBalance(account, _balances[account]);
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        _updateBalance(to);
        address owner = _msgSender();
        _updateBalance(owner);
        _transfer(owner, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        _updateBalance(from);
        _updateBalance(to);

        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }
}
