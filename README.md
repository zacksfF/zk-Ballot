### ✅ Install

Install Foundry:
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

Install Pkg
```bash
forge install OpenZeppelin/openzeppelin-contracts

```
via npm
```bash
npm install @openzeppelin/contracts
```

lib
```
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
```

---

### 🔨 Build

```bash
forge build
```
Compiles all contracts in the `src/` directory and outputs ABI, bytecode, and metadata to the `out/` folder.

Use this if you:
- Updated contract code
- Added new dependencies
- Need to regenerate the ABI for frontend

---

### 🧪 Test

Run **all tests** in `test/`:
```bash
forge test
```

Run with logs:
```bash
forge test -vvvv
```

Run a **specific test**:
```bash
forge test --match-test testElectionLifecycle
```

Use this when:
- Validating vote casting, election phases
- Checking for reverts (double voting, access control)
- Simulating zk nullifier behavior

---

### 🚀 Deploy

Simulate the deploy (dry-run):
```bash
forge script script/deploy.s.sol --rpc-url $ZKSYNC_RPC_URL
```

Deploy on zkSync Sepolia:
```bash
forge script script/deploy.s.sol --broadcast --rpc-url $ZKSYNC_RPC_URL -- --env-file .env
```

Use this when:
- You’re ready to deploy a real contract to zkSync
- Broadcasting is required with a live private key

---

### ✅ Verify

Navigate to the `verify/` folder and run:

```bash
./verify-zksync.sh
```

What it does:
- Installs dependencies if missing
- Sets up Hardhat config for zkSync
- Runs verification on the zkSync Explorer
- Uses `verify.js` + your `.env` config

> 🧠 More reliable than manual Etherscan UI. Production-grade.

---

### 🔗 Integrate (Cast)

Interact with your deployed contract directly from CLI using Foundry's `cast` tool.

#### Register a voter:
```bash
cast send $CONTRACT_ADDRESS "registerVoter(address)" 0xYourVoterAddress --private-key $PRIVATE_KEY --rpc-url $ZKSYNC_RPC_URL
```

#### Start election:
```bash
cast send $CONTRACT_ADDRESS "startElection(uint256)" 60 --private-key $PRIVATE_KEY --rpc-url $ZKSYNC_RPC_URL
```

#### Cast vote:
```bash
cast send $CONTRACT_ADDRESS "castVote(uint256,bytes32,bytes)" 1 0xNullifierHash "0xMockProof" --private-key $PRIVATE_KEY --rpc-url $ZKSYNC_RPC_URL
```

#### Get election status:
```bash
cast call $CONTRACT_ADDRESS "getElectionStatus()" --rpc-url $ZKSYNC_RPC_URL
```

> 💡 Fast way to simulate voter behavior without a frontend.

---

## 🛠️ .env Setup

Make sure you have the following in a `.env` file at the root:

```env
PRIVATE_KEY=0xYourDeployerPrivateKey
ZKSYNC_RPC_URL=https://zksync-sepolia.g.alchemy.com/v2/yourAlchemyKey
CONTRACT_ADDRESS=0xDeployedContractAddress
```

Used by:
- `forge script` to deploy
- `cast` to interact
- `verify/verify-zksync.sh` to verify

---

Let me know if you'd like this turned into a styled `README.md`, PDF handout, or added to your GitHub repo!