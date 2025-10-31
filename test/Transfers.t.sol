// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Token.t.sol";

/**
 * @title TransfersTest
 * @notice Tests for transfer and transferFrom functionality (overridden)
 */
contract TransfersTest is TokenTest {
    // ========================================
    // TRANSFER TESTS
    // ========================================

    /**
     * @notice Test 62: Transfer tokens between non-blacklisted addresses
     */
    function test_Transfer_Success_BetweenNonBlacklistedAddresses() public {
        // Arrange
        uint256 transferAmount = 1000 * 10 ** 18;
        _mintTokens(user1, 5000 * 10 ** 18);

        uint256 user1BalanceBefore = token.balanceOf(user1);
        uint256 user2BalanceBefore = token.balanceOf(user2);

        // Act
        vm.prank(user1);
        bool success = token.transfer(user2, transferAmount);

        // Assert
        assertTrue(success, "Transfer should succeed");
        assertEq(token.balanceOf(user1), user1BalanceBefore - transferAmount, "User1 balance should decrease");
        assertEq(token.balanceOf(user2), user2BalanceBefore + transferAmount, "User2 balance should increase");
    }

    /**
     * @notice Test 63: Revert when sender is blacklisted
     */
    function test_Transfer_RevertWhen_SenderBlacklisted() public {
        // Arrange
        _mintTokens(user1, 5000 * 10 ** 18);
        _blacklistAddress(user1);

        // Act & Assert
        vm.prank(user1);
        vm.expectRevert(Token.BlacklistedAddress.selector);
        token.transfer(user2, 1000 * 10 ** 18);
    }

    /**
     * @notice Test 64: Revert when recipient is blacklisted
     */
    function test_Transfer_RevertWhen_RecipientBlacklisted() public {
        // Arrange
        _mintTokens(user1, 5000 * 10 ** 18);
        _blacklistAddress(user2);

        // Act & Assert
        vm.prank(user1);
        vm.expectRevert(Token.BlacklistedAddress.selector);
        token.transfer(user2, 1000 * 10 ** 18);
    }

    /**
     * @notice Test 65: Check balances after transfer
     */
    function test_Transfer_CheckBalancesAfterTransfer() public {
        // Arrange
        uint256 user1InitialAmount = 10000 * 10 ** 18;
        uint256 transferAmount = 3000 * 10 ** 18;
        _mintTokens(user1, user1InitialAmount);

        // Act
        vm.prank(user1);
        token.transfer(user2, transferAmount);

        // Assert
        assertEq(token.balanceOf(user1), user1InitialAmount - transferAmount, "User1 should have correct balance");
        assertEq(token.balanceOf(user2), transferAmount, "User2 should have correct balance");
    }

    /**
     * @notice Test 66: Transfer to/from liquidity pool (should work)
     */
    function test_Transfer_ToFromLiquidityPool() public {
        // Arrange
        _addLiquidityPool(liquidityPool);
        _mintTokens(user1, 10000 * 10 ** 18);

        // Act - Transfer to LP
        vm.prank(user1);
        token.transfer(liquidityPool, 5000 * 10 ** 18);

        // Assert
        assertEq(token.balanceOf(liquidityPool), 5000 * 10 ** 18, "LP should receive tokens");
        assertEq(token.balanceOf(user1), 5000 * 10 ** 18, "User1 balance should decrease");

        // Act - Transfer from LP
        vm.prank(liquidityPool);
        token.transfer(user3, 2000 * 10 ** 18);

        // Assert
        assertEq(token.balanceOf(liquidityPool), 3000 * 10 ** 18, "LP balance should decrease");
        assertEq(token.balanceOf(user3), 2000 * 10 ** 18, "User3 should receive tokens");
    }

    // ========================================
    // TRANSFERFROM TESTS
    // ========================================

    /**
     * @notice Test 67: TransferFrom with approval between non-blacklisted addresses
     */
    function test_TransferFrom_Success_WithApproval() public {
        // Arrange
        uint256 transferAmount = 2000 * 10 ** 18;
        _mintTokens(user1, 10000 * 10 ** 18);

        // User1 approves user2 to spend tokens
        vm.prank(user1);
        token.approve(user2, transferAmount);

        uint256 user1BalanceBefore = token.balanceOf(user1);
        uint256 user3BalanceBefore = token.balanceOf(user3);

        // Act - User2 transfers from user1 to user3
        vm.prank(user2);
        bool success = token.transferFrom(user1, user3, transferAmount);

        // Assert
        assertTrue(success, "TransferFrom should succeed");
        assertEq(token.balanceOf(user1), user1BalanceBefore - transferAmount, "User1 balance should decrease");
        assertEq(token.balanceOf(user3), user3BalanceBefore + transferAmount, "User3 balance should increase");
    }

    /**
     * @notice Test 68: Revert when 'from' address is blacklisted
     */
    function test_TransferFrom_RevertWhen_FromAddressBlacklisted() public {
        // Arrange
        uint256 transferAmount = 1000 * 10 ** 18;
        _mintTokens(user1, 5000 * 10 ** 18);

        vm.prank(user1);
        token.approve(user2, transferAmount);

        _blacklistAddress(user1);

        // Act & Assert
        vm.prank(user2);
        vm.expectRevert(Token.BlacklistedAddress.selector);
        token.transferFrom(user1, user3, transferAmount);
    }

    /**
     * @notice Test 69: Revert when 'to' address is blacklisted
     */
    function test_TransferFrom_RevertWhen_ToAddressBlacklisted() public {
        // Arrange
        uint256 transferAmount = 1000 * 10 ** 18;
        _mintTokens(user1, 5000 * 10 ** 18);

        vm.prank(user1);
        token.approve(user2, transferAmount);

        _blacklistAddress(user3);

        // Act & Assert
        vm.prank(user2);
        vm.expectRevert(Token.BlacklistedAddress.selector);
        token.transferFrom(user1, user3, transferAmount);
    }

    /**
     * @notice Test 70: Check balances and allowances after transferFrom
     */
    function test_TransferFrom_CheckBalancesAndAllowances() public {
        // Arrange
        uint256 approvalAmount = 5000 * 10 ** 18;
        uint256 transferAmount = 3000 * 10 ** 18;
        _mintTokens(user1, 10000 * 10 ** 18);

        vm.prank(user1);
        token.approve(user2, approvalAmount);

        // Act
        vm.prank(user2);
        token.transferFrom(user1, user3, transferAmount);

        // Assert
        assertEq(token.balanceOf(user1), 7000 * 10 ** 18, "User1 balance should decrease");
        assertEq(token.balanceOf(user3), transferAmount, "User3 should receive tokens");
        assertEq(token.allowance(user1, user2), approvalAmount - transferAmount, "Allowance should decrease");
    }

    /**
     * @notice Test 71: TransferFrom to/from liquidity pool (should work)
     */
    function test_TransferFrom_ToFromLiquidityPool() public {
        // Arrange
        _addLiquidityPool(liquidityPool);
        _mintTokens(user1, 10000 * 10 ** 18);

        uint256 transferAmount = 4000 * 10 ** 18;

        // User1 approves user2 to spend tokens
        vm.prank(user1);
        token.approve(user2, transferAmount);

        // Act - User2 transfers from user1 to LP
        vm.prank(user2);
        token.transferFrom(user1, liquidityPool, transferAmount);

        // Assert
        assertEq(token.balanceOf(liquidityPool), transferAmount, "LP should receive tokens");
        assertEq(token.balanceOf(user1), 6000 * 10 ** 18, "User1 balance should decrease");

        // Arrange - LP approves user2 to spend tokens
        vm.prank(liquidityPool);
        token.approve(user2, 2000 * 10 ** 18);

        // Act - User2 transfers from LP to user3
        vm.prank(user2);
        token.transferFrom(liquidityPool, user3, 2000 * 10 ** 18);

        // Assert
        assertEq(token.balanceOf(liquidityPool), 2000 * 10 ** 18, "LP balance should decrease");
        assertEq(token.balanceOf(user3), 2000 * 10 ** 18, "User3 should receive tokens");
    }

    /**
     * @notice Test 71b: Multiple transfers in sequence
     */
    function test_Transfer_MultipleTransfersInSequence() public {
        // Arrange
        _mintTokens(user1, 10000 * 10 ** 18);

        // Act
        vm.startPrank(user1);
        token.transfer(user2, 2000 * 10 ** 18);
        token.transfer(user3, 3000 * 10 ** 18);
        vm.stopPrank();

        // Assert
        assertEq(token.balanceOf(user1), 5000 * 10 ** 18, "User1 should have correct balance");
        assertEq(token.balanceOf(user2), 2000 * 10 ** 18, "User2 should have correct balance");
        assertEq(token.balanceOf(user3), 3000 * 10 ** 18, "User3 should have correct balance");
    }

    /**
     * @notice Test 71c: Transfer zero amount (should work)
     */
    function test_Transfer_ZeroAmount() public {
        // Arrange
        _mintTokens(user1, 5000 * 10 ** 18);
        uint256 user1BalanceBefore = token.balanceOf(user1);
        uint256 user2BalanceBefore = token.balanceOf(user2);

        // Act
        vm.prank(user1);
        bool success = token.transfer(user2, 0);

        // Assert
        assertTrue(success, "Zero amount transfer should succeed");
        assertEq(token.balanceOf(user1), user1BalanceBefore, "User1 balance should not change");
        assertEq(token.balanceOf(user2), user2BalanceBefore, "User2 balance should not change");
    }

    /**
     * @notice Test 71d: TransferFrom with insufficient allowance
     */
    function test_TransferFrom_RevertWhen_InsufficientAllowance() public {
        // Arrange
        _mintTokens(user1, 10000 * 10 ** 18);

        vm.prank(user1);
        token.approve(user2, 1000 * 10 ** 18);

        // Act & Assert - Try to transfer more than allowance
        vm.prank(user2);
        vm.expectRevert(); // ERC20InsufficientAllowance from OpenZeppelin
        token.transferFrom(user1, user3, 2000 * 10 ** 18);
    }

    /**
     * @notice Test 71e: Transfer entire balance
     */
    function test_Transfer_EntireBalance() public {
        // Arrange
        uint256 amount = 7500 * 10 ** 18;
        _mintTokens(user1, amount);

        // Act
        vm.prank(user1);
        token.transfer(user2, amount);

        // Assert
        assertEq(token.balanceOf(user1), 0, "User1 should have zero balance");
        assertEq(token.balanceOf(user2), amount, "User2 should have entire amount");
    }

    /**
     * @notice Test 71f: TransferFrom entire approved amount
     */
    function test_TransferFrom_EntireApprovedAmount() public {
        // Arrange
        uint256 amount = 5000 * 10 ** 18;
        _mintTokens(user1, 10000 * 10 ** 18);

        vm.prank(user1);
        token.approve(user2, amount);

        // Act
        vm.prank(user2);
        token.transferFrom(user1, user3, amount);

        // Assert
        assertEq(token.allowance(user1, user2), 0, "Allowance should be zero");
        assertEq(token.balanceOf(user3), amount, "User3 should receive entire amount");
    }
}
