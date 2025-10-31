# ERC20 Token with Blacklist, Mint, Burn & Role-Based Access Control

A comprehensive ERC20 token implementation with advanced features including role-based access control, blacklist functionality, liquidity pool protection, and balance management. Built using **Foundry** and **OpenZeppelin** contracts.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Solidity](https://img.shields.io/badge/Solidity-^0.8.24-blue)](https://soliditylang.org/)
[![Foundry](https://img.shields.io/badge/Built%20with-Foundry-orange)](https://book.getfoundry.sh/)

---

## 📋 Table of Contents

- [Features](#-features)
- [Architecture](#-architecture)
- [Contract Overview](#-contract-overview)
- [Role-Based Access Control](#-role-based-access-control)
- [Installation](#-installation)
- [Testing](#-testing)
- [Deployment](#-deployment)
- [Usage Examples](#-usage-examples)
- [Security Features](#-security-features)
- [Gas Optimization](#-gas-optimization)
- [License](#-license)

---

## ✨ Features

### Core Functionality
- **ERC20 Standard**: Full ERC20 implementation using OpenZeppelin
- **Initial Supply**: 1,000,000 tokens minted to the owner on deployment
- **Custom Token**: Name: `TOKEN`, Symbol: `MYTKN`, Decimals: `18`

### Role-Based Access Control
- **Mint Manager**: Authorized addresses can mint new tokens
- **Burn Manager**: Authorized addresses can burn tokens from any address
- **Balance Manager**: Authorized addresses can move entire balances between wallets
- **Blacklist Manager**: Authorized addresses can blacklist/unblacklist addresses
- **Owner Privileges**: Contract owner has all manager permissions by default

### Blacklist System
- **Address Blocking**: Prevent blacklisted addresses from sending or receiving tokens
- **Transfer Protection**: Both `transfer()` and `transferFrom()` enforce blacklist checks
- **Zero Address Protection**: Cannot blacklist address(0)
- **Liquidity Pool Protection**: Cannot blacklist liquidity pool addresses

### Liquidity Pool Management
- **LP Registration**: Register DEX liquidity pool addresses
- **Protected Addresses**: LP addresses cannot be blacklisted or burned
- **Enumerable**: Get all registered LP addresses via `getLiquidityPools()`
- **Efficient Storage**: Dual mapping + array structure for O(1) lookups and enumeration

### Advanced Features
- **Balance Movement**: Move entire balance from one address to another
- **Custom Errors**: Gas-efficient error handling using custom errors
- **Event Logging**: Comprehensive events for all state changes
- **OpenZeppelin Ownable**: Secure ownership management

---

## 🏗 Architecture

### Contract Structure

```
Token Contract (ERC20, Ownable)
├── Role-Based Access Control
│   ├── Mint Managers
│   ├── Burn Managers
│   ├── Balance Managers
│   └── Blacklist Managers
│
├── Blacklist System
│   ├── Blacklist/Unblacklist
│   └── Transfer Protection
│
├── Liquidity Pool Management
│   ├── Add/Remove LP Addresses
│   └── LP Protection (no burn/blacklist)
│
└── Token Operations
    ├── Mint (with blacklist check)
    ├── Burn (with LP protection)
    ├── Move Balance
    ├── Transfer (with blacklist check)
    └── TransferFrom (with blacklist check)
```

### Storage Layout

```solidity
// Role mappings
mapping(address => bool) public mintManager;
mapping(address => bool) public burnManager;
mapping(address => bool) public balanceManager;
mapping(address => bool) public blacklistManager;

// Blacklist mapping
mapping(address => bool) public isBlacklisted;

// Liquidity pool management (dual structure for O(1) + enumeration)
mapping(address => bool) public isLiquidityPool;
address[] public liquidityPoolAddresses;
```

---

## 📜 Contract Overview

### Token Details
- **Name**: TOKEN
- **Symbol**: MYTKN
- **Decimals**: 18
- **Initial Supply**: 1,000,000 tokens
- **Owner**: Receives initial supply on deployment

### Main Functions

#### Role Management (Owner Only)
```solidity
function addMintManager(address account) external onlyOwner
function removeMintManager(address account) external onlyOwner
function addBurnManager(address account) external onlyOwner
function removeBurnManager(address account) external onlyOwner
function addBalanceManager(address account) external onlyOwner
function removeBalanceManager(address account) external onlyOwner
function addBlacklistManager(address account) external onlyOwner
function removeBlacklistManager(address account) external onlyOwner
```

#### Blacklist Management (Blacklist Manager or Owner)
```solidity
function blacklistAddress(address account) external onlyBlacklistManagerOrOwner
function unblacklistAddress(address account) external onlyBlacklistManagerOrOwner
function isAddressBlacklisted(address account) external view returns (bool)
```

#### Token Operations
```solidity
// Mint Manager or Owner
function mint(address to, uint256 amount) external onlyMintManagerOrOwner

// Burn Manager or Owner
function burn(address account, uint256 amount) external onlyBurnManagerOrOwner

// Balance Manager or Owner
function moveBalance(address from, address to) external onlyBalanceManagerOrOwner
```

#### Liquidity Pool Management (Owner Only)
```solidity
function addLiquidityPoolAddress(address lpAddress) external onlyOwner
function removeLiquidityPoolAddress(address lpAddress) external onlyOwner
function getLiquidityPools() external view returns (address[] memory)
```

#### Standard ERC20 (with Blacklist Protection)
```solidity
function transfer(address to, uint256 amount) public override returns (bool)
function transferFrom(address from, address to, uint256 amount) public override returns (bool)
```

### Custom Errors

```solidity
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
```

### Events

```solidity
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
```

---

## 🔐 Role-Based Access Control

### Permission Hierarchy

| Role | Permissions | Can Be Added By |
|------|-------------|-----------------|
| **Owner** | All permissions + ownership transfer | - |
| **Mint Manager** | Mint tokens to any address | Owner |
| **Burn Manager** | Burn tokens from any address | Owner |
| **Balance Manager** | Move entire balances between addresses | Owner |
| **Blacklist Manager** | Blacklist/unblacklist addresses | Owner |

### Multiple Managers
- Multiple addresses can have the same role
- Owner always has all permissions regardless of manager status
- Managers can be added/removed dynamically

---

## 🔧 Installation

### Prerequisites
- [Foundry](https://book.getfoundry.sh/getting-started/installation) installed
- Git installed

### Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/erc20-blacklist-mint-burn.git
cd erc20-blacklist-mint-burn

# Install dependencies
forge install

# Build the project
forge build
```

---

## 🧪 Testing

### Test Suite Overview

The project includes **105 comprehensive tests** across 9 test files:

| Test File | Tests | Description |
|-----------|-------|-------------|
| `Token.t.sol` | Base | Base test contract with common setup and helpers |
| `RoleManagement.t.sol` | 20 | Add/remove managers, access control validation |
| `Blacklist.t.sol` | 11 | Blacklist/unblacklist functionality, LP protection |
| `Minting.t.sol` | 7 | Minting with access control and validation |
| `Burning.t.sol` | 10 | Burning tokens including LP protection |
| `BalanceMovement.t.sol` | 10 | Move balance functionality |
| `LiquidityPool.t.sol` | 16 | LP management and protection |
| `Transfers.t.sol` | 16 | Transfer/transferFrom with blacklist checks |
| `Integration.t.sol` | 9 | Cross-feature integration tests |
| **Total** | **99** | **Complete test coverage** |

### Test Categories

#### 1. Role Management Tests (20 tests)
```bash
forge test --match-contract RoleManagementTest -vv
```
- Add/remove mint managers
- Add/remove burn managers
- Add/remove balance managers
- Add/remove blacklist managers
- Access control validation
- Zero address protection

#### 2. Blacklist Tests (11 tests)
```bash
forge test --match-contract BlacklistTest -vv
```
- Blacklist/unblacklist addresses
- Access control for blacklist operations
- LP address protection
- Zero address protection
- Event emission

#### 3. Minting Tests (7 tests)
```bash
forge test --match-contract MintingTest -vv
```
- Mint tokens by owner
- Mint tokens by mint manager
- Access control validation
- Blacklist address protection
- Zero address protection

#### 4. Burning Tests (10 tests)
```bash
forge test --match-contract BurningTest -vv
```
- Burn tokens by owner
- Burn tokens by burn manager
- LP address protection
- Zero address protection
- Insufficient balance handling

#### 5. Balance Movement Tests (10 tests)
```bash
forge test --match-contract BalanceMovementTest -vv
```
- Move balances between addresses
- Access control validation
- Zero balance handling
- Zero address protection

#### 6. Liquidity Pool Tests (16 tests)
```bash
forge test --match-contract LiquidityPoolTest -vv
```
- Add/remove LP addresses
- LP array management
- Duplicate prevention
- Event emission

#### 7. Transfer Tests (16 tests)
```bash
forge test --match-contract TransfersTest -vv
```
- Transfer with blacklist checks
- TransferFrom with blacklist checks
- Sender/receiver blacklist protection

#### 8. Integration Tests (9 tests)
```bash
forge test --match-contract IntegrationTest -vv
```
- Initial supply verification
- Token metadata (name, symbol, decimals)
- Owner permissions across all roles
- Multiple managers for same role
- LP protection across features
- Event emission across all operations
- Ownership transfer

### Running Tests

```bash
# Run all tests
forge test

# Run all tests with detailed output
forge test -vv

# Run all tests with gas reporting
forge test --gas-report

# Run specific test file
forge test --match-contract RoleManagementTest

# Run specific test function
forge test --match-test test_AddMintManager

# Run tests with maximum verbosity (includes stack traces)
forge test -vvvv

# Run tests with coverage
forge coverage

# Generate coverage report
forge coverage --report lcov
```

### Test Results Example

```
Running 99 tests for test suite...

Test result: ok. 99 passed; 0 failed; 0 skipped; finished in 45.23ms

Ran 1 test suite in 1.23s: 99 tests passed, 0 failed, 0 skipped (99 total tests)
```

---

## 🚀 Deployment

### Deployment Script

The project includes a comprehensive deployment script at `script/Deploy.s.sol`:

**Features:**
- Deploys token contract with deployer as owner
- Verifies deployment success
- Logs detailed deployment information
- Environment variable support for private keys

### Deploy to Local Network (Anvil)

```bash
# Terminal 1: Start local Ethereum node
anvil

# Terminal 2: Deploy contract
forge script script/Deploy.s.sol:DeployScript \
    --rpc-url http://localhost:8545 \
    --private-key <PRIVATE_KEY> \
    --broadcast
```

### Deploy to Testnet (e.g., Sepolia)

```bash
# Set up environment variable (optional)
export PRIVATE_KEY=<your_private_key>

# Deploy to Sepolia
forge script script/Deploy.s.sol:DeployScript \
    --rpc-url https://sepolia.infura.io/v3/<YOUR_INFURA_KEY> \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --verify \
    --etherscan-api-key <YOUR_ETHERSCAN_API_KEY>
```

### Deploy to Mainnet

```bash
# Deploy to Ethereum Mainnet
forge script script/Deploy.s.sol:DeployScript \
    --rpc-url https://mainnet.infura.io/v3/<YOUR_INFURA_KEY> \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --verify \
    --etherscan-api-key <YOUR_ETHERSCAN_API_KEY>
```

### Deployment Output

```
========================================
     Token Contract Deployment
========================================
Network Chain ID: 1
Deployer Address: 0x...

========================================
     Deployment Successful!
========================================
Token Address: 0x...
Owner Address: 0x...

--- Token Information ---
Token Name: TOKEN
Token Symbol: MYTKN
Token Decimals: 18
Total Supply: 1000000 tokens
Owner Balance: 1000000 tokens

========================================
```

---

## 💡 Usage Examples

### 1. Add a Mint Manager

```solidity
// As contract owner
token.addMintManager(0x123...);

// Verify manager was added
bool isMintManager = token.mintManager(0x123...);
```

### 2. Mint Tokens

```solidity
// As owner or mint manager
token.mint(recipientAddress, 1000 * 10**18); // Mint 1000 tokens
```

### 3. Blacklist an Address

```solidity
// As owner or blacklist manager
token.blacklistAddress(maliciousAddress);

// Verify blacklist
bool isBlacklisted = token.isBlacklisted(maliciousAddress);
```

### 4. Add Liquidity Pool

```solidity
// As owner (after creating LP on DEX)
token.addLiquidityPoolAddress(uniswapPairAddress);

// Get all LPs
address[] memory pools = token.getLiquidityPools();
```

### 5. Burn Tokens

```solidity
// As owner or burn manager
token.burn(addressToBurn, 500 * 10**18); // Burn 500 tokens
```

### 6. Move Balance

```solidity
// As owner or balance manager
token.moveBalance(fromAddress, toAddress);
// Moves entire balance from 'fromAddress' to 'toAddress'
```

### 7. Transfer Tokens (with Blacklist Check)

```solidity
// Standard ERC20 transfer (automatically checks blacklist)
token.transfer(recipient, 100 * 10**18);

// Transfer on behalf (with approval)
token.transferFrom(sender, recipient, 100 * 10**18);
```

---

## 🛡 Security Features

### 1. Access Control
- Role-based permissions prevent unauthorized operations
- Owner-only functions for critical operations
- Separate manager roles for delegation

### 2. Blacklist Protection
- Prevents malicious addresses from transferring tokens
- Protects both sender and receiver in transfers
- Cannot blacklist critical addresses (LP, zero address)

### 3. Liquidity Pool Protection
- LP addresses cannot be blacklisted
- LP addresses cannot be burned
- Prevents accidental/malicious LP disruption

### 4. Input Validation
- Zero address checks on all critical functions
- Duplicate prevention for roles and LP addresses
- Amount validation for balance operations

### 5. Custom Errors
- Gas-efficient error handling
- Clear error messages for debugging
- Better UX for front-end integration

### 6. Event Logging
- Comprehensive events for all state changes
- Enables off-chain monitoring and indexing
- Audit trail for all operations

---

## ⚡ Gas Optimization

### Efficient Storage
- **Dual Structure for LPs**: Mapping for O(1) lookup + Array for enumeration
- **Public Mappings**: Auto-generated getters save contract size
- **Custom Errors**: Save gas vs string-based `require()` statements

### Optimized Operations
- **Modifiers**: Reusable code reduces deployment cost
- **Minimal Storage**: Only essential data stored on-chain
- **Batch Operations**: Move entire balance in single transaction

### Gas Benchmarks

| Operation | Estimated Gas |
|-----------|---------------|
| Deploy Contract | ~2,500,000 |
| Add Manager | ~50,000 |
| Mint Tokens | ~55,000 |
| Burn Tokens | ~45,000 |
| Blacklist Address | ~48,000 |
| Transfer | ~60,000 |
| Add LP Address | ~70,000 |

*Note: Actual gas costs may vary based on network conditions and optimization level.*

---

## 📁 Project Structure

```
erc20-blacklist-mint-burn/
├── src/
│   └── token.sol                 # Main token contract
├── script/
│   └── Deploy.s.sol             # Deployment script
├── test/
│   ├── Token.t.sol              # Base test contract
│   ├── RoleManagement.t.sol     # Role management tests
│   ├── Blacklist.t.sol          # Blacklist tests
│   ├── Minting.t.sol            # Minting tests
│   ├── Burning.t.sol            # Burning tests
│   ├── BalanceMovement.t.sol    # Balance movement tests
│   ├── LiquidityPool.t.sol      # LP management tests
│   ├── Transfers.t.sol          # Transfer tests
│   └── Integration.t.sol        # Integration tests
├── lib/
│   ├── forge-std/               # Foundry standard library
│   └── openzeppelin-contracts/  # OpenZeppelin contracts
├── foundry.toml                 # Foundry configuration
├── remappings.txt               # Import remappings
└── README.md                    # This file
```

---

## 🔄 Development Workflow

### 1. Make Changes
```bash
# Edit contract
vim src/token.sol

# Format code
forge fmt
```

### 2. Test Changes
```bash
# Run tests
forge test

# Run specific test
forge test --match-test test_YourTestName -vv
```

### 3. Check Coverage
```bash
# Generate coverage report
forge coverage
```

### 4. Deploy & Verify
```bash
# Deploy to testnet
forge script script/Deploy.s.sol:DeployScript \
    --rpc-url $SEPOLIA_RPC \
    --broadcast \
    --verify
```

---

## 📚 Additional Resources

### Foundry Documentation
- [Foundry Book](https://book.getfoundry.sh/)
- [Forge Testing](https://book.getfoundry.sh/forge/tests)
- [Deployment Guide](https://book.getfoundry.sh/forge/deploying)

### OpenZeppelin
- [ERC20 Documentation](https://docs.openzeppelin.com/contracts/4.x/erc20)
- [Access Control](https://docs.openzeppelin.com/contracts/4.x/access-control)
- [Ownable Pattern](https://docs.openzeppelin.com/contracts/4.x/api/access#Ownable)

### Solidity
- [Solidity Documentation](https://docs.soliditylang.org/)
- [Style Guide](https://docs.soliditylang.org/en/latest/style-guide.html)

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style
- Follow Solidity style guide
- Run `forge fmt` before committing
- Write comprehensive tests for new features
- Update documentation as needed

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Stiliyan Goshev**

- GitHub: [@stiliyangoshev](https://github.com/stiliyangoshev)

---

## 🙏 Acknowledgments

- [Foundry](https://github.com/foundry-rs/foundry) - Fast, portable and modular toolkit for Ethereum
- [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts) - Secure smart contract library
- Ethereum Community for invaluable resources and support

---

## 📊 Project Stats

- **Total Lines of Code**: ~1500
- **Test Coverage**: 99+ tests
- **Solidity Version**: ^0.8.24
- **Dependencies**: OpenZeppelin Contracts v5.x
- **License**: MIT

---

**Built with ❤️ using Foundry**

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
