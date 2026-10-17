# Vanguard DAO - UX Design Specification
## Mission Control Army System

---

## 1. Design Philosophy

### Core Principles
- **Military Precision**: Clean hierarchy, clear chain of command
- **Cyberpunk Aesthetic**: Dark theme, neon accents, holographic effects
- **Progressive Disclosure**: Show only what's relevant to user's rank/role
- **Real Value Creation**: Every action creates real blockchain data

### Color System
| Role | Primary | Glow | Usage |
|------|---------|------|-------|
| Officers (CPT, 1LT, 2LT) | `#FFD700` Gold | `#FFA500` | Command actions, bounties |
| NCOs (1SG, SFC, SSG, SGT) | `#C0C0C0` Silver | `#909090` | Leadership, promotions |
| Enlisted (CPL, PFC, PV2, PVT) | `#CD7F32` Bronze | `#A66328` | Task execution |
| System Highlight | `#00F0FF` Cyan | `#00B8C4` | User's units, CTAs |
| Success | `#00FF88` Green | `#00CC6B` | Completions, confirmations |
| Warning | `#FFB800` Amber | `#CC9400` | Deadlines, split alerts |
| Danger | `#FF3366` Red | `#CC2952` | Errors, critical priority |

---

## 2. User Flows - Implemented

### Flow 1: New User Onboarding

```
┌─────────────────────────────────────────────────────────────┐
│                     ONBOARDING SCREEN                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│           ╔═══════════════════════════════════╗              │
│           ║        VANGUARD DAO               ║              │
│           ║      Join the Revolution          ║              │
│           ╚═══════════════════════════════════╝              │
│                                                              │
│   ┌─────────────────────────────────────────────────────┐   │
│   │ 🟢 Generate New Wallet              [Recommended]    │   │
│   │    Create a fresh wallet for Vanguard               │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                              │
│   ┌─────────────────────────────────────────────────────┐   │
│   │ 🔑 Enter Private Key                                 │   │
│   │    Use an existing wallet                            │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                              │
│   ┌─────────────────────────────────────────────────────┐   │
│   │ 👁️ Browse as Guest                                   │   │
│   │    View squads without joining                       │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                              │
│   ┌─────────────────────────────────────────────────────┐   │
│   │  LIVE STATS                                          │   │
│   │  🪖 247 Soldiers │ 💰 1.2M VGRD │ 📋 892 Tasks      │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

**Generate New Wallet Sub-flow:**
```
┌─────────────────────────────────────────────────────────────┐
│                    ⚠️ SAVE YOUR KEY                         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  This is your only chance to save your private key.         │
│  If you lose it, you lose access forever.                   │
│                                                              │
│  Wallet Address:                                             │
│  ┌───────────────────────────────────────────────────┐      │
│  │ 0x1234...5678                              [Copy] │      │
│  └───────────────────────────────────────────────────┘      │
│                                                              │
│  ⚠️ Private Key (KEEP SECRET!):                             │
│  ┌───────────────────────────────────────────────────┐      │
│  │ 0xabcd...ef01                              [Copy] │      │
│  └───────────────────────────────────────────────────┘      │
│                                                              │
│  ☐ I have saved my private key securely                     │
│                                                              │
│       [Cancel]                    [Continue]                 │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Flow 2: Squad Selection

