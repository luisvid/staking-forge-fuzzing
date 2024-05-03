# Fuzz Testing Exploration with a Staking Contract Project

### Introduction

This project serves as an educational toolkit designed to explore **Forge's property-based fuzz testing** capabilities within the context of a Solidity-based staking contract. Fuzz testing, also known as fuzzing, is an automated testing technique that generates a large number of random inputs, or "fuzz," to identify programming errors and security vulnerabilities that might otherwise go unnoticed.

Forge is a Solidity testing framework that is part of the Foundry toolchain, well-known for its advanced fuzz testing features. These features help developers ensure their smart contracts are resilient against a diverse range of input values. By adhering to property-based testing principles, Forge allows developers to define properties (expected behaviors) that should always hold true for any valid inputs, and its fuzzing engine attempts to generate test cases that challenge these properties.

For additional details on fuzz testing and its applications in Forge, refer to the Foundry documentation: [Forge Fuzz Testing](https://book.getfoundry.sh/forge/fuzz-testing).

### Project Overview

The foundation of this project is [PaulRBerg's foundry-template](https://github.com/PaulRBerg/foundry-template), which provides a robust Foundry-based template for developing Solidity smart contracts with sensible defaults.

The core functionality of the Staking Contract allows users to deposit a specific ERC-20 token into the contract to earn rewards based on the duration and amount of their stake. The contract encompasses functionalities for staking tokens, unstaking tokens along with accrued interest, and querying staked balances and earned rewards.

### Key Features

1. **Token Staking**: Enables users to deposit (stake) tokens into the contract.
2. **Unstaking and Claiming Rewards**: Allows users to withdraw their staked tokens along with any accrued rewards.
3. **Reward Calculation**: Features a mechanism to calculate rewards based on the duration and amount of the stake.

### Installation and Setup

Get started with this project by following these steps:

1. **Clone the repository**:
   ```bash
   git clone https://github.com/luisvid/staking-forge-fuzzing.git
   ```

2. **Install dependencies**:
   ```bash
   bun install
   ```

3. **Compile the contract**:
   ```bash
   forge build
   ```

4. **Run tests**:
   ```bash
   forge test
   ```

### Contracts

#### `TestToken.sol`

A simple ERC20 token utilized for testing the staking functionalities. This token:
- Initially mints 1 million tokens for the deployer.
- Includes functionality to mint new tokens to any address.

#### `StakingContract.sol`

This contract allows users to stake ERC20 tokens (`TestToken`) and earn rewards based on the duration of their stake.

Features:
- Staking and unstaking tokens.
- Calculating and claiming staking rewards.
- Emitting events for staking, unstaking, and claiming rewards to ensure transparency.

### Testing

Tests are implemented using Forge and focus on fuzz testing for the staking and unstaking functionalities. Execute the tests with the following commands:

```bash
forge test --match-path test/StakingContract.t.sol
forge test --match-path test/StakingContractFuzz.t.sol
```

#### Key Test Scenarios

Descriptions for each fuzz test in the `StakingContractFuzz.t.sol` test suite are as follows:

1. **`test_FuzzStake(uint256 amount)`**:
   - Verifies that the staking function robustly handles random staking amounts ranging from 1 to 1,000,000 tokens, ensuring the contract's token balance is reduced accordingly.

2. **`test_FuzzUnstake(uint256 amount)`**:
   - Initially stakes a random amount of tokens, then simulates 100 blocks to accrue rewards, and finally unstakes, verifying that the staked tokens and rewards are accurately returned, enhancing the final balance.

3. **`testFuzz_StakeAndImmediateUnstake(uint256 amount)`**:
   - Ensures that immediate unstaking after staking a random valid amount correctly reverts token balances to their original states, affirming that no tokens are lost.

4. **`testFuzz_MultipleStakesSingleUnstake(uint256[] memory amounts)`**:
   - Assesses the contract's capacity to manage multiple consecutive stakes and a single unstake, confirming the precise computation of accumulated rewards and the reflection of these in the final token balance.

5. **`testFuzz_StakeRedeemInterleaved(uint256[] memory stakes, uint16 rolledBlocks)`**:
   - Simulates a scenario with multiple stakes at different intervals and intermittent reward redemptions, checking the precision of reward calculations and the correct adjustment of the final token balance after all operations.

### Development Notes

- The contract and tests are intended for educational purposes and are not recommended for production use without further modifications, primarily due to their simplicity and the potential for security vulnerabilities.
- Consider further optimizing the reward calculation mechanism to better align with specific business models or operational criteria.

Explore various testing scenarios and refine the functionalities of your Staking Contract through this iterative process. This approach is essential for ensuring your contract's robustness and preparing it for practical deployment.

## Bonus: Integrating Diligence Fuzzing

[`Diligence Fuzzing`](https://consensys.io/diligence/fuzzing/) is an advanced fuzz testing tool developed by ConsenSys that aims to identify potential
vulnerabilities in Ethereum smart contracts. By generating random inputs and testing them against the contract's logic,
it helps uncover hidden issues that might not be easily caught through normal testing.

#### Why Use Diligence Fuzzing?

Fuzzing is essential for ensuring the robustness of smart contracts by exposing them to a wide range of input
conditions. Diligence Fuzzing offers:

- Automated discovery of vulnerabilities.
- Easy integration with Solidity and Foundry.
- Comprehensive documentation and support.

#### Getting Started with Diligence Fuzzing on Existing Foundry Projects

To integrate Diligence Fuzzing into your existing Foundry project and start fuzz testing your contracts, follow these
detailed steps based on the
[official tutorial](https://fuzzing-docs.diligence.tools/getting-started/fuzzing-foundry-projects).

1. **Install the CLI and Configure the API Key**
   - Ensure Foundry is installed and make sure you’re at least python 3.6 and node 16. You can add Diligence Fuzzing to
     your project by running:
     ```bash
     pip3 install diligence-fuzzing
     ```
2. **API Key**

   - With the tools installed, you will need to generate an API for the CLI and add it to the `.env` file. The API keys
     menu is [accessible here](https://fuzzing.diligence.tools/keys).

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

   - Visit the provided URL to access the Campaign Dashboard where you can monitor detailed statistics and results of
     the fuzzing process.

#### Recommendations

- **Consult the Official Documentation**: For comprehensive guidance and advanced techniques, visit the
  [Diligence Fuzzing Documentation](https://fuzzing-docs.diligence.tools/getting-started/fuzzing-foundry-projects).
- **Incorporate Regular Fuzz Testing**: Include fuzz testing in your regular testing routines to continuously improve
  the security and reliability of your contracts.

This setup not only enhances your project’s testing capabilities but also deepens your understanding of smart contract
security practices.
