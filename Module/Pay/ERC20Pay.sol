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

    // 定义事件来记录传入参数和其他信息
    event LogPay(address indexed from, address indexed to, address indexed token, uint256 amount);

    function pay(address from, address to, address token, uint256 amount) external override {
        // 通过事件记录传入参数
        emit LogPay(from, to, token, amount);
        
        //有效防止误将代币发送到零地址而无法找回的情况。
        require(to != address(0), "Invalid address: zero address");

        // 检查转账金额是否大于0
        require(amount > 0, "Amount must be greater than 0");

        // 检查用户余额是否足够
        uint256 balance = IERC20(token).balanceOf(from);
        require(balance >= amount, "Insufficient token balance");

        // 检查用户授权额度是否足够，改为检查对 `to` 地址的授权
        uint256 allowance = IERC20(token).allowance(from, address(this));
        require(allowance >= amount, "Insufficient allowance for transfer");

        // 执行代币转账，检查是否成功
        bool success = IERC20(token).transferFrom(from, to, amount);
        require(success, "Token transfer failed");
    }
}
