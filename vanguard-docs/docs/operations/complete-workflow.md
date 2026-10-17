# The Complete Workflow

This page walks through a full end-to-end example: from bounty creation to reward claiming. Follow along to understand how all the pieces fit together.

## Scenario

**Captain IRONFORGE** wants to fund a documentation project. **Sergeant PHOENIX** will create the tasks. **Private SENTINEL** will do the work.

## Step 1: Captain Creates Bounty

IRONFORGE (CPT) has 100,000 VGRD and wants to allocate 20,000 VGRD to a documentation bounty.

```javascript
// IRONFORGE's wallet
const token = await ethers.getContractAt("VGRDToken", addresses.VGRDToken);
const escrow = await ethers.getContractAt("BountyEscrow", addresses.BountyEscrow);

// First, approve the escrow to spend tokens
await token.approve(addresses.BountyEscrow, ethers.parseEther("20000"));

// Create the bounty (no objectives linked yet)
await escrow.createBounty(
  ethers.parseEther("20000"),
  [],  // objective IDs (will link later)
  []   // allocations
);
// Bounty ID 1 is created, 20,000 VGRD is now in escrow
```

## Step 2: Sergeant Creates Objective

PHOENIX (SGT) creates an objective for the documentation work.

```javascript
// PHOENIX's wallet
const taskRegistry = await ethers.getContractAt("TaskRegistry", addresses.TaskRegistry);

await taskRegistry.createObjective(
  1,  // unitId (Alpha Squad)
  "Contract Documentation",
  "Write comprehensive documentation for all 8 Vanguard contracts",
  1   // bountyId — links to IRONFORGE's bounty
);
// Objective ID 1 is created
```

## Step 3: Sergeant Creates Tasks

PHOENIX breaks the objective into individual tasks.

```javascript
// Task 1: VGRDToken docs
await taskRegistry.createTask(
  1,  // objectiveId
  "Document VGRDToken",
  "Write function reference for VGRDToken including all public functions, events, and usage examples",
  ethers.parseEther("3000")  // base reward: 3,000 VGRD
);

// Task 2: ArmyRegistry docs
await taskRegistry.createTask(
  1,
  "Document ArmyRegistry",
  "Write function reference for ArmyRegistry including enlistment, units, and soldier queries",
  ethers.parseEther("4000")  // base reward: 4,000 VGRD
);

// Tasks 3-8 for remaining contracts...
```

## Step 4: Private Claims a Task

SENTINEL (PVT) sees the open tasks and claims one.

```javascript
// SENTINEL's wallet
await taskRegistry.selfAssignTask(1);  // Claims Task #1 (VGRDToken docs)
// Task 1 status: OPEN → ASSIGNED
```

## Step 5: Private Does the Work

SENTINEL writes the VGRDToken documentation off-chain. They upload the finished document to IPFS and receive a content hash.

*(This step happens entirely off-chain. The protocol does not track work-in-progress.)*

## Step 6: Private Submits Work

SENTINEL submits the completed work with the IPFS hash as proof.

```javascript
// SENTINEL's wallet
await taskRegistry.submitTask(
  1,  // taskId
  "QmXoypizjW3WknFiJnKLwHCnL72vedxjQkDDP1mXWo6uco"  // IPFS hash
);
// Task 1 status: ASSIGNED → SUBMITTED
```

## Step 7: Sergeant Reviews and Approves

PHOENIX reviews the submission (reads the IPFS document) and approves it.

```javascript
// PHOENIX's wallet
await taskRegistry.approveTask(1);
// Task 1 status: SUBMITTED → APPROVED
```

**What happens on-chain when approveTask() executes:**

1. TaskRegistry reads SENTINEL's rank from ArmyRegistry → PVT (rank 1)
2. TaskRegistry reads PVT multiplier from RankManager → 100 (1.0x)
3. TaskRegistry calls RewardPool.distributeTaskReward(SENTINEL, 3000 VGRD, multiplier=100)
4. RewardPool calculates: 3000 × 100 ÷ 100 = **3,000 VGRD**
5. RewardPool adds 3,000 VGRD to SENTINEL's pending rewards
6. Objective 1's completedTaskCount increments from 0 to 1

## Step 8: Private Claims Rewards

SENTINEL claims their accrued rewards.

```javascript
// SENTINEL's wallet
const rewardPool = await ethers.getContractAt("RewardPool", addresses.RewardPool);

// Check pending rewards first
const pending = await rewardPool.pendingRewards(SENTINEL_ADDRESS);
console.log("Pending:", ethers.formatEther(pending), "VGRD");  // 3,000.0

// Claim
await rewardPool.claimRewards();
// 3,000 VGRD is minted/transferred to SENTINEL's wallet
// pendingRewards[SENTINEL] → 0
```

## Step 9: Objective Completes

Once PHOENIX approves all remaining tasks in the objective, the objective is complete.

```javascript
// After all 8 tasks are approved
const progress = await taskRegistry.getObjectiveProgress(1);
// Returns: [8, 8] — 8 of 8 tasks complete
```

## Step 10: Bounty Funds Released

With the objective complete, the bounty's allocated funds can be released:

```javascript
await escrow.releaseObjectiveReward(1, 1);  // bountyId=1, objectiveId=1
// Objective 1's VGRD allocation transfers from BountyEscrow to RewardPool
```

If this was the bounty's only objective, the bounty status changes to COMPLETED.

## Summary: What Each Party Did

| Party | Actions | Transactions |
|-------|---------|-------------|
| **IRONFORGE** (CPT) | Approved tokens, created bounty | 2 |
| **PHOENIX** (SGT) | Created objective, created 8 tasks, approved 8 submissions, released bounty reward | 18 |
| **SENTINEL** (PVT) | Self-assigned 8 tasks, submitted 8 tasks, claimed rewards | 17 |
| **Total** | | **37 transactions** |

At Base Sepolia gas costs (~0.0001 ETH per tx), the total gas cost for this entire workflow is approximately **0.0037 ETH** — less than a penny on mainnet.

## What If Something Goes Wrong?

| Problem | Resolution |
|---------|-----------|
| SENTINEL submits poor work | PHOENIX rejects the task; SENTINEL revises and resubmits |
| SENTINEL goes inactive after assignment | Leader can reassign the task (or SENTINEL can release it) |
| IRONFORGE cancels the bounty mid-project | Completed tasks keep their rewards; unreleased funds return to IRONFORGE |
| PHOENIX approves work that shouldn't have been approved | Currently no recourse (approved tasks are final) — this is a governance risk |
