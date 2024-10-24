// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// 创建一个模拟的 USDT 代币合约
contract MockUSDT is ERC20, Ownable {
    constructor() ERC20("Mock USDT", "mUSDT") Ownable(msg.sender) {
        // 初始化合约时，铸造 100 万个 USDT 给部署者
        _mint(msg.sender, 1000000 * (10 ** decimals()));
    }

    // 铸造函数：可以让合约所有者生成新的 USDT 代币
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
