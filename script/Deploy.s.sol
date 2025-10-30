// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Token} from "../src/token.sol";

contract DeployScript is Script {
    function run() public {
        // Get the private key from environment variable
        // Usage: forge script script/Deploy.s.sol:DeployScript --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> --broadcast
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_ANVIL_1");
        address deployerAddress = vm.addr(deployerPrivateKey);

        console.log("========================================");
        console.log("     Token Contract Deployment");
        console.log("========================================");
        console.log("Network Chain ID:", block.chainid);
        console.log("Deployer Address:", deployerAddress);
        console.log("");

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the token contract with the deployer as the initial owner
        Token token = new Token(deployerAddress);

        vm.stopBroadcast();

        // Verify deployment
        require(
            address(token) != address(0),
            "Deployment failed: token address is zero"
        );
        require(
            token.owner() == deployerAddress,
            "Deployment failed: owner not set correctly"
        );

        // Log deployment information
        console.log("");
        console.log("========================================");
        console.log("     Deployment Successful!");
        console.log("========================================");
        console.log("Token Address:", address(token));
        console.log("Owner Address:", token.owner());
        console.log("");
        console.log("--- Token Information ---");
        console.log("Token Name:", token.name());
        console.log("Token Symbol:", token.symbol());
        console.log("Token Decimals:", token.decimals());
        console.log(
            "Total Supply:",
            token.totalSupply() / (10 ** token.decimals()),
            "tokens"
        );
        console.log(
            "Owner Balance:",
            token.balanceOf(deployerAddress) / (10 ** token.decimals()),
            "tokens"
        );
        console.log("");
        console.log("========================================");
        console.log("");
    }
}
