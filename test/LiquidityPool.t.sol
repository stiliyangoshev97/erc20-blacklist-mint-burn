// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Token.t.sol";

/**
 * @title LiquidityPoolTest
 * @notice Tests for liquidity pool management functionality
 */
contract LiquidityPoolTest is TokenTest {
    // Additional LP addresses for testing
    address public liquidityPool2;
    address public liquidityPool3;

    function setUp() public override {
        super.setUp();
        liquidityPool2 = makeAddr("liquidityPool2");
        liquidityPool3 = makeAddr("liquidityPool3");
    }

    // ========================================
    // ADD LIQUIDITY POOL TESTS
    // ========================================

    /**
     * @notice Test 52: Add LP address (only owner)
     */
    function test_AddLiquidityPoolAddress_Success() public {
        // Arrange
        assertFalse(token.isLiquidityPool(liquidityPool), "LP should not be added initially");

        // Act
        vm.prank(owner);
        vm.expectEmit(true, false, false, false);
        emit Token.LiquidityPoolAdded(liquidityPool);
        token.addLiquidityPoolAddress(liquidityPool);

        // Assert
        assertTrue(token.isLiquidityPool(liquidityPool), "LP should be marked as liquidity pool");
    }

    /**
     * @notice Test 53: Revert when LP already added
     */
    function test_AddLiquidityPoolAddress_RevertWhen_AlreadyAdded() public {
        // Arrange
        _addLiquidityPool(liquidityPool);

        // Act & Assert
        vm.prank(owner);
        vm.expectRevert(Token.LiquidityPoolAlreadyAdded.selector);
        token.addLiquidityPoolAddress(liquidityPool);
    }

    /**
     * @notice Test 54: Revert when non-owner tries to add LP
     */
    function test_AddLiquidityPoolAddress_RevertWhen_NotOwner() public {
        // Act & Assert
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user1));
        token.addLiquidityPoolAddress(liquidityPool);
    }

    /**
     * @notice Test 55: Check LiquidityPoolAdded event
     */
    function test_AddLiquidityPoolAddress_EmitsEvent() public {
        // Act & Assert
        vm.prank(owner);
        vm.expectEmit(true, false, false, false);
        emit Token.LiquidityPoolAdded(liquidityPool2);
        token.addLiquidityPoolAddress(liquidityPool2);
    }

    // ========================================
    // REMOVE LIQUIDITY POOL TESTS
    // ========================================

    /**
     * @notice Test 56: Remove LP address (only owner)
     */
    function test_RemoveLiquidityPoolAddress_Success() public {
        // Arrange
        _addLiquidityPool(liquidityPool);
        assertTrue(token.isLiquidityPool(liquidityPool), "LP should be added");

        // Act
        vm.prank(owner);
        vm.expectEmit(true, false, false, false);
        emit Token.LiquidityPoolRemoved(liquidityPool);
        token.removeLiquidityPoolAddress(liquidityPool);

        // Assert
        assertFalse(token.isLiquidityPool(liquidityPool), "LP should be removed");
    }

    /**
     * @notice Test 57: Revert when LP not found
     */
    function test_RemoveLiquidityPoolAddress_RevertWhen_NotFound() public {
        // Act & Assert
        vm.prank(owner);
        vm.expectRevert(Token.LiquidityPoolNotFound.selector);
        token.removeLiquidityPoolAddress(liquidityPool);
    }

    /**
     * @notice Test 58: Revert when non-owner tries to remove LP
     */
    function test_RemoveLiquidityPoolAddress_RevertWhen_NotOwner() public {
        // Arrange
        _addLiquidityPool(liquidityPool);

        // Act & Assert
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user1));
        token.removeLiquidityPoolAddress(liquidityPool);
    }

    /**
     * @notice Test 59: Check LiquidityPoolRemoved event
     */
    function test_RemoveLiquidityPoolAddress_EmitsEvent() public {
        // Arrange
        _addLiquidityPool(liquidityPool2);

        // Act & Assert
        vm.prank(owner);
        vm.expectEmit(true, false, false, false);
        emit Token.LiquidityPoolRemoved(liquidityPool2);
        token.removeLiquidityPoolAddress(liquidityPool2);
    }

    // ========================================
    // GET LIQUIDITY POOLS TESTS
    // ========================================

    /**
     * @notice Test 60: Get all LP addresses (view function)
     */
    function test_GetLiquidityPools_ViewFunction() public {
        // Test empty array
        address[] memory pools = token.getLiquidityPools();
        assertEq(pools.length, 0, "Should have no LPs initially");

        // Add one LP
        _addLiquidityPool(liquidityPool);
        pools = token.getLiquidityPools();
        assertEq(pools.length, 1, "Should have 1 LP");
        assertEq(pools[0], liquidityPool, "First LP should match");

        // Add second LP
        _addLiquidityPool(liquidityPool2);
        pools = token.getLiquidityPools();
        assertEq(pools.length, 2, "Should have 2 LPs");
        assertEq(pools[1], liquidityPool2, "Second LP should match");
    }

    /**
     * @notice Test 61: Verify array updates after add/remove
     */
    function test_GetLiquidityPools_ArrayUpdatesAfterAddRemove() public {
        // Add three LPs
        vm.startPrank(owner);
        token.addLiquidityPoolAddress(liquidityPool);
        token.addLiquidityPoolAddress(liquidityPool2);
        token.addLiquidityPoolAddress(liquidityPool3);
        vm.stopPrank();

        address[] memory pools = token.getLiquidityPools();
        assertEq(pools.length, 3, "Should have 3 LPs");

        // Remove middle LP
        vm.prank(owner);
        token.removeLiquidityPoolAddress(liquidityPool2);

        pools = token.getLiquidityPools();
        assertEq(pools.length, 2, "Should have 2 LPs after removal");

        // Verify liquidityPool2 is not in the array
        bool found = false;
        for (uint256 i = 0; i < pools.length; i++) {
            if (pools[i] == liquidityPool2) {
                found = true;
                break;
            }
        }
        assertFalse(found, "liquidityPool2 should not be in array");
    }

    /**
     * @notice Test 61b: Add multiple LPs and verify all are tracked
     */
    function test_AddMultipleLiquidityPools() public {
        // Arrange & Act
        vm.startPrank(owner);
        token.addLiquidityPoolAddress(liquidityPool);
        token.addLiquidityPoolAddress(liquidityPool2);
        token.addLiquidityPoolAddress(liquidityPool3);
        vm.stopPrank();

        // Assert
        assertTrue(token.isLiquidityPool(liquidityPool), "LP1 should be added");
        assertTrue(token.isLiquidityPool(liquidityPool2), "LP2 should be added");
        assertTrue(token.isLiquidityPool(liquidityPool3), "LP3 should be added");

        address[] memory pools = token.getLiquidityPools();
        assertEq(pools.length, 3, "Should have 3 LPs");
    }

    /**
     * @notice Test 61c: Cannot blacklist LP address
     */
    function test_CannotBlacklistLiquidityPool() public {
        // Arrange
        _addLiquidityPool(liquidityPool);

        // Act & Assert
        vm.prank(owner);
        vm.expectRevert(Token.CannotBlacklistLiquidityPool.selector);
        token.blacklistAddress(liquidityPool);
    }

    /**
     * @notice Test 61d: Cannot burn from LP address
     */
    function test_CannotBurnFromLiquidityPool() public {
        // Arrange
        _addLiquidityPool(liquidityPool);
        _mintTokens(liquidityPool, 1000 * 10 ** 18);

        // Act & Assert
        vm.prank(owner);
        vm.expectRevert(Token.CannotBurnLiquidityPool.selector);
        token.burn(liquidityPool, 100 * 10 ** 18);
    }

    /**
     * @notice Test 61e: Can transfer to/from LP address
     */
    function test_CanTransferToFromLiquidityPool() public {
        // Arrange
        _addLiquidityPool(liquidityPool);
        _mintTokens(user1, 5000 * 10 ** 18);

        // Act - Transfer to LP
        vm.prank(user1);
        token.transfer(liquidityPool, 1000 * 10 ** 18);

        // Assert
        assertEq(token.balanceOf(liquidityPool), 1000 * 10 ** 18, "LP should receive tokens");
        assertEq(token.balanceOf(user1), 4000 * 10 ** 18, "User1 balance should decrease");

        // Act - Transfer from LP
        vm.prank(liquidityPool);
        token.transfer(user2, 500 * 10 ** 18);

        // Assert
        assertEq(token.balanceOf(liquidityPool), 500 * 10 ** 18, "LP balance should decrease");
        assertEq(token.balanceOf(user2), 500 * 10 ** 18, "User2 should receive tokens");
    }

    /**
     * @notice Test 61f: Remove all LPs
     */
    function test_RemoveAllLiquidityPools() public {
        // Arrange
        vm.startPrank(owner);
        token.addLiquidityPoolAddress(liquidityPool);
        token.addLiquidityPoolAddress(liquidityPool2);
        token.addLiquidityPoolAddress(liquidityPool3);
        vm.stopPrank();

        assertEq(token.getLiquidityPools().length, 3, "Should have 3 LPs");

        // Act - Remove all
        vm.startPrank(owner);
        token.removeLiquidityPoolAddress(liquidityPool);
        token.removeLiquidityPoolAddress(liquidityPool2);
        token.removeLiquidityPoolAddress(liquidityPool3);
        vm.stopPrank();

        // Assert
        assertEq(token.getLiquidityPools().length, 0, "Should have no LPs");
        assertFalse(token.isLiquidityPool(liquidityPool), "LP1 should be removed");
        assertFalse(token.isLiquidityPool(liquidityPool2), "LP2 should be removed");
        assertFalse(token.isLiquidityPool(liquidityPool3), "LP3 should be removed");
    }
}
