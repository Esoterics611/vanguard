# Deployment

This page covers the contract deployment process — how the existing deployment was done, how to verify contracts, and the path to mainnet.

## Current Deployment

| Property | Value |
|----------|-------|
| **Network** | Base Sepolia (Chain ID 84532) |
| **Deployer** | `0x41521c37dB02956185437C4e2461261A321073E1` |
| **Date** | April 27, 2026 |
| **Solidity** | 0.8.20 with optimizer (200 runs, viaIR) |
| **Framework** | Hardhat with ethers.js v6 |

## Deployment Script

The deployment script (`scripts/deploy.js`) handles:

1. Deploying all 8 contracts in dependency order
2. Granting cross-contract roles
3. Distributing initial token allocations
4. Saving addresses to `deployed-addresses.json`
5. Generating deployment documentation

### Deployment Order (Dependencies Matter)

```
1. VGRDToken (no dependencies)
2. Treasury (no dependencies)
3. ArmyRegistry (no dependencies)
4. RankManager (depends on ArmyRegistry)
5. RewardPool (depends on VGRDToken, ArmyRegistry, RankManager)
6. TaskRegistry (depends on ArmyRegistry, RankManager)
7. BountyEscrow (depends on VGRDToken, ArmyRegistry)
8. VanguardDAO (depends on VGRDToken, ArmyRegistry, RankManager)
```

### Post-Deployment Configuration

After all 8 contracts are deployed, the script runs these configuration transactions:

| Transaction | Purpose |
|------------|---------|
| Grant MINTER_ROLE to RewardPool | Allows RewardPool to mint VGRD for rewards |
| Grant RANK_MANAGER_ROLE to RankManager | Allows RankManager to update ranks in ArmyRegistry |
| Set RewardPool on TaskRegistry | Links task approvals to reward distribution |
| Grant DISTRIBUTOR_ROLE to TaskRegistry | Allows TaskRegistry to trigger reward distribution |
| Set TaskRegistry on BountyEscrow | Links bounty objectives to task completion |
| Set RewardPool on BountyEscrow | Links bounty fund release to reward pool |
| Grant ADMIN_ROLE to TaskRegistry | Allows TaskRegistry to update soldier stats |
| Transfer 400M VGRD to RewardPool | Fund the reward pool |
| Transfer 250M VGRD to Treasury | Fund the treasury |

### Running Deployment

```bash
cd contracts/

# Ensure .env has PRIVATE_KEY with sufficient ETH for gas
npm run deploy:sepolia
```

The script uses retry logic with exponential backoff (3 attempts per transaction, 5-10 second delays) to handle network congestion.

## Contract Verification

Verification publishes the source code on BaseScan, enabling the Read/Write Contract interface.

### Prerequisites

