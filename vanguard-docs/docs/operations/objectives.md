# Objectives

An objective is a **workstream** — a collection of related tasks that together produce a deliverable. Objectives are the middle layer between high-level bounties and individual tasks.

## Objective Structure

| Field | Type | Description |
|-------|------|-------------|
| `id` | uint256 | Auto-incrementing objective identifier |
| `creator` | address | Wallet that created the objective |
| `unitId` | uint256 | The unit (squad/section) responsible for this objective |
| `title` | string | Human-readable title |
| `description` | string | Detailed description of the deliverable |
| `bountyId` | uint256 | Associated bounty (0 if unfunded) |
| `taskCount` | uint256 | Number of tasks in this objective |
| `completedTaskCount` | uint256 | Number of approved tasks |

## Creating an Objective

### Requirements

1. **Rank:** SGT (Sergeant, rank 5) or higher
2. **Unit membership:** You should be a member of the unit the objective is assigned to

### Process

```javascript
const taskRegistry = await ethers.getContractAt(
  "TaskRegistry",
  addresses.TaskRegistry
);

const tx = await taskRegistry.createObjective(
  1,           // unitId — which squad/unit owns this
  "API Documentation",   // title
  "Complete API reference docs for all 8 contracts",  // description
  0            // bountyId — 0 if no bounty, or the bounty ID
);
await tx.wait();
```

The `nextObjectiveId` counter increments and the new objective is stored on-chain.

## Objective Progress

Objective progress is calculated automatically based on task completion:

```
progress = completedTaskCount ÷ taskCount × 100%
```

You can query progress on-chain:

```javascript
const progress = await taskRegistry.getObjectiveProgress(objectiveId);
// Returns: [completedTasks, totalTasks]
```

## Objective Completion

An objective is considered **complete** when `completedTaskCount == taskCount` — every task has been approved.

When an objective completes:

1. If linked to a bounty, the bounty's objective allocation can be released
2. Leader bonuses may be distributed
3. The objective is marked as complete in the contract state

## Objectives Without Bounties

Not every objective needs a bounty. An objective with `bountyId = 0` is an **unfunded objective** — the tasks within it still pay rewards from the RewardPool, but there is no escrow release when the objective completes.

This is useful for:

- Internal housekeeping work
- Community-driven projects where individuals fund their own effort
- Ongoing operational tasks that don't have a specific budget

## Querying Objectives

### Get a specific objective

```javascript
const obj = await taskRegistry.getObjective(objectiveId);
console.log("Title:", obj.title);
console.log("Tasks:", obj.taskCount.toString());
console.log("Completed:", obj.completedTaskCount.toString());
```

### List all objectives

```javascript
const nextId = await taskRegistry.nextObjectiveId();
for (let i = 1; i < nextId; i++) {
  const obj = await taskRegistry.getObjective(i);
  console.log(`#${i}: ${obj.title} — ${obj.completedTaskCount}/${obj.taskCount} tasks`);
}
```

!!! note "Indexing Note"
    Iterating through all objectives by ID works for small-scale testing. In production, an event indexer (like The Graph) or backend cache should be used for efficient querying.
