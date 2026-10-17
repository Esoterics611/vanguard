# Vanguard DAO Smart Contracts
## Design Specification & Implementation Prompts

---

## Overview

Vanguard is a standalone DAO and token ecosystem for the Army coordination network. Deployed on Base Sepolia (testnet) and eventually Base Mainnet. Users can connect with the same wallet used in DigitalVault but the systems are independent.

**Token:** VGRD (Vanguard Token)
**Network:** Base (Sepolia for testnet)
**Standard:** ERC-20 + Custom DAO Governance

---

## Contract Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         VANGUARD PROTOCOL                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐ │
│  │   VGRDToken.sol  │     │  ArmyRegistry.sol │     │ RankManager.sol  │ │
│  │   (ERC-20)       │────▶│  (Soldiers/Units) │────▶│ (Promotions)     │ │
│  └──────────────────┘     └──────────────────┘     └──────────────────┘ │
│           │                        │                        │            │
│           ▼                        ▼                        ▼            │
│  ┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐ │
│  │ BountyEscrow.sol │     │ TaskRegistry.sol │     │ RewardPool.sol   │ │
│  │ (Bounty Funds)   │────▶│ (Objectives/Tasks)│────▶│ (Distribution)   │ │
│  └──────────────────┘     └──────────────────┘     └──────────────────┘ │
│           │                        │                        │            │
│           └────────────────────────┼────────────────────────┘            │
│                                    ▼                                     │
│                         ┌──────────────────┐                            │
│                         │VanguardDAO.sol   │                            │
│                         │(Governance)      │                            │
│                         └──────────────────┘                            │
│                                    │                                     │
│                                    ▼                                     │
│                         ┌──────────────────┐                            │
│                         │ Treasury.sol     │                            │
│                         │ (DAO Funds)      │                            │
│                         └──────────────────┘                            │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Token Economics

### VGRD Token

| Parameter | Value |
|-----------|-------|
| Name | Vanguard Token |
| Symbol | VGRD |
| Decimals | 18 |
| Total Supply | 1,000,000,000 (1B) |
| Standard | ERC-20 |

### Initial Distribution

| Allocation | Percentage | Amount | Vesting |
|------------|------------|--------|---------|
| Army Rewards Pool | 40% | 400M | Released via bounties |
| Treasury (DAO) | 25% | 250M | DAO governed |
| Team/Founders | 15% | 150M | 2yr linear, 6mo cliff |
| Early Contributors | 10% | 100M | 1yr linear |
| Liquidity/Partnerships | 10% | 100M | As needed |

### Rank Token Multipliers

| Rank | Multiplier | Voting Power per Token |
|------|------------|------------------------|
| PVT | 1.0x | 1 |
| PV2 | 1.2x | 2 |
| PFC | 1.5x | 3 |
| CPL | 2.0x | 5 |
| SGT | 3.0x | 10 |
| SSG | 4.0x | 15 |
| SFC | 5.0x | 20 |
| 1SG | 6.0x | 25 |
| 2LT | 8.0x | 30 |
| 1LT | 10.0x | 35 |
| CPT | 15.0x | 50 |

---

## Contract Specifications

### 1. VGRDToken.sol

```solidity
// SPDX-License-Identifier: MIT
// ERC-20 with:
// - Minting restricted to RewardPool contract
// - Burning enabled for any holder
// - Snapshot capability for governance
// - Permit (EIP-2612) for gasless approvals

interface IVGRDToken {
    function mint(address to, uint256 amount) external; // onlyRewardPool
    function burn(uint256 amount) external;
    function snapshot() external returns (uint256); // onlyDAO
    function balanceOfAt(address account, uint256 snapshotId) external view returns (uint256);
}
```

### 2. ArmyRegistry.sol

