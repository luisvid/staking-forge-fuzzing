// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25;

import { TestToken } from "./TestToken.sol";

/// @title A Staking Contract for ERC20 tokens
/// @notice This contract allows users to stake ERC20 tokens and earn staking rewards
/// based on the duration of their stake.
/// Insecure, only for testing, should not be used in production
contract StakingContract {
    /// @notice The ERC20 token used for staking
    TestToken public stakingToken;

    /// @notice Rewards per block in wei
    uint256 public constant rewardRate = 100;

    /// @dev Maps an address to its current staked amount
    mapping(address => uint256) public stakes;

    /// @dev Maps an address to the block number at which they started staking
    mapping(address => uint256) public startBlock;

    /// @dev Maps an address to the total rewards they have claimed
    mapping(address => uint256) public rewards;

    /// @notice Event emitted when a user stakes tokens
    event Staked(address indexed user, uint256 amount);
    /// @notice Event emitted when a user unstakes tokens
    event Unstaked(address indexed user, uint256 amount);
    /// @notice Event emitted when a user claims rewards
    event RewardPaid(address indexed user, uint256 reward);

    /// @notice Constructs the staking contract for a given ERC20 token
    /// @param _stakingToken The ERC20 token to be staked
    constructor(address _stakingToken) {
        stakingToken = TestToken(_stakingToken);
    }

    /// @notice Stakes a certain amount of the ERC20 token
    /// @dev Requires that the transfer of tokens to the contract succeeds
    /// @param amount The amount of tokens to stake
    function stake(uint256 amount) public {
        require(amount > 0, "amount cannot be 0");
        stakes[msg.sender] += amount;
        startBlock[msg.sender] = block.number;
        emit Staked(msg.sender, amount);
        // Transfer tokens to the contract
        require(stakingToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
    }

    /// @notice Unstakes the staked tokens and pays out any accrued rewards
    /// @dev Requires that the transfer of tokens and rewards back to the staker succeeds
    function unstake() public {
        uint256 stakedAmount = stakes[msg.sender];
        uint256 reward = calculateReward(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            stakingToken.mintRewards(msg.sender, reward);
        }
        stakes[msg.sender] = 0;
        emit Unstaked(msg.sender, stakedAmount + reward);
        require(stakingToken.transfer(msg.sender, stakedAmount), "Transfer failed");
    }

    /// @notice Redeems the accrued rewards for the sender
    function redeemRewards() public {
        uint256 reward = calculateReward(msg.sender);
        require(reward > 0, "No rewards available");
        rewards[msg.sender] = 0;
        startBlock[msg.sender] = block.number;
        emit RewardPaid(msg.sender, reward);
        stakingToken.mintRewards(msg.sender, reward);
    }

    /// @notice Calculates the reward for a given staker
    /// @dev Calculation based on the staked amount, staking period, and a fixed reward rate
    /// @dev 1e8 is used to normalize the reward into a manageable number of wei
    /// @param user The address of the staker
    /// @return The calculated reward
    function calculateReward(address user) internal view returns (uint256) {
        require(stakes[user] > 0, "No stakes to calculate reward");
        uint256 stakedAmount = stakes[user];
        uint256 blocksStaked = block.number - startBlock[user];
        return (blocksStaked * rewardRate * stakedAmount);
    }
}
