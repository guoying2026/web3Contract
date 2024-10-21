// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

contract ConfigCenter {
    // 函数依赖结构：存储函数名及其依赖的合约地址
    struct FunctionDependency {
        string functionName; // 函数名称
        address dependencyAddress; // 函数依赖的合约地址
    }

    // 模块结构：问题类型对应的合约地址和函数依赖合约地址映射
    struct Module {
        address contractAddress; // 问题类型对应的合约类地址
        mapping(string => address) functionDependencies; // 函数名到依赖合约地址的映射
        string[] functionNames; // 用于记录函数名称
    }

    // 存储每个问题类型及其对应的模块（模块名称和地址）
    mapping(bytes32 => Module) public questionTypeToModule;

    // 存储所有问题类型的名称及其哈希值
    mapping(bytes32 => string) public questionTypeNames;

    // 事件：当新的问题类型被添加时触发
    event QuestionTypeAdded(bytes32 indexed questionTypeHash, string questionTypeName);

    // 事件：当对应的合约地址被配置时触发
    event ModuleConfigured(bytes32 indexed questionTypeHash, address contractAddress);

    // 事件：当函数依赖配置被设置时触发
    event FunctionDependencyConfigured(
        bytes32 indexed questionTypeHash, string functionName, address dependencyAddress
    );

    // 动态添加问题类型，并生成问题类型的哈希值
    function addQuestionType(string memory questionTypeName) external returns (bytes32) {
        // 生成问题类型的哈希值
        bytes32 questionTypeHash = keccak256(abi.encodePacked(questionTypeName));

        // 存储问题类型名称和对应的哈希值
        questionTypeNames[questionTypeHash] = questionTypeName;

        // 触发事件，记录新的问题类型
        emit QuestionTypeAdded(questionTypeHash, questionTypeName);

        // 返回生成的问题类型的哈希值
        return questionTypeHash;
    }

    // 配置某个问题类型的模块（例如 "Betting" 模块）
    // @param questionTypeHash: 问题类型的哈希值
    // @param contractAddress: 问题类型对应的合约地址
    // @param dependencies: 模块函数依赖的结构体数组
    function configureModule(
        bytes32 questionTypeHash,
        address contractAddress,
        FunctionDependency[] memory dependencies
    ) external {
        // 创建或更新该问题类型的模块
        Module storage module = questionTypeToModule[questionTypeHash];
        module.contractAddress = contractAddress;

        // 存储每个函数名及其依赖的合约地址
        for (uint256 i = 0; i < dependencies.length; i++) {
            FunctionDependency memory dep = dependencies[i];
            module.functionDependencies[dep.functionName] = dep.dependencyAddress;
            module.functionNames.push(dep.functionName); // 记录函数名

            // 触发函数依赖配置事件
            emit FunctionDependencyConfigured(questionTypeHash, dep.functionName, dep.dependencyAddress);
        }

        // 触发模块配置事件
        emit ModuleConfigured(questionTypeHash, contractAddress);
    }

    // 获取某个问题类型的合约地址
    // @param questionTypeHash: 问题类型的哈希值
    // @return 返回问题类型的合约地址
    function getModuleAddress(bytes32 questionTypeHash) external view returns (address) {
        return questionTypeToModule[questionTypeHash].contractAddress;
    }

    // 获取某个问题类型的特定函数的依赖合约地址
    // @param questionTypeHash: 问题类型的哈希值
    // @param functionName: 函数的名称
    // @return 返回函数依赖的合约地址
    function getFunctionDependency(bytes32 questionTypeHash, string memory functionName)
    external
    view
    returns (address)
    {
        return questionTypeToModule[questionTypeHash].functionDependencies[functionName];
    }

    // 获取问题类型的名称
    // @param questionTypeHash: 问题类型的哈希值
    // @return 返回问题类型名称
    function getQuestionTypeName(bytes32 questionTypeHash) external view returns (string memory) {
        return questionTypeNames[questionTypeHash];
    }

    // 获取某个问题类型的所有函数依赖
    // @param questionTypeHash: 问题类型的哈希值
    // @return 返回函数名和依赖合约地址的数组
    function getFunctionDependencies(bytes32 questionTypeHash)
    external
    view
    returns (string[] memory, address[] memory)
    {
        Module storage module = questionTypeToModule[questionTypeHash];
        uint256 length = module.functionNames.length;

        // 创建数组来存储函数名和对应的合约地址
        string[] memory functionNames = new string[](length);
        address[] memory dependencyAddresses = new address[](length);

        // 填充函数名和地址
        for (uint256 i = 0; i < length; i++) {
            string memory functionName = module.functionNames[i];
            functionNames[i] = functionName;
            dependencyAddresses[i] = module.functionDependencies[functionName];
        }

        return (functionNames, dependencyAddresses);
    }
}
