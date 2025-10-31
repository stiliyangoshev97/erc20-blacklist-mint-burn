// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Token.t.sol";

/**
 * @title BurningTest
 * @notice Tests for burning functionality
 */
contract BurningTest is TokenTest {
    // ========================================
    // BURNING TESTS
    // ========================================

    /**
     * @notice Test 37: Burn tokens as owner
     */
    function test_Burn_Success_AsOwner() public {
        // Arrange
        uint256 burnAmount = 1000 * 10 ** 18;
        uint256 initialBalance = token.balanceOf(owner);
        uint256 initialSupply = token.totalSupply();

        // Act
        vm.prank(owner);
        vm.expectEmit(true, false, false, true);
        emit Token.TokensBurned(owner, burnAmount);
        token.burn(owner, burnAmount);

        // Assert
        assertEq(token.balanceOf(owner), initialBalance - burnAmount, "Owner balance should decrease");
        assertEq(token.totalSupply(), initialSupply - burnAmount, "Total supply should decrease");
    }

    /**
     * @notice Test 38: Burn tokens as burn manager
     */
    function test_Burn_Success_AsBurnManager() public {
        // Arrange
        _addBurnManager(burnManager);
        uint256 burnAmount = 500 * 10 ** 18;
        uint256 initialBalance = token.balanceOf(owner);
        uint256 initialSupply = token.totalSupply();

        // Act
        vm.prank(burnManager);
        vm.expectEmit(true, false, false, true);
        emit Token.TokensBurned(owner, burnAmount);
        token.burn(owner, burnAmount);

        // Assert
        assertEq(token.balanceOf(owner), initialBalance - burnAmount, "Owner balance should decrease");
        assertEq(token.totalSupply(), initialSupply - burnAmount, "Total supply should decrease");
    }

    /**
     * @notice Test 39: Revert when burning from zero address
     */
    function test_Burn_RevertWhen_ZeroAddress() public {
        // Act & Assert
        vm.prank(owner);
        vm.expectRevert(Token.CannotBurnZeroAddress.selector);
        token.burn(address(0), 100 * 10 ** 18);
    }

    /**
     * @notice Test 40: Revert when burning from liquidity pool
     */
    function test_Burn_RevertWhen_LiquidityPool() public {
        // Arrange
        _addLiquidityPool(liquidityPool);
        _mintTokens(liquidityPool, 1000 * 10 ** 18);

        // Act & Assert
        vm.prank(owner);
        vm.expectRevert(Token.CannotBurnLiquidityPool.selector);
        token.burn(liquidityPool, 100 * 10 ** 18);
    }

    /**
     * @notice Test 41: Revert when non-manager/owner tries to burn
     */
    function test_Burn_RevertWhen_NotManagerOrOwner() public {
        // Act & Assert
        vm.prank(user1);
        vm.expectRevert(Token.NotBurnManager.selector);
        token.burn(owner, 100 * 10 ** 18);
    }

    /**
     * @notice Test 42: Revert when burning more than balance
     */
    function test_Burn_RevertWhen_InsufficientBalance() public {
        // Arrange
        _mintTokens(user1, 100 * 10 ** 18);
        uint256 burnAmount = 200 * 10 ** 18; // More than user1's balance

        // Act & Assert
        vm.prank(owner);
        vm.expectRevert(); // ERC20InsufficientBalance from OpenZeppelin
        token.burn(user1, burnAmount);
    }

    /**
     * @notice Test 43: Check correct balance after burning
     */
    function test_Burn_CorrectBalanceAfterBurning() public {
        // Arrange
        uint256 mintAmount = 5000 * 10 ** 18;
        uint256 burnAmount = 2000 * 10 ** 18;
        _mintTokens(user1, mintAmount);

        uint256 balanceBefore = token.balanceOf(user1);
        uint256 supplyBefore = token.totalSupply();

        // Act
        vm.prank(owner);
        token.burn(user1, burnAmount);

        // Assert
        assertEq(token.balanceOf(user1), balanceBefore - burnAmount, "User1 balance incorrect");
        assertEq(token.totalSupply(), supplyBefore - burnAmount, "Total supply incorrect");
        assertEq(token.balanceOf(user1), mintAmount - burnAmount, "Final balance should be mint - burn");
    }

    /**
     * @notice Test 44: Check TokensBurned event is emitted
     */
    function test_Burn_EmitsTokensBurnedEvent() public {
        // Arrange
        uint256 burnAmount = 1500 * 10 ** 18;
        _mintTokens(user2, 3000 * 10 ** 18);

        // Act & Assert
        vm.prank(owner);
        vm.expectEmit(true, false, false, true);
        emit Token.TokensBurned(user2, burnAmount);
        token.burn(user2, burnAmount);
    }

    /**
     * @notice Test 44b: Burn entire balance
     */
    function test_Burn_EntireBalance() public {
        // Arrange
        uint256 mintAmount = 10000 * 10 ** 18;
        _mintTokens(user3, mintAmount);

        // Act
        vm.prank(owner);
        token.burn(user3, mintAmount);

        // Assert
        assertEq(token.balanceOf(user3), 0, "User3 should have zero balance");
    }

    /**
     * @notice Test 44c: Multiple burns from same account
     */
    function test_Burn_MultipleBurnsFromSameAccount() public {
        // Arrange
        uint256 mintAmount = 10000 * 10 ** 18;
        uint256 firstBurn = 3000 * 10 ** 18;
        uint256 secondBurn = 2000 * 10 ** 18;
        _mintTokens(user1, mintAmount);

        uint256 initialSupply = token.totalSupply();

        // Act
        vm.startPrank(owner);
        token.burn(user1, firstBurn);
        token.burn(user1, secondBurn);
        vm.stopPrank();

        // Assert
        assertEq(token.balanceOf(user1), mintAmount - firstBurn - secondBurn, "User1 balance should be mint - burns");
        assertEq(
            token.totalSupply(), initialSupply - firstBurn - secondBurn, "Total supply should decrease by both burns"
        );
    }
}
