// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface IPay {
    function pay(address from, address to, address token, uint256 amount) external;
}