```solidity
// Central registry for soldiers and units
// Stores on-chain: wallet → callsign, rank, unit assignments
// Events enable off-chain indexing of full history

struct Soldier {
    bytes32 callsign;        // Unique pseudonym hash
    Rank rank;
    uint256 unitId;          // Current squad
    uint256 tasksCompleted;
    uint256 totalEarned;
    uint256 enlistedAt;
    address invitedBy;
}

struct Unit {
    UnitType unitType;       // SQUAD, SECTION, PLATOON, COMPANY
    bytes32 name;
    address leader;
    address secondInCommand;
    uint256 parentUnitId;
    uint256 memberCount;
    uint256 createdAt;
}

interface IArmyRegistry {
    // Soldier management
    function enlist(uint256 squadId) external;
    function getSoldier(address wallet) external view returns (Soldier memory);
    function isEnlisted(address wallet) external view returns (bool);
    
    // Unit management
    function createUnit(UnitType uType, bytes32 name, uint256 parentId) external returns (uint256);
    function getUnit(uint256 unitId) external view returns (Unit memory);
    function getUnitMembers(uint256 unitId) external view returns (address[] memory);
    function splitSquad(uint256 squadId, address newLeader, address[] calldata newSquadMembers) external;
    
    // Hierarchy queries
    function getUnitChain(address soldier) external view returns (uint256[] memory); // squad → section → platoon → company
    function isInSameCompany(address a, address b) external view returns (bool);
}
```

### 3. RankManager.sol

```solidity
// Handles all rank logic and promotion authority

enum Rank {
    GUEST,      // 0 - not enlisted
    PVT,        // 1
    PV2,        // 2
    PFC,        // 3
    CPL,        // 4
    SGT,        // 5
    SSG,        // 6
    SFC,        // 7
    FIRST_SGT,  // 8
    SECOND_LT,  // 9
    FIRST_LT,   // 10
    CPT         // 11
}

interface IRankManager {
    function getRank(address soldier) external view returns (Rank);
    function getTokenMultiplier(Rank rank) external pure returns (uint256); // basis points (100 = 1x)
    function getVotingPower(Rank rank) external pure returns (uint256);
    
    function canPromote(address promoter, address target, Rank newRank) external view returns (bool);
    function promote(address target, Rank newRank) external;
    
    function completePLDC(address soldier) external; // CPL → SGT qualification
    function completeOBC(address soldier) external;  // 2LT → 1LT qualification
    
    // Events
    event Promoted(address indexed soldier, Rank fromRank, Rank toRank, address indexed promotedBy);
    event TrainingCompleted(address indexed soldier, bytes32 courseId);
}
```

**Promotion Authority Matrix (enforced on-chain):**

| Promoter Rank | Can Promote To |
|---------------|----------------|
| SGT | (recommend only) |
| SSG | PVT → PV2 |
| 2LT/1LT | PV2 → PFC, PFC → CPL |
| CPT | Any enlisted, appoint 2IC |
| DAO | Any rank (governance vote) |

### 4. BountyEscrow.sol

```solidity
// Holds funds for bounties, releases on completion

struct Bounty {
    bytes32 titleHash;
    address creator;           // Must be CPT+
    uint256 totalAmount;
    uint256 remainingAmount;
    uint256 deadline;
    BountyStatus status;
    uint256[] objectiveIds;
}

interface IBountyEscrow {
    function createBounty(
        bytes32 titleHash,
        uint256 amount,
        uint256 deadline,
        uint256[] calldata objectiveAllocations // must sum to amount
    ) external returns (uint256 bountyId);
    
    function fundBounty(uint256 bountyId, uint256 amount) external;
    function cancelBounty(uint256 bountyId) external; // creator only, before any completion
    function completeBounty(uint256 bountyId) external; // when all objectives done
    
    // Called by TaskRegistry when tasks complete
    function releaseObjectiveReward(uint256 bountyId, uint256 objectiveId) external;
}
```

### 5. TaskRegistry.sol

```solidity
// Objectives (unit-level) and Tasks (individual)

struct Objective {
    uint256 bountyId;
    uint256 unitId;            // Assigned platoon/section
    bytes32 descriptionHash;
    uint256 allocatedAmount;
    uint256 taskCount;
    uint256 completedTasks;
    ObjectiveStatus status;
}

struct Task {
    uint256 objectiveId;
    address assignee;
    bytes32 descriptionHash;
    uint256 rewardAmount;
    uint256 deadline;
    TaskStatus status;
    bytes32 submissionHash;    // IPFS hash of work
}

interface ITaskRegistry {
    // Objectives (created by unit leaders)
    function createObjective(
        uint256 bountyId,
        uint256 unitId,
        bytes32 descriptionHash,
        uint256 allocation
    ) external returns (uint256);
    
    // Tasks (created by squad leaders, assigned to soldiers)
    function createTask(
        uint256 objectiveId,
        bytes32 descriptionHash,
        uint256 reward,
        uint256 deadline
    ) external returns (uint256);
    
    function assignTask(uint256 taskId, address soldier) external;
    function submitTask(uint256 taskId, bytes32 submissionHash) external;
    function approveTask(uint256 taskId) external; // leader approval triggers reward
    function rejectTask(uint256 taskId, bytes32 reason) external;
    
    // Queries
    function getTasksForSoldier(address soldier) external view returns (uint256[] memory);
    function getObjectiveProgress(uint256 objectiveId) external view returns (uint256 completed, uint256 total);
}
```

