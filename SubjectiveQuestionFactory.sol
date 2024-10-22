// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "SubjectiveQuestion.sol";

interface IQuestionFactory {
    function createQuestion(
        string memory _question,
        string[] memory _betOptions,
        string[] memory functionNames,
        address[] memory dependencyAddresses
    ) external returns (address);
}

// 工厂合约，用来创建 SubjectiveQuestion 实例
contract SubjectiveQuestionFactory is IQuestionFactory {
    // 创建一个新的 SubjectiveQuestion 合约实例
    function createQuestion(
        string memory _question,
        string[] memory _betOptions,
        string[] memory functionNames,
        address[] memory dependencyAddresses
    ) external returns (address) {
        SubjectiveQuestion newQuestion = new SubjectiveQuestion();

        // 调用初始化函数
        newQuestion.initialize(msg.sender, _question, _betOptions, functionNames, dependencyAddresses);

        return address(newQuestion);
    }
}