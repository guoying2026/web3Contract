// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";  // 使用 OpenZeppelin 的 Ownable 合约

interface IPay {
    function pay(address from, address to, address token, uint256 amount) external;
}

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract TokenManager is Ownable {
    // 支持的支付处理器映射 (token 地址 => 支付处理器地址)
    mapping(address => address) public paymentHandlers;

    // 事件：记录添加支付处理器
    event PaymentHandlerAdded(address token, address handler);

    // 事件：记录支付成功
    event PaymentProcessed(address from, address to, address token, uint256 amount);

    // 添加支付处理器（仅限管理员调用）
    function addPaymentHandler(address token, address handler) external onlyOwner {
        require(handler != address(0), "Invalid handler address");
        paymentHandlers[token] = handler;

        // 触发事件
        emit PaymentHandlerAdded(token, handler);
    }

    // 支付函数
    function pay(address from, address to, address token, uint256 amount) external {
        address handler = paymentHandlers[token];
        require(handler != address(0), "Payment handler not found");

        // 调用处理器的 pay 函数
        IPay paymentHandler = IPay(handler);
        paymentHandler.pay(from, to, token, amount);

        // 触发事件
        emit PaymentProcessed(from, to, token, amount);
    }
}
