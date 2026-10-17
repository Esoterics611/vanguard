# Smart Contract Risk

This chapter identifies and analyzes the smart contract risks present in the Vanguard protocol. It is written for institutional evaluators, security auditors, and informed participants who need to understand the risk profile before engaging with the protocol.

## Audit Status

!!! danger "No Formal Audit"
    The Vanguard smart contracts have **not undergone a formal security audit** by an independent firm. This is the single most significant risk factor. All other risks discussed in this chapter are secondary to the absence of professional audit coverage.

    A formal audit should cover:

    - Static analysis (Slither, Mythril)
    - Manual code review by experienced Solidity auditors
    - Economic attack simulation
    - Access control verification
    - Gas optimization review

## Risk Categories

### 1. Access Control Risks

**Centralization Risk: HIGH (Current State)**

The deployer wallet (`0x41521c37...`) currently holds:

- `DEFAULT_ADMIN_ROLE` on all 8 contracts
- `DAO_ROLE` on Treasury, RankManager, BountyEscrow
- `PAUSER_ROLE` on VGRDToken
- `SNAPSHOT_ROLE` on VGRDToken
- `EXECUTOR_ROLE` on VanguardDAO

This means a single private key can:

- Pause all token transfers
- Withdraw the entire Treasury (250M VGRD)
- Change rank multipliers arbitrarily
- Grant/revoke any role on any contract
- Mint unlimited VGRD (by granting themselves MINTER_ROLE)

**Mitigation path:** Transfer administrative roles to the VanguardDAO contract, requiring governance votes for all sensitive operations. This is planned but not yet executed.

### 2. Reentrancy Risks

**Risk: LOW**

All token-handling functions use OpenZeppelin's `ReentrancyGuard`. The check-effects-interactions pattern is followed.

| Contract | Protected Functions |
|----------|-------------------|
| RewardPool | claimRewards |
| Treasury | withdraw, claimStream |
| BountyEscrow | createBounty, releaseObjectiveReward, cancelBounty |

### 3. Integer Overflow/Underflow

**Risk: LOW**

Solidity 0.8.20 has built-in overflow/underflow protection. All arithmetic operations revert on overflow by default.

### 4. Reward Calculation Risk

**Risk: MEDIUM**

The reward formula `baseReward × multiplier ÷ 100` could theoretically be manipulated if:

- A leader sets an extremely high base reward
- The DAO role sets an extremely high multiplier
- Both occur simultaneously, draining the RewardPool rapidly

**Mitigation:** There are no per-task or per-period reward caps. Adding maximum base reward limits and daily distribution caps would reduce this risk.

### 5. Token Minting Risk

**Risk: MEDIUM**

The RewardPool holds `MINTER_ROLE` and can mint unlimited VGRD. If the RewardPool's distribution logic were compromised, or if the DISTRIBUTOR_ROLE were granted to a malicious contract, unlimited token inflation could occur.

**Mitigation:** The DISTRIBUTOR_ROLE is restricted to the TaskRegistry contract. However, the DEFAULT_ADMIN can grant this role to any address.

### 6. Upgrade and Immutability

**Risk Context: IMMUTABLE CONTRACTS**

The Vanguard contracts are **not upgradeable**. They do not use proxy patterns (UUPS, Transparent Proxy, etc.). This means:

**Advantage:** No risk of malicious upgrades or storage corruption from proxy implementation bugs.

**Disadvantage:** Any bugs discovered after deployment cannot be fixed in place. The only remediation is deploying new contracts and migrating state — a complex and potentially disruptive process.

### 7. Flash Loan Attack Resistance

**Risk: LOW**

The VanguardDAO uses snapshot-based voting, which records token balances at the block a proposal is created. This prevents flash loan attacks where an attacker borrows tokens to vote and returns them in the same transaction.

### 8. Front-Running Risk

**Risk: LOW-MEDIUM**

On Base (an L2), the sequencer has a first-come-first-served ordering policy, which reduces (but does not eliminate) MEV-based front-running compared to Ethereum L1.

Potential front-running scenarios:

- A soldier sees a high-reward task and races to self-assign it
- A voter sees the current vote tally and adjusts their vote

These are low-severity — they don't result in fund loss, only competitive advantage.

## Dependency Risk

All contracts depend on OpenZeppelin v5.4 libraries:

| Library | Purpose | Risk Level |
|---------|---------|-----------|
| AccessControl | Role management | Low (battle-tested) |
| ERC20 | Token standard | Low (battle-tested) |
| ERC20Snapshot | Balance snapshots | Low |
| ERC20Permit | Gasless approvals | Low |
| Pausable | Emergency pause | Low |
| ReentrancyGuard | Reentrancy protection | Low |

OpenZeppelin is the most widely used and audited smart contract library. The risk of a vulnerability in these base contracts is low but non-zero.

## Recommended Risk Mitigations

| Priority | Action | Effort |
|----------|--------|--------|
| Critical | Commission formal security audit | High |
| High | Transfer admin roles to VanguardDAO | Medium |
| High | Implement reward caps (per-task and per-period) | Low |
| Medium | Add timelock to governance execution | Medium |
| Medium | Deploy monitoring for unusual token movements | Medium |
| Low | Consider multisig for admin roles during transition | Low |
