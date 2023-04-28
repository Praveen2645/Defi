// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
contract Lending{
    //variables
    address payable  public lender;
    address payable  public Borrower;
    uint public totLiquidity;
    uint public interestRate;
    uint public interestPaid;
    uint Amount;// amount of loan to be borrowed
    uint public timePeriod;// loan time period eg: 1year
    bool public isRepayed;
    uint public startDate;

//struct
    struct Deposit { 
        address borrower;// the one who applying for loan
        uint amount;// amount of loan
        uint interest; //interest rate
        uint dueDate;// date of loan to be paid
        bool active; // to check loan is still active
    }
//mappings
    mapping (address => Deposit[]) public _borrowersDetails;// mapping for Deposit[] struct with address to track the borrowers details
    mapping (address => uint256) public _balances; // mapping of address to uint to track the balances of a particular account

constructor(uint _amount){
    lender=payable(msg.sender); // deployer will be the owner
    interestRate=10; // 10% annual interest rate
    Amount=_amount;
    //timePeriod=_time;
    isRepayed=false;
    startDate = block.timestamp;
}

//function for depositing the lending amount to the pool
function fundDeposite() public payable { //payable because dealing with ethers
 require(msg.value > 0,"Deposit amount should be greater than 0"); // amount should not be zero
 _balances[msg.sender] += msg.value; // msg.value will be added to balances mapping so we can fetch the balance of an address
 totLiquidity += msg.value; // totalLiquidity balnce will also increase
}

//function to borrowing amount by borrower
 function borrow(uint _amount) public   {
 require(_amount > 0,"Deposited amount should be greater than 0"); //amount should not be zero
 require (_amount <= totLiquidity,"Insufficient fund in the contract");// amount should not be greater than the total Liquidity
 require(_amount==Amount,"Enter exact amount you want to borrow");
 uint dueDate = block.timestamp + 365 days; //for due date that is yearly
 uint256 interest = _amount * interestRate / 100; //formula for interest rate
_borrowersDetails[msg.sender].push(Deposit(msg.sender, _amount, interest, dueDate,true)); // pushing details to the _borrowersDetails
 totLiquidity -= _amount;// amount will deduct from the totLiquidity
_balances[msg.sender] += Amount; //balance of borrower will update
Borrower = payable (msg.sender);//to know who is the borower
Borrower.transfer(_amount); //amount will transfer to the borrowers account
}

//Lender can withdraw the amount paid by the borrower
function Withdraw(uint _amount) public   {
require(msg.sender==lender,"sorry,only owner allowed to withdraw");//this function is ccalled only by the owner
require(Amount > 0,"amount should be greater than zero");//amount should not be zero
require(isRepayed,"LOAN has not been paid yet");
 require(_amount <= _balances[msg.sender], "Insufficient balance");
//require(Amount==Amount+interestOwed(),"");
_balances[msg.sender] -= _amount;
totLiquidity -= _amount;
 _balances[msg.sender] += _amount;
lender.transfer(address(this).balance); // withdrawing from the contract balance to the lenders account

}

//borrower can repay the lended amount
// function repay(uint id) public payable  {
//     require(_borrowersDetails[msg.sender][id].active, "You Already repaid"); // checking due is paid or unpaid
//     require(block.timestamp <= _borrowersDetails[msg.sender][id].dueDate, "Deposit overdue");// checking overdue time
//     uint amountDue = _borrowersDetails [msg.sender][id].amount + _borrowersDetails[msg.sender][id].interest;//accessing _borrowersDetail mapping fro details
//     require(msg.sender==Borrower,"you are not the borrower");//only Borrower can access this function
//     require(msg.value==Amount + (Amount * interestRate * timePeriod ) / 100,"Incorrect amount,please pay the exact amount");
//     _borrowersDetails[msg.sender][id].active = false;// after price paid loan become false
//     totLiquidity += _borrowersDetails[msg.sender][id].amount + _borrowersDetails[msg.sender][id].interest;//accesing elements of the the _borrowersDetails 
//     _balances[msg.sender] -= _borrowersDetails[msg.sender][id].amount;//amount of the caller of the function will be deduct to update the balances
//     uint change = msg.value - amountDue;
//     if (change > 0) {
//             payable(msg.sender).transfer(change);
//         }
//         //totLiquidity -= Amount;
       
//     totLiquidity+=Amount;//amount will be added to totLiquiidty
//     // address payable contractAddress = payable(address(this));
//     // contractAddress.transfer(msg.value);
//     isRepayed=true;

// }
function repay() public payable{
    require(msg.sender == Borrower, "Only borrower can repay the loan");
    require(!isRepayed, "Loan has already been paid back");
    require(msg.value == Amount, "Incorrect repayment amount");

    isRepayed = true;
    totLiquidity += Amount;
    // address payable contractAddress = payable(address(this));
    // contractAddress.transfer(msg.value);
}

// borrower will repay the lended amount with interest

    function repayInterest() public payable {
        require(msg.sender == Borrower, "Only borrower can repay interest");
        uint interestOwend = Amount * interestRate / 100 - interestPaid;
        require(msg.value <= interestOwend, "Amount paid exceeds interest owed");
        interestPaid += msg.value;   
 }

 //function for total interest has to pay for a year
    function TotalInterest() public view returns (uint) {
        return Amount* interestRate / 100- interestPaid; // formula
    }

//function for calculating the interest owned compare to current timestamp.
    function Interest() public view returns (uint) {
    uint timeElapsed = 0; //variable
    if (Borrower != address(0)) { //  checks if a borrower has been assigned to the contract yet 
        timeElapsed = block.timestamp - startDate;
    }
    return (Amount * interestRate * timeElapsed) / (100 * 365 days);//formula
}
 
    
}

