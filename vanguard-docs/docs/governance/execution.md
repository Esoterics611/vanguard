# Execution and Enforcement

When a governance proposal succeeds, its encoded contract calls must be executed on-chain. This page covers the execution process, who can trigger it, and the security implications.

## Executing a Passed Proposal

After the voting period ends and a proposal has **Succeeded** status:

```javascript
const dao = await ethers.getContractAt("VanguardDAO", addresses.VanguardDAO);

// Execute using the same parameters as the original proposal
const tx = await dao.execute(
  targets,      // same as propose()
  values,       // same as propose()
  calldatas,    // same as propose()
  descriptionHash  // keccak256 of the description string
);
await tx.wait();
```

### Who Can Execute

Execution requires the `EXECUTOR_ROLE`. Currently held by the deployer wallet.

!!! warning "Future Feature"
    When governance is fully decentralized, the EXECUTOR_ROLE should be granted more broadly — potentially to any address — since execution is permissionless by design (the proposal has already passed the vote). Restricting execution to a single address creates a centralization risk where a passed proposal could be blocked by the executor refusing to act.

### Description Hash

The execute function requires the hash of the proposal description to identify which proposal is being executed:

```javascript
const descriptionHash = ethers.keccak256(
  ethers.toUtf8Bytes("Increase PVT multiplier from 1.0x to 1.5x")
);
```

This prevents executing the wrong proposal and ensures the executed actions match what was voted on.

## What Execution Does

Execution calls the `targets` contracts with the `calldatas` payloads. These calls execute atomically — if any call fails, the entire execution reverts.

**Examples of executable actions:**

| Action | Target | Calldata |
|--------|--------|----------|
| Change multiplier | RankManager | `setMultiplier(rank, value)` |
| Withdraw from treasury | Treasury | `withdraw(token, amount, recipient)` |
| Create payment stream | Treasury | `createStream(recipient, token, amount, duration)` |
| Pause token | VGRDToken | `pause()` |
| Grant role | Any contract | `grantRole(role, address)` |
| Transfer admin | Any contract | `grantRole(DEFAULT_ADMIN_ROLE, newAdmin)` |

## Proposal Cancellation

A proposal can be cancelled by its creator at any point before execution:

```javascript
await dao.cancel(targets, values, calldatas, descriptionHash);
```

Cancellation is irreversible. A cancelled proposal cannot be re-activated — a new proposal must be created.

## Governance Attack Vectors and Mitigations

| Attack | Description | Mitigation |
|--------|-------------|-----------|
| **Flash loan voting** | Borrow tokens to vote, return immediately | Snapshot-based voting (balance at proposal creation) |
| **Proposal spam** | Flood governance with proposals | 100,000 VGRD or CPT rank threshold |
| **Voter apathy** | Not enough participation to reach quorum | 4% quorum requirement; Abstain option to help reach quorum |
| **Governance capture** | Small group controls all decisions | Dual-weight system (tokens x rank) diversifies influence |
| **Executor censorship** | Executor refuses to execute passed proposals | Transfer EXECUTOR_ROLE to open access or DAO-controlled multisig |

## Emergency Governance

In critical situations (security vulnerability, active exploit), the protocol relies on the PAUSER_ROLE to pause contracts immediately. This is faster than the ~1 week governance cycle.

**Current emergency process:**

1. Deployer (holding PAUSER_ROLE) pauses the affected contract
2. Vulnerability is assessed and fixed
3. A governance proposal is created to implement the fix
4. After the vote passes, the fix is executed and the contract is unpaused

!!! warning "Future Feature"
    **Timelock:** A standard governance enhancement is adding a timelock between proposal success and execution. This gives the community time to react if a malicious proposal passes. Typical timelocks are 24-48 hours. Vanguard does not currently have a timelock — execution is immediate after a vote succeeds.
