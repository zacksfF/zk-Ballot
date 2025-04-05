```bash
function castVote(bytes memory _proof, uint256 _voteOption) external {
    require(!hasVoted[msg.sender], "Already voted");
    require(verifyProof(_proof), "Invalid ZK proof");
    votes[_voteOption] += 1;
    hasVoted[msg.sender] = true;
}

```