```
┌─────────────────────────────────────────────────────────────┐
│                   CHOOSE YOUR PATH                           │
├────────────────────────┬────────────────────────────────────┤
│    [CREATE SQUAD]      │        [JOIN SQUAD]                │
├────────────────────────┴────────────────────────────────────┤
│                                                              │
│  CREATE SQUAD TAB:                                           │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  🚩 START YOUR OWN SQUAD                            │    │
│  │                                                      │    │
│  │  Lead from day one. Build your team.                │    │
│  │  Complete bounties together.                         │    │
│  │                                                      │    │
│  │  Squad Name: [________________________]              │    │
│  │  Description: [______________________]               │    │
│  │                                                      │    │
│  │  As Squad Leader you can:                            │    │
│  │  ✓ Recruit up to 10 soldiers                        │    │
│  │  ✓ Create and assign tasks                          │    │
│  │  ✓ Promote squad members                            │    │
│  │  ✓ Claim bounty rewards                             │    │
│  │                                                      │    │
│  │           [CREATE SQUAD]                             │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  JOIN SQUAD TAB:                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ 🏴 ALPHA SQUAD                                      │    │
│  │ 8/10 members • Led by SGT VIPER-7X4                 │    │
│  │ ████████░░ 80%                          [APPLY]     │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ 🏴 BRAVO SQUAD                                      │    │
│  │ 5/10 members • Led by SGT HAWK-3K2                  │    │
│  │ █████░░░░░ 50%                          [APPLY]     │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Flow 3: Create Bounty (4-Step Wizard)

**Step 1: Details**
```
┌─────────────────────────────────────────────────────────────┐
│  [×]              CREATE BOUNTY                              │
├─────────────────────────────────────────────────────────────┤
│  ①━━━━━━━②━━━━━━━③━━━━━━━④                                   │
│  Details  Objectives  Tasks  Review                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Bounty Details                                              │
│  Define what needs to be accomplished                        │
│                                                              │
│  Title:                                                      │
│  ┌───────────────────────────────────────────────────┐      │
│  │ Build Token Staking Dashboard                      │      │
│  └───────────────────────────────────────────────────┘      │
│                                                              │
│  Description:                                                │
│  ┌───────────────────────────────────────────────────┐      │
│  │ Create a dashboard for users to stake VGRD        │      │
│  │ tokens and track their rewards...                 │      │
│  └───────────────────────────────────────────────────┘      │
│                                                              │
│  Total Reward (VGRD):                                        │
│  ┌───────────────────────────────────────────────────┐      │
│  │ 💰 10,000                                          │      │
│  └───────────────────────────────────────────────────┘      │
│                                                              │
│  Deadline: [30 days ▼]                                       │
│                                                              │
│  Skill Tags:                                                 │
│  [Solidity✓] [Flutter✓] [Backend] [Frontend] [Security]     │
│                                                              │
├─────────────────────────────────────────────────────────────┤
│                                          [NEXT →]            │
└─────────────────────────────────────────────────────────────┘
```

**Step 2: Objectives**
```
┌─────────────────────────────────────────────────────────────┐
│  [×]              CREATE BOUNTY                              │
├─────────────────────────────────────────────────────────────┤
│  ✓━━━━━━━②━━━━━━━③━━━━━━━④                                   │
│  Details  Objectives  Tasks  Review                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Objectives                          Remaining: 4,000 VGRD   │
│  Break the bounty into unit objectives       ┌──────────┐   │
│                                              │ 4,000    │   │
│                                              │remaining │   │
│  ┌───────────────────────────────────────────┴──────────┘   │
│  │ 1│ Smart Contract Development                         │   │
│  │  │ 3,000 VGRD • 0 tasks                              │   │
│  │  │                              [Edit] [×]            │   │
│  └───────────────────────────────────────────────────────┘   │
│  ┌───────────────────────────────────────────────────────┐   │
│  │ 2│ Frontend UI Implementation                         │   │
│  │  │ 2,500 VGRD • 0 tasks                              │   │
│  │  │                              [Edit] [×]            │   │
│  └───────────────────────────────────────────────────────┘   │
│  ┌───────────────────────────────────────────────────────┐   │
│  │ 3│ Testing & Documentation                            │   │
│  │  │ 500 VGRD • 0 tasks                                │   │
│  │  │                              [Edit] [×]            │   │
│  └───────────────────────────────────────────────────────┘   │
│                                                              │
│  [+ ADD OBJECTIVE]                                           │
│                                                              │
├─────────────────────────────────────────────────────────────┤
│       [← BACK]                               [NEXT →]        │
└─────────────────────────────────────────────────────────────┘
```

**Step 3: Tasks**
```
┌─────────────────────────────────────────────────────────────┐
│  [×]              CREATE BOUNTY                              │
├─────────────────────────────────────────────────────────────┤
│  ✓━━━━━━━✓━━━━━━━③━━━━━━━④                                   │
│  Details  Objectives  Tasks  Review                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Tasks                                                       │
│  Break objectives into individual tasks                      │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ 🚩 Smart Contract Development            3,000 VGRD │    │
│  ├─────────────────────────────────────────────────────┤    │
│  │ ┌─────────────────────────────────────────────────┐ │    │
│  │ │ 🔴 Write staking contract                       │ │    │
│  │ │    1,200 VGRD • Assigned to: Me                 │ │    │
│  │ │                               [Edit] [×]        │ │    │
│  │ └─────────────────────────────────────────────────┘ │    │
│  │ ┌─────────────────────────────────────────────────┐ │    │
│  │ │ 🟡 Write unit tests                             │ │    │
│  │ │    800 VGRD • Unassigned                        │ │    │
│  │ │                               [Edit] [×]        │ │    │
│  │ └─────────────────────────────────────────────────┘ │    │
│  │ ┌─────────────────────────────────────────────────┐ │    │
│  │ │ 🟢 Deploy to testnet                            │ │    │
│  │ │    1,000 VGRD • Unassigned                      │ │    │
│  │ │                               [Edit] [×]        │ │    │
│  │ └─────────────────────────────────────────────────┘ │    │
│  │                                                      │    │
│  │ [+ Add Task]                                         │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
├─────────────────────────────────────────────────────────────┤
│       [← BACK]                               [NEXT →]        │
└─────────────────────────────────────────────────────────────┘
```

**Step 4: Review**
```
┌─────────────────────────────────────────────────────────────┐
│  [×]              CREATE BOUNTY                              │
├─────────────────────────────────────────────────────────────┤
│  ✓━━━━━━━✓━━━━━━━✓━━━━━━━④                                   │
│  Details  Objectives  Tasks  Review                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Review & Create                                             │
│  Verify everything looks correct                             │
│                                                              │
│  ╔═══════════════════════════════════════════════════════╗  │
│  ║ 🚩 Build Token Staking Dashboard                      ║  │
│  ║                                                        ║  │
│  ║ Create a dashboard for users to stake VGRD tokens     ║  │
│  ║ and track their rewards over time.                    ║  │
│  ║                                                        ║  │
│  ║ 💰 10,000 VGRD  📅 30 days  🚩 3 objectives           ║  │
│  ║                                                        ║  │
│  ║ [Solidity] [Flutter]                                  ║  │
│  ╚═══════════════════════════════════════════════════════╝  │
│                                                              │
│  OBJECTIVES                                                  │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ 1│ Smart Contract Development           3,000 VGRD  │    │
│  │  │  ☐ Write staking contract    🔴 1,200           │    │
│  │  │  ☐ Write unit tests          🟡 800             │    │
│  │  │  ☐ Deploy to testnet         🟢 1,000           │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ 2│ Frontend UI Implementation           2,500 VGRD  │    │
│  │  │  ☐ Design staking UI         🟡 800             │    │
│  │  │  ☐ Build dashboard           🔴 1,200           │    │
│  │  │  ☐ Connect to contracts      🟢 500             │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
├─────────────────────────────────────────────────────────────┤
│       [← BACK]                        [CREATE BOUNTY ✓]      │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. User Flows - To Implement

