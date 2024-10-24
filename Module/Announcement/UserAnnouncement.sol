// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "Module/Announcement/IAnnouncementStrategy.sol";

contract UserAnnouncement is IAnnouncementStrategy {
    event WinningOptionAnnounced(uint256 optionIndex);

    // 公布赢的选项并返回获胜索引
    function announceWinningOption(bytes memory data) external override returns (uint256) {
        // 从 data 中解析用户输入的选项索引
        uint256 optionIndex = abi.decode(data, (uint256));

        // 触发事件
        emit WinningOptionAnnounced(optionIndex);

        // 返回用户输入的选项索引
        return optionIndex;
    }
}
