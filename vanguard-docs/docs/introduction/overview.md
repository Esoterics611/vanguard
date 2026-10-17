# Protocol Overview

## What Is Vanguard DAO?

Vanguard is a **decentralized coordination protocol** that organizes contributors into a structured hierarchy, assigns and tracks work, distributes token-based compensation, and governs itself through on-chain voting. It runs on Base, an Ethereum Layer 2 network.

The simplest way to understand Vanguard is through analogy:

| Traditional Organization | Vanguard DAO |
|--------------------------|-------------|
| Company | The DAO itself |
| Departments / Teams | Units (Squads, Sections, Platoons, Companies) |
| Employees | Soldiers (contributors with wallets) |
| Job titles and pay grades | Ranks (PVT through CPT) with multipliers |
| Projects | Bounties (funded initiatives) |
| Deliverables | Objectives (workstreams within a bounty) |
| Tasks / Tickets | Tasks (individual work items with VGRD rewards) |
| Payroll | RewardPool (automated, rank-adjusted token distribution) |
| Board of Directors | VanguardDAO governance (proposal + vote) |
| Corporate Treasury | Treasury contract (reserve fund with payment streams) |

The key difference: in Vanguard, **the rules are enforced by smart contracts**, not by managers or HR departments. When a task is approved, the reward is distributed automatically. When a vote passes, the proposal executes on-chain. No one can override the protocol without a governance vote.

## The Eight Smart Contracts

Vanguard's on-chain logic is implemented across eight smart contracts, each handling a distinct responsibility:

| # | Contract | Role | One-Line Summary |
|---|----------|------|-----------------|
| 1 | **VGRDToken** | Currency | ERC-20 token with snapshots, permits, and pause capability |
| 2 | **ArmyRegistry** | Membership | Tracks soldiers, squads, and the unit hierarchy |
| 3 | **RankManager** | Authority | Manages rank promotions, multipliers, and training requirements |
| 4 | **TaskRegistry** | Work Management | Creates and tracks objectives and tasks through their lifecycle |
| 5 | **RewardPool** | Compensation | Calculates and distributes rank-adjusted VGRD rewards |
| 6 | **BountyEscrow** | Funding | Holds bounty funds in escrow, releases on objective completion |
| 7 | **Treasury** | Reserve | DAO savings account with payment stream capability |
| 8 | **VanguardDAO** | Governance | Proposal creation, weighted voting, and on-chain execution |

These contracts are deployed on **Base Sepolia** (testnet) and interact with each other through a defined permission system. No single contract operates in isolation — they form a cohesive protocol.

## Who Participates?

Vanguard is designed for three categories of participant:

### Contributors (Soldiers)
Individuals who enlist, complete tasks, earn VGRD, and advance through the ranks. This is the majority of participants. A contributor's journey typically follows this arc:

1. Connect wallet and enlist as a Private (PVT)
2. Get assigned to a squad
3. Pick up tasks, complete work, submit deliverables
4. Earn VGRD tokens (amount scales with rank)
5. Accumulate enough experience to qualify for promotion
6. As rank increases, gain access to leadership functions (creating tasks, approving work, creating bounties)

### Leaders (NCOs and Officers)
Senior-ranked contributors who create objectives, assign tasks, review submissions, and manage their units. Leadership is earned through the rank system, not appointed — you must complete work and meet promotion requirements to gain authority.

| Rank Tier | Can Do |
|-----------|--------|
| Enlisted (PVT–CPL) | Complete tasks, self-assign, submit work |
| NCO (SGT–1SG) | All of the above, plus create tasks, review submissions, manage squads |
| Officer (2LT–CPT) | All of the above, plus create bounties, create objectives, submit governance proposals |

### Stakeholders
Token holders, analysts, and advisors who participate in governance, evaluate protocol economics, or provide strategic guidance. Stakeholders may or may not be active contributors — holding VGRD tokens alone grants voting rights (though rank significantly amplifies voting power).

## Design Principles

Vanguard is built on five design principles:

1. **Merit-Based Authority.** Rank is earned, not given. Higher rank grants more compensation and more governance power, but it requires demonstrated contribution.

2. **Programmatic Enforcement.** Rules are encoded in smart contracts. Reward calculations, promotion eligibility, voting weights — these execute deterministically, not at anyone's discretion.

3. **Transparent Economics.** Token supply, distribution, reward formulas, and treasury balances are all on-chain and publicly auditable. There are no hidden allocations or off-books payments.

4. **Graduated Decentralization.** The protocol starts with a deployer-controlled admin structure and transitions toward full DAO governance as the community matures. Early-stage operational flexibility is exchanged for long-term decentralization.

5. **Composability.** Each contract exposes a clean interface. External applications, bots, dashboards, and integrations can read from and write to the protocol permissionlessly (subject to the access control rules encoded in each contract).
