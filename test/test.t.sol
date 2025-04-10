// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/Voting.sol";

contract ElectionVotingTest is Test {
    ElectionVoting public voting;
    address public admin = address(1);
    address public voter1 = address(2);
    address public voter2 = address(3);


    function setUp() public {
        vm.startPrank(admin);
        voting = new ElectionVoting("Test Election");

        // Add candidates
        voting.addCandidate("Candidate A", "Party X");
        voting.addCandidate("Candidate B", "Party Y");

        // Register voters
        voting.registerVoter(voter1);
        voting.registerVoter(voter2);

        vm.stopPrank();
    }

    function testElectionLifecycle() public {
        // Start as admin
        vm.startPrank(admin);
        voting.startElection(60); // 60 minutes
        vm.stopPrank();

        // Check election status
        (string memory name, bool started, , , , , , ) = voting
            .getElectionStatus();
        assertEq(name, "Test Election");
        assertTrue(started);

        // Cast votes
        bytes32 nullifier1 = keccak256(abi.encodePacked("voter1secret"));
        bytes32 nullifier2 = keccak256(abi.encodePacked("voter2secret"));

        vm.startPrank(voter1);
        voting.castVote(1, nullifier1, "0x"); // Mock proof
        vm.stopPrank();

        vm.startPrank(voter2);
        voting.castVote(2, nullifier2, "0x"); // Mock proof
        vm.stopPrank();

        // End election
        vm.warp(block.timestamp + 61 minutes);
        vm.startPrank(admin);
        voting.endElection();
        vm.stopPrank();

        // Check results
        ElectionVoting.Candidate[] memory results = voting.getElectionResults();
        assertEq(results.length, 2);
        assertEq(results[0].voteCount, 1);
        assertEq(results[1].voteCount, 1);
    }

    //This test validates your zk-SNARK-style anonymity with double-vote protection.
    function testDoubleVotePrevention() public {
        // Start election
        vm.startPrank(admin);
        voting.startElection(60);
        vm.stopPrank();

        // Cast vote
        bytes32 nullifier = keccak256(abi.encodePacked("voter1secret"));

        vm.startPrank(voter1);
        voting.castVote(1, nullifier, "0x"); // Mock proof

        // Try to vote again with same nullifier
        vm.expectRevert("Vote already cast");
        voting.castVote(2, nullifier, "0x");
        vm.stopPrank();
    }
}
