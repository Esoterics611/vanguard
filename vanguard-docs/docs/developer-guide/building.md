# Building on Vanguard

This page is for developers who want to build applications, bots, dashboards, or integrations that interact with the Vanguard protocol. The contracts are permissionless — anyone can read from them and any enlisted soldier can write to them (within their rank permissions).

## What You Can Build

### Analytics Dashboard

Read contract state and index events to build real-time protocol analytics:

- Token flow visualization
- RewardPool depletion rate and runway
- Task completion trends
- Rank distribution charts
- Governance participation metrics

**Contracts to read:** All 8 (primarily VGRDToken events, TaskRegistry events, VanguardDAO events)

### Notification Bot

Monitor contract events and send notifications (Discord, Telegram, email):

- New bounty created
- Task assigned to a soldier
- Task approved (reward earned)
- New governance proposal
- Voting period ending soon

**Events to monitor:**

```javascript
// Listen for task approvals
taskRegistry.on("TaskApproved", (taskId, approver, soldier) => {
  sendNotification(`Task #${taskId} approved! ${soldier} earned a reward.`);
});

// Listen for new proposals
dao.on("ProposalCreated", (proposalId, proposer, description) => {
  sendNotification(`New proposal: ${description}`);
});
```

### Leaderboard

Build a competitive ranking system based on on-chain metrics:

```javascript
// Query all soldiers' stats
const soldiers = [];  // collect from Enlist events
for (const addr of soldiers) {
  const s = await registry.getSoldier(addr);
  soldiers.push({
    address: addr,
    rank: s.rank,
    tasksCompleted: s.tasksCompleted,
    totalEarned: s.totalEarned
  });
}
// Sort by totalEarned, tasksCompleted, or rank
```

### Auto-Claimer

A bot that automatically claims pending rewards for soldiers:

```javascript
// Check and claim pending rewards
const pending = await rewardPool.pendingRewards(soldierAddress);
if (pending > 0n) {
  const tx = await rewardPool.connect(soldierSigner).claimRewards();
  await tx.wait();
}
```

!!! note "Gas Sponsorship"
    Auto-claimers need to pay gas on behalf of the soldier. This is a common pattern in DeFi protocols and can be funded through a meta-transaction relayer or gas sponsorship program.

## Event Indexing

For any application that needs historical data or efficient queries, direct contract reads are insufficient. You need an **event indexer**.

### Option 1: Custom Indexer

Build a simple indexer that scans blocks for Vanguard events and stores them in a database:

```javascript
const filter = taskRegistry.filters.TaskApproved();
const events = await taskRegistry.queryFilter(filter, fromBlock, toBlock);

for (const event of events) {
  await db.insert({
    taskId: event.args.taskId,
    soldier: event.args.soldier,
    reward: event.args.reward,
    block: event.blockNumber,
    timestamp: (await event.getBlock()).timestamp
  });
}
```

### Option 2: The Graph (Subgraph)

!!! warning "Future Feature"
    A Graph subgraph for Vanguard is planned but not yet deployed. When available, it will provide a GraphQL API for efficient querying of all contract events and derived state.

## API Design Considerations

If you're building a backend API that wraps Vanguard contract interactions:

1. **Cache aggressively.** On-chain state changes infrequently (only on transactions). Cache read results with block-number-based invalidation.

2. **Batch RPC calls.** Use `ethers.Contract.multicall()` or a multicall contract to batch multiple reads into a single RPC call.

3. **Handle reorgs.** On L2s like Base, block reorganizations are rare but possible. Wait for 2-3 confirmations before treating data as final.

4. **Rate limit writes.** Implement rate limiting on any endpoint that triggers transactions to prevent gas waste and potential abuse.

## Security Considerations for Integrators

1. **Never expose private keys in frontend code.** All transaction signing must happen in the user's wallet.

2. **Validate all inputs client-side.** Check that amounts, addresses, and IDs are valid before sending transactions to avoid wasting gas on reverts.

3. **Handle contract reverts gracefully.** Parse revert reasons to show meaningful error messages to users.

4. **Respect access control.** Don't attempt actions the connected wallet is not authorized to perform — check rank and roles before presenting UI options.
