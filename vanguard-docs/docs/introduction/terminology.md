# Key Terminology

This page defines the core terms used throughout this guide. Refer back to this page whenever you encounter an unfamiliar term.

## Protocol Terms

**Vanguard DAO**
:   The decentralized autonomous organization governed by the VanguardDAO smart contract. Refers to the collective of all participants, contracts, and governance processes.

**VGRD**
:   The native ERC-20 token of the Vanguard protocol. Used for compensation, governance voting, and bounty funding. Total supply: 1,000,000,000 (one billion) with 18 decimal places.

**Base**
:   An Ethereum Layer 2 network built on the OP Stack. Vanguard contracts are deployed on Base Sepolia (testnet) with a target of Base Mainnet for production.

**Base Sepolia**
:   The test network (testnet) for Base. All current Vanguard contracts are deployed here. Transactions use test ETH (no real monetary value) and test VGRD tokens.

## Membership Terms

**Soldier**
:   Any wallet address that has called the `enlist()` function on the ArmyRegistry contract. A soldier has a rank, belongs to a squad, and can participate in tasks and governance.

**Enlistment**
:   The act of joining the Vanguard DAO by calling `ArmyRegistry.enlist(squadId)`. Creates a soldier record on-chain. Irreversible — once enlisted, you cannot un-enlist.

**Callsign**
:   An optional display name for a soldier (e.g., "IRONFORGE", "NIGHTHAWK"). Stored on-chain in the ArmyRegistry.

**Rank**
:   A soldier's position in the hierarchy, from Private (PVT, rank 1) to Captain (CPT, rank 11). Rank determines reward multiplier, voting power, and access to protocol functions.

**Tier**
:   The broad category a rank falls into. There are three tiers:

    - **Enlisted** (PVT, PV2, PFC, CPL) — contributors who complete tasks
    - **NCO** (SGT, SSG, SFC, 1SG) — non-commissioned officers who manage squads and review work
    - **Officer** (2LT, 1LT, CPT) — leaders who create bounties, objectives, and governance proposals

## Unit Terms

**Squad**
:   The smallest organizational unit. Contains 4-10 soldiers and one leader. The basic working team.

**Section**
:   A unit containing two or more squads. Created automatically when a squad splits.

**Platoon**
:   A unit containing two or more sections.

**Company**
:   The largest organizational unit, containing two or more platoons.

**Alpha Squad**
:   The first squad, created automatically when the ArmyRegistry contract is deployed. All initial enlistees join Alpha Squad (Unit ID 1) unless directed to a different squad.

**Squad Split**
:   When a squad reaches 10 members, the ArmyRegistry automatically splits it into two squads under a new section. This enforces the small-team structure.

## Work Management Terms

**Bounty**
:   A funded initiative. A bounty has a VGRD budget, one or more objectives, and a lifecycle (Active -> Completed or Cancelled). Only Captain-rank soldiers can create bounties. Think of it as a project with a budget.

**Objective**
:   A workstream within a bounty. Contains one or more tasks. Analogous to a pull request or a milestone. Has its own progress tracking (percentage of tasks completed).

**Task**
:   The atomic unit of work. Has a title, description, VGRD reward amount, and a lifecycle:

    - **OPEN** — created, not yet assigned
    - **ASSIGNED** — a soldier has claimed or been assigned the task
    - **SUBMITTED** — the soldier has submitted their work (with an IPFS hash as proof)
    - **APPROVED** — a leader has reviewed and accepted the work (triggers reward)
    - **REJECTED** — a leader has reviewed and rejected the work (soldier can resubmit)

**IPFS Hash**
:   A content-addressed identifier for off-chain data (documents, code, designs). When a soldier submits a task, they provide an IPFS hash pointing to their deliverable. The hash is stored on-chain as proof of submission.

## Economic Terms

**Reward Multiplier**
:   A rank-based factor applied to task rewards. A Private (1.0x) earning a 1,000 VGRD task receives 1,000 VGRD. A Sergeant (3.0x) receives 3,000 VGRD for the same task. Multipliers are stored in the RankManager contract.

**Pending Rewards**
:   VGRD rewards that have been calculated and accrued but not yet claimed. Stored per-soldier in the RewardPool contract. Soldiers must call `claimRewards()` to transfer pending rewards to their wallet.

**Leader Bonus**
:   An additional VGRD reward distributed to unit leaders when an objective is completed. Incentivizes effective management.

**Payment Stream**
:   A time-based vesting schedule in the Treasury contract. Creates a stream that releases a specified amount of VGRD to a recipient over a defined period. The recipient can claim vested tokens as they accrue.

## Governance Terms

**Proposal**
:   A formal on-chain suggestion for a protocol change. Contains one or more contract calls to execute if the vote passes. Only CPT-rank soldiers or addresses holding 100,000+ VGRD can submit proposals.

**Voting Period**
:   The window during which soldiers can cast votes on a proposal. Set to 45,818 blocks (approximately one week on Base).

**Voting Power**
:   A soldier's influence in governance votes. Calculated as `token_balance x rank_voting_weight`. A Captain (voting weight 50) holding 10,000 VGRD has voting power of 500,000.

**Quorum**
:   The minimum total voting power that must participate for a vote to be valid. Set to 4% of the total VGRD supply.

**Execution**
:   The act of carrying out a passed proposal's contract calls. Requires the EXECUTOR_ROLE. Execution is permissionless once a proposal has succeeded — anyone with the role can trigger it.

## Technical Terms

**ABI (Application Binary Interface)**
:   A JSON specification defining how to interact with a smart contract — its functions, their parameters, and return types. Required by frontend applications to construct valid contract calls.

**Gas**
:   The fee paid to the network for processing a transaction. On Base Sepolia, gas is paid in test ETH. On Base Mainnet, gas is paid in real ETH. Typical Vanguard transactions cost less than $0.01 in gas.

**Signer**
:   A wallet that can sign transactions (as opposed to a read-only provider). Required for any operation that changes on-chain state (enlisting, creating tasks, voting, etc.).

**Provider**
:   A connection to the blockchain network. Can read data without a wallet. Required for all contract interactions, read or write.

**Testnet / Mainnet**
:   Testnet is a practice network where tokens have no real value. Mainnet is the production network where tokens have real economic value. Vanguard is currently on testnet (Base Sepolia).
