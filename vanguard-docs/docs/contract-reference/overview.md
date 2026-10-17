# Contract Reference Overview

This section provides function-level documentation for all 8 Vanguard smart contracts. Each page lists every public and external function, its parameters, return values, access control requirements, and emitted events.

## Reading This Reference

Each function entry follows this format:

```
### functionName

**Access:** Who can call this function
**Mutability:** view (read-only) | nonpayable (writes state) | payable (accepts ETH)

Description of what the function does.

Parameters:
- `param1` (type) — description
- `param2` (type) — description

Returns:
- `value` (type) — description

Emits: `EventName(param1, param2)`

Reverts if:
- Condition that causes revert — "Error message"
```

## Contract Addresses (Base Sepolia)

| Contract | Address | Functions | Events |
|----------|---------|-----------|--------|
| [VGRDToken](vgrd-token.md) | `0x2Ef7...7493` | ~20 | Transfer, Approval, Snapshot |
| [ArmyRegistry](army-registry.md) | `0xBf3B...F270` | ~15 | Enlisted, RankUpdated, UnitCreated |
| [RankManager](rank-manager.md) | `0xcbB1...c0f2` | ~10 | Promoted, TrainingCompleted |
| [TaskRegistry](task-registry.md) | `0xd583...7e5A` | ~12 | ObjectiveCreated, TaskCreated, TaskApproved |
| [RewardPool](reward-pool.md) | `0x840E...429C` | ~8 | RewardDistributed, RewardClaimed |
| [BountyEscrow](bounty-escrow.md) | `0x19F1...B143` | ~8 | BountyCreated, ObjectiveRewarded |
| [Treasury](treasury.md) | `0x55B8...1d54` | ~6 | StreamCreated, StreamClaimed, Withdrawn |
| [VanguardDAO](vanguard-dao.md) | `0x1F6F...A7Af` | ~10 | ProposalCreated, VoteCast, ProposalExecuted |

## Common Patterns

### AccessControl Functions (All Contracts)

Every contract inherits OpenZeppelin's AccessControl and exposes:

| Function | Description |
|----------|-------------|
| `hasRole(bytes32 role, address account)` | Returns true if account has the role |
| `getRoleAdmin(bytes32 role)` | Returns the admin role for a given role |
| `grantRole(bytes32 role, address account)` | Grant a role (requires admin of that role) |
| `revokeRole(bytes32 role, address account)` | Revoke a role (requires admin of that role) |
| `renounceRole(bytes32 role, address account)` | Renounce your own role (irreversible) |

### Pausable Functions (Select Contracts)

Contracts that implement Pausable expose:

| Function | Description |
|----------|-------------|
| `paused()` | Returns true if the contract is paused |
| `pause()` | Pause the contract (requires PAUSER_ROLE) |
| `unpause()` | Unpause the contract (requires PAUSER_ROLE) |
