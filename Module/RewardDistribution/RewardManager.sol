// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface IRewardStrategy {
    function distributeReward(address token, uint256 amount, address recipient) external;
}

contract RewardManager {
    address public owner; // 管理员地址
    mapping(string => address) public rewardStrategies; // 奖励分发策略映射

    event StrategyAdded(string strategyName, address strategyAddress); // 当添加新的分发策略时触发的事件

    constructor() {
        owner = msg.sender;
    }

    // 添加奖励分发策略
    function addRewardStrategy(string memory strategyName, address strategyAddress) external {
        require(msg.sender == owner, "Only owner can add strategies");
        require(strategyAddress != address(0), "Invalid strategy address");

        rewardStrategies[strategyName] = strategyAddress;
        emit StrategyAdded(strategyName, strategyAddress);
    }

    // 根据指定策略分发奖励
    function distributeUsingStrategy(string memory strategyName, address token, uint256 amount, address recipient)
    external
    {
        address strategyAddress = rewardStrategies[strategyName];
        require(strategyAddress != address(0), "Strategy not found");

        IRewardStrategy(strategyAddress).distributeReward(token, amount, recipient);
    }
}
