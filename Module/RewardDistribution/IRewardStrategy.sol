// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface IRewardStrategy {
    function distributeReward(address token, uint256 amount, address recipient) external;
}