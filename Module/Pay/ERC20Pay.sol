// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "Module/Pay/IPay.sol";

// 确保导入或定义 IERC20 接口
interface IERC20 {
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract ERC20Pay is IPay {
    function pay(address from, address to, address token, uint256 amount) external override {
        // 检查转账金额是否大于0
        require(amount > 0, "Amount must be greater than 0");

        // 检查用户余额是否足够
        uint256 balance = IERC20(token).balanceOf(from);
        require(balance >= amount, "Insufficient token balance");

        // 检查用户授权额度是否足够
        uint256 allowance = IERC20(token).allowance(from, address(this));
        require(allowance >= amount, "Insufficient allowance for transfer");

        // 执行代币转账，检查是否成功
        bool success = IERC20(token).transferFrom(from, to, amount);
        require(success, "Token transfer failed");
    }
}
