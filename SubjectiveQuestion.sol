// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "Module/Pay/IPay.sol";
import "Module/RewardDistribution/IRewardStrategy.sol";
import "Module/Announcement/IAnnouncementStrategy.sol";

contract SubjectiveQuestion {
    // 具体问题
    string public question;
    address public creator;

    // 定义每个投注选项的数据结构
    struct BetOption {
        string name; // 投注选项名称，例如 "Option A"
        uint256 totalBetAmount; // 该选项的总投注金额
    }

    // 投注选项数组
    BetOption[] public betOptions;

    // 用户 => 代币 => 下注金额
    mapping(address => mapping(address => uint256)) public bets;

    // 定义事件：记录下注信息
    event BetPlaced(address indexed bettor, uint256 optionIndex, address indexed token, uint256 amount);

    // 定义事件：公布正确选项时触发
    event WinningOptionRevealed(uint256 indexed optionIndex);

    // 定义事件：记录奖励分发
    event RewardDistributed(address indexed recipient, address indexed token, uint256 amount);

    // 存储函数依赖映射
    mapping(string => address) public functionDependencies;

    bool public isRevealed; // 是否已公布赢的选项
    uint256 public winningOption; // 赢的选项索引

    function initialize(
        address _creator,
        string memory _question,
        string[] memory _betOptions,
        string[] memory functionNames,
        address[] memory dependencyAddresses
    ) external {
        require(creator == address(0), "Already initialized");
        creator = _creator;
        question = _question;
        isRevealed = false;

        for (uint256 i = 0; i < _betOptions.length; i++) {
            betOptions.push(BetOption({name: _betOptions[i], totalBetAmount: 0}));
        }

        for (uint256 i = 0; i < functionNames.length; i++) {
            functionDependencies[functionNames[i]] = dependencyAddresses[i];
        }
    }

    // 用户下注到特定选项
    function placeBet(uint256 optionIndex, address token, uint256 amount) external {
        require(optionIndex < betOptions.length, "Invalid bet option");
        require(amount > 0, "Bet amount must be greater than 0");
        require(!isRevealed, "Winning option has already been revealed");

        address IPayAddress = functionDependencies["IPay"];
        require(IPayAddress != address(0), "IPay not configured");

        IPay ipay = IPay(IPayAddress);

        // 通过 pay 函数将资金转入当前问题合约
        ipay.pay(msg.sender, address(this), token, amount);

        // 更新选项的总投注金额
        betOptions[optionIndex].totalBetAmount += amount;

        // 更新用户的投注记录
        bets[msg.sender][token] += amount;

        // 触发事件，记录下注信息
        emit BetPlaced(msg.sender, optionIndex, token, amount);
    }

    // 公布赢的选项（仅限创建者调用）
    function revealWinningOption(uint256 optionIndex) external {
        require(optionIndex < betOptions.length, "Invalid option index");
        require(!isRevealed, "Winning option has already been revealed");

        winningOption = optionIndex;

        // 调用公告合约（通过依赖注入）
        address announcementAddress = functionDependencies["IAnnouncementStrategy"];
        require(announcementAddress != address(0), "AnnouncementAddress not configured");

        IAnnouncementStrategy announcement = IAnnouncementStrategy(announcementAddress);
        announcement.announceWinningOption(optionIndex);

        // 触发事件，记录公布的选项
        emit WinningOptionRevealed(optionIndex);

        isRevealed = true;
    }

    // 奖金分发
    function distributeReward(address token, uint256 amount, address recipient) external {
        require(isRevealed, "Winning option has not been revealed yet"); // 判断是否已公布结果
        require(bets[recipient][token] >= amount, "Not enough bet amount");
        bets[recipient][token] -= amount;

        address rewardStrategyAddress = functionDependencies["IRewardStrategy"];
        require(rewardStrategyAddress != address(0), "rewardStrategyAddress not configured");

        IRewardStrategy irewardStrategy = IRewardStrategy(rewardStrategyAddress);
        irewardStrategy.distributeReward(token, amount, recipient);
    }

    // 设置新的函数依赖
    function setFunctionDependency(string memory functionName, address newDependencyAddress) external {
        require(msg.sender == creator, "Only creator can set function dependencies");
        functionDependencies[functionName] = newDependencyAddress;
    }

    function getEtherBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getTokenBalance(address tokenAddress) external view returns (uint256) {
        IERC20 token = IERC20(tokenAddress);
        return token.balanceOf(address(this));
    }
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}
