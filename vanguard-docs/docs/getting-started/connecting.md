# Connecting to the Protocol

Once you have a wallet with test ETH on Base Sepolia, you can connect to the Vanguard protocol. This page covers the available interfaces and how to use them.

## Available Interfaces

### 1. BaseScan (Available Now)

Until the web UI is connected to the contracts, you can interact with every contract directly through BaseScan's Read/Write interface. This is the most reliable method for testing.

**Steps:**

1. Go to the contract's BaseScan page (addresses listed below)
2. Click the "Contract" tab
3. If the contract is verified, you'll see "Read Contract" and "Write Contract" sub-tabs
4. Click "Write Contract"
5. Click "Connect to Web3" and connect your MetaMask
6. Select the function you want to call
7. Enter parameters and click "Write"

!!! note "Contract Verification Required"
    The BaseScan Read/Write interface is only available for verified contracts. If the contracts have not yet been verified, you will need to use the programmatic method below.

**Contract addresses on Base Sepolia:**

| Contract | Address |
|----------|---------|
| VGRDToken | `0x2Ef78A107b20eb4263448e70E643bA9621657493` |
| Treasury | `0x55B811D87CFBbb149ea436BD5F57671602D91d54` |
| ArmyRegistry | `0xBf3BEE33090fb5f9b147a72cAac6f4f44CE1F270` |
| RankManager | `0xcbB1fB5E862D7e339619B55fE2E58dA6f35bc0f2` |
| RewardPool | `0x840E56bAA0774b41eec0448F81a802281799429C` |
| TaskRegistry | `0xd5832E767C76FbCBbee6F071b80B7F78Ad5F7e5A` |
| BountyEscrow | `0x19F1A7F9d4A3d36BEAF2e4fb5A5E42F3f080B143` |
| VanguardDAO | `0x1F6FB4dB93691747420d0fb9d397E4f97443A7Af` |

### 2. Hardhat Console (Developers)

For developers comfortable with the command line, Hardhat's console provides direct contract interaction:

```bash
cd contracts/
npx hardhat console --network baseSepolia
```

```javascript
// In the console:
const registry = await ethers.getContractAt(
  "ArmyRegistry",
  "0xBf3BEE33090fb5f9b147a72cAac6f4f44CE1F270"
);
const isEnlisted = await registry.isEnlisted("0xYOUR_ADDRESS");
console.log("Enlisted:", isEnlisted);
```

### 3. Web UI (Coming Soon)

!!! warning "Future Feature"
    The Vanguard web UI (`vanguard-ui/`) is fully built with 11 pages but currently runs on mock data. Web3 integration (wallet connection, contract calls) is the next development phase. When complete, the web UI will be the primary interface for all participants.

### 4. Mobile App (Partial)

!!! warning "Future Feature"
    The Flutter mobile app is built but uses Firebase as its backend rather than direct contract interaction. Mobile wallet integration (via WalletConnect) is planned for a future phase.

## Checking Your Connection

To verify that everything is working:

1. Open MetaMask and confirm you're on "Base Sepolia"
2. Confirm you have test ETH (balance > 0)
3. Try a read-only call (no gas required):
   - Go to [VGRDToken on BaseScan](https://base-sepolia.blockscout.com/address/0x2Ef78A107b20eb4263448e70E643bA9621657493#readContract)
   - Click "Read Contract"
   - Find `name()` and click "Query"
   - It should return "Vanguard Token"

If you see "Vanguard Token," your connection to the Base Sepolia network is working correctly.
