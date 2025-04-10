#!/bin/bash

# Set your contract details
CONTRACT_ADDRESS="0x4510bAE133e9917587255A6166be55C79f0ce474"  # Replace with your actual contract address
CONTRACT_NAME="ElectionVoting"  # Replace with your actual contract name
CONSTRUCTOR_ARGS="National Election 2025"  # Your election name passed to the constructor

# Install zksync-cli if not already installed
if ! command -v zksync-cli &> /dev/null; then
    echo "Installing zksync-cli..."
    npm install -g zksync-cli
fi

# Make sure we have hardhat installed
if ! command -v npx &> /dev/null; then
    echo "Installing npx..."
    npm install -g npx
fi

if [ ! -f "package.json" ]; then
    echo "Initializing npm project..."
    npm init -y
fi

# Install required dependencies if not present
if [ ! -d "node_modules/@matterlabs" ]; then
    echo "Installing zkSync hardhat plugins..."
    npm install --save-dev @matterlabs/hardhat-zksync-verify @matterlabs/hardhat-zksync-solc @nomicfoundation/hardhat-verify hardhat @nomiclabs/hardhat-etherscan
fi

# Generate hardhat.config.js if it doesn't exist
if [ ! -f "hardhat.config.js" ]; then
    echo "Creating hardhat.config.js..."
    cat > hardhat.config.js << 'EOL'
require("@matterlabs/hardhat-zksync-verify");
require("@matterlabs/hardhat-zksync-solc");

module.exports = {
  zksolc: {
    version: "1.3.13",
    compilerSource: "binary",
    settings: {},
  },
  defaultNetwork: "zkSyncSepolia",
  networks: {
    zkSyncSepolia: {
      url: "https://sepolia.era.zksync.dev",
      ethNetwork: "sepolia",
      verifyURL: "https://explorer.sepolia.era.zksync.dev/contract_verification",
      zksync: true,
    },
  },
  solidity: {
    version: "0.8.19",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
};
EOL
fi

# Create verification script
cat > verify.js << EOL
async function main() {
  const contractAddress = "${CONTRACT_ADDRESS}";
  const contractName = "${CONTRACT_NAME}";
  const constructorArgs = ["${CONSTRUCTOR_ARGS}"];

  // Verify the contract
  await hre.run("verify:verify", {
    address: contractAddress,
    contract: "src/${CONTRACT_NAME}.sol:${CONTRACT_NAME}",
    constructorArguments: constructorArgs,
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
EOL

# Run verification
echo "Running contract verification..."
npx hardhat run verify.js --network zkSyncSepolia

echo "Verification process complete!"
