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

    /// @notice Set up the test environment
    function setUp() public {
        testToken = new TestToken();
        stakingContract = new StakingContract(address(testToken));
        testToken.approve(address(stakingContract), type(uint256).max);
    }

    /// @notice Test staking with random amounts using fuzzing
    function testFuzzStake(uint256 amount) public {
        amount = bound(amount, 1, 1_000_000 * 10 ** 18); // Cap amount to prevent trivial failures

        uint256 initialBalance = testToken.balanceOf(address(this));
        stakingContract.stake(amount);

        uint256 expectedBalance = initialBalance - amount;
        uint256 actualBalance = testToken.balanceOf(address(this));

        assertEq(actualBalance, expectedBalance, "Balance mismatch post-staking");
    }

    /// @notice Test unstaking with random amounts using fuzzing
    function testFuzzUnstake(uint256 amount) public {
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

    /// @notice Test staking with a specific amount
    /// @notice This is a not a fuzz test, but a specific test for a specific amount
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

        console2.log("initialBalance", initialBalance);
        console2.log("finalBalance", finalBalance);

        // Check if the amount was transferred back and the rewards were paid
        bool rewardPaid = finalBalance > initialBalance;

        assertTrue(rewardPaid, "Rewards not paid correctly.");

        assertGt(
            finalBalance, initialBalance, "Final balance should be greater than initial after unstaking with rewards."
        );
    }
}
