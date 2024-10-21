// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface IAnnouncementStrategy {
    function announceWinningOption(uint256 optionIndex) external;
}

contract AnnouncementManager {
    address public owner; // 管理员地址
    mapping(string => address) public announcementMethods; // 公告方式映射

    event MethodAdded(string methodName, address methodAddress); // 当添加新的公告方式时触发的事件

    constructor() {
        owner = msg.sender;
    }

    // 添加公告方式
    function addAnnouncementMethod(string memory methodName, address methodAddress) external {
        require(msg.sender == owner, "Only owner can add methods");
        require(methodAddress != address(0), "Invalid method address");

        announcementMethods[methodName] = methodAddress;
        emit MethodAdded(methodName, methodAddress);
    }

    // 根据指定方式公布赢的选项
    function announceUsingMethod(string memory methodName, uint256 optionIndex) external {
        address methodAddress = announcementMethods[methodName];
        require(methodAddress != address(0), "Method not found");

        IAnnouncementStrategy(methodAddress).announceWinningOption(optionIndex);
    }
}
