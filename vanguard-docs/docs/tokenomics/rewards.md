# Reward Mechanics

This chapter details exactly how VGRD flows from the RewardPool to soldier wallets.

## The Reward Pipeline

When a task is approved, four contracts interact to calculate and distribute the reward:

```
TaskRegistry.approveTask()
    → ArmyRegistry.getSoldier() — gets the soldier's rank
    → RankManager.MULTIPLIERS() — gets the rank's multiplier
    → RewardPool.distributeTaskReward() — accrues the calculated reward
```

The soldier then claims their accrued rewards in a separate transaction:

```
RewardPool.claimRewards()
    → VGRDToken.mint() or transfer() — sends VGRD to soldier's wallet
```

## Reward Calculation

### Base Reward

Each task has a **base reward** set by the task creator (a leader of SGT+ rank). This is the nominal VGRD value of the work.

Example: A leader creates a task "Write documentation for the API" with a base reward of 5,000 VGRD.

### Rank Multiplier Application

The base reward is multiplied by the soldier's rank multiplier:

```
actual_reward = base_reward × rank_multiplier ÷ 100
```

For the 5,000 VGRD documentation task:

| Soldier Rank | Multiplier | Calculation | Actual Reward |
|-------------|-----------|-------------|---------------|
| PVT (1.0x) | 100 | 5,000 × 100 ÷ 100 | 5,000 VGRD |
| PFC (1.5x) | 150 | 5,000 × 150 ÷ 100 | 7,500 VGRD |
| SGT (3.0x) | 300 | 5,000 × 300 ÷ 100 | 15,000 VGRD |
| CPT (15.0x) | 1500 | 5,000 × 1500 ÷ 100 | 75,000 VGRD |

### Accrual vs. Distribution

Rewards are **accrued, not immediately paid**. When a task is approved:

1. The calculated reward is added to the soldier's `pendingRewards` balance in the RewardPool
2. The soldier can check their pending balance at any time
3. The soldier calls `claimRewards()` to withdraw all pending rewards to their wallet
4. On claim, the RewardPool mints or transfers VGRD to the soldier

This "pull" model (soldier initiates the claim) is a standard pattern in DeFi that reduces gas costs and gives soldiers control over when they receive their tokens.

### Checking Pending Rewards

```javascript
const rewardPool = await ethers.getContractAt(
  "RewardPool",
  "0x840E56bAA0774b41eec0448F81a802281799429C"
);

const pending = await rewardPool.pendingRewards("0xYOUR_ADDRESS");
console.log("Pending:", ethers.formatEther(pending), "VGRD");
```

### Claiming Rewards

```javascript
const tx = await rewardPool.claimRewards();
await tx.wait();
console.log("Rewards claimed!");
```

After claiming, your VGRD token balance increases and your pending rewards reset to 0.

## Leader Bonuses

When an objective is fully completed (all tasks approved), the objective leader receives a **leader bonus** — an additional VGRD reward for managing the workstream successfully.

```
RewardPool.distributeLeaderBonus(leaderAddress, bonusAmount)
```

The leader bonus:

- Is separate from individual task rewards
- Incentivizes leaders to create objectives and manage them to completion
- Is added to the leader's pending rewards (same claim process)

## Preview Reward Calculation

Before accepting a task, a soldier can preview what they would earn:

```javascript
const expectedReward = await rewardPool.calculateReward(baseReward, soldierRank);
console.log("Expected reward:", ethers.formatEther(expectedReward), "VGRD");
```

This is a read-only call (no gas cost) that applies the rank multiplier to a given base reward.

## Reward Tracking

The RewardPool tracks cumulative statistics:

| Metric | Description |
|--------|-------------|
| `totalDistributed` | Total VGRD distributed since deployment |
| `totalClaimed` | Total VGRD claimed by soldiers |
| `pendingRewards[address]` | Unclaimed balance for a specific soldier |

These metrics are useful for protocol analytics and sustainability monitoring.
