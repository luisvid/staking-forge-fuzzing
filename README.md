
# Fuzz Testing Staking Contract Project

### Introduction

This project is designed as an educational toolkit to learn and experiment with **Forge's property-based fuzz testing** capabilities. Fuzz testing, or fuzzing, is an automated testing technique used to uncover programming errors and security vulnerabilities in software. Unlike traditional testing methods, fuzz testing involves generating a large number of random inputs (or "fuzz") to a system in order to trigger unexpected behaviors such as crashes or failed assertions. 

Forge, a Solidity testing framework included within the Foundry toolchain, supports advanced fuzz testing features that help developers ensure their contracts are robust against a wide range of inputs. By using property-based testing principles, Forge allows developers to define properties (expected behaviors) that should always hold true for any valid inputs. The fuzz testing engine then attempts to generate test cases that disprove these properties, providing a powerful way to identify potential issues in contract logic.

For more detailed information on fuzz testing and its implementation in Forge, please refer to the Foundry documentation: [Forge Fuzz Testing](https://book.getfoundry.sh/forge/fuzz-testing).

### Project Overview

This project utilizes [PaulRBerg's foundry-template](https://github.com/PaulRBerg/foundry-template), a Foundry-based template for developing Solidity smart contracts with sensible defaults.

The Staking Contract will allow users to deposit a specific ERC-20 token into the contract to earn rewards based on the duration and amount of their stake. The contract will include functions for staking tokens, unstaking tokens with interest, and querying staked balances and earned rewards.

### Key Features to Implement

1. **Token Staking**: Functionality for users to deposit (stake) tokens into the contract.
2. **Unstaking and Claiming Rewards**: Allow users to withdraw their staked tokens along with any accrued rewards.
3. **Reward Calculation**: Implement a system to calculate rewards based on staking duration and amount.

### Installation and Setup

To get started with this project, clone the repository and install the dependencies as follows:

```bash
git clone https://github.com/your-repository/staking-contract
cd staking-contract
forge install
```

### Contracts

#### TestToken.sol

A simple ERC20 token used for testing the staking functionalities. It features:

- An initial minting of 1 million tokens for the deployer.
- Functionality to mint new tokens to any address.

#### StakingContract.sol

A contract that allows users to stake ERC20 tokens (`TestToken`) and earn rewards based on the duration of their stake.

Features include:
- Staking and unstaking tokens.
- Calculating and claiming staking rewards.
- Events for staking, unstaking, and claiming rewards for transparency.

### Testing

Tests are written using Forge and include fuzz testing for the staking and unstaking functionalities. To run the tests, execute the following command:

```bash
forge test --match-contract StakingContractTest --ffi
```

#### Key Test Scenarios

- `testFuzzStake(uint256 amount)`: Tests the staking function with various random amounts.
- `testFuzzUnstake(uint256 amount)`: Tests the unstaking function, ensuring rewards are paid out correctly.

### Example Usage

Below are snippets to illustrate how you might interact with the Staking Contract:

#### Staking Tokens

```solidity
// Assuming you have an instance of the TestToken and StakingContract
testToken.approve(address(stakingContract), 1000 * 1e18);
stakingContract.stake(1000 * 1e18);
```

#### Unstaking Tokens

```solidity
stakingContract.unstake();
```

### Development Notes

- The contract and tests are designed for educational purposes and should not be used in production as-is due to the simplicity and potential security vulnerabilities.
- The reward calculation mechanism can be further optimized and tailored to fit specific business models.

Feel free to explore different scenarios and add complexity to your tests to thoroughly evaluate all functionalities of your Staking Contract. This iterative testing process is crucial for understanding the robustness of your contract and preparing it for a real-world application.



### Bonus: Integrating Diligence Fuzzing

**Diligence Fuzzing** is an advanced fuzz testing tool developed by ConsenSys that aims to identify potential vulnerabilities in Ethereum smart contracts. By generating random inputs and testing them against the contract's logic, it helps uncover hidden issues that might not be easily caught through normal testing.

#### Why Use Diligence Fuzzing?

Fuzzing is essential for ensuring the robustness of smart contracts by exposing them to a wide range of input conditions. Diligence Fuzzing offers:
- Automated discovery of vulnerabilities.
- Easy integration with Solidity and Foundry.
- Comprehensive documentation and support.

#### Getting Started with Diligence Fuzzing on Existing Foundry Projects

To integrate Diligence Fuzzing into your existing Foundry project and start fuzz testing your contracts, follow these detailed steps based on the [official tutorial](https://fuzzing-docs.diligence.tools/getting-started/fuzzing-foundry-projects).

1. **Install the CLI and Configure the API Key**
   - Ensure Foundry is installed and make sure you’re at least python 3.6 and node 16. You can add Diligence Fuzzing to your project by running:
     ```bash
     pip3 install diligence-fuzzing
     ```
2. **API Key**
   - With the tools installed, you will need to generate an API for the CLI and add it to the `.env` file. The API keys menu is [accessible here](https://fuzzing.diligence.tools/keys). 

3. **Running Fuzz Tests**
   - Run your fuzz tests to see how your contract behaves under random conditions:
     ```bash
     fuzz forge test
     ```
   - This sequence compiles unit tests, automatically detects and collects test contracts, and submits them for fuzzing:
      ```bash
      $ fuzz forge test

      🛠️  Parsing Foundry configuration
      🛠️  Compiling tests
      🛠️  Gathering test contracts
      🛠️  Assembling and validating campaigns for submission
      🛠️  Configuring the initial seed state
      ⚡️ Launching fuzzing campaigns
      You can track the progress of the campaign here: [Campaign Dashboard](https://fuzzing.diligence.tools/campaigns/cmp_ffcd3abf6b0640598c7cc7e436717xxx)
      Done 🎉
      ```
   - Visit the provided URL to access the Campaign Dashboard where you can monitor detailed statistics and results of the fuzzing process.

#### Recommendations

- **Consult the Official Documentation**: For comprehensive guidance and advanced techniques, visit the [Diligence Fuzzing Documentation](https://fuzzing-docs.diligence.tools/getting-started/fuzzing-foundry-projects).
- **Incorporate Regular Fuzz Testing**: Include fuzz testing in your regular testing routines to continuously improve the security and reliability of your contracts.

This setup not only enhances your project’s testing capabilities but also deepens your understanding of smart contract security practices.

