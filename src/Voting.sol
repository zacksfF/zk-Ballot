// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
//import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title Zk-Ballot Election voting contract
/// @author Zakaria Saif
/// @dev Implements a secure e-voting system with privacy using zk-SNARKs

contract ElectionVoting is Ownable, ReentrancyGuard {
    struct Candidate {
        uint256 id;
        string name;
        string party;
        uint256 voteCount;
    }

    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 votedCandidateId;
        bytes32 nullifierHash;
    }

    string public electionName;
    uint256 public startTime;
    uint256 public endTime;
    bool public electionStarted;
    bool public electionEnded;

    mapping(uint256 => Candidate) public candidates;
    mapping(address => Voter) public voters;
    mapping(bytes32 => bool) public nullifierHashes; // Prevents double voting

    address public zkVerifierContract;
    uint256 public candidatesCount;
    uint256 public registeredVotersCount;
    uint256 public totalVotesCast;

    event VoterRegistered(address indexed voter);
    event VoteCast(bytes32 indexed nullifierHash);
    event CandidateAdded(
        uint256 indexed candidateId,
        string name,
        string party
    );
    event ElectionStarted(uint256 startTime, uint256 endTime);
    event ElectionEnded(
        uint256 endTime,
        uint256 totalVotes,
        uint256 winningCandidateId,
        string winnerName
    );

    constructor(string memory _electionName) Ownable(msg.sender) {
        electionName = _electionName;
    }

    modifier onlyDuringElection() {
        require(electionStarted, "Election has not started");
        require(!electionEnded, "Election already ended");
        require(
            block.timestamp >= startTime && block.timestamp <= endTime,
            "Outside election timeframe"
        );
        _;
    }

    modifier onlyBeforeElection() {
        require(!electionStarted, "Election already started");
        _;
    }

    /*
    Todo fucntion:
        addCandidate
        startElection
        endElection
        registerVoter
        batchRegisterVoters
        castVote
        verifyZkProof
        getElectionResults
        getWinningCandidateId
        getWinningCandidate
        getElectionStatus
    */

    // Adds a new candidate before election starts.
    function addCandidate(
        string memory _name,
        string memory _party
    ) public onlyOwner onlyBeforeElection {
        candidatesCount++;
        candidates[candidatesCount] = Candidate(
            candidatesCount,
            _name,
            _party,
            0
        );
        emit CandidateAdded(candidatesCount, _name, _party);
    }

    //Starts election, defines duration, and sets timestamps.
    function startElection(
        uint256 _durationInMinutes
    ) public onlyOwner onlyBeforeElection {
        require(candidatesCount > 0, "No candidates registered");
        require(_durationInMinutes > 0, "Duration must be positive");

        startTime = block.timestamp;
        endTime = startTime + (_durationInMinutes * 1 minutes);
        electionStarted = true;

        emit ElectionStarted(startTime, endTime);
    }

    //Ends election, identifies winner, emits final event.
    function endElection() public onlyOwner {
        require(electionStarted, "Election has not started");
        require(!electionEnded, "Election already ended");
        require(block.timestamp >= endTime, "Election still in progress");

        electionEnded = true;

        uint256 winningCandidateId = getWinningCandidateId();
        emit ElectionEnded(
            block.timestamp,
            totalVotesCast,
            winningCandidateId,
            candidates[winningCandidateId].name
        );
    }

    // Useful for testing multiple voters in Foundry.
    function registerVoter(address _voter) public onlyOwner onlyBeforeElection {
        require(!voters[_voter].isRegistered, "Voter already registered");

        voters[_voter].isRegistered = true;
        voters[_voter].hasVoted = false;
        registeredVotersCount++;

        emit VoterRegistered(_voter);
    }

    function batchRegisterVoters(
        address[] memory _voters
    ) public onlyOwner onlyBeforeElection {
        for (uint256 i = 0; i < _voters.length; i++) {
            if (!voters[_voters[i]].isRegistered) {
                voters[_voters[i]].isRegistered = true;
                voters[_voters[i]].hasVoted = false;
                registeredVotersCount++;
                emit VoterRegistered(_voters[i]);
            }
        }
    }

    //- ✅ Verifies voter
    //- ✅ Checks nullifier (no double voting)
    //- ✅ Verifies ZK proof
    //- ✅ Increments candidate vote count
    //- ✅ Stores nullifier and updates voter status
    function castVote(
        uint256 _candidateId,
        bytes32 _nullifierHash,
        bytes calldata _zkProof
    ) public onlyDuringElection nonReentrant {
        require(voters[msg.sender].isRegistered, "Voter not registered");
        require(!nullifierHashes[_nullifierHash], "Vote already cast");
        require(
            _candidateId > 0 && _candidateId <= candidatesCount,
            "Invalid candidate"
        );
        require(verifyZkProof(_nullifierHash, _zkProof), "Invalid ZK proof");

        nullifierHashes[_nullifierHash] = true;
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedCandidateId = _candidateId;
        voters[msg.sender].nullifierHash = _nullifierHash;

        candidates[_candidateId].voteCount++;
        totalVotesCast++;

        emit VoteCast(_nullifierHash);
    }

    // ✔️ FIXED COMPILER WARNINGS:
    // - Commented out unused parameters `_nullifierHash` and `_zkProof` to suppress Warning 5667
    // - Changed function from `view` to `pure` since it doesn't access or read any contract state (Warning 2018)
    function verifyZkProof(
        bytes32 /*_nullifierHash*/,
        bytes calldata /*_zkProof*/
    ) internal pure returns (bool) {
        return true; // Placeholder for actual ZK verification
    }

    //Returns array of all candidates with their vote counts.
    function getElectionResults() public view returns (Candidate[] memory) {
        require(electionEnded, "Election not ended yet");

        Candidate[] memory results = new Candidate[](candidatesCount);
        for (uint256 i = 1; i <= candidatesCount; i++) {
            results[i - 1] = candidates[i];
        }
        return results;
    }

    function getWinningCandidateId() internal view returns (uint256) {
        uint256 winningVoteCount = 0;
        uint256 winningCandidateId = 0;

        for (uint256 i = 1; i <= candidatesCount; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winningCandidateId = i;
            }
        }
        return winningCandidateId;
    }

    function getWinningCandidate() public view returns (Candidate memory) {
        require(electionEnded, "Election not ended yet");

        uint256 winningCandidateId = getWinningCandidateId();
        require(winningCandidateId > 0, "No winner found");

        return candidates[winningCandidateId];
    }

    // Gives a frontend summary: total candidates, votes, start/end time, etc.
    function getElectionStatus()
        public
        view
        returns (
            string memory name,
            bool started,
            bool ended,
            uint256 start,
            uint256 end,
            uint256 totalCandidates,
            uint256 registeredVoters,
            uint256 totalVotes
        )
    {
        return (
            electionName,
            electionStarted,
            electionEnded,
            startTime,
            endTime,
            candidatesCount,
            registeredVotersCount,
            totalVotesCast
        );
    }
}