### 6. RewardPool.sol

```solidity
// Manages reward distribution with rank multipliers

interface IRewardPool {
    function distributeTaskReward(
        address soldier,
        uint256 baseAmount,
        uint256 taskId
    ) external;
    
    function distributeLeaderBonus(
        address leader,
        uint256 objectiveId,
        uint256 bonusAmount
    ) external;
    
    function claimRewards() external; // Soldier claims accumulated rewards
    function getPendingRewards(address soldier) external view returns (uint256);
    
    // Admin
    function setMultipliers(Rank[] calldata ranks, uint256[] calldata multipliers) external; // onlyDAO
}
```

**Reward Calculation:**
```
finalReward = baseReward * rankMultiplier / 100

Example: PFC (1.5x) completes 1000 VGRD task
finalReward = 1000 * 150 / 100 = 1500 VGRD
```

### 7. VanguardDAO.sol

```solidity
// Governor contract for protocol governance

interface IVanguardDAO {
    // Proposal creation (CPT+ or threshold token holders)
    function propose(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata calldatas,
        string calldata description
    ) external returns (uint256 proposalId);
    
    // Voting (rank-weighted)
    function castVote(uint256 proposalId, uint8 support) external returns (uint256 weight);
    function getVotingPower(address soldier) external view returns (uint256);
    
    // Execution
    function execute(uint256 proposalId) external;
    
    // Parameters
    function setVotingDelay(uint256 blocks) external;
    function setVotingPeriod(uint256 blocks) external;
    function setProposalThreshold(uint256 amount) external;
    function setQuorum(uint256 percentage) external;
}
```

**Voting Power Formula:**
```
votingPower = tokenBalance * rankVotingMultiplier

Example: SGT with 10,000 VGRD
votingPower = 10,000 * 10 = 100,000 votes
```

### 8. Treasury.sol

```solidity
// Holds DAO funds, controlled by governance

interface ITreasury {
    function withdraw(address token, address to, uint256 amount) external; // onlyDAO
    function withdrawETH(address to, uint256 amount) external; // onlyDAO
    function getBalance(address token) external view returns (uint256);
    
    // Streaming payments (for salaries, grants)
    function createStream(address recipient, uint256 amount, uint256 duration) external; // onlyDAO
    function cancelStream(uint256 streamId) external; // onlyDAO
    function claimStream(uint256 streamId) external;
}
```

---

## Deployment Order

```
1. VGRDToken.sol (no dependencies)
2. Treasury.sol (token address)
3. ArmyRegistry.sol (no dependencies)
4. RankManager.sol (registry address)
5. RewardPool.sol (token, registry, rank manager)
6. TaskRegistry.sol (registry, rank manager, reward pool)
7. BountyEscrow.sol (token, task registry, reward pool)
8. VanguardDAO.sol (token, all contract addresses)

Post-deployment:
- Set RewardPool as minter on VGRDToken
- Set DAO as admin on all contracts
- Transfer initial allocations
- Seed callsign word lists in ArmyRegistry
```

---

## Events Index

All contracts emit events for off-chain indexing:

