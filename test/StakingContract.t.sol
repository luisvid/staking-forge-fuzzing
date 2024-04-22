// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import "../src/StakingContract.sol";

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title TestToken
/// @notice A simple ERC20 token for testing purposes
contract TestToken is ERC20 {
    constructor() ERC20("Test Token", "TT") {
        // Mint 1 million tokens for testing
        _mint(msg.sender, 1_000_000 * 10 ** 18);
    }
}

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
        vm.assume(amount > 0); // Only attempt to stake if the amount is greater than 0
        amount = bound(amount, 1, 500_000 * 10 ** 18); // Cap amount to prevent trivial failures

        assertTrue(testToken.transfer(address(stakingContract), amount), "Transfer failed");
        uint256 initialBalance = testToken.balanceOf(address(this));
        stakingContract.stake(amount);

        uint256 expectedBalance = initialBalance - amount;
        uint256 actualBalance = testToken.balanceOf(address(this));

        assertEq(actualBalance, expectedBalance, "Balance mismatch post-staking");
    }

    /// @notice Test unstaking with random amounts using fuzzing
    function testFuzzUnstake(uint256 amount) public {
        vm.assume(amount > 0); // Only attempt to unstake if the amount is greater than 0
        amount = bound(amount, 1, 500_000 * 10 ** 18); // Cap amount to prevent trivial failures

        // Stake the amount first
        assertTrue(testToken.transfer(address(stakingContract), amount), "Transfer failed");
        uint256 initialBalance = testToken.balanceOf(address(this));
        stakingContract.stake(amount);

        // Simulate time passage to accrue rewards
        vm.roll(block.number + 10);

        // Unstake the amount
        stakingContract.unstake();

        // Check if the amount was transferred back to the user
        uint256 finalBalance = testToken.balanceOf(address(this));

        // Check if the rewards were paid
        bool rewardPaid = finalBalance > initialBalance;

        assertTrue(rewardPaid, "Rewards not paid correctly.");

        assertGt(
            finalBalance, initialBalance, "Final balance should be greater than initial after unstaking with rewards."
        );
    }
}
