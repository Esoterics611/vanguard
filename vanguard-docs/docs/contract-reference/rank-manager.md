# RankManager

**Address:** `0xcbB1fB5E862D7e339619B55fE2E58dA6f35bc0f2`
**Purpose:** Manages rank promotions, multiplier tables, and training requirements.

## Roles

| Role | Holder | Purpose |
|------|--------|---------|
| `DEFAULT_ADMIN_ROLE` | Deployer | Grant/revoke roles |
| `DAO_ROLE` | Deployer | Update multipliers, set training completion |

## Constants

### MULTIPLIERS

**Access:** Public | **Mutability:** view

```solidity
mapping(uint8 => uint256) public MULTIPLIERS;
```

Rank-indexed reward multipliers (100 = 1.0x):

| Rank | Value | Effective |
|------|-------|-----------|
| 0 (GUEST) | 0 | 0x |
| 1 (PVT) | 100 | 1.0x |
| 2 (PV2) | 120 | 1.2x |
| 3 (PFC) | 150 | 1.5x |
| 4 (CPL) | 200 | 2.0x |
| 5 (SGT) | 300 | 3.0x |
| 6 (SSG) | 400 | 4.0x |
| 7 (SFC) | 500 | 5.0x |
| 8 (1SG) | 600 | 6.0x |
| 9 (2LT) | 800 | 8.0x |
| 10 (1LT) | 1000 | 10.0x |
| 11 (CPT) | 1500 | 15.0x |

### VOTING_POWER

**Access:** Public | **Mutability:** view

```solidity
mapping(uint8 => uint256) public VOTING_POWER;
```

Rank-indexed governance voting weights: 0, 1, 2, 3, 5, 10, 15, 20, 25, 30, 35, 50.

## Functions

### promote

**Access:** Enlisted soldiers (SGT+) | **Mutability:** nonpayable

Promote a soldier to the next rank.

- `_soldier` (address) — soldier to promote

**Validation checks:**
1. Caller's rank > target's current rank
2. Cooldown elapsed (7 days since last promotion)
3. Minimum tasks completed for target rank
4. Required training completed (PLDC for CPL→SGT, OBC for 1SG→2LT and 2LT→1LT)

Emits: `Promoted(soldier, oldRank, newRank, promoter)`

Reverts if: any validation check fails.

### setTrainingComplete

**Access:** DAO_ROLE | **Mutability:** nonpayable

Mark a soldier's training course as completed.

- `_soldier` (address) — soldier who completed training
- `_track` (uint8) — training track (0=PLDC, 1=OBC)

Emits: `TrainingCompleted(soldier, track)`

### setMultiplier

**Access:** DAO_ROLE | **Mutability:** nonpayable

Update the reward multiplier for a rank.

- `_rank` (uint8) — rank to update
- `_multiplier` (uint256) — new multiplier value

### registry

**Access:** Public | **Mutability:** view

Returns: address — the linked ArmyRegistry contract address.

### trainingCompleted

**Access:** Public | **Mutability:** view

- `_soldier` (address) — soldier to check
- `_track` (uint8) — training track

Returns: bool — whether the soldier has completed the specified training.

## Events

| Event | Parameters |
|-------|-----------|
| `Promoted` | `soldier` (address), `oldRank` (uint8), `newRank` (uint8), `promoter` (address) |
| `TrainingCompleted` | `soldier` (address), `track` (uint8) |
| `MultiplierUpdated` | `rank` (uint8), `oldMultiplier` (uint256), `newMultiplier` (uint256) |
