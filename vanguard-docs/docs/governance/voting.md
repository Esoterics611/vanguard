# Voting

This page covers the mechanics of casting votes, how voting power is calculated, and the strategies that emerge from Vanguard's dual-weight system.

## Casting a Vote

Once a proposal is in the **Active** state, any soldier holding VGRD can vote:

```javascript
const dao = await ethers.getContractAt("VanguardDAO", addresses.VanguardDAO);

// Vote options: 0 = Against, 1 = For, 2 = Abstain
await dao.castVote(proposalId, 1);  // Vote FOR
```

### Vote Types

| Value | Type | Effect |
|-------|------|--------|
| 0 | **Against** | Votes against the proposal |
| 1 | **For** | Votes in favor of the proposal |
| 2 | **Abstain** | Counts toward quorum but does not affect the for/against ratio |

**Abstain votes are important:** They help reach quorum without forcing a yes/no decision. If you believe a proposal should be decided by others but want to help it reach quorum, vote Abstain.

## Voting Power Calculation

Your voting power on any proposal is:

```
voting_power = vgrd_balance_at_snapshot × rank_voting_weight
```

### Snapshot Timing

When a proposal is created, a **snapshot** of all token balances is taken. Your voting power is based on your balance at that snapshot, not your current balance. This prevents:

- Buying tokens right before a vote, voting, then selling
- Moving tokens between wallets to vote multiple times
- Flash loan attacks (borrowing tokens just to vote)

### Voting Power Examples

| Soldier | VGRD Balance | Rank | Weight | Voting Power |
|---------|-------------|------|--------|-------------|
| Alpha | 50,000 | CPT (50) | 50 | 2,500,000 |
| Bravo | 200,000 | SGT (10) | 10 | 2,000,000 |
| Charlie | 500,000 | PVT (1) | 1 | 500,000 |
| Delta | 10,000 | 1SG (25) | 25 | 250,000 |

Alpha (a Captain with 50k VGRD) has more voting power than Charlie (a Private with 500k VGRD), despite Charlie holding 10x more tokens. This illustrates the rank-amplification effect.

## Quorum

Quorum is the minimum total voting power that must be cast (For + Against + Abstain) for a vote to be valid:

```
quorum = 4% × total_supply = 40,000,000 VGRD-equivalent voting power
```

If quorum is not reached by the end of the voting period, the proposal is **Defeated** regardless of the for/against ratio.

### Reaching Quorum

The practical difficulty of reaching quorum depends on the rank distribution of voters:

| All voters are... | VGRD needed collectively |
|-------------------|------------------------|
| Captains (weight 50) | 800,000 VGRD |
| Sergeants (weight 10) | 4,000,000 VGRD |
| Privates (weight 1) | 40,000,000 VGRD |

This means a small group of high-ranked, well-funded participants can reach quorum easily, while a large group of low-ranked participants would need substantial collective holdings.

## Delegation

!!! warning "Future Feature"
    **Vote delegation** — the ability to delegate your voting power to another address without transferring tokens — is not currently implemented. This is a standard feature in many governance systems (e.g., Compound, Uniswap) and is planned for a future upgrade.

    Delegation would allow:

    - Passive token holders to delegate to active governance participants
    - Squad leaders to accumulate delegated voting power from their team
    - Professional governance delegates to represent broader constituencies

## Strategic Considerations

### For Individual Voters

1. **Vote early if you want to signal.** Other voters can see on-chain votes in real-time. Early votes can influence later voters.

2. **Abstain strategically.** If you're unsure about a proposal but want it to reach quorum, abstain rather than not voting.

3. **Accumulate tokens before proposals you care about.** Since voting power uses snapshots, your balance at proposal creation time matters.

### For Proposal Authors

1. **Build consensus before proposing.** Off-chain discussion (forums, chat) before on-chain voting improves proposal quality and pass rates.

2. **Time your proposals carefully.** Token distribution at snapshot time determines the voter base. Avoid creating proposals right after a large token distribution event.

3. **Write clear descriptions.** The proposal description is stored on-chain and is the primary way voters understand what they're voting on.
