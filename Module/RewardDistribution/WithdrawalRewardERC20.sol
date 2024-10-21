// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

// 引入 IERC20 接口，用于调用 ERC20 代币的 transfer 方法
interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}

interface IRewardStrategy {
    function distributeReward(address token, uint256 amount, address recipient) external;
}

contract withdrawalRewardERC20 is IRewardStrategy {
    function distributeReward(address token, uint256 amount, address recipient) external override {
        require(amount > 0, "No reward to distribute");
        IERC20(token).transfer(recipient, amount);
    }
}
