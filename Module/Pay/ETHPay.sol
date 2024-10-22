// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "Module/Pay/IPay.sol";

contract ETHPay is IPay {
    function pay(address from, address to, address /*token*/, uint256 amount) external override {
        require(amount > 0, "Amount must be greater than 0");
        require(from.balance >= amount, "Insufficient balance");

        // 发送 ETH 代币
        (bool success, ) = to.call{value: amount}("");
        require(success, "Payment failed");
    }
}
