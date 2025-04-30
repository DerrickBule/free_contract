// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Bank {
    // 管理员地址
    address public admin;
    // 记录每个地址的存款金额
    mapping(address => uint256) public balances;
    // 记录存款金额前 3 名用户
    address[3] public top3Depositors;

    // 构造函数，初始化管理员为合约部署者
    constructor() {
        admin = msg.sender;
    }

    // 接收以太币的函数，允许直接向合约地址存款
    receive() external payable {
        balances[msg.sender] += msg.value;
        updateTop3Depositors(msg.sender);
    }

    // 提取资金的方法，仅管理员可以调用
    function withdraw() external onlyAdmin {
        payable(admin).transfer(address(this).balance);
    }

    // 更新存款金额前 3 名用户的函数
    function updateTop3Depositors(address depositor) internal {
        // 检查 depositor 是否已经在 top3Depositors 中
        bool isInTop3 = false;
        for (uint256 i = 0; i < 3; i++) {
            if (top3Depositors[i] == depositor) {
                isInTop3 = true;
                break;
            }
        }

        if (!isInTop3) {
            // 找到第一个空位
            for (uint256 i = 0; i < 3; i++) {
                if (top3Depositors[i] == address(0)) {
                    top3Depositors[i] = depositor;
                    sortTop3Depositors();
                    return;
                }
            }

            // 检查是否需要替换最后一名
            if (balances[depositor] > balances[top3Depositors[2]]) {
                top3Depositors[2] = depositor;
                sortTop3Depositors();
            }
        } else {
            sortTop3Depositors();
        }
    }

    // 对 top3Depositors 按存款金额从大到小排序
    function sortTop3Depositors() internal {
        for (uint256 i = 0; i < 2; i++) {
            for (uint256 j = i + 1; j < 3; j++) {
                if (balances[top3Depositors[i]] < balances[top3Depositors[j]]) {
                    address temp = top3Depositors[i];
                    top3Depositors[i] = top3Depositors[j];
                    top3Depositors[j] = temp;
                }
            }
        }
    }

    // 仅管理员修饰器
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }
}