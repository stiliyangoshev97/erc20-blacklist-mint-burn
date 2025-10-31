// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Token.t.sol";

/**
 * @title RoleManagementTest
 * @notice Tests for role management functions (mint, burn, balance, blacklist managers)
 */
contract RoleManagementTest is TokenTest {
    // ========================================
    // MINT MANAGER TESTS
    // ========================================

    /**
     * @notice Test 1: Add a mint manager (only owner)
     */
    function test_AddMintManager_Success() public {
        // Arrange
        assertFalse(
            token.mintManager(mintManager),
            "Mint manager should not be set initially"
        );

        // Act
        vm.prank(owner);
        vm.expectEmit(true, false, false, false);
        emit Token.MintManagerAdded(mintManager);
        token.addMintManager(mintManager);

        // Assert
        assertTrue(
            token.mintManager(mintManager),
            "Mint manager should be set"
        );
    }

    /**
     * @notice Test 2: Revert when adding zero address as mint manager
     */
    function test_AddMintManager_RevertWhen_ZeroAddress() public {
        // Act & Assert
        vm.prank(owner);
        vm.expectRevert(Token.CannotAssignZeroAddress.selector);
        token.addMintManager(address(0));
    }

    /**
     * @notice Test 3: Revert when non-owner tries to add mint manager
     */
    function test_AddMintManager_RevertWhen_NotOwner() public {
        // Act & Assert
        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSignature(
                "OwnableUnauthorizedAccount(address)",
                user1
            )
        );
        token.addMintManager(mintManager);
    }

    /**
     * @notice Test 4: Remove a mint manager (only owner)
     */
    function test_RemoveMintManager_Success() public {
        // Arrange
        _addMintManager(mintManager);
        assertTrue(
            token.mintManager(mintManager),
            "Mint manager should be set"
        );

        // Act
        vm.prank(owner);
        vm.expectEmit(true, false, false, false);
        emit Token.MintManagerRemoved(mintManager);
        token.removeMintManager(mintManager);

        // Assert
        assertFalse(
            token.mintManager(mintManager),
            "Mint manager should be removed"
        );
    }

    /**
     * @notice Test 5: Revert when non-owner tries to remove mint manager
     */
    function test_RemoveMintManager_RevertWhen_NotOwner() public {
        // Arrange
        _addMintManager(mintManager);

        // Act & Assert
        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSignature(
                "OwnableUnauthorizedAccount(address)",
                user1
            )
        );
        token.removeMintManager(mintManager);
    }

    // ========================================
    // BURN MANAGER TESTS
    // ========================================

    /**
     * @notice Test 6: Add a burn manager (only owner)
     */
    function test_AddBurnManager_Success() public {
        // Arrange
        assertFalse(
            token.burnManager(burnManager),
            "Burn manager should not be set initially"
        );

        // Act
        vm.prank(owner);
        vm.expectEmit(true, false, false, false);
        emit Token.BurnManagerAdded(burnManager);
        token.addBurnManager(burnManager);

        // Assert
        assertTrue(
            token.burnManager(burnManager),
            "Burn manager should be set"
        );
    }

    /**
     * @notice Test 7: Revert when adding zero address as burn manager
     */
    function test_AddBurnManager_RevertWhen_ZeroAddress() public {
        // Act & Assert
        vm.prank(owner);
        vm.expectRevert(Token.CannotAssignZeroAddress.selector);
        token.addBurnManager(address(0));
    }

    /**
     * @notice Test 8: Revert when non-owner tries to add burn manager
     */
    function test_AddBurnManager_RevertWhen_NotOwner() public {
        // Act & Assert
        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSignature(
                "OwnableUnauthorizedAccount(address)",
                user1
            )
        );
        token.addBurnManager(burnManager);
    }

    /**
     * @notice Test 9: Remove a burn manager (only owner)
     */
    function test_RemoveBurnManager_Success() public {
        // Arrange
        _addBurnManager(burnManager);
        assertTrue(
            token.burnManager(burnManager),
            "Burn manager should be set"
        );

        // Act
        vm.prank(owner);
        vm.expectEmit(true, false, false, false);
        emit Token.BurnManagerRemoved(burnManager);
        token.removeBurnManager(burnManager);

        // Assert
        assertFalse(
            token.burnManager(burnManager),
            "Burn manager should be removed"
        );
    }

    /**
     * @notice Test 10: Revert when non-owner tries to remove burn manager
     */
    function test_RemoveBurnManager_RevertWhen_NotOwner() public {
        // Arrange
        _addBurnManager(burnManager);

        // Act & Assert
        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSignature(
                "OwnableUnauthorizedAccount(address)",
                user1
            )
        );
        token.removeBurnManager(burnManager);
    }

    // ========================================
    // BALANCE MANAGER TESTS
    // ========================================

    /**
     * @notice Test 11: Add a balance manager (only owner)
     */
    function test_AddBalanceManager_Success() public {
        // Arrange
        assertFalse(
            token.balanceManager(balanceManager),
            "Balance manager should not be set initially"
        );

        // Act
        vm.prank(owner);
        vm.expectEmit(true, false, false, false);
        emit Token.BalanceManagerAdded(balanceManager);
        token.addBalanceManager(balanceManager);

        // Assert
        assertTrue(
            token.balanceManager(balanceManager),
            "Balance manager should be set"
        );
    }

    /**
     * @notice Test 12: Revert when adding zero address as balance manager
     */
    function test_AddBalanceManager_RevertWhen_ZeroAddress() public {
        // Act & Assert
        vm.prank(owner);
        vm.expectRevert(Token.CannotAssignZeroAddress.selector);
        token.addBalanceManager(address(0));
    }

    /**
     * @notice Test 13: Revert when non-owner tries to add balance manager
     */
    function test_AddBalanceManager_RevertWhen_NotOwner() public {
        // Act & Assert
        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSignature(
                "OwnableUnauthorizedAccount(address)",
                user1
            )
        );
        token.addBalanceManager(balanceManager);
    }

    /**
     * @notice Test 14: Remove a balance manager (only owner)
     */
    function test_RemoveBalanceManager_Success() public {
        // Arrange
        _addBalanceManager(balanceManager);
        assertTrue(
            token.balanceManager(balanceManager),
            "Balance manager should be set"
        );

        // Act
        vm.prank(owner);
        vm.expectEmit(true, false, false, false);
        emit Token.BalanceManagerRemoved(balanceManager);
        token.removeBalanceManager(balanceManager);

        // Assert
        assertFalse(
            token.balanceManager(balanceManager),
            "Balance manager should be removed"
        );
    }

    /**
     * @notice Test 15: Revert when non-owner tries to remove balance manager
     */
    function test_RemoveBalanceManager_RevertWhen_NotOwner() public {
        // Arrange
        _addBalanceManager(balanceManager);

        // Act & Assert
        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSignature(
                "OwnableUnauthorizedAccount(address)",
                user1
            )
        );
        token.removeBalanceManager(balanceManager);
    }

    // ========================================
    // BLACKLIST MANAGER TESTS
    // ========================================

    /**
     * @notice Test 16: Add a blacklist manager (only owner)
     */
    function test_AddBlacklistManager_Success() public {
        // Arrange
        assertFalse(
            token.blacklistManager(blacklistManager),
            "Blacklist manager should not be set initially"
        );

        // Act
        vm.prank(owner);
        vm.expectEmit(true, false, false, false);
        emit Token.BlacklistManagerAdded(blacklistManager);
        token.addBlacklistManager(blacklistManager);

        // Assert
        assertTrue(
            token.blacklistManager(blacklistManager),
            "Blacklist manager should be set"
        );
    }

    /**
     * @notice Test 17: Revert when adding zero address as blacklist manager
     */
    function test_AddBlacklistManager_RevertWhen_ZeroAddress() public {
        // Act & Assert
        vm.prank(owner);
        vm.expectRevert(Token.CannotAssignZeroAddress.selector);
        token.addBlacklistManager(address(0));
    }

    /**
     * @notice Test 18: Revert when non-owner tries to add blacklist manager
     */
    function test_AddBlacklistManager_RevertWhen_NotOwner() public {
        // Act & Assert
        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSignature(
                "OwnableUnauthorizedAccount(address)",
                user1
            )
        );
        token.addBlacklistManager(blacklistManager);
    }

    /**
     * @notice Test 19: Remove a blacklist manager (only owner)
     */
    function test_RemoveBlacklistManager_Success() public {
        // Arrange
        _addBlacklistManager(blacklistManager);
        assertTrue(
            token.blacklistManager(blacklistManager),
            "Blacklist manager should be set"
        );

        // Act
        vm.prank(owner);
        vm.expectEmit(true, false, false, false);
        emit Token.BlacklistManagerRemoved(blacklistManager);
        token.removeBlacklistManager(blacklistManager);

        // Assert
        assertFalse(
            token.blacklistManager(blacklistManager),
            "Blacklist manager should be removed"
        );
    }

    /**
     * @notice Test 20: Revert when non-owner tries to remove blacklist manager
     */
    function test_RemoveBlacklistManager_RevertWhen_NotOwner() public {
        // Arrange
        _addBlacklistManager(blacklistManager);

        // Act & Assert
        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSignature(
                "OwnableUnauthorizedAccount(address)",
                user1
            )
        );
        token.removeBlacklistManager(blacklistManager);
    }
}
