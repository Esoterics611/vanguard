# Valuation Framework

This chapter provides analytical frameworks for evaluating VGRD's economic properties. It is written for financial professionals, analysts, and institutional stakeholders conducting due diligence on the protocol.

!!! note "Disclaimer"
    This section provides analytical frameworks, not investment advice. VGRD is currently a testnet token with no monetary value. The frameworks here are intended for evaluating the protocol's economic design, not for making investment decisions.

## Framework 1: Work-Output Model

The most direct valuation approach treats VGRD as a claim on the productive output of the DAO.

### Core Metrics

| Metric | Source | Description |
|--------|--------|-------------|
| Tasks completed per period | TaskRegistry event logs | Volume of productive output |
| Average base reward | TaskRegistry task data | Price of work in VGRD terms |
| Average rank multiplier | ArmyRegistry + RankManager | Effective cost amplifier |
| RewardPool balance | VGRDToken.balanceOf(RewardPool) | Remaining reward budget |
| Circulating supply | Total - contract balances | Tokens in active circulation |

### Sustainable Emission Rate

The protocol's sustainability depends on balancing task reward emission against productive output value:

```
Daily emission = (tasks_per_day × avg_base_reward × avg_multiplier) ÷ 100
Pool lifetime = RewardPool_balance ÷ daily_emission
```

**Example scenarios:**

| Active Soldiers | Tasks/Day | Avg Reward | Avg Multiplier | Daily Emission | Pool Lifetime |
|----------------|-----------|------------|----------------|---------------|---------------|
| 10 | 5 | 2,000 | 1.5x | 15,000 | ~73 years |
| 50 | 30 | 3,000 | 2.5x | 225,000 | ~4.9 years |
| 200 | 150 | 5,000 | 3.0x | 2,250,000 | ~178 days |
| 500 | 500 | 5,000 | 4.0x | 10,000,000 | ~40 days |

The high-growth scenario (500 soldiers) shows pool depletion in ~40 days, illustrating why the minting capability exists as a safety valve. At scale, the DAO would need to either:

1. Adjust base reward levels downward
2. Enable controlled minting through governance
3. Replenish the RewardPool from Treasury

## Framework 2: Governance-Premium Model

VGRD's governance utility creates a premium above its pure compensation value. The governance premium can be estimated by comparing:

- **Work value:** The VGRD needed to compensate a soldier at fair market rates for their labor
- **Governance value:** The additional VGRD a rational actor would hold for governance influence

### Governance Concentration Analysis

At current parameters:

| To Achieve | VGRD Needed (as PVT) | VGRD Needed (as CPT) |
|-----------|---------------------|---------------------|
| Submit proposals | 100,000 | 0 (rank qualifies) |
| 1% of quorum | 400,000 | 8,000 |
| 5% of quorum | 2,000,000 | 40,000 |
| Single-handedly reach quorum | 40,000,000 | 800,000 |

A Captain needs **50x fewer tokens** to achieve the same governance influence as a Private. This creates an implicit governance premium for holding tokens at high rank.

## Framework 3: Treasury-Backing Model

The Treasury holds 250M VGRD (25% of supply) as a strategic reserve. This creates a floor value analysis:

```
Treasury backing per circulating VGRD = Treasury_balance ÷ circulating_supply
```

At deployment (350M circulating):

```
250,000,000 ÷ 350,000,000 = 0.714 VGRD treasury backing per circulating VGRD
```

This means each circulating VGRD has 0.714 VGRD of treasury backing. As the circulating supply increases (rewards are claimed), this ratio decreases — but the Treasury may also earn returns on strategic deployments.

## Key Risk Factors for Valuation

1. **Minting dilution risk:** The RewardPool can mint new VGRD, diluting existing holders. The rate of dilution is controlled by task creation volume and average multiplier.

2. **Rank inflation risk:** If promotions are too easy, average multipliers rise, accelerating pool depletion and inflation.

3. **Concentration risk:** The deployer holds 35% of supply. Any significant selling would impact token value.

4. **Governance capture risk:** If a small number of high-rank holders accumulate sufficient tokens, they can dominate governance decisions including treasury withdrawals.

5. **Demand-side risk:** VGRD's value depends on demand for governance participation and protocol services. If the DAO produces no valuable output, the token has no utility.

## On-Chain Metrics for Ongoing Monitoring

Institutional stakeholders should monitor these on-chain metrics:

| Metric | How to Query | What It Indicates |
|--------|-------------|-------------------|
| RewardPool balance | `token.balanceOf(rewardPool)` | Remaining reward budget |
| Treasury balance | `token.balanceOf(treasury)` | Strategic reserve health |
| Active soldiers | ArmyRegistry event logs | Protocol adoption |
| Tasks completed (cumulative) | TaskRegistry event logs | Productive output |
| Average rank | ArmyRegistry analysis | Multiplier pressure |
| Proposal count | VanguardDAO event logs | Governance activity |
| Voter participation | VanguardDAO vote events | Governance health |
| Token velocity | Transfer event frequency | Holder behavior |
