// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract LendingPool {
    
    address public owner;
    uint256 public totalLiquidity;
    uint256 public interestRate;
    
    struct Deposit {
        address depositor;
        uint256 amount;
        uint256 interest;
        uint256 dueDate;
        bool active;
    }
    
    mapping (address => Deposit[]) public deposits;
    mapping (address => uint256) public balances;
    
    event DepositMade(address indexed depositor, uint256 amount);
    event DepositWithdrawn(address indexed depositor, uint256 amount);
    
    constructor() {
        owner = msg.sender;
        interestRate = 10; // 10% annual interest rate
    }
    
    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        balances[msg.sender] += msg.value;
        totalLiquidity += msg.value;
        emit DepositMade(msg.sender, msg.value);
    }
    
    function withdraw(uint256 amount) public {
        require(amount > 0, "Withdrawal amount must be greater than zero");
        require(amount <= balances[msg.sender], "Insufficient balance");
        balances[msg.sender] -= amount;
        totalLiquidity -= amount;
        payable(msg.sender).transfer(amount);
        emit DepositWithdrawn(msg.sender, amount);
    }
    
    function borrow(uint256 amount) public {
        require(amount > 0, "Borrow amount must be greater than zero");
        require(amount <= totalLiquidity, "Insufficient liquidity");
        uint256 dueDate = block.timestamp + 30 days;
        uint256 interest = amount * interestRate / 100;
        deposits[msg.sender].push(Deposit(msg.sender, amount, interest, dueDate, true));
        totalLiquidity -= amount;
        balances[msg.sender] += amount;
    }
    
    function repay(uint256 depositId) public payable {
        require(deposits[msg.sender][depositId].active, "Deposit not found or already repaid");
        require(block.timestamp <= deposits[msg.sender][depositId].dueDate, "Deposit overdue");
        uint256 amountDue = deposits[msg.sender][depositId].amount + deposits[msg.sender][depositId].interest;
        require(msg.value >= amountDue, "Insufficient repayment amount");
        deposits[msg.sender][depositId].active = false;
        totalLiquidity += deposits[msg.sender][depositId].amount;
        balances[msg.sender] -= deposits[msg.sender][depositId].amount;
        uint256 change = msg.value - amountDue;
        if (change > 0) {
            payable(msg.sender).transfer(change);
        }
    }
}


