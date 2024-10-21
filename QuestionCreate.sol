// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface IQuestionFactory {
    function createQuestion(
        string memory _question,
        string[] memory _betOptions,
        string[] memory functionNames,
        address[] memory dependencyAddresses
    ) external returns (address);
}

contract QuestionCreate {
    address public owner; // 工厂合约的拥有者
    address public configCenter; // 配置中心合约地址

    // 事件：当问题合约被创建时触发
    event QuestionCreated(address questionContract, address creator, string question);

    // 存储所有问题的映射 (问题 => 问题合约地址)
    mapping(string => address) public questionToContract;

    // 存储所有问题的列表
    string[] public allQuestions;

    // 构造函数，初始化配置中心地址
    // @param _configCenter: 配置中心合约的地址
    constructor(address _configCenter) {
        owner = msg.sender;
        configCenter = _configCenter;
    }

    // 创建问题合约，并通过配置中心获取该问题类型的模块
    function createQuestion(
        string memory _question,
        bytes32 questionTypeHash, // 传入问题类型的哈希值
        string[] memory _betOptions // 投注选项数组
    ) external returns (address) {
        require(_betOptions.length >= 2, "Must have at least two bet options");

        // 从配置中心获取问题类型的合约地址
        address questionContractAddress = _getModuleAddress(questionTypeHash);
        require(questionContractAddress != address(0), "Invalid question contract address");

        // 获取配置中心中的函数依赖
        (bool success, bytes memory dependenciesData) =
                            configCenter.call(abi.encodeWithSignature("getFunctionDependencies(bytes32)", questionTypeHash));
        require(success, "Failed to get function dependencies from ConfigCenter");

        (string[] memory functionNames, address[] memory dependencyAddresses) =
                            abi.decode(dependenciesData, (string[], address[]));

        // 通过工厂接口创建新问题合约
        IQuestionFactory factory = IQuestionFactory(questionContractAddress);
        address newQuestionContract = factory.createQuestion(_question, _betOptions, functionNames, dependencyAddresses);

        // 存储问题和对应的合约地址
        questionToContract[_question] = newQuestionContract;
        allQuestions.push(_question);

        emit QuestionCreated(newQuestionContract, msg.sender, _question);
        return newQuestionContract;
    }

    // 从配置中心获取问题类型的模块地址
    function _getModuleAddress(bytes32 questionTypeHash) internal returns (address) {
        (bool success, bytes memory moduleData) =
                            configCenter.call(abi.encodeWithSignature("getModuleAddress(bytes32)", questionTypeHash));
        require(success, "Failed to get module address from ConfigCenter");

        return abi.decode(moduleData, (address));
    }

    // 获取所有问题及其对应的合约地址
    function getAllQuestions() external view returns (string[] memory, address[] memory) {
        uint256 length = allQuestions.length;
        address[] memory addresses = new address[](length);

        // 将所有问题的合约地址填充到地址数组中
        for (uint256 i = 0; i < length; i++) {
            addresses[i] = questionToContract[allQuestions[i]];
        }

        return (allQuestions, addresses);
    }
}