```solidity
// ArmyRegistry
event SoldierEnlisted(address indexed wallet, bytes32 callsign, uint256 squadId);
event UnitCreated(uint256 indexed unitId, UnitType unitType, bytes32 name);
event UnitSplit(uint256 indexed parentId, uint256 newUnitId, address newLeader);
event MemberTransferred(address indexed soldier, uint256 fromUnit, uint256 toUnit);

// RankManager
event Promoted(address indexed soldier, Rank from, Rank to, address indexed by);
event TrainingCompleted(address indexed soldier, bytes32 courseId);

// TaskRegistry
event ObjectiveCreated(uint256 indexed bountyId, uint256 objectiveId, uint256 unitId);
event TaskCreated(uint256 indexed objectiveId, uint256 taskId);
event TaskAssigned(uint256 indexed taskId, address indexed soldier);
event TaskSubmitted(uint256 indexed taskId, bytes32 submissionHash);
event TaskApproved(uint256 indexed taskId, uint256 reward);
event TaskRejected(uint256 indexed taskId, bytes32 reason);

// BountyEscrow
event BountyCreated(uint256 indexed bountyId, address creator, uint256 amount);
event BountyFunded(uint256 indexed bountyId, uint256 amount);
event BountyCompleted(uint256 indexed bountyId);
event BountyCancelled(uint256 indexed bountyId);

// RewardPool
event RewardDistributed(address indexed soldier, uint256 baseAmount, uint256 finalAmount, uint256 taskId);
event RewardsClaimed(address indexed soldier, uint256 amount);

// VanguardDAO
event ProposalCreated(uint256 indexed proposalId, address proposer);
event VoteCast(uint256 indexed proposalId, address indexed voter, uint8 support, uint256 weight);
event ProposalExecuted(uint256 indexed proposalId);
```

---

## Security Considerations

1. **Reentrancy Guards** — All fund-moving functions
2. **Access Control** — Role-based (DAO, CPT, SGT, etc.)
3. **Pausable** — Emergency stop on all contracts
4. **Upgradeable** — UUPS proxy pattern for future fixes
5. **Rate Limiting** — Cooldowns on promotions, unit creation
6. **Signature Verification** — For gasless task submissions

---

## Gas Optimization Notes

- Store callsigns as bytes32 (hashed) not strings
- Batch task approvals where possible
- Use mappings over arrays for lookups
- Minimize storage writes in hot paths
- Consider L2-native patterns (Base is already L2)

---

# Claude Code Implementation Prompt

Use this prompt in a new Claude Code session with a fresh `vanguard-contracts` directory:

