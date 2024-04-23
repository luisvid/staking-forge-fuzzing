// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title TestToken
/// @notice A simple ERC20 token for testing purposes with extended minting capability

contract TestToken is ERC20 {

    constructor() ERC20("Test Token", "TT") {
        _mint(msg.sender, 1_000_000 * 10 ** 18); // Mint initial supply
    }

    /// @notice Allows dynamic minting of tokens. 
    /// @notice Totally insecure, only for testing, should not be used in production
    function mintRewards(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
