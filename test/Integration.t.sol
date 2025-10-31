// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {TokenTest} from "./Token.t.sol";
import {Token} from "../src/token.sol";

/**
 * @title Integration Tests
 * @notice Tests 72-80: Integration tests covering deployment, initialization, and cross-feature functionality
 */
contract IntegrationTest is TokenTest {
    // Test 72: Initial supply minted to owner on deployment
    function test_InitialSupplyMintedToOwner() public view {
        // Arrange & Act (deployment happens in setUp)

        // Assert
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY, "Owner should have initial supply");
        assertEq(token.totalSupply(), INITIAL_SUPPLY, "Total supply should equal initial supply");
    }

    // Test 73: Token name and symbol are correct
    function test_TokenNameAndSymbol() public view {
        // Arrange & Act (deployment happens in setUp)

        // Assert
        assertEq(token.name(), "TOKEN", "Token name should be TOKEN");
        assertEq(token.symbol(), "MYTKN", "Token symbol should be MYTKN");
    }

    // Test 74: Decimals are correct (18)
    function test_TokenDecimals() public view {
        // Arrange & Act (deployment happens in setUp)

        // Assert
        assertEq(token.decimals(), 18, "Token decimals should be 18");
    }

    // Test 75: Owner can perform all manager functions
    function test_OwnerCanPerformAllManagerFunctions() public {
        // Arrange
        address newManager = makeAddr("newManager");
        uint256 mintAmount = 1000e18;
        uint256 burnAmount = 500e18;

        // Act & Assert - Add mint manager
        vm.prank(owner);
        token.addMintManager(newManager);
        assertTrue(token.mintManager(newManager), "Owner should be able to add mint manager");

        // Act & Assert - Add burn manager
        vm.prank(owner);
        token.addBurnManager(newManager);
        assertTrue(token.burnManager(newManager), "Owner should be able to add burn manager");

        // Act & Assert - Add balance manager
        vm.prank(owner);
        token.addBalanceManager(newManager);
        assertTrue(token.balanceManager(newManager), "Owner should be able to add balance manager");

        // Act & Assert - Add blacklist manager
        vm.prank(owner);
        token.addBlacklistManager(newManager);
        assertTrue(token.blacklistManager(newManager), "Owner should be able to add blacklist manager");

        // Act & Assert - Mint tokens
        vm.prank(owner);
        token.mint(user1, mintAmount);
        assertEq(token.balanceOf(user1), mintAmount, "Owner should be able to mint tokens");

        // Act & Assert - Burn tokens
        vm.prank(owner);
        token.burn(user1, burnAmount);
        assertEq(token.balanceOf(user1), mintAmount - burnAmount, "Owner should be able to burn tokens");

        // Act & Assert - Blacklist user
        vm.prank(owner);
        token.blacklistAddress(user2);
        assertTrue(token.isBlacklisted(user2), "Owner should be able to blacklist users");

        // Act & Assert - Add LP
        vm.prank(owner);
        token.addLiquidityPoolAddress(liquidityPool);
        assertTrue(token.isLiquidityPool(liquidityPool), "Owner should be able to add LP");
    }

    // Test 76: Multiple managers can be added for same role
    function test_MultipleManagersForSameRole() public {
        // Arrange
        address manager1 = makeAddr("manager1");
        address manager2 = makeAddr("manager2");
        address manager3 = makeAddr("manager3");
        uint256 mintAmount = 1000e18;

        // Act - Add multiple mint managers
        vm.prank(owner);
        token.addMintManager(manager1);
        vm.prank(owner);
        token.addMintManager(manager2);
        vm.prank(owner);
        token.addMintManager(manager3);

        // Assert - All managers have the role
        assertTrue(token.mintManager(manager1), "Manager1 should have mint role");
        assertTrue(token.mintManager(manager2), "Manager2 should have mint role");
        assertTrue(token.mintManager(manager3), "Manager3 should have mint role");

        // Act & Assert - All managers can mint
        vm.prank(manager1);
        token.mint(user1, mintAmount);
        assertEq(token.balanceOf(user1), mintAmount, "Manager1 should be able to mint");

        vm.prank(manager2);
        token.mint(user2, mintAmount);
        assertEq(token.balanceOf(user2), mintAmount, "Manager2 should be able to mint");

        vm.prank(manager3);
        token.mint(user3, mintAmount);
        assertEq(token.balanceOf(user3), mintAmount, "Manager3 should be able to mint");
    }

    // Test 77: LP addresses cannot be blacklisted
    function test_LPAddressesCannotBeBlacklisted() public {
        // Arrange
        _addLiquidityPool(liquidityPool);

        // Act & Assert
        vm.prank(owner);
        vm.expectRevert(Token.CannotBlacklistLiquidityPool.selector);
        token.blacklistAddress(liquidityPool);

        assertFalse(token.isBlacklisted(liquidityPool), "LP should not be blacklisted");
    }

    // Test 78: LP addresses cannot be burned
    function test_LPAddressesCannotBeBurned() public {
        // Arrange
        _addLiquidityPool(liquidityPool);
        vm.prank(owner);
        token.transfer(liquidityPool, 1000e18);

        // Act & Assert
        vm.prank(owner);
        vm.expectRevert(Token.CannotBurnLiquidityPool.selector);
        token.burn(liquidityPool, 500e18);

        assertEq(token.balanceOf(liquidityPool), 1000e18, "LP balance should remain unchanged");
    }

    // Test 79: Events are emitted correctly for all state changes
    function test_EventsEmittedCorrectly() public {
        // Arrange
        address manager = makeAddr("manager");
        uint256 amount = 1000e18;

        // Test MintManagerAdded event
        vm.expectEmit(true, false, false, false);
        emit Token.MintManagerAdded(manager);
        vm.prank(owner);
        token.addMintManager(manager);

        // Test BurnManagerAdded event
        vm.expectEmit(true, false, false, false);
        emit Token.BurnManagerAdded(manager);
        vm.prank(owner);
        token.addBurnManager(manager);

        // Test BalanceManagerAdded event
        vm.expectEmit(true, false, false, false);
        emit Token.BalanceManagerAdded(manager);
        vm.prank(owner);
        token.addBalanceManager(manager);

        // Test BlacklistManagerAdded event
        vm.expectEmit(true, false, false, false);
        emit Token.BlacklistManagerAdded(manager);
        vm.prank(owner);
        token.addBlacklistManager(manager);

        // Test TokensMinted event
        vm.expectEmit(true, false, false, true);
        emit Token.TokensMinted(user1, amount);
        vm.prank(owner);
        token.mint(user1, amount);

        // Test TokensBurned event
        vm.expectEmit(true, false, false, true);
        emit Token.TokensBurned(user1, amount / 2);
        vm.prank(owner);
        token.burn(user1, amount / 2);

        // Test Blacklisted event
        vm.expectEmit(true, false, false, false);
        emit Token.BlackListed(user2);
        vm.prank(owner);
        token.blacklistAddress(user2);

        // Test Unblacklisted event
        vm.expectEmit(true, false, false, false);
        emit Token.UnBlackListed(user2);
        vm.prank(owner);
        token.unblacklistAddress(user2);

        // Test LiquidityPoolAdded event
        vm.expectEmit(true, false, false, false);
        emit Token.LiquidityPoolAdded(liquidityPool);
        vm.prank(owner);
        token.addLiquidityPoolAddress(liquidityPool);

        // Test LiquidityPoolRemoved event
        vm.expectEmit(true, false, false, false);
        emit Token.LiquidityPoolRemoved(liquidityPool);
        vm.prank(owner);
        token.removeLiquidityPoolAddress(liquidityPool);
    }

    // Test 80: Ownership transfer works (Ownable functionality)
    function test_OwnershipTransfer() public {
        // Arrange
        address newOwner = makeAddr("newOwner");

        // Assert initial owner
        assertEq(token.owner(), owner, "Initial owner should be deployer");

        // Act - Transfer ownership (OpenZeppelin Ownable transfers immediately)
        vm.prank(owner);
        token.transferOwnership(newOwner);

        // Assert ownership transferred immediately
        assertEq(token.owner(), newOwner, "Owner should be transferred immediately");

        // Assert old owner cannot perform owner functions
        vm.prank(owner);
        vm.expectRevert();
        token.addMintManager(user1);

        // Assert new owner can perform owner functions
        vm.prank(newOwner);
        token.addMintManager(user1);
        assertTrue(token.mintManager(user1), "New owner should be able to add managers");
    }
}
