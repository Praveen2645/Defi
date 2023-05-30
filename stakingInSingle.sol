// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Staking is Ownable, ReentrancyGuard, ERC20, Pausable {
    uint8 constant _decimals = 18;
    uint256 constant _totalSupply = 21 * (10**6); // 21m tokens for distribution
    address admin;

    constructor() ERC20("PBM Coin", "PBMC") {
        _mint(msg.sender, _totalSupply); //tokens minting on deployment
        admin = msg.sender;
    }

    //modifier
    modifier onlyAdmin() {
        require(admin == msg.sender, "Sorry,only Admin have the access");
        _;
    }

    uint256 planId = 1;

    struct Plans {
        uint256 interestRate;
        uint256 timePeriodInMonth;
        bool active;
    }

    struct User {
        uint256 startTS;
        uint256 endTS;
        uint256 amount;
        uint256 rewards;
        uint256 planId;
        bool active;
    }

    mapping(uint256 => Plans) public planIdToPlans; // for getting plans details
    mapping(address => mapping(uint256 => User)) public userToUserInfo; //for user information

    function createPlan(uint256 _interestRate, uint256 timePeriodInMonth)
        external
        onlyOwner
        returns (bool)
    {
        planIdToPlans[planId] = Plans(_interestRate, timePeriodInMonth, true);
        planId++;
        return true;
    }

    function stake(uint256 _amount, uint256 _planId)
        external
        nonReentrant
        returns (bool)
    {
        Plans memory plan = planIdToPlans[_planId];
        User storage user = userToUserInfo[msg.sender][_planId];
        require(plan.active == true, "please enter a valid plan");
        require(_amount > 0, "please enter the amount greater than zero");
        require(user.active == false, "you have already staked ");  
        transfer(address(this), _amount);
        uint256 monthToSeconds = plan.timePeriodInMonth * 1;
          // uint256 monthToSeconds = plan.timePeriodInMonth *  2,592,000;  //=30 days
        userToUserInfo[msg.sender][_planId] = User(
            block.timestamp,
            block.timestamp + monthToSeconds,
            _amount,
            0,
            _planId,
            true
        );
        // Calculate and store the rewards for the user
        user.rewards = calculateRewards(user);
        return true;
    }

    function unstake(uint256 _planId) external {
        User storage user = userToUserInfo[msg.sender][_planId];
        require(user.active == true, "stake is not active");
        require(user.endTS < block.timestamp, "period is not expire");
        uint256 rewards = calculateRewards(user);
        user.rewards = rewards;
        user.active = false;
        _transfer(address(this), msg.sender, (user.amount + rewards));
    }

    function calculateRewards(User memory user)
        internal
        view
        returns (uint256)
    {
        uint256 month = planIdToPlans[user.planId].timePeriodInMonth;
        uint256 interestRate = planIdToPlans[user.planId].interestRate;
        uint256 rewards = (user.amount * month * interestRate) /
            (12 * 100 * 10);
        return rewards;
    }

    function withdraw() external onlyOwner whenNotPaused {
        uint256 contractBalance = balanceOf(address(this));
        require(
            contractBalance > 0,
            "Contract does not have any balance to withdraw"
        );
        _transfer(address(this), msg.sender, balanceOf(address(this)));
    }

    function deactivatePlan(uint256 _planId) external onlyOwner {
        planIdToPlans[_planId].active = false;
    }

    function pause() public onlyAdmin {
        _pause();
    }

    function unpause() public onlyAdmin {
        _unpause();
    }
}
