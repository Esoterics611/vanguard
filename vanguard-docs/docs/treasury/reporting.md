# Reporting and Transparency

One of Vanguard's core advantages over traditional organizations is **radical transparency**. Every token movement, governance vote, and operational action is recorded on the public blockchain. This page explains how to access and interpret the protocol's financial data.

## On-Chain Financial Statements

### Balance Sheet (Point-in-Time)

At any moment, you can construct a balance sheet by querying token balances:

```javascript
const token = await ethers.getContractAt("VGRDToken", addresses.VGRDToken);

const rewardPoolBal = await token.balanceOf(addresses.RewardPool);
const treasuryBal = await token.balanceOf(addresses.Treasury);
const escrowBal = await token.balanceOf(addresses.BountyEscrow);
const totalSupply = await token.totalSupply();

const contractHeld = rewardPoolBal + treasuryBal + escrowBal;
const circulating = totalSupply - contractHeld;

console.log("=== VGRD Balance Sheet ===");
console.log("RewardPool:", ethers.formatEther(rewardPoolBal));
console.log("Treasury:", ethers.formatEther(treasuryBal));
console.log("BountyEscrow:", ethers.formatEther(escrowBal));
console.log("Circulating:", ethers.formatEther(circulating));
console.log("Total Supply:", ethers.formatEther(totalSupply));
```

### Income Statement (Period-Based)

By scanning Transfer events over a time period, you can construct a cash flow statement:

| Flow | Source | Destination | Meaning |
|------|--------|-------------|---------|
| Task rewards | RewardPool | Soldier wallets | Operating expense (compensation) |
| Bounty funding | Captain wallets | BountyEscrow | Project investment |
| Bounty release | BountyEscrow | RewardPool | Project completion payout |
| Treasury withdrawal | Treasury | Any address | Strategic allocation |
| Stream claims | Treasury | Recipient wallets | Ongoing compensation |

### Key Performance Indicators

| KPI | How to Calculate | What It Measures |
|-----|-----------------|-----------------|
| **Burn Rate** | RewardPool balance change over time | How fast rewards are being distributed |
| **Runway** | RewardPool balance ÷ daily reward outflow | How long until RewardPool is depleted |
| **Task Throughput** | TaskRegistry approval events per period | Productive output of the DAO |
| **Average Reward** | Total distributed ÷ tasks completed | Cost per unit of work |
| **Governance Participation** | Voter count ÷ total soldiers | Health of governance system |
| **Rank Distribution** | Soldiers per rank tier | Maturity and structure of the workforce |

## Block Explorer Analysis

All data is publicly available on BaseScan:

1. **Token transfers:** [VGRDToken on BaseScan](https://base-sepolia.blockscout.com/address/0x2Ef78A107b20eb4263448e70E643bA9621657493) — "Token Transfers" tab
2. **Contract interactions:** Click any contract address — "Transactions" tab
3. **Event logs:** Click any contract address — "Events" tab
4. **Token holders:** VGRDToken page — "Holders" tab (shows distribution)

## Building a Dashboard

!!! warning "Future Feature"
    A real-time analytics dashboard (the "Intel" page in the web UI spec) is planned but not yet implemented. When built, it will provide:

    - Live token flow visualization
    - RewardPool runway projections
    - Task completion trends
    - Rank distribution charts
    - Governance activity timeline
    - Treasury balance history

    Until the dashboard is built, all metrics can be computed by querying the blockchain directly using the examples above.

## Comparison to Traditional Financial Reporting

| Traditional | Vanguard On-Chain |
|-------------|-------------------|
| Quarterly financial statements | Real-time, continuous reporting |
| Audited by accounting firm | Publicly verifiable by anyone |
| Subject to accounting standards (GAAP/IFRS) | Raw transaction data, no interpretation |
| Published weeks/months after period end | Available within seconds of each transaction |
| Access may require regulatory filings | Open access, no permission required |

The trade-off: on-chain data is perfectly accurate and transparent, but it lacks the interpretive frameworks (revenue recognition, depreciation, etc.) that traditional financial statements provide. Institutional stakeholders will need to develop their own analytical frameworks for interpreting on-chain financial data in the context of their evaluation criteria.