### Flow 4: Task Execution Lifecycle

```
TASK STATES:
Created → Assigned → In Progress → Submitted → Completed
                  ↘            ↗
                    Blocked →

┌─────────────────────────────────────────────────────────────┐
│                    TASK DETAIL                               │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  🔴 HIGH PRIORITY                                            │
│                                                              │
│  Write Staking Contract                                      │
│  ────────────────────────────────────────────────────────   │
│  Implement the core staking logic with time-locked          │
│  deposits, reward calculation, and emergency withdraw.       │
│                                                              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ 📋 Objective: Smart Contract Development              │  │
│  │ 🏆 Bounty: Token Staking Dashboard                    │  │
│  │ 💰 Reward: 1,200 VGRD                                 │  │
│  │ 📅 Deadline: 14 days (Dec 15, 2026)                   │  │
│  │ 👤 Assigned: SGT CIPHER-7X4 (You)                     │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                              │
│  STATUS: In Progress                                         │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ Created ──✓── Assigned ──✓── In Progress ── Submit  │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  SUBMISSION                                          │    │
│  │                                                      │    │
│  │  Link/Hash:                                          │    │
│  │  ┌───────────────────────────────────────────────┐  │    │
│  │  │ ipfs://Qm...                                   │  │    │
│  │  └───────────────────────────────────────────────┘  │    │
│  │                                                      │    │
│  │  Notes (optional):                                   │    │
│  │  ┌───────────────────────────────────────────────┐  │    │
│  │  │ Implemented with OpenZeppelin SafeERC20...    │  │    │
│  │  └───────────────────────────────────────────────┘  │    │
│  │                                                      │    │
│  │           [SUBMIT FOR REVIEW]                        │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  [Mark Blocked]              [Request Extension]     │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

**Task Review (Leader View):**
```
┌─────────────────────────────────────────────────────────────┐
│                 REVIEW SUBMISSION                            │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Write Staking Contract                                      │
│  Submitted by: SGT CIPHER-7X4                                │
│  ────────────────────────────────────────────────────────   │
│                                                              │
│  SUBMISSION:                                                 │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ ipfs://QmX7k2...                        [View Link]   │  │
│  │                                                        │  │
│  │ Notes: Implemented with OpenZeppelin SafeERC20.       │  │
│  │ Added reentrancy guards. All tests passing.           │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                              │
│  REVIEW DECISION:                                            │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                                                      │    │
│  │  ○ Approve - Task completed satisfactorily           │    │
│  │                                                      │    │
│  │  ○ Request Changes - Needs modifications             │    │
│  │    Feedback: [_________________________]             │    │
│  │                                                      │    │
│  │  ○ Reject - Does not meet requirements               │    │
│  │    Reason: [__________________________]              │    │
│  │                                                      │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  On approval:                                                │
│  • 1,200 VGRD released to CIPHER-7X4                        │
│  • +120 XP awarded                                           │
│  • Task marked complete                                      │
│                                                              │
│       [Cancel]                        [Submit Review]        │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Flow 5: Squad Application Review (Leader View)

