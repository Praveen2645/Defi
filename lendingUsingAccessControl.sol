pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Lending is AccessControl {
    using SafeERC20 for IERC20;

    bytes32 public constant LENDER_ROLE = keccak256("LENDER_ROLE");
    bytes32 public constant BORROWER_ROLE = keccak256("BORROWER_ROLE");

    address public borrower;
    address public lender;
    uint public amount;
    uint public interestRate;
    uint public term;
    uint public startTime;

    IERC20 public token;

    constructor(address _token, address _borrower, uint _amount, uint _interestRate, uint _term) {
        _setupRole(BORROWER_ROLE, _borrower);
        _setRoleAdmin(LENDER_ROLE, BORROWER_ROLE);
        token = IERC20(_token);
        borrower = _borrower;
        amount = _amount;
        interestRate = _interestRate;
        term = _term;
    }

    function lend(address _lender) public onlyRole(LENDER_ROLE) {
        require(token.balanceOf(_lender) >= amount, "Insufficient balance");
        require(token.allowance(_lender, address(this)) >= amount, "Insufficient allowance");
        token.safeTransferFrom(_lender, address(this), amount);
        lender = _lender;
        startTime = block.timestamp;
        grantRole(BORROWER_ROLE, borrower);
    }

    function repay() public {
        require(msg.sender == borrower, "Only borrower can repay");
        require(block.timestamp >= startTime + term, "Loan term not over yet");
        uint interest = amount * interestRate / 100;
        uint total = amount + interest;
        token.safeTransfer(lender, total);
        revokeRole(BORROWER_ROLE, borrower);
    }

    function addLender(address _lender) public onlyRole(BORROWER_ROLE) {
        grantRole(LENDER_ROLE, _lender);
    }

    function removeLender(address _lender) public onlyRole(BORROWER_ROLE) {
        revokeRole(LENDER_ROLE, _lender);
    }
}
