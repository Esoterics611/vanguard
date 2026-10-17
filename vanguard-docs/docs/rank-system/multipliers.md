# Multipliers and Voting Power

The rank system creates two parallel incentive structures: economic (reward multipliers) and political (voting power). This page explains both in detail.

## Reward Multipliers

Every rank has a **token multiplier** stored in the RankManager contract. When a task is completed and approved, the base reward is multiplied by this factor to determine the actual payout.

### The Formula

```
actual_reward = base_reward × rank_multiplier ÷ 100
```

The multiplier is stored as an integer with 2 implicit decimal places (100 = 1.0x, 150 = 1.5x, 1500 = 15.0x).

### Multiplier Table

| Rank | Stored Value | Effective Multiplier | 1,000 VGRD Task Pays |
|------|-------------|---------------------|---------------------|
| GUEST | 0 | 0x | 0 VGRD |
| PVT | 100 | 1.0x | 1,000 VGRD |
| PV2 | 120 | 1.2x | 1,200 VGRD |
| PFC | 150 | 1.5x | 1,500 VGRD |
| CPL | 200 | 2.0x | 2,000 VGRD |
| SGT | 300 | 3.0x | 3,000 VGRD |
| SSG | 400 | 4.0x | 4,000 VGRD |
| SFC | 500 | 5.0x | 5,000 VGRD |
| 1SG | 600 | 6.0x | 6,000 VGRD |
| 2LT | 800 | 8.0x | 8,000 VGRD |
| 1LT | 1000 | 10.0x | 10,000 VGRD |
| CPT | 1500 | 15.0x | 15,000 VGRD |

### Multiplier Curve Analysis

The multiplier curve is **superlinear** — it grows faster than the rank number:

- PVT to SGT (4 promotions): multiplier goes from 1.0x to 3.0x (+200%)
- SGT to 1SG (3 promotions): multiplier goes from 3.0x to 6.0x (+100%)
- 1SG to CPT (3 promotions): multiplier goes from 6.0x to 15.0x (+150%)

This creates strong economic incentive to reach officer rank, where the multiplier growth accelerates significantly (6x to 15x in the final three ranks).

### Impact on RewardPool Sustainability

The RewardPool holds 400,000,000 VGRD. Here is a simplified analysis of how long this lasts at different contribution rates:

| Scenario | Avg Multiplier | Tasks/Day | Avg Reward | Daily Outflow | Pool Duration |
|----------|---------------|-----------|------------|---------------|--------------|
| 10 Privates | 1.0x | 20 | 1,000 | 20,000 VGRD | ~54 years |
| 50 mixed ranks | 2.5x | 100 | 2,500 | 250,000 VGRD | ~4.4 years |
| 200 mixed ranks | 3.0x | 400 | 3,000 | 1,200,000 VGRD | ~333 days |

These are rough estimates. The actual duration depends on task creation rate, average reward amounts, and the rank distribution of active contributors.

!!! note "Minting Capability"
    The RewardPool has `MINTER_ROLE` on VGRDToken, meaning it can mint new tokens beyond the initial allocation. However, minting dilutes existing holders. The DAO governance system provides the mechanism to decide whether and when to enable additional minting.

## Voting Power

Each rank also carries a **voting weight** that amplifies the governance power of held tokens.

### The Voting Formula

```
voting_power = token_balance × rank_voting_weight
```

### Voting Power Table

| Rank | Voting Weight | 10,000 VGRD Gives Voting Power Of |
|------|--------------|-----------------------------------|
| GUEST | 0 | 0 (cannot vote) |
| PVT | 1 | 10,000 |
| PV2 | 2 | 20,000 |
| PFC | 3 | 30,000 |
| CPL | 5 | 50,000 |
| SGT | 10 | 100,000 |
| SSG | 15 | 150,000 |
| SFC | 20 | 200,000 |
| 1SG | 25 | 250,000 |
| 2LT | 30 | 300,000 |
| 1LT | 35 | 350,000 |
| CPT | 50 | 500,000 |

### Governance Implications

The dual-weight system (tokens x rank) has important implications:

**A Captain with 10,000 VGRD has more voting power (500,000) than a Private with 100,000 VGRD (100,000).**

This is by design. It ensures that governance is influenced by both economic stake (token holdings) and demonstrated contribution (rank). A pure plutocratic model (tokens only) would allow anyone to buy governance power without contributing. A pure rank model would ignore economic stake entirely.

The combined model means:

1. **Pure token whales** have limited governance influence unless they also contribute and earn rank
2. **Active contributors** have amplified influence because their rank multiplies their token-based voting power
3. **The most influential participants** are those who both hold significant tokens AND have achieved high rank — aligning governance power with protocol expertise

### Quorum Analysis

Quorum is set at 4% of total supply = 40,000,000 VGRD worth of voting power.

To reach quorum with minimum participants:

| Scenario | Participants Needed |
|----------|-------------------|
| All CPT (50 weight), 100K VGRD each | 8 Captains |
| All SGT (10 weight), 100K VGRD each | 40 Sergeants |
| All PVT (1 weight), 100K VGRD each | 400 Privates |
| Mixed realistic | ~20-50 active voters |
