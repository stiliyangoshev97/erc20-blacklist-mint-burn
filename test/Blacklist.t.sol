// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Token.t.sol";

/**
 * @title BlacklistTest
 * @notice Tests for blacklist functionality
 */
contract BlacklistTest is TokenTest {
    
    // ========================================
    // BLACKLIST ADDRESS TESTS
    // ========================================
    
    /**
     * @notice Test 21: Blacklist an address (manager or owner)
     */
    function test_BlacklistAddress_Success_AsOwner() public {
        // Arrange
        assertFalse(token.isBlacklisted(user1), "User1 should not be blacklisted initially");
        
        // Act
        vm.prank(owner);
        vm.expectEmit(true, false, false, false);
        emit Token.BlackListed(user1);
        token.blacklistAddress(user1);
        
        // Assert
        assertTrue(token.isBlacklisted(user1), "User1 should be blacklisted");
    }
    
    /**
     * @notice Test 21b: Blacklist an address as blacklist manager
     */
    function test_BlacklistAddress_Success_AsManager() public {
        // Arrange
        _addBlacklistManager(blacklistManager);
        assertFalse(token.isBlacklisted(user1), "User1 should not be blacklisted initially");
        
        // Act
        vm.prank(blacklistManager);
        vm.expectEmit(true, false, false, false);
        emit Token.BlackListed(user1);
        token.blacklistAddress(user1);
        
        // Assert
        assertTrue(token.isBlacklisted(user1), "User1 should be blacklisted");
    }
    
    /**
     * @notice Test 22: Revert when blacklisting zero address
     */
    function test_BlacklistAddress_RevertWhen_ZeroAddress() public {
        // Act & Assert
        vm.prank(owner);
        vm.expectRevert(Token.CannotBlacklistZeroAddress.selector);
        token.blacklistAddress(address(0));
    }
    
    /**
     * @notice Test 23: Revert when blacklisting liquidity pool
     */
    function test_BlacklistAddress_RevertWhen_LiquidityPool() public {
        // Arrange
        _addLiquidityPool(liquidityPool);
        
        // Act & Assert
        vm.prank(owner);
        vm.expectRevert(Token.CannotBlacklistLiquidityPool.selector);
        token.blacklistAddress(liquidityPool);
    }
    
    /**
     * @notice Test 24: Revert when address already blacklisted
     */
    function test_BlacklistAddress_RevertWhen_AlreadyBlacklisted() public {
        // Arrange
        _blacklistAddress(user1);
        
        // Act & Assert
        vm.prank(owner);
        vm.expectRevert(Token.AddressAlreadyBlacklisted.selector);
        token.blacklistAddress(user1);
    }
    
    /**
     * @notice Test 25: Revert when non-manager/owner tries to blacklist
     */
    function test_BlacklistAddress_RevertWhen_NotManagerOrOwner() public {
        // Act & Assert
        vm.prank(user2);
        vm.expectRevert(Token.NotBlackListManager.selector);
        token.blacklistAddress(user1);
    }
    
    // ========================================
    // UNBLACKLIST ADDRESS TESTS
    // ========================================
    
    /**
     * @notice Test 26: Unblacklist an address (manager or owner)
     */
    function test_UnblacklistAddress_Success_AsOwner() public {
        // Arrange
        _blacklistAddress(user1);
        assertTrue(token.isBlacklisted(user1), "User1 should be blacklisted");
        
        // Act
        vm.prank(owner);
        vm.expectEmit(true, false, false, false);
        emit Token.UnBlackListed(user1);
        token.unblacklistAddress(user1);
        
        // Assert
        assertFalse(token.isBlacklisted(user1), "User1 should not be blacklisted");
    }
    
    /**
     * @notice Test 26b: Unblacklist an address as blacklist manager
     */
    function test_UnblacklistAddress_Success_AsManager() public {
        // Arrange
        _addBlacklistManager(blacklistManager);
        _blacklistAddress(user1);
        assertTrue(token.isBlacklisted(user1), "User1 should be blacklisted");
        
        // Act
        vm.prank(blacklistManager);
        vm.expectEmit(true, false, false, false);
        emit Token.UnBlackListed(user1);
        token.unblacklistAddress(user1);
        
        // Assert
        assertFalse(token.isBlacklisted(user1), "User1 should not be blacklisted");
    }
    
    /**
     * @notice Test 27: Revert when address not blacklisted
     */
    function test_UnblacklistAddress_RevertWhen_NotBlacklisted() public {
        // Arrange
        assertFalse(token.isBlacklisted(user1), "User1 should not be blacklisted");
        
        // Act & Assert
        vm.prank(owner);
        vm.expectRevert(Token.AddressNotBlacklisted.selector);
        token.unblacklistAddress(user1);
    }
    
    /**
     * @notice Test 28: Revert when non-manager/owner tries to unblacklist
     */
    function test_UnblacklistAddress_RevertWhen_NotManagerOrOwner() public {
        // Arrange
        _blacklistAddress(user1);
        
        // Act & Assert
        vm.prank(user2);
        vm.expectRevert(Token.NotBlackListManager.selector);
        token.unblacklistAddress(user1);
    }
    
    // ========================================
    // VIEW FUNCTION TESTS
    // ========================================
    
    /**
     * @notice Test 29: Check if address is blacklisted (view function)
     */
    function test_IsAddressBlacklisted_ViewFunction() public {
        // Test not blacklisted
        assertFalse(token.isAddressBlacklisted(user1), "User1 should not be blacklisted");
        
        // Blacklist user1
        _blacklistAddress(user1);
        
        // Test blacklisted
        assertTrue(token.isAddressBlacklisted(user1), "User1 should be blacklisted");
        
        // Test other users still not blacklisted
        assertFalse(token.isAddressBlacklisted(user2), "User2 should not be blacklisted");
        assertFalse(token.isAddressBlacklisted(user3), "User3 should not be blacklisted");
    }
}
