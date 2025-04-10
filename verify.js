async function main() {
  const contractAddress = "0x4510bAE133e9917587255A6166be55C79f0ce474";
  const contractName = "ElectionVoting";
  const constructorArgs = ["National Election 2025"];

  // Verify the contract
  await hre.run("verify:verify", {
    address: contractAddress,
    contract: "src/ElectionVoting.sol:ElectionVoting",
    constructorArguments: constructorArgs,
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
