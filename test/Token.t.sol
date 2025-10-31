// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/token.sol";

/**
 * @title TokenTest
 * @notice Base test contract with common setup and helper functions
 * @dev All other test contracts inherit from this base
 */
contract TokenTest is Test {
    Token public token;

    // Test addresses
    address public owner;
    address public user1;
    address public user2;
    address public user3;
    address public liquidityPool;
    address public mintManager;
    address public burnManager;
    address public balanceManager;
    address public blacklistManager;

    // Constants
    uint256 public constant INITIAL_SUPPLY = 1_000_000 * 10 ** 18;
    uint256 public constant MINT_AMOUNT = 1000 * 10 ** 18;

    /**
     * @notice Setup function runs before each test
     */
    function setUp() public virtual {
        // Create test addresses
        owner = makeAddr("owner");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        user3 = makeAddr("user3");
        liquidityPool = makeAddr("liquidityPool");
        mintManager = makeAddr("mintManager");
        burnManager = makeAddr("burnManager");
        balanceManager = makeAddr("balanceManager");
        blacklistManager = makeAddr("blacklistManager");

        // Deploy token contract as owner
        vm.prank(owner);
        token = new Token(owner);
    }

    /**
     * @notice Helper function to add a mint manager
     */
    function _addMintManager(address account) internal {
        vm.prank(owner);
        token.addMintManager(account);
    }

    /**
     * @notice Helper function to add a burn manager
     */
    function _addBurnManager(address account) internal {
        vm.prank(owner);
        token.addBurnManager(account);
    }

    /**
     * @notice Helper function to add a balance manager
     */
    function _addBalanceManager(address account) internal {
        vm.prank(owner);
        token.addBalanceManager(account);
    }

    /**
     * @notice Helper function to add a blacklist manager
     */
    function _addBlacklistManager(address account) internal {
        vm.prank(owner);
        token.addBlacklistManager(account);
    }

    /**
     * @notice Helper function to add a liquidity pool
     */
    function _addLiquidityPool(address lpAddress) internal {
        vm.prank(owner);
        token.addLiquidityPoolAddress(lpAddress);
    }

    /**
     * @notice Helper function to blacklist an address
     */
    function _blacklistAddress(address account) internal {
        vm.prank(owner);
        token.blacklistAddress(account);
    }

    /**
     * @notice Helper function to mint tokens
     */
    function _mintTokens(address to, uint256 amount) internal {
        vm.prank(owner);
        token.mint(to, amount);
    }
}
