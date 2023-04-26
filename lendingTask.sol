// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
contract Lending{
    address public owner;
    address public Borrower;
    uint public totLiquidity;
    uint public interestRate;
    uint interestPaid;
    uint Amount;

//struct
    struct Deposit { 
        address borrower;// the one who applying for loan
        uint256 amount;// amount of loan
        uint256 interest; //interest rate
        uint256 dueDate;// date of loan to be paid
        bool active; // to check loan is still active
    }

    mapping (address => Deposit[]) public _borrowersDetails;// mapping for Deposit[] struct with address to track the borrowers details
    mapping (address => uint256) public _balances; // mapping of address to uint to track the balances of a particular account

constructor(address _borrower,uint _amount){
    owner=msg.sender; // deployer will be the owner
    interestRate=10; // 10% annual interest rate
    Borrower=_borrower;
    Amount=_amount;
}

//function for depositing the lending amount to the pool
function fundDepositeByLender() public payable { //payable because dealing with ethers
 require(msg.value > 0,"Deposit amount should be greater than 0"); // amount should not be zero
 _balances[msg.sender] += msg.value; // msg.value will be added to balances mapping so we can fetch the balance of an address
 totLiquidity += msg.value; // totalLiquidity balnce will also increase
}

//function to borrowing amount by borrower
function borrow(uint amount) public {
 require(amount > 0,"Deposited amount should be greater than 0"); //amount should not be zero
 require (amount <= totLiquidity,"Insufficient liquidity");// amount should not be greater than the total Liquidity
 uint dueDate = block.timestamp + 365 days; //for due date that is yearly
 uint256 interest = amount * interestRate / 100; //formula for interest rate
_borrowersDetails[msg.sender].push(Deposit(msg.sender, amount, interest, dueDate, true)); // pushing details to the _borrowersDetails
 totLiquidity -= amount;// amount will deduct from the totLiquidity
_balances[msg.sender] += amount; //amount will added to the borrowers address
}

//Lender can withdraw the amount paid by the borrower
function Withdraw(uint amount) public view {
require(msg.sender==owner,"sorry,only owner allowed to withdraw");//this function is ccalled only by the owner
require(amount > 0,"amount should be greater than zero");//amount should not be zero

}

//borrower can repay the lended amount
function repay(uint id,uint amount) public payable  {
  require(_borrowersDetails[msg.sender][id].active, "Deposit not found or already repaid"); // checking due is paid or unpaid
  require(block.timestamp <= _borrowersDetails[msg.sender][id].dueDate, "Deposit overdue");// checking overdue time
  require(msg.sender==Borrower,"you are not the borrower");
  require(msg.value==amount,"please enter the exact amount");
}

// borrower will repay the lended amount with interest

    function repayInterest() public payable {
        require(msg.sender == Borrower, "Only borrower can repay interest");
        uint interestOwend = Amount * interestRate / 100 - interestPaid;
        require(msg.value <= interestOwend, "Amount paid exceeds interest owed");
        interestPaid += msg.value;
    
 }
 //function is to calculate the interest amount owed at any point in time.
    function interestOwed() public view returns (uint) {
        return Amount* interestRate / 100- interestPaid ; // formula
    }
 
}







