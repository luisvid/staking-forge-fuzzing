
### Project Overview: Staking Contract

The Staking Contract will allow users to deposit a specific ERC-20 token into the contract to earn rewards based on the duration and amount of their stake. The contract will include functions for staking tokens, unstaking tokens with interest, and querying staked balances and earned rewards.

### Key Features to Implement

1. **Token Staking**: Functionality for users to deposit (stake) tokens into the contract.
2. **Unstaking and Claiming Rewards**: Allow users to withdraw their staked tokens along with any accrued rewards.
3. **Reward Calculation**: Implement a system to calculate rewards based on staking duration and amount.
4. **Emergency Withdrawal**: Include safety mechanisms to allow users to withdraw their original staked amount in case of issues.

### Step 1: Contract Skeleton in Solidity

Here’s a basic skeleton for your staking contract using Solidity:

StakingContract.sol

3. **Write Fuzz Tests**:
   Create a file named `StakingContract.t.sol` in the `test` directory, and start with the following test:


### Step 3: Run Fuzz Tests

Run your fuzz tests using Forge:

```bash
forge test --match-contract StakingContractTest --ffi
```

This setup will perform fuzz testing on the `stake` function to ensure it handles a wide range of input values robustly. The `--ffi` flag allows Forge to use the Foreign Function Interface for additional capabilities if needed.

Feel free to explore different scenarios and add complexity to your tests to thoroughly evaluate all functionalities of your Staking Contract. This process will help you understand the robustness of your contract and prepare it for a production environment.