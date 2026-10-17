# Rank Overview

The rank system is the backbone of Vanguard's authority model. It determines what a soldier can do, how much they earn, and how much their vote counts. Unlike traditional DAOs where all participants are equal or authority is informally assigned, Vanguard encodes a explicit hierarchy where authority is earned through contribution.

## The 12 Ranks

Every wallet in Vanguard holds one of 12 ranks, from Guest (no rank) to Captain (maximum rank):

| Rank # | Abbreviation | Full Name | Tier | Reward Multiplier | Voting Power |
|--------|-------------|-----------|------|-------------------|--------------|
| 0 | GUEST | Guest | — | 0x | 0 |
| 1 | PVT | Private | Enlisted | 1.0x | 1 |
| 2 | PV2 | Private 2nd Class | Enlisted | 1.2x | 2 |
| 3 | PFC | Private First Class | Enlisted | 1.5x | 3 |
| 4 | CPL | Corporal | Enlisted | 2.0x | 5 |
| 5 | SGT | Sergeant | NCO | 3.0x | 10 |
| 6 | SSG | Staff Sergeant | NCO | 4.0x | 15 |
| 7 | SFC | Sergeant First Class | NCO | 5.0x | 20 |
| 8 | 1SG | First Sergeant | NCO | 6.0x | 25 |
| 9 | 2LT | Second Lieutenant | Officer | 8.0x | 30 |
| 10 | 1LT | First Lieutenant | Officer | 10.0x | 35 |
| 11 | CPT | Captain | Officer | 15.0x | 50 |

## The Three Tiers

Ranks are grouped into three tiers, each with a distinct role in the protocol:

### Enlisted (Ranks 1-4: PVT, PV2, PFC, CPL)

**Role:** Individual contributors. The workforce of the DAO.

**What they can do:**

- Complete assigned tasks
- Self-assign open tasks
- Submit work for review
- Claim earned rewards
- Vote on governance proposals (with low voting weight)

**What they cannot do:**

- Create objectives or tasks
- Approve or reject work submissions
- Create bounties
- Submit governance proposals (unless they hold 100,000+ VGRD)

### NCO — Non-Commissioned Officers (Ranks 5-8: SGT, SSG, SFC, 1SG)

**Role:** Team leaders and managers. They create work, assign it, and review it.

**Additional capabilities over Enlisted:**

- Create tasks within objectives
- Assign tasks to soldiers
- Approve or reject task submissions
- Manage squad composition

### Officer (Ranks 9-11: 2LT, 1LT, CPT)

**Role:** Strategic leaders. They create funded initiatives and govern the protocol.

**Additional capabilities over NCO:**

- Create objectives (workstreams)
- Create bounties (funded projects)
- Submit governance proposals
- Execute passed proposals (with EXECUTOR_ROLE)

## Why Rank Matters: A Concrete Example

Consider a task worth 1,000 VGRD base reward:

| Rank | Multiplier | Actual Reward | Voting Power per Token |
|------|-----------|---------------|----------------------|
| PVT | 1.0x | 1,000 VGRD | 1 |
| CPL | 2.0x | 2,000 VGRD | 5 |
| SGT | 3.0x | 3,000 VGRD | 10 |
| 1SG | 6.0x | 6,000 VGRD | 25 |
| CPT | 15.0x | 15,000 VGRD | 50 |

A Captain earns **15 times** what a Private earns for identical work, and each VGRD token the Captain holds counts for **50 times** the voting power. This creates a strong incentive to advance through the ranks — and advancement requires completing real work.

## Rank Is On-Chain

Your rank is stored in the ArmyRegistry smart contract. It is:

- **Public** — anyone can query your rank via `getSoldier(address)`
- **Immutable except by the RankManager** — only the RankManager contract (which has `RANK_MANAGER_ROLE`) can change your rank
- **Permanent** — ranks cannot currently be revoked (demotion is not implemented)

!!! warning "Future Feature"
    **Rank Demotion:** A governance mechanism for demoting soldiers who violate community standards is planned but not yet implemented. Currently, once a rank is achieved, it is permanent.