```
┌─────────────────────────────────────────────────────────────┐
│                 PENDING APPLICATIONS                         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Alpha Squad • 8/10 members                                  │
│  ────────────────────────────────────────────────────────   │
│                                                              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  NEW APPLICATION                           2 days ago │  │
│  │                                                        │  │
│  │  Wallet: 0x7a3f...8b2c                                │  │
│  │                                                        │  │
│  │  Message:                                              │  │
│  │  "I'm a smart contract developer with 3 years         │  │
│  │  experience. Looking to contribute to DeFi projects   │  │
│  │  and earn while learning from experienced teams."     │  │
│  │                                                        │  │
│  │  Skills: [Solidity] [Hardhat] [Testing]               │  │
│  │                                                        │  │
│  │  ┌─────────────────────────────────────────────────┐  │  │
│  │  │  [Reject]                         [Accept ✓]    │  │  │
│  │  └─────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  PENDING                                   5 days ago │  │
│  │                                                        │  │
│  │  Wallet: 0x9c2d...4e1a                                │  │
│  │                                                        │  │
│  │  Message:                                              │  │
│  │  "Interested in joining. I can help with frontend."   │  │
│  │                                                        │  │
│  │  ┌─────────────────────────────────────────────────┐  │  │
│  │  │  [Reject]                         [Accept ✓]    │  │  │
│  │  └─────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Flow 6: Promotion Workflow

```
┌─────────────────────────────────────────────────────────────┐
│                    PROMOTE SOLDIER                           │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  👤 PFC GHOST-9K2                                     │  │
│  │                                                        │  │
│  │  Current Rank: PFC (Private First Class)              │  │
│  │  Time in Rank: 45 days                                │  │
│  │  Tasks Completed: 23                                   │  │
│  │  XP: 2,340 / 3,000                                    │  │
│  │                                                        │  │
│  │  ════════════════════════════════════════════════════ │  │
│  │                                                        │  │
│  │  PROMOTE TO: CPL (Corporal)                           │  │
│  │                                                        │  │
│  │  Requirements:                                         │  │
│  │  ✓ Complete 20+ tasks (23/20)                         │  │
│  │  ✓ Minimum 30 days as PFC (45/30)                     │  │
│  │  ✓ XP threshold met (2,340/2,000)                     │  │
│  │  ✓ Leader recommendation (You, SSG)                   │  │
│  │                                                        │  │
│  │  New Benefits:                                         │  │
│  │  • Voting Power: 3 → 5                                │  │
│  │  • Token Multiplier: 1.5x → 2x                        │  │
│  │  • Can assist squad leader                            │  │
│  │                                                        │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                              │
│  Promotion Reason (optional):                                │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ Consistent quality work on smart contract tasks.      │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                              │
│       [Cancel]                        [Confirm Promotion]    │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Flow 7: Squad Split (Auto-triggered at 11 members)

