# Token Overview

## VGRD: The Vanguard Token

VGRD is the native ERC-20 token of the Vanguard protocol. It serves three functions:

1. **Compensation** — soldiers earn VGRD for completing tasks, with amounts scaled by rank
2. **Governance** — VGRD holders vote on protocol changes, with voting power amplified by rank
3. **Funding** — bounties are denominated and funded in VGRD

VGRD is not a stablecoin, a wrapped asset, or a synthetic derivative. It is a protocol-native utility token whose value derives from the productive work output of the DAO and the governance rights it confers.

## Token Specification

| Property | Value |
|----------|-------|
| **Name** | Vanguard Token |
| **Symbol** | VGRD |
| **Standard** | ERC-20 (OpenZeppelin v5.4) |
| **Decimals** | 18 |
| **Total Supply** | 1,000,000,000 (1 billion) |
| **Blockchain** | Base (Ethereum L2) |
| **Contract** | `0x2Ef78A107b20eb4263448e70E643bA9621657493` |

## Extended Capabilities

VGRD extends the base ERC-20 standard with three additional features:

### Snapshots (ERC-20 Snapshot)

The token supports **balance snapshots** — a mechanism that records the token balance of every holder at a specific point in time (block number). This is critical for fair governance voting.

**Why it matters:** Without snapshots, a voter could cast their vote, then transfer their tokens to another address and vote again. Snapshots freeze balances at the moment a proposal is created, preventing double-voting.

```solidity
// Create a snapshot (SNAPSHOT_ROLE required)
function snapshot() external returns (uint256 snapshotId);

// Query historical balance
function balanceOfAt(address account, uint256 snapshotId) external view returns (uint256);
```

### Permits (EIP-2612)

VGRD supports **gasless approvals** via the EIP-2612 permit standard. Instead of sending a separate `approve()` transaction before transferring tokens, a user can sign a message off-chain that authorizes the transfer. This saves gas and improves UX.

**Why it matters:** In a typical ERC-20 bounty flow, the user would need two transactions: (1) approve the BountyEscrow to spend their tokens, (2) create the bounty. With permits, step 1 can be folded into step 2 via a signed message.

### Pausability

The token can be **paused** by an address holding the `PAUSER_ROLE`, which stops all transfers, mints, and burns. This is an emergency circuit breaker.

**Why it matters:** If a critical vulnerability is discovered, pausing the token prevents exploitation while a fix is developed and deployed.

!!! note "Current Pause Authority"
    The `PAUSER_ROLE` is currently held by the deployer wallet. In a fully decentralized state, this role would be transferred to the VanguardDAO contract, requiring a governance vote to pause or unpause.
