# Token Utility

VGRD is not a speculative asset designed to appreciate. It is a **utility token** with concrete, protocol-defined uses. This page catalogs every way VGRD is used within the Vanguard system.

## Primary Utilities

### 1. Compensation for Work

The most direct utility of VGRD: soldiers earn it by completing tasks. The protocol's work management system (TaskRegistry) and compensation system (RewardPool) are designed around VGRD as the unit of payment.

**Mechanism:** Task base rewards are denominated in VGRD. Rank multipliers are applied at distribution time.

### 2. Governance Voting

VGRD is the governance token of the VanguardDAO. Holding VGRD grants the right to vote on proposals, with voting power calculated as:

```
voting_power = vgrd_balance × rank_voting_weight
```

**Mechanism:** The VanguardDAO contract reads token balances (via snapshots) and rank weights to calculate votes.

### 3. Bounty Funding

Officers fund bounties by depositing VGRD into the BountyEscrow contract. The deposited tokens are held in escrow until objectives are completed, at which point they flow to the RewardPool for distribution to task completers.

**Mechanism:** `token.approve(bountyEscrow, amount)` then `bountyEscrow.createBounty(...)`.

### 4. Proposal Threshold

To submit a governance proposal without holding Captain rank, a wallet must hold at least **100,000 VGRD**. This prevents spam proposals while allowing non-officer token holders to participate in governance.

**Mechanism:** `VanguardDAO.proposalThreshold()` returns `100000e18`.

## Secondary Utilities

### 5. Treasury Streams

The Treasury contract can create payment streams denominated in VGRD — recurring payments that vest over time to recipients. This is used for ongoing contributor compensation, advisor fees, and other scheduled payments.

### 6. Economic Signaling

A soldier's `totalEarned` VGRD (tracked in ArmyRegistry) serves as a verifiable, on-chain measure of cumulative contribution. This functions as a reputation signal — a soldier who has earned 500,000 VGRD has demonstrably done more work than one who has earned 5,000 VGRD.

## What VGRD Is Not

For clarity, VGRD does **not** currently serve these functions:

| Not This | Explanation |
|----------|-------------|
| **Staking** | There is no staking mechanism. VGRD is not locked for yield. |
| **Fee payment** | Gas fees are paid in ETH (Base network), not VGRD. |
| **Access gating** | Protocol access is based on rank, not token balance (except proposal threshold). |
| **Collateral** | VGRD cannot be used as collateral for borrowing. |
| **Liquidity mining** | There are no liquidity incentive programs. |

!!! warning "Future Feature"
    **Staking and delegation** mechanisms are under consideration for future governance iterations. A staking system could allow soldiers to lock VGRD for enhanced voting power or protocol rewards. A delegation system could allow token holders to delegate their voting power to active participants without transferring tokens.

## Token Velocity Considerations

For institutional evaluators, token velocity — how quickly tokens change hands — is a key metric for assessing token value. VGRD has several velocity-dampening properties:

1. **Accrual delay:** Rewards accrue as pending balances and require a claim transaction. This natural friction slows token velocity.
2. **Governance incentive to hold:** Since voting power is proportional to token balance, rational governance participants accumulate rather than spend their VGRD.
3. **Bounty escrow:** Tokens deposited into bounties are locked until objective completion, removing them from circulation for the duration of the bounty.
4. **No speculative burn:** There is no burn mechanism that incentivizes holding to reduce supply.

The net effect is that VGRD is designed to accumulate in the wallets of active, engaged participants — which is the economically desirable outcome for a coordination protocol.
