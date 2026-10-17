# Financial Controls

This page documents the financial controls embedded in the Vanguard smart contracts — the rules that govern how tokens move, who can authorize movements, and what safeguards exist against misuse.

## Access Control Matrix

| Operation | Required Role | Current Holder | Target Holder |
|-----------|--------------|----------------|--------------|
| Treasury withdrawal | DAO_ROLE | Deployer | VanguardDAO |
| Create payment stream | DAO_ROLE | Deployer | VanguardDAO |
| Mint VGRD | MINTER_ROLE | RewardPool | RewardPool |
| Pause VGRD transfers | PAUSER_ROLE | Deployer | VanguardDAO |
| Distribute task rewards | DISTRIBUTOR_ROLE | TaskRegistry | TaskRegistry |
| Update rank | RANK_MANAGER_ROLE | RankManager | RankManager |
| Grant/revoke roles | DEFAULT_ADMIN_ROLE | Deployer | VanguardDAO |

## Reentrancy Protection

All contracts that handle token transfers use OpenZeppelin's `ReentrancyGuard`. This prevents reentrancy attacks — a class of exploit where a malicious contract calls back into the victim contract during a token transfer.

Protected functions include:

- `RewardPool.claimRewards()`
- `Treasury.withdraw()`
- `Treasury.claimStream()`
- `BountyEscrow.createBounty()`
- `BountyEscrow.releaseObjectiveReward()`
- `BountyEscrow.cancelBounty()`

## Token Transfer Safeguards

### Pausability

VGRDToken can be paused, stopping all transfers, mints, and burns. This is the nuclear option for emergencies.

```javascript
// Pause (requires PAUSER_ROLE)
await token.pause();

// Unpause (requires PAUSER_ROLE)
await token.unpause();
```

When paused:
- No transfers between any addresses
- No minting (RewardPool cannot distribute rewards)
- No burning
- Read functions still work (balanceOf, totalSupply, etc.)

### Escrow Isolation

BountyEscrow tokens are isolated per-bounty. A bug or exploit in one bounty cannot drain tokens allocated to another bounty. Each bounty's allocation is tracked independently.

## Spending Limits

The current contract design does not enforce per-transaction spending limits on Treasury withdrawals or RewardPool distributions. The primary control is role-based access — only authorized contracts/addresses can trigger movements.

!!! warning "Future Feature"
    **Spending limits and rate limiting** for Treasury operations are planned governance enhancements. These would cap the amount that can be withdrawn in a given time period, providing an additional safeguard even if DAO_ROLE is compromised.

## Audit Trail

All token movements emit standard ERC-20 `Transfer` events, providing a complete, immutable audit trail on the blockchain. Additionally, each contract emits domain-specific events:

| Contract | Key Events |
|----------|-----------|
| RewardPool | `RewardDistributed(soldier, amount)`, `RewardClaimed(soldier, amount)` |
| BountyEscrow | `BountyCreated(id, creator, amount)`, `ObjectiveRewarded(bountyId, objectiveId, amount)` |
| Treasury | `StreamCreated(id, recipient, amount)`, `StreamClaimed(id, amount)` |
| VanguardDAO | `ProposalCreated(...)`, `VoteCast(voter, proposalId, support, weight)` |

These events can be indexed by off-chain services (The Graph, custom indexers) for real-time monitoring and historical analysis.

## Recommendations for Institutional Oversight

For organizations evaluating or participating in the protocol, recommended monitoring practices include:

1. **Real-time alerts** on Treasury withdrawals exceeding a threshold
2. **Daily snapshots** of RewardPool balance to track depletion rate
3. **Governance activity monitoring** — new proposals, vote distributions, execution events
4. **Role change monitoring** — any grantRole/revokeRole events across all contracts
5. **Large transfer alerts** — VGRD transfers exceeding a defined threshold
