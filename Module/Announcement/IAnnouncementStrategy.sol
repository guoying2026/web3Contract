// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface IAnnouncementStrategy {
    function announceWinningOption(bytes memory data) external returns (uint256);
}