```
# Vanguard DAO Smart Contracts Implementation

Build the complete smart contract suite for Vanguard, a military-hierarchy DAO coordination protocol on Base (Sepolia testnet).

## Project Setup

Initialize a Hardhat project with:
- Solidity 0.8.20+
- OpenZeppelin contracts v5
- Hardhat toolbox
- Base Sepolia network config

```bash
mkdir vanguard-contracts && cd vanguard-contracts
npm init -y
npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox
npm install @openzeppelin/contracts @openzeppelin/contracts-upgradeable
npx hardhat init
```

## Contracts to Implement

### 1. VGRDToken.sol
ERC-20 token with:
- 1 billion total supply
- Minting restricted to RewardPool
- Burning by any holder
- ERC20Snapshot for governance
- ERC20Permit for gasless approvals

### 2. ArmyRegistry.sol
Soldier and Unit management:
- Soldier struct: callsign (bytes32), rank, unitId, stats
- Unit struct: type, name, leader, 2IC, parentId, memberCount
- enlist() - join a squad
- createUnit() - spawn new unit
- splitSquad() - handle >10 member split
- Callsign generation from word lists

### 3. RankManager.sol
Rank enum (GUEST through CPT) with:
- Token multipliers (100-1500 basis points)
- Voting power per rank
- Promotion authority matrix
- canPromote() validation
- promote() execution
- Training course completion tracking

### 4. TaskRegistry.sol
Objectives and Tasks:
- Objective: bountyId, unitId, allocation, progress
- Task: objectiveId, assignee, reward, status, submission
- createObjective() - leader creates from bounty
- createTask() - squad leader creates
- assignTask(), submitTask(), approveTask(), rejectTask()

### 5. BountyEscrow.sol
Bounty funding and release:
- createBounty() - CPT+ deposits VGRD
- fundBounty() - add more funds
- Automatic release on task approval
- cancelBounty() - refund if no progress

### 6. RewardPool.sol
Reward distribution:
- Calculate final reward with rank multiplier
- Accumulate pending rewards
- claimRewards() - soldier withdraws
- Mints VGRD from allocation pool

### 7. VanguardDAO.sol
Governance:
- Propose (CPT+ or token threshold)
- Vote with rank-weighted power
- Execute after timelock
- Parameter updates (quorum, thresholds)

### 8. Treasury.sol
DAO treasury:
- Hold VGRD and ETH
- Withdraw via governance
- Streaming payments for grants

## Key Implementation Details

### Rank Multipliers (basis points)
```solidity
uint256[12] public MULTIPLIERS = [
    0,    // GUEST
    100,  // PVT (1.0x)
    120,  // PV2 (1.2x)
    150,  // PFC (1.5x)
    200,  // CPL (2.0x)
    300,  // SGT (3.0x)
    400,  // SSG (4.0x)
    500,  // SFC (5.0x)
    600,  // 1SG (6.0x)
    800,  // 2LT (8.0x)
    1000, // 1LT (10.0x)
    1500  // CPT (15.0x)
];
```

### Promotion Authority
```solidity
function canPromote(address promoter, address target, Rank newRank) public view returns (bool) {
    Rank promoterRank = getRank(promoter);
    Rank targetRank = getRank(target);
    
    // Must be promoting to adjacent rank
    if (uint8(newRank) != uint8(targetRank) + 1) return false;
    
    // Authority matrix
    if (newRank == Rank.PV2) return promoterRank >= Rank.SSG;
    if (newRank == Rank.PFC || newRank == Rank.CPL) return promoterRank >= Rank.SECOND_LT;
    if (newRank == Rank.SGT) return promoterRank >= Rank.CPT && hasCompletedPLDC(target);
    if (newRank >= Rank.SSG) return promoterRank == Rank.CPT;
    
    return false;
}
```

### Unit Split Logic
```solidity
function splitSquad(uint256 squadId, address newLeader, address[] calldata newMembers) external {
    Unit storage squad = units[squadId];
    require(squad.memberCount > 10, "Not enough members");
    require(squad.leader == msg.sender, "Not squad leader");
    require(newMembers.length >= 5, "New squad needs 5+");
    
    // Create section if doesn't exist
    uint256 sectionId = squad.parentUnitId;
    if (sectionId == 0 || units[sectionId].unitType != UnitType.SECTION) {
        sectionId = _createUnit(UnitType.SECTION, squad.name, squad.parentUnitId);
        units[sectionId].leader = squad.leader;
        // Promote to SSG handled by RankManager
    }
    
    // Create new squad under section
    uint256 newSquadId = _createUnit(UnitType.SQUAD, keccak256("NEW"), sectionId);
    units[newSquadId].leader = newLeader;
    
    // Transfer members
    for (uint i = 0; i < newMembers.length; i++) {
        _transferMember(newMembers[i], squadId, newSquadId);
    }
    
    emit UnitSplit(squadId, newSquadId, newLeader);
}
```

## Deployment Script

Create `scripts/deploy.js`:
```javascript
async function main() {
    // 1. Deploy Token
    // 2. Deploy Treasury
    // 3. Deploy Registry
    // 4. Deploy RankManager
    // 5. Deploy RewardPool
    // 6. Deploy TaskRegistry
    // 7. Deploy BountyEscrow
    // 8. Deploy DAO
    // 9. Configure permissions
    // 10. Initial token distribution
}
```

## Testing Requirements

Create comprehensive tests for:
- Token minting/burning
- Soldier enlistment flow
- Promotion authority matrix
- Squad split mechanics
- Task completion → reward flow
- Bounty lifecycle
- DAO proposal → execution

## Network Config

hardhat.config.js:
```javascript
networks: {
    baseSepolia: {
        url: "https://sepolia.base.org",
        chainId: 84532,
        accounts: [process.env.PRIVATE_KEY]
    }
}
```

## Deliverables

1. All 8 contracts with full implementation
2. Deployment script
3. Test suite (90%+ coverage)
4. Contract addresses output file
5. ABI exports for frontend

Start with VGRDToken and ArmyRegistry, then build up the dependency chain.
```

---

## Contract Verification

After deployment, verify on Basescan:

```bash
npx hardhat verify --network baseSepolia <CONTRACT_ADDRESS> <CONSTRUCTOR_ARGS>
```

---

## Integration Notes

### For Flutter App
- Use contract ABIs from `artifacts/`
- Connect via ethers.js or web3dart
- Same wallet works for DigitalVault (just different contracts)

### For Backend
- Index events via The Graph or custom indexer
- Cache soldier/unit data off-chain
- Use contract reads for authoritative state

---

*Version 1.0 — Vanguard Protocol*
