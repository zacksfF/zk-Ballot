// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/Voting.sol";

contract DeployElectionVoting is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        ElectionVoting voting = new ElectionVoting("National Election 2025");

        vm.stopBroadcast();

        console.log("ElectionVoting deployed at:", address(voting));
    }
}
