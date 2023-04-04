// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract DeFiBank {
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;
    address public owner;
    uint256 public totalDeposits;
    uint256 public interestRate;
    uint256 public interestInterval;
    uint256 public lastInterestPaid;

    constructor() {
        owner = msg.sender;
    }
//any account can deposite the ethers
    function deposit() public payable {
        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
    }
//any account can withdraw the eters
    function withdraw(uint256 _amount) public {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        balances[msg.sender] -= _amount;
        totalDeposits -= _amount;
        payable(msg.sender).transfer(_amount);
    }
// transfer the ether to another address
    function transfer(address _to, uint256 _amount) public {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
    }
//function to apporove the other account
    function approve(address _spender, uint256 _amount) public {
        allowances[msg.sender][_spender] = _amount;
    }
// function to transfer the ethrs 
    function transferFrom(address _from, address _to, uint256 _amount) public {
        require(balances[_from] >= _amount, "Insufficient balance");
        require(allowances[_from][msg.sender] >= _amount, "Allowance exceeded");
        balances[_from] -= _amount;
        balances[_to] += _amount;
        allowances[_from][msg.sender] -= _amount;
    }
// function to set the intrest rate
    function setInterestRate(uint256 _interestRate) public {
        require(msg.sender == owner, "Only owner can set interest rate");
        interestRate = _interestRate;
    }
// function to set the intrest interval
    function setInterestInterval(uint256 _interestInterval) public {
        require(msg.sender == owner, "Only owner can set interest interval");
        interestInterval = _interestInterval;
    }
//function for paying the intrest
    function payInterest() public {
        require(block.timestamp >= lastInterestPaid + interestInterval, "Not enough time passed since last interest payment");
        uint256 interest = (totalDeposits * interestRate) / 1 ether;
        balances[owner] += interest;
        totalDeposits += interest;
        lastInterestPaid = block.timestamp;
    }
}
