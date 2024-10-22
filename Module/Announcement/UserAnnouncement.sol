// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "Module/Announcement/IAnnouncementStrategy.sol";

contract UserAnnouncement is IAnnouncementStrategy {
    address public owner; // 管理员地址

    event WinningOptionAnnounced(uint256 optionIndex); // 当赢的选项被公布时触发

    constructor() {
        owner = msg.sender;
    }

    // 公布赢的选项
    function announceWinningOption(uint256 optionIndex) external override {
        require(msg.sender == owner, "Only owner can announce the winning option");

        emit WinningOptionAnnounced(optionIndex);
    }
}
