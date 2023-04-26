# Defi
## Dbank.sol

This Dbank contract gives an idea how a D Bnank works, where no middleman present , all things managed by a smart contract.
This is basically a smart contract for Decentralize Bank, where any user can add his account where one can deposite() and withdraw() ethers. Also transfer from one account to another is possible through transfer(). And contract owner can set the intrest rate.

## Lending.sol
// This smart contract defines a lending pool that allows users to deposit digital assets, borrow funds, and repay the borrowed amount plus interest within 30 days.
//  The interest rate is set at 10% annually.

// When a user deposits funds, the smart contract records the deposit and adds the funds to the total liquidity of the pool. When a user borrows funds, 
// the smart contract deducts the borrowed amount from the total liquidity and adds it to the borrower's balance.
//  The smart contract also records the amount borrowed, the interest due, and the due date of the repayment.

// When a user repays a deposit, the smart contract checks if the deposit is active and not overdue, 
// and verifies that the repayment amount is sufficient to cover the borrowed amount plus interest.
//  If the repayment is successful, the smart contract marks the deposit as repaid, adds the deposited amount to the total liquidity of the pool,
//   and deducts the borrowed amount from the borrower's