1. Get a BaseScan API key from [basescan.org](https://basescan.org)
2. Add to `contracts/.env`: `BASESCAN_API_KEY=your_key`

### Verification Commands

Each contract must be verified individually with its constructor arguments:

```bash
# VGRDToken(admin)
npx hardhat verify --network baseSepolia \
  0x2Ef78A107b20eb4263448e70E643bA9621657493 \
  "0x41521c37dB02956185437C4e2461261A321073E1"

# Treasury(admin)
npx hardhat verify --network baseSepolia \
  0x55B811D87CFBbb149ea436BD5F57671602D91d54 \
  "0x41521c37dB02956185437C4e2461261A321073E1"

# ArmyRegistry(admin)
npx hardhat verify --network baseSepolia \
  0xBf3BEE33090fb5f9b147a72cAac6f4f44CE1F270 \
  "0x41521c37dB02956185437C4e2461261A321073E1"

# RankManager(admin, registry)
npx hardhat verify --network baseSepolia \
  0xcbB1fB5E862D7e339619B55fE2E58dA6f35bc0f2 \
  "0x41521c37dB02956185437C4e2461261A321073E1" \
  "0xBf3BEE33090fb5f9b147a72cAac6f4f44CE1F270"

# RewardPool(admin, token, registry, rankManager)
npx hardhat verify --network baseSepolia \
  0x840E56bAA0774b41eec0448F81a802281799429C \
  "0x41521c37dB02956185437C4e2461261A321073E1" \
  "0x2Ef78A107b20eb4263448e70E643bA9621657493" \
  "0xBf3BEE33090fb5f9b147a72cAac6f4f44CE1F270" \
  "0xcbB1fB5E862D7e339619B55fE2E58dA6f35bc0f2"

# TaskRegistry(admin, registry, rankManager)
npx hardhat verify --network baseSepolia \
  0xd5832E767C76FbCBbee6F071b80B7F78Ad5F7e5A \
  "0x41521c37dB02956185437C4e2461261A321073E1" \
  "0xBf3BEE33090fb5f9b147a72cAac6f4f44CE1F270" \
  "0xcbB1fB5E862D7e339619B55fE2E58dA6f35bc0f2"

# BountyEscrow(admin, token, registry)
npx hardhat verify --network baseSepolia \
  0x19F1A7F9d4A3d36BEAF2e4fb5A5E42F3f080B143 \
  "0x41521c37dB02956185437C4e2461261A321073E1" \
  "0x2Ef78A107b20eb4263448e70E643bA9621657493" \
  "0xBf3BEE33090fb5f9b147a72cAac6f4f44CE1F270"

# VanguardDAO(admin, token, registry, rankManager)
npx hardhat verify --network baseSepolia \
  0x1F6FB4dB93691747420d0fb9d397E4f97443A7Af \
  "0x41521c37dB02956185437C4e2461261A321073E1" \
  "0x2Ef78A107b20eb4263448e70E643bA9621657493" \
  "0xBf3BEE33090fb5f9b147a72cAac6f4f44CE1F270" \
  "0xcbB1fB5E862D7e339619B55fE2E58dA6f35bc0f2"
```

## Live Demo Run

`contracts/scripts/demo.js` runs a full bounty on the live deployment: two fresh analyst wallets enlist, a bounty is posted and funded, both analysts complete tasks, and the escrow pays out in VGRD.

```bash
cd contracts
ENV_FILE=/path/to/.env npx hardhat run scripts/demo.js --network baseSepolia
```

The script is resumable. Each completed step is written to `demo/run.json` and skipped on re-run. Set `FORK=1` and use `--network hardhat` to rehearse on a local fork first. The analyst keys it generates go to `demo/wallets.json`, which is git-ignored.

`scripts/chaincheck.js` compares on-chain bytecode with the compiled sources, and `scripts/bsverify.js` submits source verification to Blockscout.

## Path to Mainnet

!!! warning "Future Feature"
    Mainnet deployment is planned but not yet scheduled. The following milestones must be completed first:

### Pre-Mainnet Checklist

- [ ] All contracts verified on testnet
- [ ] Comprehensive test suite passing (50+ checks)
- [ ] Full task lifecycle tested with multiple wallets
- [ ] Governance tested (proposal → vote → execute)
- [ ] Web UI connected to contracts
- [ ] Security audit by independent firm
- [ ] Formal verification of critical paths (reward calculation, voting power)
- [ ] Gas optimization review
- [ ] Emergency pause/unpause procedures documented and tested
- [ ] Role transfer plan finalized (deployer → DAO governance)
- [ ] Token distribution plan for mainnet finalized
- [ ] Legal review of token classification
- [ ] Community testnet feedback incorporated

### Mainnet Deployment Differences

| Aspect | Testnet | Mainnet |
|--------|---------|---------|
| Network | Base Sepolia (84532) | Base (8453) |
| ETH | Test ETH (no value) | Real ETH |
| VGRD | Test tokens | Real tokens |
| Gas costs | Free (faucet) | Real (~$0.001-0.01 per tx) |
| Verification | BaseScan Sepolia | BaseScan Mainnet |
| Risk | None | Real economic risk |
