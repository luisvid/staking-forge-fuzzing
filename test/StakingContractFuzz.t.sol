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
    
    // Test fuzzing

    /// @notice Test staking with random amounts using fuzzing
    function test_FuzzStake(uint256 amount) public {
        amount = bound(amount, 1, 1_000_000 * 10 ** 18); // Cap amount to prevent trivial failures

        uint256 initialBalance = testToken.balanceOf(address(this));
        stakingContract.stake(amount);

        uint256 expectedBalance = initialBalance - amount;
        uint256 actualBalance = testToken.balanceOf(address(this));

        assertEq(actualBalance, expectedBalance, "Balance mismatch post-staking");
    }

    /// @notice Test unstaking with random amounts using fuzzing
    function test_FuzzUnstake(uint256 amount) public {
        // Only attempt to unstake if the amount is between 1 and 1_000_000
        amount = bound(amount, 1, 1_000_000 * 10 ** 18);

        // Stake the amount first
        uint256 initialBalance = testToken.balanceOf(address(this));
        stakingContract.stake(amount);

        // Simulate time passage to accrue rewards
        vm.roll(block.number + 100);

        // Unstake the amount
        stakingContract.unstake();

        uint256 finalBalance = testToken.balanceOf(address(this));
        bool rewardPaid = finalBalance > initialBalance;
        // Check if the amount was transferred back and the rewards were paid
        assertTrue(rewardPaid, "Rewards not paid correctly.");

        assertGt(
            finalBalance, initialBalance, "Final balance should be greater than initial after unstaking with rewards."
        );
    }

    /// @notice This test checks whether users can safely stake and then immediately unstake their tokens, ensuring
    /// all state changes are correctly reverted and rewards are handled properly.
    function testFuzz_StakeAndImmediateUnstake(uint256 amount) public {
        // Ensure the amount is within a reasonable range and not zero
        vm.assume(amount > 0 && amount <= 1_000_000 * 10 ** 18);
        uint256 initialBalance = testToken.balanceOf(address(this));

        stakingContract.stake(amount);
        stakingContract.unstake();

        // Assert that the final balances and staked amounts are as expected
        assertEq(testToken.balanceOf(address(this)), initialBalance, "Token balance should revert to initial");
        assertEq(stakingContract.stakes(address(this)), 0, "Stakes should be zero after unstaking");
    }

    /// @notice This test examines the contract's ability to handle multiple consecutive stakes followed by a single
    /// unstake, ensuring the calculations for accumulated rewards and the final token balances are correct.
    function testFuzz_MultipleStakesSingleUnstake(uint256[] memory amounts) public {
        vm.assume(amounts.length > 0);
        uint256 rolledBlocks = 100;
        uint256 totalStaked = 0;
        uint256 initialBalance = testToken.balanceOf(address(this));

        for (uint256 i = 0; i < amounts.length; i++) {
            amounts[i] = bound(amounts[i], 1, 100 * 10 ** 18); // Cap amount to prevent trivial failures
            stakingContract.stake(amounts[i]);
            totalStaked += amounts[i];
        }

        // check totalStaked amount is correct after multiple stakes and before unstaking
        assertEq(stakingContract.stakes(address(this)), totalStaked, "Total staked amount should be correct");

        vm.roll(block.number + rolledBlocks); // Simulate some blocks passing for rewards to accumulate
        stakingContract.unstake();

        // Assert final state checks
        assertEq(stakingContract.stakes(address(this)), 0, "Stakes should be zero after unstaking");
        uint256 finalBalance = testToken.balanceOf(address(this));
        assertGt(
            finalBalance, initialBalance, "Final balance should be greater than initial after unstaking with rewards."
        );

        uint256 expectedRewards = calculateTotalRewards(totalStaked, rolledBlocks);
        uint256 actualRewards = finalBalance - initialBalance;

        assertEq(actualRewards, expectedRewards, "Rewards calculation mismatch");
    }

    /// @notice This test investigates how the contract behaves when stakes and reward redemptions are interleaved,
    /// ensuring rewards are calculated and disbursed correctly throughout.
    function testFuzz_StakeRedeemInterleaved(uint256[] memory stakes, uint16 rolledBlocks) public {
        vm.assume(stakes.length > 0);
        vm.assume(rolledBlocks > 0);
        uint256 initialBalance = testToken.balanceOf(address(this));

        uint256 lastBlock = block.number;
        for (uint256 i = 0; i < stakes.length; i++) {
            stakes[i] = bound(stakes[i], 1, 50 * 10 ** 18);
            stakingContract.stake(stakes[i]);
            vm.roll(lastBlock + rolledBlocks); // Simulate time passage for reward accrual

            // Redeem rewards at specified intervals
            if (i % 2 == 0) {
                // Redeem rewards every other operation
                stakingContract.redeemRewards();
            }
            lastBlock = block.number;
        }

        // Final redeem and unstake
        stakingContract.unstake();

        uint256 finalBalance = testToken.balanceOf(address(this));
        assertEq(stakingContract.stakes(address(this)), 0, "Stakes should be zero after all operations");
        assertGt(
            finalBalance, initialBalance, "Final balance should be greater than initial after unstaking with rewards."
        );
    }

    /// @notice  Mock implementation of reward calculation for testing purposes
    function calculateTotalRewards(uint256 totalStaked, uint256 blocksStaked) public pure returns (uint256) {
        uint256 rewardRate = 100; // This should match the reward rate in the StakingContract
        return blocksStaked * rewardRate * totalStaked;
    }
}