```
┌─────────────────────────────────────────────────────────────┐
│                    🎖️ SQUAD SPLIT                           │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Alpha Squad has reached 11 members!                         │
│  Time to form a Section.                                     │
│                                                              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                                                        │  │
│  │     ALPHA SQUAD (11)                                  │  │
│  │          │                                            │  │
│  │          ▼                                            │  │
│  │    ┌─────────────┐                                    │  │
│  │    │  SECTION 1  │  ← You become SSG                  │  │
│  │    │   (SSG)     │                                    │  │
│  │    └──────┬──────┘                                    │  │
│  │       ┌───┴───┐                                       │  │
│  │       ▼       ▼                                       │  │
│  │   ┌───────┐ ┌───────┐                                │  │
│  │   │Squad A│ │Squad B│                                │  │
│  │   │ (6)   │ │ (5)   │                                │  │
│  │   │ SGT   │ │ SGT   │ ← Choose new leader            │  │
│  │   └───────┘ └───────┘                                │  │
│  │                                                        │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                              │
│  ASSIGN SQUAD B LEADER:                                      │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  ○ CPL NOVA-3X7  (23 tasks, 2,100 VGRD)              │  │
│  │  ○ CPL VIPER-1A8 (19 tasks, 1,800 VGRD)              │  │
│  │  ○ PFC RAVEN-5Z2 (15 tasks, 1,200 VGRD)              │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                              │
│  DISTRIBUTE MEMBERS:                                         │
│  ┌────────────────────┐  ┌────────────────────┐             │
│  │ SQUAD A (You)      │  │ SQUAD B            │             │
│  │ ───────────────    │  │ ───────────────    │             │
│  │ ☑ SGT CIPHER-7X4   │  │ ☑ CPL NOVA-3X7    │             │
│  │ ☑ CPL GHOST-9K2    │  │ ☑ PFC SHADOW-2X1  │             │
│  │ ☑ PFC HAWK-4J8     │  │ ☑ PV2 STORM-8K4   │             │
│  │ ☐ Move to B →      │  │ ← ☐ Move to A     │             │
│  └────────────────────┘  └────────────────────┘             │
│                                                              │
│       [Cancel]                        [Execute Split]        │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Flow 8: Chat & Comms

```
┌─────────────────────────────────────────────────────────────┐
│                         COMMS                                │
├──────────────────┬──────────────────────────────────────────┤
│  CHANNELS        │  # alpha-squad                            │
│                  │  ─────────────────────────────────────── │
│  YOUR UNIT       │                                           │
│  ┌────────────┐  │  ┌─────────────────────────────────────┐ │
│  │# alpha-sqd │◄─┤  │ 🔹 SGT CIPHER-7X4          10:34 AM │ │
│  └────────────┘  │  │    Task assigned. Check #smart-      │ │
│                  │  │    contracts for details.             │ │
│  SECTION         │  └─────────────────────────────────────┘ │
│  ┌────────────┐  │                                           │
│  │📢 1st-sect │  │  ┌─────────────────────────────────────┐ │
│  └────────────┘  │  │ 🔹 PFC GHOST-9K2            10:36 AM │ │
│                  │  │    Roger. Starting review now.        │ │
│  PLATOON         │  └─────────────────────────────────────┘ │
│  ┌────────────┐  │                                           │
│  │📢 2nd-plt  │  │  ┌─────────────────────────────────────┐ │
│  └────────────┘  │  │ ⚡ SYSTEM                   10:40 AM │ │
│                  │  │    Task #892 created: "Fix           │ │
│  COMPANY         │  │    reentrancy in withdraw()"         │ │
│  ┌────────────┐  │  └─────────────────────────────────────┘ │
│  │📻 alpha-co │  │                                           │
│  └────────────┘  │  ┌─────────────────────────────────────┐ │
│                  │  │ 🔹 You                      10:42 AM │ │
│  ─────────────── │  │    I'll take that one. Assigning     │ │
│  DMs (2)         │  │    to myself.                        │ │
│  ┌────────────┐  │  └─────────────────────────────────────┘ │
│  │🔵 NOVA-3X7 │  │                                           │
│  │⚪ VIPER-1A8│  │  ─────────────────────────────────────── │
│  └────────────┘  │  ┌─────────────────────────────────────┐ │
│                  │  │ 💬 Type message...          [Send]   │ │
│                  │  └─────────────────────────────────────┘ │
└──────────────────┴──────────────────────────────────────────┘
```

### Flow 9: Intel Dashboard

```
┌─────────────────────────────────────────────────────────────┐
│                          INTEL                               │
├─────────────────────────────────────────────────────────────┤
│  [Personal] [Squad] [Section] [Platoon] [Company] [Army]    │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌────────────────────────┬────────────────────────────┐    │
│  │  TASK COMPLETION       │  EARNINGS (30 days)        │    │
│  │  ┌──────────────────┐  │  ┌────────────────────────┐│    │
│  │  │     ████         │  │  │         📈            ││    │
│  │  │   ██████  ▲ 15%  │  │  │       ╱    ╲          ││    │
│  │  │  ████████        │  │  │     ╱        ╲   ╱╲   ││    │
│  │  │ ██████████       │  │  │   ╱            ╲╱  ╲  ││    │
│  │  │████████████      │  │  │ ╱                    ╲││    │
│  │  └──────────────────┘  │  └────────────────────────┘│    │
│  │  47 tasks │ 92% rate   │  3,450 VGRD this month     │    │
│  └────────────────────────┴────────────────────────────┘    │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  LEADERBOARD - 2nd Platoon                            │   │
│  │  ┌──────┬─────────────────┬─────────┬────────┬──────┐│   │
│  │  │ Rank │ Callsign        │ Tasks   │ VGRD   │Streak││   │
│  │  ├──────┼─────────────────┼─────────┼────────┼──────┤│   │
│  │  │  🥇  │ CIPHER-7X4      │ 47      │ 3,450  │ 12🔥 ││   │
│  │  │  🥈  │ NOVA-3X7        │ 43      │ 3,200  │ 8    ││   │
│  │  │  🥉  │ GHOST-9K2       │ 38      │ 2,850  │ 5    ││   │
│  │  │  4   │ VIPER-1A8       │ 31      │ 2,100  │ 3    ││   │
│  │  │  5   │ SHADOW-5Z9      │ 28      │ 1,900  │ 1    ││   │
│  │  └──────┴─────────────────┴─────────┴────────┴──────┘│   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  PROMOTION PROGRESS                                   │   │
│  │                                                        │   │
│  │  SGT ──────────────[████████░░]───────────────► SSG  │   │
│  │                      78%                               │   │
│  │                                                        │   │
│  │  Requirements:                                         │   │
│  │  ✅ Lead squad with 8+ members (8/8)                  │   │
│  │  ✅ Complete 40+ tasks (47/40)                        │   │
│  │  🔄 Squad reaches 10 for split (8/10)                 │   │
│  │  ⬜ Appointed by Platoon Leader                       │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 4. Component Library

