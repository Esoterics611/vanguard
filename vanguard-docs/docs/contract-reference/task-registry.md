# TaskRegistry

**Address:** `0xd5832E767C76FbCBbee6F071b80B7F78Ad5F7e5A`
**Purpose:** Work management — creates and tracks objectives and tasks through their lifecycle.

## Roles

| Role | Holder | Purpose |
|------|--------|---------|
| `DEFAULT_ADMIN_ROLE` | Deployer | Grant/revoke roles |
| `DAO_ROLE` | Deployer | Administrative operations |
| `BOUNTY_ESCROW_ROLE` | BountyEscrow | Link bounties to objectives |

## Data Structures

### Objective

```solidity
struct Objective {
    address creator;
    uint256 unitId;
    string title;
    string description;
    uint256 bountyId;
    uint256 taskCount;
    uint256 completedTaskCount;
}
```

### Task

```solidity
struct Task {
    uint256 objectiveId;
    address creator;
    address assignee;
    string title;
    string description;
    uint256 rewardAmount;
    TaskStatus status;     // OPEN=0, ASSIGNED=1, SUBMITTED=2, APPROVED=3, REJECTED=4
    string submissionHash;
}
```

## Functions

### createObjective

**Access:** SGT+ rank | **Mutability:** nonpayable

Create a new objective (workstream).

- `_unitId` (uint256) — owning unit
- `_title` (string) — objective title
- `_description` (string) — objective description
- `_bountyId` (uint256) — associated bounty (0 for unfunded)

Emits: `ObjectiveCreated(objectiveId, creator, unitId, title)`

### createTask

**Access:** SGT+ rank | **Mutability:** nonpayable

Create a new task within an objective.

- `_objectiveId` (uint256) — parent objective
- `_title` (string) — task title
- `_description` (string) — task description
- `_rewardAmount` (uint256) — base VGRD reward

Emits: `TaskCreated(taskId, objectiveId, creator, title, rewardAmount)`

### assignTask

**Access:** SGT+ rank | **Mutability:** nonpayable

Assign a task to a specific soldier.

- `_taskId` (uint256) — task to assign
- `_soldier` (address) — soldier to assign

Reverts if: task not OPEN, soldier not enlisted.

Emits: `TaskAssigned(taskId, soldier, assigner)`

### selfAssignTask

**Access:** Any enlisted soldier | **Mutability:** nonpayable

Assign a task to yourself.

- `_taskId` (uint256) — task to claim

Reverts if: task not OPEN, caller not enlisted.

### submitTask

**Access:** Assigned soldier | **Mutability:** nonpayable

Submit completed work.

- `_taskId` (uint256) — task to submit
- `_submissionHash` (string) — IPFS hash of deliverable

Reverts if: task not ASSIGNED, caller is not the assignee.

Emits: `TaskSubmitted(taskId, soldier, submissionHash)`

### approveTask

**Access:** SGT+ rank | **Mutability:** nonpayable

Approve a submitted task. Triggers automatic reward distribution.

- `_taskId` (uint256) — task to approve

Reverts if: task not SUBMITTED.

Emits: `TaskApproved(taskId, approver, soldier, reward)`

**Side effects:**
1. Calls `RewardPool.distributeTaskReward(soldier, rewardAmount, multiplier)`
2. Increments `soldier.tasksCompleted` in ArmyRegistry
3. Increments `objective.completedTaskCount`

### rejectTask

**Access:** SGT+ rank | **Mutability:** nonpayable

Reject a submitted task, returning it to ASSIGNED state.

- `_taskId` (uint256) — task to reject

Emits: `TaskRejected(taskId, rejector, soldier)`

### getObjective

**Access:** Public | **Mutability:** view

- `_objectiveId` (uint256)

Returns: Objective struct.

### getTask

**Access:** Public | **Mutability:** view

- `_taskId` (uint256)

Returns: Task struct.

### getObjectiveProgress

**Access:** Public | **Mutability:** view

- `_objectiveId` (uint256)

Returns: (completedTasks, totalTasks) — both uint256.

### nextObjectiveId / nextTaskId

**Access:** Public | **Mutability:** view

Returns: uint256 — the next auto-increment ID (current count + 1).

### setRewardPool

**Access:** DEFAULT_ADMIN_ROLE | **Mutability:** nonpayable

- `_rewardPool` (address) — RewardPool contract address

Links the TaskRegistry to the RewardPool for reward distribution.

## Events

| Event | Parameters |
|-------|-----------|
| `ObjectiveCreated` | `objectiveId`, `creator`, `unitId`, `title` |
| `TaskCreated` | `taskId`, `objectiveId`, `creator`, `title`, `rewardAmount` |
| `TaskAssigned` | `taskId`, `soldier`, `assigner` |
| `TaskSubmitted` | `taskId`, `soldier`, `submissionHash` |
| `TaskApproved` | `taskId`, `approver`, `soldier`, `reward` |
| `TaskRejected` | `taskId`, `rejector`, `soldier` |
