# RewardPool

**Address:** `0x840E56bAA0774b41eec0448F81a802281799429C`
**Purpose:** Calculates and distributes rank-adjusted VGRD rewards for task completion.

## Roles

| Role | Holder | Purpose |
|------|--------|---------|
| `DEFAULT_ADMIN_ROLE` | Deployer | Grant/revoke roles |
| `DISTRIBUTOR_ROLE` | TaskRegistry | Trigger reward distribution |
| `DAO_ROLE` | Deployer | Administrative operations |

## State Variables

| Variable | Type | Description |
|----------|------|-------------|
| `token` | address | VGRDToken contract address |
| `registry` | address | ArmyRegistry contract address |
| `rankManager` | address | RankManager contract address |
| `pendingRewards` | mapping(address => uint256) | Unclaimed rewards per soldier |
| `totalDistributed` | uint256 | Cumulative VGRD distributed |
| `totalClaimed` | uint256 | Cumulative VGRD claimed |

## Functions

### distributeTaskReward

**Access:** DISTRIBUTOR_ROLE (TaskRegistry) | **Mutability:** nonpayable

Calculate and accrue a task reward for a soldier.

- `_soldier` (address) — soldier who completed the task
- `_baseReward` (uint256) — base VGRD reward amount
- `_multiplier` (uint256) — rank multiplier (e.g., 300 for SGT = 3.0x)

**Calculation:** `actualReward = _baseReward × _multiplier ÷ 100`

Emits: `RewardDistributed(soldier, actualReward)`

### distributeLeaderBonus

**Access:** DISTRIBUTOR_ROLE | **Mutability:** nonpayable

Accrue a leadership bonus for an objective leader.

- `_leader` (address) — leader to reward
- `_amount` (uint256) — bonus amount

Emits: `RewardDistributed(leader, amount)`

### claimRewards

**Access:** Any soldier with pending > 0 | **Mutability:** nonpayable

Claim all pending rewards. Transfers VGRD from the pool to the caller's wallet.

Reverts if: no pending rewards, contract paused.

Emits: `RewardClaimed(soldier, amount)`

**Side effects:** Mints or transfers VGRD to the soldier. Resets `pendingRewards[soldier]` to 0.

### calculateReward

**Access:** Public | **Mutability:** view

Preview a reward calculation (no gas cost).

- `_baseReward` (uint256) — base reward amount
- `_rank` (uint8) — soldier's rank

Returns: uint256 — calculated reward after multiplier.

### pendingRewards

**Access:** Public | **Mutability:** view

- `_soldier` (address) — soldier to check

Returns: uint256 — unclaimed VGRD rewards.

## Events

| Event | Parameters |
|-------|-----------|
| `RewardDistributed` | `soldier` (address), `amount` (uint256) |
| `RewardClaimed` | `soldier` (address), `amount` (uint256) |