### Buttons
```
Primary:    [████████████]  Cyan glow, dark text
Secondary:  [────────────]  Outlined, cyan border
Danger:     [████████████]  Red glow, white text
Disabled:   [░░░░░░░░░░░░]  Muted, no interaction
```

### Cards
```
Standard:   Dark background (#1A2332), subtle border
Glowing:    + Colored border glow (rank-based)
Highlighted: + Cyan border, background tint
Warning:    + Amber pulsing border (near-split squads)
```

### Progress Indicators
```
Bar:        [██████████░░░░░░░░░░] 50%
Ring:       ◯ with animated fill
Steps:      ①━━━②━━━③━━━④
```

### Status Badges
```
Priority:   🔴 Critical  🟠 High  🟡 Medium  🟢 Low
Status:     ● Active  ○ Pending  ◐ In Progress  ✓ Complete
Rank:       [SGT] with rank-appropriate color
```

### Notifications
```
Success:    Green left border, checkmark icon
Warning:    Amber left border, alert icon
Error:      Red left border, x icon
Info:       Cyan left border, info icon
```

---

## 5. Animation Specifications

### Rank-Up Animation
```
Duration: 3 seconds (skippable after 1s)
Sequence:
1. Screen dims, old rank badge centers
2. Badge glows intensely
3. Particle burst effect
4. Badge morphs to new rank
5. New rank name types in
6. Confetti/sparkle effect
7. Stats update animation
```

