# Contract Integration

This guide explains how to integrate the Vanguard smart contracts into a frontend application. While the examples use the Vanguard SvelteKit UI, the patterns apply to any JavaScript/TypeScript frontend.

!!! warning "Future Feature"
    The web UI does not currently have web3 integration. This guide describes the intended architecture and implementation pattern for the upcoming integration work.

## Architecture Overview

```
Browser
  ├── Wallet (MetaMask) ← user signs transactions
  ├── Provider (ethers.js) ← reads blockchain state
  ├── Signer (from wallet) ← writes to blockchain
  └── Contract Instances (ethers.Contract) ← typed interfaces to each contract
        ├── VGRDToken
        ├── ArmyRegistry
        ├── RankManager
        ├── TaskRegistry
        ├── RewardPool
        ├── BountyEscrow
        ├── Treasury
        └── VanguardDAO
```

## Step 1: Install Dependencies

```bash
cd vanguard-ui
npm install ethers
```

ethers.js v6 is recommended because it matches the Hardhat setup used in the contracts project.

## Step 2: Extract and Store ABIs

The compiled ABIs live in `contracts/artifacts/contracts/`. Extract just the ABI arrays (not the full artifact) into the UI project:

```typescript
// src/lib/contracts/abis/VGRDToken.ts
export const VGRDTokenABI = [
  "function name() view returns (string)",
  "function symbol() view returns (string)",
  "function totalSupply() view returns (uint256)",
  "function balanceOf(address) view returns (uint256)",
  "function transfer(address, uint256) returns (bool)",
  "function approve(address, uint256) returns (bool)",
  "function allowance(address, address) view returns (uint256)",
  // ... all public functions
] as const;
```

!!! tip "Human-Readable ABI"
    ethers.js v6 supports human-readable ABI strings (as shown above). This is much more readable than the full JSON ABI format. You can convert between formats using `ethers.Interface`.

## Step 3: Contract Addresses

```typescript
// src/lib/contracts/addresses.ts
export const CONTRACTS = {
  VGRDToken: "0x2Ef78A107b20eb4263448e70E643bA9621657493",
  Treasury: "0x55B811D87CFBbb149ea436BD5F57671602D91d54",
  ArmyRegistry: "0xBf3BEE33090fb5f9b147a72cAac6f4f44CE1F270",
  RankManager: "0xcbB1fB5E862D7e339619B55fE2E58dA6f35bc0f2",
  RewardPool: "0x840E56bAA0774b41eec0448F81a802281799429C",
  TaskRegistry: "0xd5832E767C76FbCBbee6F071b80B7F78Ad5F7e5A",
  BountyEscrow: "0x19F1A7F9d4A3d36BEAF2e4fb5A5E42F3f080B143",
  VanguardDAO: "0x1F6FB4dB93691747420d0fb9d397E4f97443A7Af",
} as const;

export const CHAIN_ID = 84532;  // Base Sepolia
export const RPC_URL = "https://sepolia.base.org";
```

## Step 4: Wallet Connection Store

Using Svelte 5 runes for reactive state:

```typescript
// src/lib/contracts/wallet.svelte.ts
import { ethers } from "ethers";
import { CHAIN_ID, RPC_URL } from "./addresses";

class WalletStore {
  provider = $state<ethers.BrowserProvider | null>(null);
  signer = $state<ethers.Signer | null>(null);
  account = $state<string | null>(null);
  chainId = $state<number | null>(null);
  isConnected = $derived(this.account !== null);
  isCorrectNetwork = $derived(this.chainId === CHAIN_ID);

  async connect() {
    if (!window.ethereum) throw new Error("No wallet detected");

    this.provider = new ethers.BrowserProvider(window.ethereum);
    this.signer = await this.provider.getSigner();
    this.account = await this.signer.getAddress();
    const network = await this.provider.getNetwork();
    this.chainId = Number(network.chainId);
  }

  async switchNetwork() {
    await window.ethereum.request({
      method: "wallet_switchEthereumChain",
      params: [{ chainId: "0x" + CHAIN_ID.toString(16) }],
    });
  }

  async disconnect() {
    this.provider = null;
    this.signer = null;
    this.account = null;
    this.chainId = null;
  }
}

export const wallet = new WalletStore();
```

## Step 5: Contract Factory

```typescript
// src/lib/contracts/contracts.svelte.ts
import { ethers } from "ethers";
import { wallet } from "./wallet.svelte";
import { CONTRACTS } from "./addresses";
import { VGRDTokenABI } from "./abis/VGRDToken";
import { ArmyRegistryABI } from "./abis/ArmyRegistry";
// ... import all ABIs

function getContract(address: string, abi: any) {
  if (!wallet.provider) throw new Error("Wallet not connected");
  const signer = wallet.signer;
  return new ethers.Contract(address, abi, signer || wallet.provider);
}

// Typed contract getters
export function getVGRDToken() {
  return getContract(CONTRACTS.VGRDToken, VGRDTokenABI);
}

export function getArmyRegistry() {
  return getContract(CONTRACTS.ArmyRegistry, ArmyRegistryABI);
}

// ... getters for all 8 contracts
```

## Step 6: Transaction Handling Pattern

Every write transaction should follow this pattern:

```typescript
async function executeTransaction(
  contractCall: () => Promise<ethers.ContractTransactionResponse>,
  onSuccess?: () => void
) {
  try {
    // 1. Send the transaction
    const tx = await contractCall();

    // 2. Wait for confirmation
    const receipt = await tx.wait();

    // 3. Handle success
    if (receipt?.status === 1) {
      onSuccess?.();
      // Show success notification
    } else {
      // Transaction reverted
      // Show error notification
    }
  } catch (error: any) {
    if (error.code === "ACTION_REJECTED") {
      // User rejected in wallet — not an error
    } else {
      // Show error notification with error.reason or error.message
    }
  }
}

// Usage:
await executeTransaction(
  () => getArmyRegistry().enlist(1),
  () => console.log("Enlisted successfully!")
);
```

## Reading vs. Writing

| Operation Type | Requires Wallet? | Costs Gas? | Example |
|---------------|-----------------|-----------|---------|
| **Read** (view/pure) | No | No | `token.balanceOf(address)` |
| **Write** (state change) | Yes (signer) | Yes | `registry.enlist(squadId)` |

For read-only operations, you can create a provider without a wallet:

```typescript
const readOnlyProvider = new ethers.JsonRpcProvider(RPC_URL);
const token = new ethers.Contract(CONTRACTS.VGRDToken, VGRDTokenABI, readOnlyProvider);
const balance = await token.balanceOf(someAddress);  // No wallet needed
```
