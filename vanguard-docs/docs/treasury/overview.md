# Treasury Overview

The Treasury contract is the DAO's **reserve fund**. It holds 250,000,000 VGRD (25% of total supply) and can also hold ETH. The Treasury is designed for long-term strategic allocations — ongoing contributor compensation, partnership funding, liquidity provision, and emergency reserves.

## Treasury vs. RewardPool vs. BountyEscrow

Vanguard has three contracts that hold VGRD. Understanding their distinct purposes is critical:

| Contract | Balance | Purpose | Who Controls | Release Trigger |
|----------|---------|---------|-------------|-----------------|
| **RewardPool** | 400M VGRD | Pay soldiers for task completion | Automated (TaskRegistry) | Task approved |
| **BountyEscrow** | Variable | Hold bounty funds until objectives complete | Bounty creator / DAO | Objective completed |
| **Treasury** | 250M VGRD | Strategic reserve and long-term payments | DAO governance | Governance vote or stream vesting |

**RewardPool** is the payroll system — tokens flow out automatically when work is approved.

**BountyEscrow** is project-specific — tokens are locked per-bounty and released per-objective.

**Treasury** is the savings account — tokens are released only through governance votes or pre-approved payment streams.

## Treasury Holdings

At deployment:

| Asset | Amount | Source |
|-------|--------|--------|
| VGRD | 250,000,000 | Initial allocation (25%) |
| ETH | 0 | Can receive ETH via direct transfer |

The Treasury can hold any ERC-20 token, not just VGRD. This allows the DAO to diversify its reserves if needed.

## Treasury Operations

### Withdrawals

The DAO role can withdraw tokens or ETH from the Treasury:

```javascript
// Withdraw VGRD
await treasury.withdraw(
  addresses.VGRDToken,         // token address
  ethers.parseEther("50000"),  // amount
  recipientAddress             // where to send
);

// Withdraw ETH
await treasury.withdrawETH(
  ethers.parseEther("1.0"),    // amount
  recipientAddress             // where to send
);
```

### Payment Streams

The Treasury's most powerful feature is **payment streams** — vesting schedules that release tokens over time. See [Payment Streams](streams.md) for full details.

## Treasury Governance

!!! info "Current Control"
    The `DAO_ROLE` on the Treasury contract is currently held by the deployer wallet. In the fully decentralized state, this role will be transferred to the VanguardDAO contract, meaning all Treasury operations will require a governance vote.

### Governance-Controlled Operations

Once DAO_ROLE is transferred to VanguardDAO:

| Operation | Governance Required? |
|-----------|---------------------|
| Withdraw tokens | Yes — requires proposal + vote |
| Create payment stream | Yes — requires proposal + vote |
| Withdraw ETH | Yes — requires proposal + vote |
| Receive tokens/ETH | No — anyone can deposit |

This ensures the community collectively decides how reserve funds are allocated.
