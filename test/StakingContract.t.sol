// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import "../src/StakingContract.sol";

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { TestToken } from "../src/TestToken.sol";

/// @title StakingContractTest
/// @notice Test suite for the Staking Contract
contract StakingContractTest is Test {
    StakingContract public stakingContract;
    TestToken public testToken;

    // event declarations for testing
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    /// @notice Set up the test environment
    function setUp() public {
        testToken = new TestToken();
        stakingContract = new StakingContract(address(testToken));
        testToken.approve(address(stakingContract), type(uint256).max);
    }

    // Test staking and unstaking

    /// @notice Test staking with a minimum amount
    function testStakeWithMinAmount() public {
        uint256 amount = 1;

        // Stake the amount first
        uint256 initialBalance = testToken.balanceOf(address(this));
        stakingContract.stake(amount);

        uint256 expectedBalance = initialBalance - amount;
        uint256 actualBalance = testToken.balanceOf(address(this));

        assertEq(actualBalance, expectedBalance, "Balance mismatch post-staking");
    }

    /// @notice Test staking with a minimum amount
    function testUnstakeWithMinAmount() public {
        uint256 amount = 1;

        // Stake the amount first
        uint256 initialBalance = testToken.balanceOf(address(this));
        stakingContract.stake(amount);

        // Simulate time passage
        vm.roll(block.number + 100);

        // Unstake the amount
        stakingContract.unstake();
        uint256 finalBalance = testToken.balanceOf(address(this));

        // Check if the amount was transferred back and the rewards were paid
        bool rewardPaid = finalBalance > initialBalance;
        assertTrue(rewardPaid, "Rewards not paid correctly.");
        assertGt(
            finalBalance, initialBalance, "Final balance should be greater than initial after unstaking with rewards."
        );
    }

    // Test events

    /// @notice Test event emission on staking  with a specific amount
    function testStakeEmitsEvent() public {
        uint256 amount = 1e18; // 1 token, adjust according to your token's decimals
        vm.expectEmit(true, true, false, true);
        emit Staked(address(this), amount);
        stakingContract.stake(amount);
    }

    /// @notice Test event emission on unstaking with a specific amount
    function testUnStakeEmitsEvent() public {
        uint256 totalStaked = 1e18;
        uint256 rolledBlocks = 100;
        stakingContract.stake(totalStaked);
        vm.roll(block.number + rolledBlocks);
        uint256 expectedRewards = calculateTotalRewards(totalStaked, rolledBlocks);
        vm.expectEmit(true, true, false, true);
        emit Unstaked(address(this), totalStaked + expectedRewards);
        stakingContract.unstake();
    }

    /// @notice Test event emission on redeeming rewards
    function testRedeemRewardsEmitsEvent() public {
        uint256 totalStaked = 1e18;
        uint256 rolledBlocks = 100;
        stakingContract.stake(totalStaked);
        vm.roll(block.number + rolledBlocks);
        uint256 expectedRewards = calculateTotalRewards(totalStaked, rolledBlocks);
        vm.expectEmit(true, true, false, true);
        emit RewardPaid(address(this), expectedRewards);
        stakingContract.redeemRewards();
    }

    /// @notice  Mock implementation of reward calculation for testing purposes
    function calculateTotalRewards(uint256 totalStaked, uint256 blocksStaked) public pure returns (uint256) {
        uint256 rewardRate = 100; // This should match the reward rate in the StakingContract
        return blocksStaked * rewardRate * totalStaked;
    }
}
