// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Token.t.sol";

/**
 * @title BalanceMovementTest
 * @notice Tests for balance movement functionality
 */
contract BalanceMovementTest is TokenTest {
    // ========================================
    // BALANCE MOVEMENT TESTS
    // ========================================

    /**
     * @notice Test 45: Move balance as owner
     */
    function test_MoveBalance_Success_AsOwner() public {
        // Arrange
        uint256 moveAmount = 5000 * 10 ** 18;
        _mintTokens(user1, moveAmount);

        uint256 user2BalanceBefore = token.balanceOf(user2);

        // Act
        vm.prank(owner);
        vm.expectEmit(true, true, false, true);
        emit Token.BalanceMoved(user1, user2, moveAmount);
        token.moveBalance(user1, user2);

        // Assert
        assertEq(token.balanceOf(user1), 0, "User1 balance should be zero");
        assertEq(token.balanceOf(user2), user2BalanceBefore + moveAmount, "User2 balance should increase");
    }

    /**
     * @notice Test 46: Move balance as balance manager
     */
    function test_MoveBalance_Success_AsBalanceManager() public {
        // Arrange
        _addBalanceManager(balanceManager);
        uint256 moveAmount = 3000 * 10 ** 18;
        _mintTokens(user1, moveAmount);

        uint256 user3BalanceBefore = token.balanceOf(user3);

        // Act
        vm.prank(balanceManager);
        vm.expectEmit(true, true, false, true);
        emit Token.BalanceMoved(user1, user3, moveAmount);
        token.moveBalance(user1, user3);

        // Assert
        assertEq(token.balanceOf(user1), 0, "User1 balance should be zero");
        assertEq(token.balanceOf(user3), user3BalanceBefore + moveAmount, "User3 balance should increase");
    }

    /**
     * @notice Test 47: Revert when moving to zero address
     */
    function test_MoveBalance_RevertWhen_ToZeroAddress() public {
        // Arrange
        _mintTokens(user1, 1000 * 10 ** 18);

        // Act & Assert
        vm.prank(owner);
        vm.expectRevert(Token.CannotMoveToZeroAddress.selector);
        token.moveBalance(user1, address(0));
    }

    /**
     * @notice Test 48: Revert when moving zero amount (empty balance)
     */
    function test_MoveBalance_RevertWhen_ZeroAmount() public {
        // Arrange - user2 has no tokens

        // Act & Assert
        vm.prank(owner);
        vm.expectRevert(Token.CannotMoveZeroAmount.selector);
        token.moveBalance(user2, user3);
    }

    /**
     * @notice Test 49: Revert when non-manager/owner tries to move balance
     */
    function test_MoveBalance_RevertWhen_NotManagerOrOwner() public {
        // Arrange
        _mintTokens(user1, 1000 * 10 ** 18);

        // Act & Assert
        vm.prank(user2);
        vm.expectRevert(Token.NotBalanceManager.selector);
        token.moveBalance(user1, user3);
    }

    /**
     * @notice Test 50: Check correct balances after moving
     */
    function test_MoveBalance_CorrectBalancesAfterMoving() public {
        // Arrange
        uint256 user1Amount = 10000 * 10 ** 18;
        uint256 user2InitialAmount = 5000 * 10 ** 18;

        _mintTokens(user1, user1Amount);
        _mintTokens(user2, user2InitialAmount);

        uint256 totalSupplyBefore = token.totalSupply();

        // Act
        vm.prank(owner);
        token.moveBalance(user1, user2);

        // Assert
        assertEq(token.balanceOf(user1), 0, "User1 should have zero balance");
        assertEq(token.balanceOf(user2), user2InitialAmount + user1Amount, "User2 should have both amounts");
        assertEq(token.totalSupply(), totalSupplyBefore, "Total supply should not change");
    }

    /**
     * @notice Test 51: Check BalanceMoved event is emitted
     */
    function test_MoveBalance_EmitsBalanceMovedEvent() public {
        // Arrange
        uint256 moveAmount = 7500 * 10 ** 18;
        _mintTokens(user3, moveAmount);

        // Act & Assert
        vm.prank(owner);
        vm.expectEmit(true, true, false, true);
        emit Token.BalanceMoved(user3, user1, moveAmount);
        token.moveBalance(user3, user1);
    }

    /**
     * @notice Test 51b: Move balance to same address (edge case)
     */
    function test_MoveBalance_ToSameAddress() public {
        // Arrange
        uint256 amount = 5000 * 10 ** 18;
        _mintTokens(user1, amount);

        // Act
        vm.prank(owner);
        token.moveBalance(user1, user1);

        // Assert - balance should remain the same
        assertEq(token.balanceOf(user1), amount, "User1 balance should remain unchanged");
    }

    /**
     * @notice Test 51c: Move balance from owner
     */
    function test_MoveBalance_FromOwner() public {
        // Arrange
        uint256 ownerBalance = token.balanceOf(owner);
        uint256 user1BalanceBefore = token.balanceOf(user1);

        // Act
        vm.prank(owner);
        token.moveBalance(owner, user1);

        // Assert
        assertEq(token.balanceOf(owner), 0, "Owner balance should be zero");
        assertEq(token.balanceOf(user1), user1BalanceBefore + ownerBalance, "User1 should receive owner's balance");
    }

    /**
     * @notice Test 51d: Multiple balance moves in sequence
     */
    function test_MoveBalance_MultipleMovesInSequence() public {
        // Arrange
        uint256 amount1 = 5000 * 10 ** 18;
        uint256 amount2 = 3000 * 10 ** 18;

        _mintTokens(user1, amount1);
        _mintTokens(user2, amount2);

        // Act
        vm.startPrank(owner);
        token.moveBalance(user1, user3); // user1 -> user3
        token.moveBalance(user2, user3); // user2 -> user3
        vm.stopPrank();

        // Assert
        assertEq(token.balanceOf(user1), 0, "User1 should have zero balance");
        assertEq(token.balanceOf(user2), 0, "User2 should have zero balance");
        assertEq(token.balanceOf(user3), amount1 + amount2, "User3 should have both amounts");
    }
}
