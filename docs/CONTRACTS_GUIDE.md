# Vanguard Contracts Guide

> Written for new team members. Read this before touching the smart contracts or the UI.

## Table of Contents

1. [The Big Picture](#the-big-picture)
2. [How the Contracts Work Together](#how-the-contracts-work-together)
3. [Contract-by-Contract Breakdown](#contract-by-contract-breakdown)
4. [Deployed Addresses (Base Sepolia)](#deployed-addresses-base-sepolia)
5. [Token Economics](#token-economics)
6. [Rank System](#rank-system)
7. [Key Workflows](#key-workflows)
8. [Running the Tests](#running-the-tests)
9. [What the Tests Cover](#what-the-tests-cover)
10. [Verifying Contracts on BaseScan](#verifying-contracts-on-basescan)

---

## The Big Picture

Vanguard is a **DAO coordination platform** — think "GitHub for decentralized teams" with a military rank structure. Members ("soldiers") join squads, work on tasks, earn VGRD tokens, rank up, and eventually vote on governance proposals.

The mental model is:

| Vanguard Concept | Analogy |
|-----------------|---------|
| **Bounty** | A funded project (like a grant or contract) |
| **Objective** | A workstream within a bounty (like a pull request) |
| **Task** | An individual work item (like a commit/issue) |
| **Soldier** | A contributor with a rank |
| **Squad** | A small team (up to 10 members) |

**There are 8 smart contracts** deployed on Base Sepolia (an Ethereum L2 testnet). They handle membership, task management, token rewards, bounty funding, and governance. Everything else (the UI, notifications, user profiles) lives off-chain.

---

## How the Contracts Work Together

```
                         +----------------+
                         |  VanguardDAO   |
                         | (Governance)   |
                         +-------+--------+
                                 |
                    votes use token balance x rank
                                 |
     +----------+        +------+------+        +-----------+
     | VGRDToken |<-------| RankManager |------->|ArmyRegistry|
     | (ERC-20)  |        | (Promotions)|        | (Members) |
     +-----+----+        +-------------+        +-----+-----+
           |                                           |
           |  mints tokens                    enlist / units
           v                                           |
     +----------+        +--------------+        +-----+-----+
     | RewardPool|<------| TaskRegistry |------->|  (tasks &  |
     | (Payouts) |       | (Work Items) |        | objectives)|
     +----------+        +------+-------+        +-----------+
           ^                    ^
           |                    |
     +-----+------+            |
     |BountyEscrow|------------+
     |(Bounty Fund)|    releases funds when
     +-------------+   objectives complete

     +----------+
     | Treasury |   (DAO savings account,
     | (Reserve)|    separate from bounties)
     +----------+
```

**Data flows:**

1. A soldier **enlists** via ArmyRegistry (joins a squad)
2. Leaders **create objectives and tasks** via TaskRegistry
3. Soldiers **do tasks**, submit work, leaders approve
4. On approval, TaskRegistry tells RewardPool to **pay the soldier** (VGRD tokens, multiplied by rank)
5. Bounties **fund objectives** via BountyEscrow (tokens held in escrow until objectives complete)
6. Soldiers **rank up** via RankManager (higher rank = bigger reward multiplier + more voting power)
7. Senior members **propose and vote** via VanguardDAO (voting power = token balance x rank weight)

---

## Contract-by-Contract Breakdown

### 1. VGRDToken (ERC-20 Token)

**What it does:** The VGRD token is the currency of the DAO. It's a standard ERC-20 token with a few extras.

**Key facts:**
- Total supply: **1 billion VGRD** (fixed at deployment, no more can be created except by the RewardPool via minting)
- Supports **snapshots** — you can query "what was this address's balance at block X?" (used for fair governance voting)
- Supports **EIP-2612 permits** — gasless approvals (sign a message instead of sending a transaction)
- Can be **paused** in emergencies (stops all transfers)

**Who interacts with it:**
- RewardPool has MINTER_ROLE (can mint new tokens as task rewards)
- Any holder can transfer, approve, etc.

**Address:** `0x2Ef78A107b20eb4263448e70E643bA9621657493`

---

### 2. Treasury (DAO Reserve)

**What it does:** Holds the DAO's savings. Think of it as a bank account the DAO controls. It also supports **payment streams** — vesting schedules that release tokens over time.

**Key facts:**
- Holds **250M VGRD** (25% of total supply)
- Can hold ETH too
- Payment streams: create a stream that releases X tokens over Y days to a recipient
- Only the DAO role (governance) can withdraw or create streams

**Example use:** "Pay contributor Alice 10,000 VGRD per month for 6 months" — create a stream, Alice claims as tokens vest.

**Address:** `0x55B811D87CFBbb149ea436BD5F57671602D91d54`

---

### 3. ArmyRegistry (Membership)

**What it does:** The member directory. Tracks who's in the DAO, what rank they hold, which squad they're in, and their stats.

**Key facts:**
- **Enlisting** makes you a soldier (PVT rank, assigned to a squad)
- **Invite system** — existing members can invite new ones (`enlistWithInvite`)
- **Unit hierarchy:** Squads (4-10 members) -> Sections -> Platoons -> Companies
- **Auto-split:** When a squad hits 10 members, it splits into two squads under a new section
- Tracks per-soldier stats: tasks completed, total VGRD earned, enlistment date
- **Alpha Squad** (Unit 1) was created at deployment — the first squad everyone joins

**Data stored per soldier:**
```
callsign (empty until set)
rank (1-11, starts at PVT=1)
unitId (which squad)
tasksCompleted (count)
totalEarned (VGRD amount)
enlistmentDate
inviter (who invited them)
```

**Address:** `0xBf3BEE33090fb5f9b147a72cAac6f4f44CE1F270`

---

### 4. RankManager (Promotions & Multipliers)

**What it does:** Manages the rank ladder, promotion rules, and the multiplier/voting tables.

**Key facts:**
- 12 ranks from GUEST (0) to CPT (11)
- Each rank has a **token multiplier** (how much more you earn per task) and **voting power**
- Promotions require: minimum tasks completed, training courses, 7-day cooldown
- **Training tracks:** PLDC (required for CPL->SGT), OBC (required for 2LT->1LT)
- Only the RankManager contract can update ranks in the ArmyRegistry (it has RANK_MANAGER_ROLE)

**Address:** `0xcbB1fB5E862D7e339619B55fE2E58dA6f35bc0f2`

---

### 5. RewardPool (Payouts)

**What it does:** The payroll system. When a task is approved, this contract calculates and distributes the VGRD reward.

**Key facts:**
- Holds **400M VGRD** (40% of total supply) — the reward budget
- **Reward formula:** `base_reward x rank_multiplier / 100`
  - A PVT completing a 1000 VGRD task gets: 1000 x 100/100 = 1000 VGRD
  - A SGT completing the same task gets: 1000 x 300/100 = 3000 VGRD
- Also pays **leader bonuses** when objectives complete
- Soldiers must **claim** their rewards (pull model, not push)
- Only TaskRegistry can trigger distributions (it has DISTRIBUTOR_ROLE)

**Address:** `0x840E56bAA0774b41eec0448F81a802281799429C`

---

### 6. TaskRegistry (Work Management)

**What it does:** The project management system. Handles creating objectives, breaking them into tasks, assigning work, and tracking completion.

**Key facts:**
- **Objectives** = workstreams (contain multiple tasks, linked to bounties)
- **Tasks** = individual work items with VGRD rewards
- Task lifecycle: `OPEN -> ASSIGNED -> SUBMITTED -> APPROVED` (or `REJECTED`)
- Leaders create objectives/tasks, soldiers self-assign or get assigned
- On **task approval**, automatically triggers RewardPool to pay the soldier
- Tracks progress: how many tasks in an objective are done

**Address:** `0xd5832E767C76FbCBbee6F071b80B7F78Ad5F7e5A`

---

### 7. BountyEscrow (Bounty Funding)

**What it does:** Holds bounty funds in escrow and releases them as objectives are completed.

**Key facts:**
- **CPT+ rank required** to create bounties
- Creator deposits VGRD tokens, allocates amounts to each objective
- When an objective completes, funds release to RewardPool for distribution
- Can be cancelled (refunds remaining funds)
- Bounty states: `ACTIVE -> COMPLETED` or `CANCELLED`

**Flow:**
1. Captain creates bounty with 50,000 VGRD, allocates 25k to Objective A, 25k to Objective B
2. Team completes Objective A -> 25k released to RewardPool
3. Team completes Objective B -> 25k released, bounty marked COMPLETED

**Address:** `0x19F1A7F9d4A3d36BEAF2e4fb5A5E42F3f080B143`

---

### 8. VanguardDAO (Governance)

**What it does:** The voting system. Members propose changes, vote on them, and execute approved proposals.

**Key facts:**
- **Who can propose:** Must hold 100,000 VGRD or be CPT+ rank
- **Voting power:** `token_balance x rank_voting_weight` (so rank matters a lot)
- **Voting period:** ~1 week (45,818 blocks on Base)
- **Quorum:** 4% of total supply must vote
- **Proposal lifecycle:** Pending -> Active -> Succeeded/Defeated -> Executed
- Proposals can execute arbitrary contract calls (upgrade parameters, move funds, etc.)

**Address:** `0x1F6FB4dB93691747420d0fb9d397E4f97443A7Af`

---

## Deployed Addresses (Base Sepolia)

| Contract | Address | BaseScan |
|----------|---------|----------|
| VGRDToken | `0x2Ef7...7493` | [View](https://base-sepolia.blockscout.com/address/0x2Ef78A107b20eb4263448e70E643bA9621657493) |
| Treasury | `0x55B8...1d54` | [View](https://base-sepolia.blockscout.com/address/0x55B811D87CFBbb149ea436BD5F57671602D91d54) |
| ArmyRegistry | `0xBf3B...F270` | [View](https://base-sepolia.blockscout.com/address/0xBf3BEE33090fb5f9b147a72cAac6f4f44CE1F270) |
| RankManager | `0xcbB1...c0f2` | [View](https://base-sepolia.blockscout.com/address/0xcbB1fB5E862D7e339619B55fE2E58dA6f35bc0f2) |
| RewardPool | `0x840E...429C` | [View](https://base-sepolia.blockscout.com/address/0x840E56bAA0774b41eec0448F81a802281799429C) |
| TaskRegistry | `0xd583...7e5A` | [View](https://base-sepolia.blockscout.com/address/0xd5832E767C76FbCBbee6F071b80B7F78Ad5F7e5A) |
| BountyEscrow | `0x19F1...B143` | [View](https://base-sepolia.blockscout.com/address/0x19F1A7F9d4A3d36BEAF2e4fb5A5E42F3f080B143) |
| VanguardDAO | `0x1F6F...A7Af` | [View](https://base-sepolia.blockscout.com/address/0x1F6FB4dB93691747420d0fb9d397E4f97443A7Af) |

**Network:** Base Sepolia (Chain ID 84532)
**Deployer:** `0x41521c37dB02956185437C4e2461261A321073E1`
**Deployed:** April 27, 2026

---

## Token Economics

| Allocation | Amount | % | Where |
|------------|--------|---|-------|
| Reward Pool | 400,000,000 VGRD | 40% | RewardPool contract (task payouts) |
| Treasury | 250,000,000 VGRD | 25% | Treasury contract (DAO reserve) |
| Team/Founders | 350,000,000 VGRD | 35% | Deployer wallet |
| **Total** | **1,000,000,000 VGRD** | **100%** | |

---

## Rank System

| # | Rank | Abbrev | Reward Multiplier | Voting Power | Tier |
|---|------|--------|-------------------|-------------|------|
| 0 | Guest | GUEST | 0x | 0 | - |
| 1 | Private | PVT | 1.0x | 1 | Enlisted |
| 2 | Private 2nd Class | PV2 | 1.2x | 2 | Enlisted |
| 3 | Private First Class | PFC | 1.5x | 3 | Enlisted |
| 4 | Corporal | CPL | 2.0x | 5 | Enlisted |
| 5 | Sergeant | SGT | 3.0x | 10 | NCO |
| 6 | Staff Sergeant | SSG | 4.0x | 15 | NCO |
| 7 | Sergeant First Class | SFC | 5.0x | 20 | NCO |
| 8 | First Sergeant | 1SG | 6.0x | 25 | NCO |
| 9 | Second Lieutenant | 2LT | 8.0x | 30 | Officer |
| 10 | First Lieutenant | 1LT | 10.0x | 35 | Officer |
| 11 | Captain | CPT | 15.0x | 50 | Officer |

**What this means practically:** A Captain earns 15x what a Private earns for the same task, and has 50x the voting power.

---

## Key Workflows

### Workflow 1: A New Member Joins

```
1. User connects wallet to the app
2. Calls ArmyRegistry.enlist(squadId) or enlistWithInvite(squadId, inviterAddress)
3. They become a PVT in that squad
4. They can now be assigned tasks
```

### Workflow 2: Completing a Task for Rewards

```
1. Leader calls TaskRegistry.createObjective(...) to create a workstream
2. Leader calls TaskRegistry.createTask(objectiveId, ..., rewardAmount) for each work item
3. Soldier calls TaskRegistry.selfAssignTask(taskId) — or leader assigns them
4. Soldier does the work off-chain, then calls TaskRegistry.submitTask(taskId, ipfsHash)
5. Leader reviews and calls TaskRegistry.approveTask(taskId)
6. TaskRegistry automatically tells RewardPool to distribute reward
7. Soldier calls RewardPool.claimRewards() to withdraw their VGRD
```

### Workflow 3: Funded Bounty Flow

```
1. Captain calls BountyEscrow.createBounty(amount, objectiveAllocations)
   — tokens are transferred from captain to escrow
2. Team works on the objectives (Workflow 2 above)
3. When an objective is fully complete, BountyEscrow.releaseObjectiveReward() is called
   — funds go from escrow to RewardPool
4. When all objectives are done, bounty is marked COMPLETED
```

### Workflow 4: Governance Proposal

```
1. A CPT (or someone with 100k+ VGRD) calls VanguardDAO.propose(targets, values, calldatas, description)
2. After 1 block delay, voting opens for ~1 week
3. Members call VanguardDAO.castVote(proposalId, support)
   — vote weight = token balance x rank voting power
4. If quorum (4%) is reached and majority votes FOR, proposal succeeds
5. Executor calls VanguardDAO.execute(...) to run the proposal's actions
```

---

## Running the Tests

### Prerequisites

```bash
cd contracts/
npm install
```

Make sure `contracts/.env` has your `PRIVATE_KEY` set (the deployer wallet's private key).

### Run Tests Against Deployed Contracts

```bash
npm run test:deployed
```

This runs `scripts/test-deployed.js` against the live Base Sepolia contracts. It will:

1. **Connect** to Base Sepolia using your private key
2. **Read contract state** to verify deployment was correct
3. **Run a functional test** — enlists the deployer as a soldier (if not already enlisted)
4. **Print a pass/fail report**

### What the Tests Cover

| Test Area | What's Checked | Count |
|-----------|---------------|-------|
| **VGRDToken** | Name, symbol, total supply, deployer balance | 4 |
| **Treasury** | Holds 250M VGRD | 1 |
| **RewardPool** | Holds 400M VGRD | 1 |
| **ArmyRegistry** | Default squad exists, unit 1 is active, is a squad | 3 |
| **RankManager** | PVT multiplier (100), CPT multiplier (1500), SGT voting power (10) | 3 |
| **TaskRegistry** | Initialized (nextObjectiveId=1, nextTaskId=1) | 1 |
| **BountyEscrow** | Initialized (nextBountyId=1) | 1 |
| **VanguardDAO** | Voting period > 0, proposal threshold = 100k VGRD | 2 |
| **Integration** | RewardPool->Token link, TaskRegistry->Registry link, RankManager->Registry link | 3 |
| **Functional** | Enlist soldier, verify rank=PVT, verify squad member count | 3 |
| **Total** | | **~22 checks** |

### What the Tests Do NOT Cover

These are **read-only sanity checks** plus one enlistment. The following workflows are NOT tested:

- Creating objectives or tasks
- Assigning, submitting, or approving tasks
- Reward distribution and claiming
- Creating or funding bounties
- Rank promotions
- DAO proposals and voting
- Treasury streams
- Error cases (unauthorized access, invalid inputs)
- Multi-user scenarios
- Squad splitting

---

## Verifying Contracts on BaseScan

Verification makes the contract source code public on BaseScan, letting anyone read the code and interact via the BaseScan UI. **None of the 8 contracts are currently verified.**

### Step 1: Get a BaseScan API Key

1. Go to https://basescan.org and create an account
2. Go to API Keys and create a new key
3. Add it to `contracts/.env`:
   ```
   BASESCAN_API_KEY=your_key_here
   ```

### Step 2: Run Verification Commands

```bash
cd contracts/

# VGRDToken
npx hardhat verify --network baseSepolia 0x2Ef78A107b20eb4263448e70E643bA9621657493 "0x41521c37dB02956185437C4e2461261A321073E1"

# Treasury
npx hardhat verify --network baseSepolia 0x55B811D87CFBbb149ea436BD5F57671602D91d54 "0x41521c37dB02956185437C4e2461261A321073E1"

# ArmyRegistry
npx hardhat verify --network baseSepolia 0xBf3BEE33090fb5f9b147a72cAac6f4f44CE1F270 "0x41521c37dB02956185437C4e2461261A321073E1"

# RankManager
npx hardhat verify --network baseSepolia 0xcbB1fB5E862D7e339619B55fE2E58dA6f35bc0f2 "0x41521c37dB02956185437C4e2461261A321073E1" "0xBf3BEE33090fb5f9b147a72cAac6f4f44CE1F270"

# RewardPool
npx hardhat verify --network baseSepolia 0x840E56bAA0774b41eec0448F81a802281799429C "0x41521c37dB02956185437C4e2461261A321073E1" "0x2Ef78A107b20eb4263448e70E643bA9621657493" "0xBf3BEE33090fb5f9b147a72cAac6f4f44CE1F270" "0xcbB1fB5E862D7e339619B55fE2E58dA6f35bc0f2"

# TaskRegistry
npx hardhat verify --network baseSepolia 0xd5832E767C76FbCBbee6F071b80B7F78Ad5F7e5A "0x41521c37dB02956185437C4e2461261A321073E1" "0xBf3BEE33090fb5f9b147a72cAac6f4f44CE1F270" "0xcbB1fB5E862D7e339619B55fE2E58dA6f35bc0f2"

# BountyEscrow
npx hardhat verify --network baseSepolia 0x19F1A7F9d4A3d36BEAF2e4fb5A5E42F3f080B143 "0x41521c37dB02956185437C4e2461261A321073E1" "0x2Ef78A107b20eb4263448e70E643bA9621657493" "0xBf3BEE33090fb5f9b147a72cAac6f4f44CE1F270"

# VanguardDAO
npx hardhat verify --network baseSepolia 0x1F6FB4dB93691747420d0fb9d397E4f97443A7Af "0x41521c37dB02956185437C4e2461261A321073E1" "0x2Ef78A107b20eb4263448e70E643bA9621657493" "0xBf3BEE33090fb5f9b147a72cAac6f4f44CE1F270" "0xcbB1fB5E862D7e339619B55fE2E58dA6f35bc0f2"
```

Each command should print "Successfully verified" when done. After verification, the "Contract" tab on BaseScan will show the source code and a Read/Write interface.
