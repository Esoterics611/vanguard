# Training and Qualifications

!!! warning "Future Feature"
    The training system infrastructure exists in the RankManager smart contract, but the course content, completion mechanics, and certification process are not yet implemented. This page describes the intended design.

## Purpose of Training

Training courses serve as gates at critical rank transitions. They ensure that soldiers have the knowledge and skills required for their new responsibilities before being promoted.

## Training Tracks

### PLDC — Primary Leadership Development Course

**Gate:** Corporal (CPL) to Sergeant (SGT)

**Why it exists:** The CPL-to-SGT promotion is the most significant transition in the system. A Corporal is an individual contributor — they complete tasks. A Sergeant is a leader — they create tasks, assign work, and approve submissions. PLDC ensures the soldier understands:

- How to create well-defined tasks with clear deliverables
- How to evaluate and approve submitted work
- How to manage a squad effectively
- Protocol rules around task rewards and distribution

**Intended format:**

- A series of on-chain or off-chain modules covering leadership topics
- A practical exercise (e.g., create a mock objective with tasks)
- Completion recorded on-chain via RankManager

### OBC — Officer Basic Course

**Gate:** First Sergeant (1SG) to Second Lieutenant (2LT), and Second Lieutenant (2LT) to First Lieutenant (1LT)

**Why it exists:** Officers can create bounties (committing DAO funds), submit governance proposals, and make decisions that affect the entire protocol. OBC ensures the soldier understands:

- Bounty creation and fund management
- Governance proposal mechanics
- Treasury operations
- Strategic planning and resource allocation

**Intended format:**

- Advanced modules covering protocol economics and governance
- A governance exercise (e.g., draft a mock proposal)
- Completion recorded on-chain via RankManager

## Current State

The RankManager contract has the following training-related infrastructure:

```solidity
// Training completion mapping
mapping(address => mapping(uint8 => bool)) public trainingCompleted;

// Training track enum
enum TrainingTrack { PLDC, OBC }
```

The DAO role can mark a soldier's training as complete:

```javascript
// Only callable by DAO_ROLE
await rankManager.setTrainingComplete(soldierAddress, 0); // 0 = PLDC
await rankManager.setTrainingComplete(soldierAddress, 1); // 1 = OBC
```

Until the full training system is built, the deployer (holding DAO_ROLE) can manually certify training completion to unblock promotions during the testnet phase.

## Roadmap

The training system will be developed in phases:

1. **Phase 1 (Current):** Manual certification by DAO role holder
2. **Phase 2:** Off-chain course content with on-chain completion certificates
3. **Phase 3:** Peer-reviewed practical exercises with on-chain verification
4. **Phase 4:** Community-created training content governed by DAO proposals
