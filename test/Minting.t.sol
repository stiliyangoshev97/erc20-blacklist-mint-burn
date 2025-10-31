// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Token.t.sol";

/**
 * @title MintingTest
 * @notice Tests for minting functionality
 */
contract MintingTest is TokenTest {
    // ========================================
    // MINT AS OWNER TESTS
    // ========================================

    /**
     * @notice Test 30: Mint tokens as owner
     */
    function test_Mint_Success_AsOwner() public {
        // Arrange
        uint256 initialBalance = token.balanceOf(user1);
        uint256 initialSupply = token.totalSupply();

        // Act
        vm.prank(owner);
        vm.expectEmit(true, false, false, true);
        emit Token.TokensMinted(user1, MINT_AMOUNT);
        token.mint(user1, MINT_AMOUNT);

        // Assert
        assertEq(token.balanceOf(user1), initialBalance + MINT_AMOUNT, "Balance should increase by mint amount");
        assertEq(token.totalSupply(), initialSupply + MINT_AMOUNT, "Total supply should increase by mint amount");
    }

    /**
     * @notice Test 31: Mint tokens as mint manager
     */
    function test_Mint_Success_AsMintManager() public {
        // Arrange
        _addMintManager(mintManager);
        uint256 initialBalance = token.balanceOf(user1);
        uint256 initialSupply = token.totalSupply();

        // Act
        vm.prank(mintManager);
        vm.expectEmit(true, false, false, true);
        emit Token.TokensMinted(user1, MINT_AMOUNT);
        token.mint(user1, MINT_AMOUNT);

        // Assert
        assertEq(token.balanceOf(user1), initialBalance + MINT_AMOUNT, "Balance should increase by mint amount");
        assertEq(token.totalSupply(), initialSupply + MINT_AMOUNT, "Total supply should increase by mint amount");
    }

    // ========================================
    // MINT REVERT TESTS
    // ========================================

    /**
     * @notice Test 32: Revert when minting to zero address
     */
    function test_Mint_RevertWhen_ZeroAddress() public {
        // Act & Assert
        vm.prank(owner);
        vm.expectRevert(Token.CannotMintToZeroAddress.selector);
        token.mint(address(0), MINT_AMOUNT);
    }

    /**
     * @notice Test 33: Revert when minting to blacklisted address
     */
    function test_Mint_RevertWhen_BlacklistedAddress() public {
        // Arrange
        _blacklistAddress(user1);

        // Act & Assert
        vm.prank(owner);
        vm.expectRevert(Token.BlacklistedAddress.selector);
        token.mint(user1, MINT_AMOUNT);
    }

    /**
     * @notice Test 34: Revert when non-manager/owner tries to mint
     */
    function test_Mint_RevertWhen_NotManagerOrOwner() public {
        // Act & Assert
        vm.prank(user2);
        vm.expectRevert(Token.NotMintManager.selector);
        token.mint(user1, MINT_AMOUNT);
    }

    // ========================================
    // MINT BALANCE VERIFICATION TESTS
    // ========================================

    /**
     * @notice Test 35: Check correct balance after minting
     */
    function test_Mint_BalanceVerification() public {
        // Arrange
        uint256 firstMint = 1000 * 10 ** 18;
        uint256 secondMint = 2000 * 10 ** 18;

        // Act - First mint
        vm.prank(owner);
        token.mint(user1, firstMint);

        // Assert - First mint
        assertEq(token.balanceOf(user1), firstMint, "Balance should equal first mint amount");

        // Act - Second mint
        vm.prank(owner);
        token.mint(user1, secondMint);

        // Assert - Second mint (cumulative)
        assertEq(token.balanceOf(user1), firstMint + secondMint, "Balance should equal sum of both mints");
    }

    /**
     * @notice Test 36: Check TokensMinted event is emitted
     */
    function test_Mint_EventEmission() public {
        // Arrange
        uint256 mintAmount = 5000 * 10 ** 18;

        // Act & Assert - Event should be emitted with correct parameters
        vm.prank(owner);
        vm.expectEmit(true, false, false, true);
        emit Token.TokensMinted(user2, mintAmount);
        token.mint(user2, mintAmount);
    }

    // ========================================
    // ADDITIONAL EDGE CASE TESTS
    // ========================================

    /**
     * @notice Test: Mint zero amount (should succeed but not change balance)
     */
    function test_Mint_ZeroAmount() public {
        // Arrange
        uint256 initialBalance = token.balanceOf(user1);
        uint256 initialSupply = token.totalSupply();

        // Act
        vm.prank(owner);
        token.mint(user1, 0);

        // Assert
        assertEq(token.balanceOf(user1), initialBalance, "Balance should not change");
        assertEq(token.totalSupply(), initialSupply, "Total supply should not change");
    }

    /**
     * @notice Test: Multiple managers can mint
     */
    function test_Mint_MultipleManagers() public {
        // Arrange
        address manager1 = makeAddr("manager1");
        address manager2 = makeAddr("manager2");
        _addMintManager(manager1);
        _addMintManager(manager2);

        // Act - Manager 1 mints
        vm.prank(manager1);
        token.mint(user1, MINT_AMOUNT);

        // Act - Manager 2 mints
        vm.prank(manager2);
        token.mint(user2, MINT_AMOUNT);

        // Assert
        assertEq(token.balanceOf(user1), MINT_AMOUNT, "User1 should have minted amount");
        assertEq(token.balanceOf(user2), MINT_AMOUNT, "User2 should have minted amount");
    }

    /**
     * @notice Test: Mint to liquidity pool (should succeed)
     */
    function test_Mint_ToLiquidityPool() public {
        // Arrange
        _addLiquidityPool(liquidityPool);
        uint256 initialBalance = token.balanceOf(liquidityPool);

        // Act
        vm.prank(owner);
        token.mint(liquidityPool, MINT_AMOUNT);

        // Assert
        assertEq(token.balanceOf(liquidityPool), initialBalance + MINT_AMOUNT, "LP should receive minted tokens");
    }

    /**
     * @notice Test: Large mint amount
     */
    function test_Mint_LargeAmount() public {
        // Arrange
        uint256 largeAmount = 1_000_000_000 * 10 ** 18; // 1 billion tokens
        uint256 initialSupply = token.totalSupply();

        // Act
        vm.prank(owner);
        token.mint(user1, largeAmount);

        // Assert
        assertEq(token.balanceOf(user1), largeAmount, "User1 should have large amount");
        assertEq(token.totalSupply(), initialSupply + largeAmount, "Total supply should increase by large amount");
    }
}
