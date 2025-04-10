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
