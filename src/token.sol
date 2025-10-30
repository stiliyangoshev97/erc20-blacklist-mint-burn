// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token is ERC20, Ownable {
    // Custom errors
    error NotMintManager();
    error NotBurnManager();
    error NotBalanceManager();
    error NotBlackListManager();
    error BlacklistedAddress();
    error AddressAlreadyBlacklisted();
    error AddressNotBlacklisted();
    error CannotBlacklistZeroAddress();
    error CannotBlacklistLiquidityPool();
    error CannotMintToZeroAddress();
    error CannotBurnLiquidityPool();
    error CannotBurnZeroAddress();
    error CannotMoveToZeroAddress();
    error CannotMoveZeroAmount();
    error CannotAssignZeroAddress();
    error LiquidityPoolAlreadyAdded();
    error LiquidityPoolNotFound();

    uint256 private constant INITIAL_SUPPLY = 1000000;

    // Liquidity pool management - using mapping for O(1) lookup + array for enumeration
    mapping(address => bool) public isLiquidityPool;
    address[] public liquidityPoolAddresses;

    // Role-based access control mappings
    mapping(address => bool) public mintManager;
    mapping(address => bool) public burnManager;
    mapping(address => bool) public balanceManager;
    mapping(address => bool) public blacklistManager;

    // Blacklist mapping
    mapping(address => bool) public isBlacklisted;

    // Events
    event MintManagerAdded(address indexed account);
    event MintManagerRemoved(address indexed account);
    event BurnManagerAdded(address indexed account);
    event BurnManagerRemoved(address indexed account);
    event BalanceManagerAdded(address indexed account);
    event BalanceManagerRemoved(address indexed account);
    event BlacklistManagerAdded(address indexed account);
    event BlacklistManagerRemoved(address indexed account);
    event BlackListed(address indexed account);
    event UnBlackListed(address indexed account);
    event TokensMinted(address indexed to, uint256 amount);
    event TokensBurned(address indexed from, uint256 amount);
    event BalanceMoved(address indexed from, address indexed to, uint256 amount);
    event LiquidityPoolAdded(address indexed liquidityPool);
    event LiquidityPoolRemoved(address indexed liquidityPool);

    // Constructor to initialize the token with an initial supply to the owner
    constructor(address initialOwner) ERC20("TOKEN", "MYTKN") Ownable(initialOwner) {
        _mint(initialOwner, INITIAL_SUPPLY * (10 ** decimals()));
    }

    // Modifier to check if the caller can mint tokens
    modifier onlyMintManager() {
        if (!mintManager[msg.sender]) {
            revert NotMintManager();
        }
        _;
    }

    // Modifier to check if the caller can burn tokens
    modifier onlyBurnManager() {
        if (!burnManager[msg.sender]) {
            revert NotBurnManager();
        }
        _;
    }

    // Modifier to check if the caller can move balances
    modifier onlyBalanceManager() {
        if (!balanceManager[msg.sender]) {
            revert NotBalanceManager();
        }
        _;
    }

    // Modifier to check if the caller can manage the blacklist
    modifier onlyBlacklistManager() {
        if (!blacklistManager[msg.sender]) {
            revert NotBlackListManager();
        }
        _;
    }

    // Modifier to check if an address is blacklisted
    modifier addrBlacklisted(address account) {
        if (isBlacklisted[account]) {
            revert BlacklistedAddress();
        }
        _;
    }

    // Modifier to check if the caller is a mint manager or owner
    modifier onlyMintManagerOrOwner() {
        if (!mintManager[msg.sender] && msg.sender != owner()) {
            revert NotMintManager();
        }
        _;
    }

    // Modifier to check if the caller is a burn manager or owner
    modifier onlyBurnManagerOrOwner() {
        if (!burnManager[msg.sender] && msg.sender != owner()) {
            revert NotBurnManager();
        }
        _;
    }

    // Modifier to check if the caller is a balance manager or owner
    modifier onlyBalanceManagerOrOwner() {
        if (!balanceManager[msg.sender] && msg.sender != owner()) {
            revert NotBalanceManager();
        }
        _;
    }

    // Modifier to check if the caller is a blacklist manager or owner
    modifier onlyBlacklistManagerOrOwner() {
        if (!blacklistManager[msg.sender] && msg.sender != owner()) {
            revert NotBlackListManager();
        }
        _;
    }

    // Function to add a minter
    function addMintManager(address account) external onlyOwner {
        if (account == address(0)) {
            revert CannotAssignZeroAddress();
        }
        mintManager[account] = true;
        emit MintManagerAdded(account);
    }

    // Function to remove a minter
    function removeMintManager(address account) external onlyOwner {
        mintManager[account] = false;
        emit MintManagerRemoved(account);
    }

    // Function to add a burner
    function addBurnManager(address account) external onlyOwner {
        if (account == address(0)) {
            revert CannotAssignZeroAddress();
        }
        burnManager[account] = true;
        emit BurnManagerAdded(account);
    }

    // Function to remove a burner
    function removeBurnManager(address account) external onlyOwner {
        burnManager[account] = false;
        emit BurnManagerRemoved(account);
    }

    // Function to add balance manager
    function addBalanceManager(address account) external onlyOwner {
        if (account == address(0)) {
            revert CannotAssignZeroAddress();
        }
        balanceManager[account] = true;
        emit BalanceManagerAdded(account);
    }

    // Function to remove balance manager
    function removeBalanceManager(address account) external onlyOwner {
        balanceManager[account] = false;
        emit BalanceManagerRemoved(account);
    }

    // Function to add blacklist manager
    function addBlacklistManager(address account) external onlyOwner {
        if (account == address(0)) {
            revert CannotAssignZeroAddress();
        }
        blacklistManager[account] = true;
        emit BlacklistManagerAdded(account);
    }

    // Function to remove blacklist manager
    function removeBlacklistManager(address account) external onlyOwner {
        blacklistManager[account] = false;
        emit BlacklistManagerRemoved(account);
    }

    // Function to blacklist an address
    function blacklistAddress(address account) external onlyBlacklistManagerOrOwner {
        if (isBlacklisted[account]) {
            revert AddressAlreadyBlacklisted();
        }

        // Address zero cannot be blacklisted
        if (account == address(0)) {
            revert CannotBlacklistZeroAddress();
        }

        // Liquidity pool addresses cannot be blacklisted
        if (isLiquidityPool[account]) {
            revert CannotBlacklistLiquidityPool();
        }

        // Blacklist the address
        isBlacklisted[account] = true;
        emit BlackListed(account);
    }

    // Function to unblacklist an address
    function unblacklistAddress(address account) external onlyBlacklistManagerOrOwner {
        if (!isBlacklisted[account]) {
            revert AddressNotBlacklisted();
        }
        isBlacklisted[account] = false;
        emit UnBlackListed(account);
    }

    // Function to mint new tokens
    function mint(address to, uint256 amount) external onlyMintManagerOrOwner {
        // Check if address if blacklisted before minting
        if (isBlacklisted[to]) {
            revert BlacklistedAddress();
        }
        // Check if address is zero address before minting
        if (to == address(0)) {
            revert CannotMintToZeroAddress();
        }

        _mint(to, amount);
        emit TokensMinted(to, amount);
    }

    // Function to burn tokens (permanently remove from circulation)
    function burn(address account, uint256 amount) external onlyBurnManagerOrOwner {
        // Cannot burn zero address
        if (account == address(0)) {
            revert CannotBurnZeroAddress();
        }

        // Cannot burn liquidity pool addresses
        if (isLiquidityPool[account]) {
            revert CannotBurnLiquidityPool();
        }

        _burn(account, amount);
        emit TokensBurned(account, amount);
    }

    // Function to move tokens (move them to other wallets)
    function moveBalance(address from, address to) external onlyBalanceManagerOrOwner {
        // Validate recipient address
        if (to == address(0)) {
            revert CannotMoveToZeroAddress();
        }

        uint256 amount = balanceOf(from);

        // Ensure there is a balance to move
        if (amount == 0) {
            revert CannotMoveZeroAmount();
        }

        _transfer(from, to, amount);
        emit BalanceMoved(from, to, amount);
    }

    // Add liquidity pool addresses (after adding liquidity)
    function addLiquidityPoolAddress(address lpAddress) external onlyOwner {
        if (isLiquidityPool[lpAddress]) {
            revert LiquidityPoolAlreadyAdded();
        }
        isLiquidityPool[lpAddress] = true;
        liquidityPoolAddresses.push(lpAddress);
        emit LiquidityPoolAdded(lpAddress);
    }

    // Remove liquidity pool address
    function removeLiquidityPoolAddress(address lpAddress) external onlyOwner {
        if (!isLiquidityPool[lpAddress]) {
            revert LiquidityPoolNotFound();
        }
        isLiquidityPool[lpAddress] = false;
        // Remove from array
        for (uint256 i = 0; i < liquidityPoolAddresses.length; i++) {
            if (liquidityPoolAddresses[i] == lpAddress) {
                liquidityPoolAddresses[i] = liquidityPoolAddresses[liquidityPoolAddresses.length - 1];
                liquidityPoolAddresses.pop();
                break;
            }
        }
        emit LiquidityPoolRemoved(lpAddress);
    }

    // Get all liquidity pool addresses
    function getLiquidityPools() external view returns (address[] memory) {
        return liquidityPoolAddresses;
    }

    // Override transfer function to include blacklist check
    function transfer(address to, uint256 amount)
        public
        override
        addrBlacklisted(msg.sender)
        addrBlacklisted(to)
        returns (bool)
    {
        return super.transfer(to, amount); // Call the parent contract's transfer
    }

    // Override transferFrom function to include blacklist check
    function transferFrom(address from, address to, uint256 amount)
        public
        override
        addrBlacklisted(from)
        addrBlacklisted(to)
        returns (bool)
    {
        return super.transferFrom(from, to, amount); // Call the parent contract's transferFrom
    }

    // Check blacklisted addresses
    function isAddressBlacklisted(address account) external view returns (bool) {
        return isBlacklisted[account];
    }
}