### Task Complete Animation
```
Duration: 1.5 seconds
Sequence:
1. Task card pulses
2. Checkmark draws in
3. VGRD amount floats up with + sign
4. XP bar increments
5. Subtle screen flash
```

### Squad Split Animation
```
Duration: 2 seconds
Sequence:
1. Squad node pulses/grows
2. Node splits into two
3. Connection lines animate to new Section
4. New Section node fades in above
5. Leader badges update
```

---

## 6. Responsive Breakpoints

| Breakpoint | Width | Layout |
|------------|-------|--------|
| Mobile | < 600px | Single column, bottom nav |
| Tablet | 600-1024px | Two column where applicable |
| Desktop | > 1024px | Full layout, side nav option |

---

## 7. Accessibility

- All interactive elements have minimum 44px tap target
- Color is never the only indicator (icons + labels)
- Text contrast ratio minimum 4.5:1
- Focus indicators visible
- Screen reader labels for all icons
- Reduced motion option available

---

## 8. Data States

### Loading
```
┌─────────────────────────────────────┐
│                                     │
│        ◌ Loading...                 │
│        ▁▂▃▄▅▆▇█▇▆▅▄▃▂▁             │
│                                     │
└─────────────────────────────────────┘
```

### Empty
```
┌─────────────────────────────────────┐
│                                     │
│        📭                           │
│        No items yet                 │
│        [Create First]               │
│                                     │
└─────────────────────────────────────┘
```

### Error
```
┌─────────────────────────────────────┐
│                                     │
│        ⚠️                           │
│        Something went wrong         │
│        [Try Again]                  │
│                                     │
└─────────────────────────────────────┘
```

---

## 9. Future Considerations

### Phase 2 Features
- Training courses (PLDC, OBC) with quiz UI
- Achievement/badge system
- Direct messaging
- Voice channels (integration)
- Mobile push notifications

### Phase 3 Features
- Multi-company Army view
- Cross-company bounty marketplace
- Governance voting UI
- Treasury management
- Token staking interface

---

*Document Version: 1.0*
*Last Updated: February 2026*
*For: Vanguard DAO Mission Control*
