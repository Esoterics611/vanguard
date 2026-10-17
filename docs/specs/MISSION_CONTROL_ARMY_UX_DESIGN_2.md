# Mission Control: Army Network UX Design Specification
## DigitalVault Decentralized Coordination System

---

## 1. Executive Vision

Mission Control transforms anonymous blockchain coordination into a structured, gamified military hierarchy. Users progress from guests observing the "Army" to Private soldiers, climbing through ranks by contributing to squad objectives, earning tokens, and building reputation within a decentralized autonomous organization.

**Core Philosophy:** *"Anonymous soldiers, transparent missions, shared victory"*

---

## 2. Organizational Hierarchy

### 2.1 Unit Structure & Growth Mechanics

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              COMPANY (40-100)                                │
│                           Commander: CPT (Captain)                           │
│                          2IC: 1SG (First Sergeant)                          │
│                                                                              │
│   ┌────────────────────────────────────────────────────────────────────┐    │
│   │                         PLATOON (20-50)                             │    │
│   │                    Leader: 2LT/1LT (Lieutenant)                     │    │
│   │                      2IC: SFC (Sergeant First Class)                │    │
│   │                                                                      │    │
│   │   ┌────────────────────────────────────────────────────────────┐   │    │
│   │   │                      SECTION (10-25)                        │   │    │
│   │   │                   Leader: SSG (Staff Sergeant)              │   │    │
│   │   │                                                              │   │    │
│   │   │   ┌────────────────────────────────────────────────────┐   │   │    │
│   │   │   │                   SQUAD (2-10)                       │   │   │    │
│   │   │   │              Leader: SGT (Sergeant)                  │   │   │    │
│   │   │   │                                                       │   │   │    │
│   │   │   │   [ PVT ] [ PV2 ] [ PFC ] [ CPL ] [ SGT ]           │   │   │    │
│   │   │   │                                                       │   │   │    │
│   │   │   └────────────────────────────────────────────────────┘   │   │    │
│   │   │   ┌────────────────────────────────────────────────────┐   │   │    │
│   │   │   │                   SQUAD (2-10)                       │   │   │    │
│   │   │   └────────────────────────────────────────────────────┘   │   │    │
│   │   └────────────────────────────────────────────────────────────┘   │    │
│   │   ┌────────────────────────────────────────────────────────────┐   │    │
│   │   │                      SECTION (10-25)                        │   │    │
│   │   └────────────────────────────────────────────────────────────┘   │    │
│   └────────────────────────────────────────────────────────────────────┘    │
│   ┌────────────────────────────────────────────────────────────────────┐    │
│   │                         PLATOON (20-50)                             │    │
│   └────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │       COMMAND STAFF           │
                    │   (All CPTs - Officer Network)│
                    │   Define Bounties & Strategy  │
                    └───────────────────────────────┘
```

### 2.2 Rank Progression System

| Rank | Abbrev | Promoted By | Requirements | Voting Power | Token Multiplier |
|------|--------|-------------|--------------|--------------|------------------|
| Guest | - | - | Connect wallet | 0 | 0x |
| Private | PVT | Squad acceptance | Join squad | 1 | 1x |
| Private 2nd Class | PV2 | SGT (Squad Leader) | Complete 5 tasks | 2 | 1.2x |
| Private First Class | PFC | SSG (Section Leader) | Complete 10 tasks | 3 | 1.5x |
| Corporal | CPL | 2LT (Platoon Leader) | Complete 20 tasks, lead assistance | 5 | 2x |
| Sergeant | SGT | PLDC Completion | CPL + PLDC training | 10 | 3x |
| Staff Sergeant | SSG | Section formation | Lead squad → section split | 15 | 4x |
| Sergeant First Class | SFC | Platoon Leader appt | Appointed as Platoon 2IC | 20 | 5x |
| First Sergeant | 1SG | Company Cmdr appt | Appointed as Company 2IC | 25 | 6x |
| Second Lieutenant | 2LT | Section → Platoon | Lead section to platoon | 30 | 8x |
| First Lieutenant | 1LT | OBC Completion | 2LT + Officer Basic Course | 35 | 10x |
| Captain | CPT | Platoon → Company | Lead platoon to company | 50 | 15x |

### 2.3 Unit Split Mechanics

```
SQUAD SPLIT (>10 members):
┌──────────────┐         ┌──────────────┐   ┌──────────────┐
│  SQUAD (11)  │   ──►   │  SQUAD A (6) │ + │  SQUAD B (5) │
│   SGT Smith  │         │  SGT Smith   │   │  SGT Jones   │
└──────────────┘         └──────────────┘   └──────────────┘
                                  │
                         Becomes SECTION
                         Smith → SSG (Section Leader)
                         Smith appoints Jones as Squad B leader

SECTION → PLATOON (when any squad within section splits):
┌─────────────────────┐         ┌─────────────────────────────┐
│ SECTION             │         │ PLATOON                      │
│  ├─ Squad A         │   ──►   │  ├─ Section (original)      │
│  └─ Squad B (splits)│         │  │   ├─ Squad A             │
│                     │         │  │   └─ Squad B             │
│                     │         │  └─ Section (new from B)     │
│                     │         │       ├─ Squad B1            │
│                     │         │       └─ Squad B2            │
└─────────────────────┘         └─────────────────────────────┘
                         SSG Smith → 2LT Smith (Platoon Leader)
                         Smith appoints new Section Leader
```

---

## 3. Network Graph Model

### 3.1 Core Entities

```typescript
// Graph Node Types
enum NodeType {
  GUEST,      // Anonymous observer
  SOLDIER,    // Active member
  UNIT,       // Squad/Section/Platoon/Company
  OBJECTIVE,  // Unit-level goal
  TASK,       // Individual assignment
  BOUNTY,     // Command staff defined reward
  CHAT,       // Communication channel
}

// Relationship Types
enum EdgeType {
  // Membership
  MEMBER_OF,        // Soldier → Unit
  LEADS,            // Leader → Unit
  SECOND_IN_COMMAND,// 2IC → Unit
  
  // Hierarchy
  PARENT_UNIT,      // Squad → Section → Platoon → Company
  CHILD_UNIT,       // Inverse
  
  // Work
  ASSIGNED_TO,      // Soldier → Task
  CONTRIBUTES_TO,   // Task → Objective
  FULFILLS,         // Objective → Bounty
  
  // Social
  CAN_VIEW,         // Soldier → Chat (visibility)
  CAN_PROMOTE,      // Leader → Soldier (promotion authority)
  APPLIED_TO,       // Guest → Squad (pending membership)
  INVITED_BY,       // Soldier → Soldier (recruitment chain)
}
```

### 3.2 Network Access Control

```
┌─────────────────────────────────────────────────────────────────────┐
│                         VISIBILITY MATRIX                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  GUEST can see:                                                      │
│    ✓ Army structure (anonymous - no wallet addresses)               │
│    ✓ Public bounties                                                 │
│    ✓ Unit statistics (member count, completion rates)               │
│    ✗ Individual soldiers                                             │
│    ✗ Chat channels                                                   │
│    ✗ Task details                                                    │
│                                                                      │
│  SOLDIER (PVT-CPL) can see:                                         │
│    ✓ Own squad chat                                                  │
│    ✓ Section announcements (if in section)                          │
│    ✓ Platoon announcements (if in platoon)                          │
│    ✓ Company broadcasts (if in company)                             │
│    ✓ Own tasks and squad objectives                                 │
│    ✓ Squad member pseudonyms (not wallet addresses)                 │
│                                                                      │
│  NCO (SGT-1SG) can see:                                             │
│    ✓ All subordinate unit chats                                     │
│    ✓ Promotion history                                               │
│    ✓ Task completion metrics                                         │
│    ✓ Member performance data                                         │
│                                                                      │
│  OFFICER (2LT-CPT) can see:                                         │
│    ✓ Full unit analytics                                             │
│    ✓ Cross-unit coordination channels                               │
│    ✓ Bounty creation/management                                      │
│    ✓ Command staff network (CPT only)                               │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### 3.3 Graph Query Examples

```graphql
# Find all chats a soldier can access
query SoldierChats($walletAddress: String!) {
  soldier(wallet: $walletAddress) {
    rank
    memberOf {
      ... on Squad {
        chat { id, name }
        parentSection {
          announcementChannel { id, name }
          parentPlatoon {
            announcementChannel { id, name }
            parentCompany {
              broadcastChannel { id, name }
            }
          }
        }
      }
    }
  }
}

# Check promotion authority
query CanPromote($promoter: String!, $target: String!, $newRank: Rank!) {
  canPromote(
    promoterWallet: $promoter,
    targetWallet: $target,
    toRank: $newRank
  ) {
    allowed
    reason
  }
}

# Get unit growth potential (split prediction)
query UnitGrowth($unitId: String!) {
  unit(id: $unitId) {
    memberCount
    maxSize
    splitThreshold
    predictedSplitDate
    activeRecruitmentApplications
  }
}
```

---

## 4. Work Coordination Model

### 4.1 Hierarchy of Work

```
                    ┌─────────────────────────┐
                    │        BOUNTY           │
                    │   Created by: CPT       │
                    │   Reward: 10,000 VLTC   │
                    │   "Launch V2 Protocol"  │
                    └───────────┬─────────────┘
                                │
            ┌───────────────────┼───────────────────┐
            ▼                   ▼                   ▼
    ┌───────────────┐   ┌───────────────┐   ┌───────────────┐
    │  OBJECTIVE    │   │  OBJECTIVE    │   │  OBJECTIVE    │
    │  Unit: Plt 1  │   │  Unit: Plt 2  │   │  Unit: Plt 3  │
    │  "Smart       │   │  "Mobile      │   │  "Backend     │
    │   Contracts"  │   │   App"        │   │   Services"   │
    └───────┬───────┘   └───────┬───────┘   └───────┬───────┘
            │                   │                   │
    ┌───────┴───────┐   ┌───────┴───────┐   ┌───────┴───────┐
    │               │   │               │   │               │
    ▼               ▼   ▼               ▼   ▼               ▼
┌───────┐       ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐
│ TASK  │       │ TASK  │ │ TASK  │ │ TASK  │ │ TASK  │ │ TASK  │
│ PVT A │       │ PFC B │ │ CPL C │ │ PV2 D │ │ SGT E │ │ PVT F │
│"Audit"│       │"Test" │ │"Build"│ │"UI"   │ │"API"  │ │"Docs" │
└───────┘       └───────┘ └───────┘ └───────┘ └───────┘ └───────┘
```

### 4.2 Task States

```
┌─────────┐    assign    ┌──────────┐    start    ┌────────────┐
│ CREATED │ ───────────► │ ASSIGNED │ ──────────► │ IN_PROGRESS│
└─────────┘              └──────────┘             └─────┬──────┘
                                                        │
                              ┌──────────────────┬──────┴──────┐
                              ▼                  ▼             ▼
                        ┌──────────┐      ┌───────────┐  ┌──────────┐
                        │ BLOCKED  │      │ SUBMITTED │  │ FAILED   │
                        └────┬─────┘      └─────┬─────┘  └──────────┘
                             │                  │
                             │                  ▼
                             │           ┌───────────┐
                             └──────────►│ COMPLETED │
                                         └───────────┘
```

### 4.3 Reward Distribution

```
BOUNTY: 10,000 VLTC total
├── Platform Fee (2.5%): 250 VLTC → DAO Treasury
├── Command Allocation (10%): 975 VLTC → CPT who created bounty
└── Worker Pool (87.5%): 8,775 VLTC
    │
    ├── Objective 1 (40%): 3,510 VLTC
    │   ├── Task A (500 VLTC base) × 1.0 (PVT) = 500 VLTC
    │   ├── Task B (800 VLTC base) × 1.5 (PFC) = 1,200 VLTC
    │   ├── Task C (1,000 VLTC base) × 2.0 (CPL) = 2,000 VLTC
    │   └── Objective Leader Bonus (SSG): 310 VLTC
    │
    ├── Objective 2 (35%): 3,071 VLTC
    │   └── [distributed similarly]
    │
    └── Objective 3 (25%): 2,194 VLTC
        └── [distributed similarly]
```

---

## 5. UI/UX Design Specifications

### 5.1 Design Language: "Cyber Command"

**Theme:** Military discipline meets cyberpunk aesthetics
- Dark base (#0A0E17 - deep space black)
- Accent: Electric cyan (#00F0FF) for active elements
- Secondary: Military amber (#FFB800) for warnings/highlights
- Success: Tactical green (#00FF88)
- Rank: Gold gradient (#FFD700 → #FFA500) for officers
- Danger: Combat red (#FF3366)

**Typography:**
- Headers: "Orbitron" or "Rajdhani" (military tech feel)
- Body: "Inter" or "Roboto Mono" (clean, readable)
- Callsigns: Monospace with glow effect

**Visual Motifs:**
- Hexagonal frames for avatars/units
- Scan lines and subtle grid overlays
- Holographic card effects on hover
- Rank insignia as badges
- Progress bars styled as loading ammunition

### 5.2 Screen Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         APP SHELL                                    │
├─────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  TOP BAR                                                     │    │
│  │  [≡] Mission Control    [🔔 3]  [👤 SGT CIPHER-7X4]  [⚡]   │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │                                                               │    │
│  │                     CONTENT AREA                              │    │
│  │                     (see screens below)                       │    │
│  │                                                               │    │
│  │                                                               │    │
│  │                                                               │    │
│  │                                                               │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  BOTTOM NAV                                                   │    │
│  │                                                               │    │
│  │  [🏠]      [🎯]       [💬]       [📊]       [👥]             │    │
│  │  HQ      Missions    Comms     Intel      Army               │    │
│  │                                                               │    │
│  └─────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────┘
```

### 5.3 Screen Specifications

#### Screen 1: HQ (Headquarters) - Personal Dashboard

```
┌─────────────────────────────────────────────────────────────────────┐
│                         HEADQUARTERS                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   ┌─────────────────────────────────────────────────────────────┐   │
│   │  SOLDIER PROFILE                                             │   │
│   │  ┌────────┐                                                  │   │
│   │  │  ⬡⬡⬡   │  SGT CIPHER-7X4                                 │   │
│   │  │  ⬡👤⬡  │  Alpha Squad Leader                             │   │
│   │  │  ⬡⬡⬡   │  1st Section, 2nd Platoon                       │   │
│   │  └────────┘                                                  │   │
│   │                                                              │   │
│   │  [████████████████████░░░░░] 78/100 XP to SSG               │   │
│   │                                                              │   │
│   │  ┌──────────┬──────────┬──────────┬──────────┐              │   │
│   │  │ 47       │ 12       │ 3,450    │ 10       │              │   │
│   │  │ Tasks    │ Recruits │ VLTC     │ Voting   │              │   │
│   │  │ Complete │ Invited  │ Earned   │ Power    │              │   │
│   │  └──────────┴──────────┴──────────┴──────────┘              │   │
│   └─────────────────────────────────────────────────────────────┘   │
│                                                                      │
│   ┌─────────────────────────────────────────────────────────────┐   │
│   │  ACTIVE TASKS                                    [View All →]│   │
│   │  ┌─────────────────────────────────────────────────────────┐│   │
│   │  │ 🔴 HIGH │ Audit TokenVesting contract                   ││   │
│   │  │         │ Bounty: Smart Contract Security               ││   │
│   │  │         │ Due: 2 days │ Reward: 800 VLTC               ││   │
│   │  └─────────────────────────────────────────────────────────┘│   │
│   │  ┌─────────────────────────────────────────────────────────┐│   │
│   │  │ 🟡 MED  │ Review PR #234 - Fee calculation fix          ││   │
│   │  │         │ Objective: Protocol Hardening                 ││   │
│   │  │         │ Due: 5 days │ Reward: 200 VLTC               ││   │
│   │  └─────────────────────────────────────────────────────────┘│   │
│   └─────────────────────────────────────────────────────────────┘   │
│                                                                      │
│   ┌─────────────────────────────────────────────────────────────┐   │
│   │  SQUAD STATUS                                                │   │
│   │  Alpha Squad │ 8/10 members │ 3 tasks active                │   │
│   │  ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐          │   │
│   │  │🟢│ │🟢│ │🟡│ │🟢│ │⚪│ │🟢│ │🟢│ │🟢│          │   │
│   │  │SGT│ │PFC│ │CPL│ │PV2│ │PVT│ │PVT│ │PV2│ │PFC│          │   │
│   │  └───┘ └───┘ └───┘ └───┘ └───┘ └───┘ └───┘ └───┘          │   │
│   │                                         [+ Recruit]         │   │
│   └─────────────────────────────────────────────────────────────┘   │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Screen 2: Missions - Bounties & Objectives

```
┌─────────────────────────────────────────────────────────────────────┐
│                           MISSIONS                                   │
├─────────────────────────────────────────────────────────────────────┤
│  [All] [Available] [In Progress] [Completed]      [🔍 Search]       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   ┌─────────────────────────────────────────────────────────────┐   │
│   │  🏆 FEATURED BOUNTY                                          │   │
│   │  ┌─────────────────────────────────────────────────────────┐│   │
│   │  │                                                          ││   │
│   │  │  ████████████████████████████████████████████████████   ││   │
│   │  │  █ OPERATION: PHOENIX RISING                         █   ││   │
│   │  │  █ Launch V2 Protocol on Mainnet                     █   ││   │
│   │  │  ████████████████████████████████████████████████████   ││   │
│   │  │                                                          ││   │
│   │  │  💰 50,000 VLTC          ⏱️ 30 days remaining           ││   │
│   │  │  👥 12 units assigned    📊 34% complete                ││   │
│   │  │                                                          ││   │
│   │  │  [View Details]                                          ││   │
│   │  └─────────────────────────────────────────────────────────┘│   │
│   └─────────────────────────────────────────────────────────────┘   │
│                                                                      │
│   ┌─────────────────────────────────────────────────────────────┐   │
│   │  📋 AVAILABLE BOUNTIES                                       │   │
│   │                                                              │   │
│   │  ┌────────────────────────────────────────────────────────┐ │   │
│   │  │ Smart Contract Audit      │ 10,000 VLTC │ 14 days     │ │   │
│   │  │ Skills: Solidity, Security│ 3 objectives│ ⚡ Urgent   │ │   │
│   │  └────────────────────────────────────────────────────────┘ │   │
│   │  ┌────────────────────────────────────────────────────────┐ │   │
│   │  │ Mobile App Polish         │ 5,000 VLTC  │ 21 days     │ │   │
│   │  │ Skills: Flutter, UI/UX    │ 5 objectives│             │ │   │
│   │  └────────────────────────────────────────────────────────┘ │   │
│   │  ┌────────────────────────────────────────────────────────┐ │   │
│   │  │ Documentation Sprint      │ 2,000 VLTC  │ 7 days      │ │   │
│   │  │ Skills: Technical Writing │ 2 objectives│ 🆕 New      │ │   │
│   │  └────────────────────────────────────────────────────────┘ │   │
│   │                                                              │   │
│   └─────────────────────────────────────────────────────────────┘   │
│                                                                      │
│   [CPT+ Only: + Create Bounty]                                      │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Screen 3: Comms - Chat Network

```
┌─────────────────────────────────────────────────────────────────────┐
│                            COMMS                                     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌───────────────────┬──────────────────────────────────────────┐   │
│  │  CHANNELS         │  # alpha-squad                            │   │
│  │                   │  ─────────────────────────────────────────│   │
│  │  YOUR UNIT        │                                           │   │
│  │  ┌─────────────┐  │  ┌────────────────────────────────────┐  │   │
│  │  │ # alpha-sqd │◄─┤  │ 🔹 CIPHER-7X4 (SGT) - 10:34        │  │   │
│  │  └─────────────┘  │  │    Objective assigned. Check your   │  │   │
│  │                   │  │    tasks for the audit work.        │  │   │
│  │  SECTION          │  └────────────────────────────────────┘  │   │
│  │  ┌─────────────┐  │  ┌────────────────────────────────────┐  │   │
│  │  │ 📢 1st-sect │  │  │ 🔹 GHOST-9K2 (PFC) - 10:36         │  │   │
│  │  └─────────────┘  │  │    Roger that. Starting review now. │  │   │
│  │                   │  └────────────────────────────────────┘  │   │
│  │  PLATOON          │  ┌────────────────────────────────────┐  │   │
│  │  ┌─────────────┐  │  │ 🔹 NOVA-3X7 (CPL) - 10:38          │  │   │
│  │  │ 📢 2nd-plt  │  │  │    Found critical issue in line    │  │   │
│  │  └─────────────┘  │  │    234. Creating task now.         │  │   │
│  │                   │  └────────────────────────────────────┘  │   │
│  │  COMPANY          │  ┌────────────────────────────────────┐  │   │
│  │  ┌─────────────┐  │  │ ⚡ SYSTEM - 10:40                   │  │   │
│  │  │ 📻 bravo-co │  │  │    Task #892 created by NOVA-3X7   │  │   │
│  │  └─────────────┘  │  │    "Fix reentrancy in withdraw()"  │  │   │
│  │                   │  └────────────────────────────────────┘  │   │
│  │  ───────────────  │                                           │   │
│  │  DMs (3)          │                                           │   │
│  │  ┌─────────────┐  │  ─────────────────────────────────────────│   │
│  │  │ 🔵 NOVA-3X7 │  │  ┌────────────────────────────────────┐  │   │
│  │  │ 🔵 GHOST-9K2│  │  │ 💬 Type message...          [Send] │  │   │
│  │  │ ⚪ VIPER-1A8│  │  └────────────────────────────────────┘  │   │
│  │  └─────────────┘  │                                           │   │
│  └───────────────────┴──────────────────────────────────────────┘   │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Screen 4: Intel - Analytics Dashboard

```
┌─────────────────────────────────────────────────────────────────────┐
│                            INTEL                                     │
├─────────────────────────────────────────────────────────────────────┤
│  [Personal] [Squad] [Section] [Platoon] [Company] [Army]            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   ┌────────────────────────────┬────────────────────────────────┐   │
│   │  TASK COMPLETION           │  EARNINGS (30 days)            │   │
│   │  ┌──────────────────────┐  │  ┌────────────────────────────┐│   │
│   │  │     ████             │  │  │         📈                 ││   │
│   │  │   ██████             │  │  │       ╱    ╲               ││   │
│   │  │  ████████   ▲ 15%    │  │  │     ╱        ╲   ╱╲       ││   │
│   │  │ ██████████           │  │  │   ╱            ╲╱  ╲      ││   │
│   │  │████████████          │  │  │ ╱                    ╲    ││   │
│   │  └──────────────────────┘  │  └────────────────────────────┘│   │
│   │  47 tasks │ 92% success    │  3,450 VLTC earned this month  │   │
│   └────────────────────────────┴────────────────────────────────┘   │
│                                                                      │
│   ┌─────────────────────────────────────────────────────────────┐   │
│   │  LEADERBOARD - 2nd Platoon                                   │   │
│   │  ┌──────┬─────────────────┬───────────┬───────────┬────────┐│   │
│   │  │ Rank │ Callsign        │ Tasks     │ VLTC      │ Streak ││   │
│   │  ├──────┼─────────────────┼───────────┼───────────┼────────┤│   │
│   │  │  🥇  │ CIPHER-7X4      │ 47        │ 3,450     │ 12 🔥  ││   │
│   │  │  🥈  │ NOVA-3X7        │ 43        │ 3,200     │ 8      ││   │
│   │  │  🥉  │ GHOST-9K2       │ 38        │ 2,850     │ 5      ││   │
│   │  │  4   │ VIPER-1A8       │ 31        │ 2,100     │ 3      ││   │
│   │  │  5   │ SHADOW-5Z9      │ 28        │ 1,900     │ 1      ││   │
│   │  └──────┴─────────────────┴───────────┴───────────┴────────┘│   │
│   └─────────────────────────────────────────────────────────────┘   │
│                                                                      │
│   ┌─────────────────────────────────────────────────────────────┐   │
│   │  PROMOTION PROGRESS                                          │   │
│   │                                                              │   │
│   │  SGT ──────────────────[████████░░]────────────────► SSG    │   │
│   │                         78%                                  │   │
│   │                                                              │   │
│   │  Requirements:                                               │   │
│   │  ✅ Lead squad with 8+ members (8/8)                        │   │
│   │  ✅ Complete 40+ tasks (47/40)                              │   │
│   │  🔄 Squad reaches 10 members for split (8/10)               │   │
│   │  ⬜ Appointed by Platoon Leader                             │   │
│   └─────────────────────────────────────────────────────────────┘   │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Screen 5: Army - Network Visualization

```
┌─────────────────────────────────────────────────────────────────────┐
│                            ARMY                                      │
├─────────────────────────────────────────────────────────────────────┤
│  [Graph View] [List View] [Apply to Join]       [🔍 Search Units]   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   ┌─────────────────────────────────────────────────────────────┐   │
│   │                                                              │   │
│   │                    🏛️ ALPHA COMPANY (CPT)                    │   │
│   │                           │                                  │   │
│   │           ┌───────────────┼───────────────┐                  │   │
│   │           │               │               │                  │   │
│   │      ⭐ 1st PLT      ⭐ 2nd PLT      ⭐ 3rd PLT              │   │
│   │        (2LT)          (1LT)          (2LT)                   │   │
│   │           │               │               │                  │   │
│   │     ┌─────┴─────┐   ┌─────┴─────┐   ┌─────┴─────┐           │   │
│   │     │           │   │           │   │           │           │   │
│   │   🔷1A        🔷1B 🔷2A        🔷2B 🔷3A        🔷3B          │   │
│   │   (SSG)      (SSG) (SSG)      (SSG) (SSG)      (SSG)        │   │
│   │     │           │   │           │   │           │           │   │
│   │   ┌─┴─┐     ┌─┴─┐ ┌─┴─┐     ┌─┴─┐ ┌─┴─┐     ┌─┴─┐          │   │
│   │   ◆   ◆     ◆   ◆ ◆ ★ ◆     ◆   ◆ ◆   ◆     ◆   ◆          │   │
│   │  (8) (7)   (9) (6)(8)(★)(7) (10)(5)(6) (8)   (7) (9)        │   │
│   │                     YOU                                      │   │
│   │                                                              │   │
│   │  Legend: 🏛️ Company  ⭐ Platoon  🔷 Section  ◆ Squad         │   │
│   │          ★ Your location  (n) = member count                │   │
│   │                                                              │   │
│   └─────────────────────────────────────────────────────────────┘   │
│                                                                      │
│   ┌─────────────────────────────────────────────────────────────┐   │
│   │  ARMY STATS                                                  │   │
│   │  ┌────────────┬────────────┬────────────┬────────────┐      │   │
│   │  │   247      │   2        │   6        │   24       │      │   │
│   │  │  Soldiers  │ Companies  │ Platoons   │  Squads    │      │   │
│   │  └────────────┴────────────┴────────────┴────────────┘      │   │
│   │                                                              │   │
│   │  🔥 Hot Squads (Near Split):                                 │   │
│   │     • Section 2B Squad 1 (10/10) - Splitting soon!          │   │
│   │     • Section 1A Squad 2 (9/10)                              │   │
│   │                                                              │   │
│   └─────────────────────────────────────────────────────────────┘   │
│                                                                      │
│  [Guest View: Connect Wallet]  [+ Apply to Squad]                   │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### 5.4 Guest Experience Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                        GUEST LANDING                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│        ████████████████████████████████████████████████████         │
│        █                                                    █         │
│        █       ╔═══════════════════════════════════╗       █         │
│        █       ║     DIGITAL VAULT ARMY            ║       █         │
│        █       ║     Join the Revolution           ║       █         │
│        █       ╚═══════════════════════════════════╝       █         │
│        █                                                    █         │
│        ████████████████████████████████████████████████████         │
│                                                                      │
│                                                                      │
│   ┌─────────────────────────────────────────────────────────────┐   │
│   │                                                              │   │
│   │  OBSERVE THE ARMY                                            │   │
│   │  View our organizational structure, active bounties, and     │   │
│   │  watch anonymous soldiers coordinate global objectives.      │   │
│   │                                                              │   │
│   │                    [👁️ View as Guest]                        │   │
│   │                                                              │   │
│   └─────────────────────────────────────────────────────────────┘   │
│                                                                      │
│   ┌─────────────────────────────────────────────────────────────┐   │
│   │                                                              │   │
│   │  ENLIST NOW                                                  │   │
│   │  Connect your wallet, apply to a squad, and begin your      │   │
│   │  journey from Private to Captain.                           │   │
│   │                                                              │   │
│   │                    [🔗 Connect Wallet]                       │   │
│   │                                                              │   │
│   └─────────────────────────────────────────────────────────────┘   │
│                                                                      │
│   ┌─────────────────────────────────────────────────────────────┐   │
│   │  LIVE STATS                                                  │   │
│   │  🪖 247 Soldiers │ 💰 1.2M VLTC Distributed │ 📋 892 Tasks  │   │
│   └─────────────────────────────────────────────────────────────┘   │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 6. Component Specifications

### 6.1 Core Widgets

```dart
// Rank Badge Widget
class RankBadge extends StatelessWidget {
  final Rank rank;
  final bool showGlow;
  final double size;
  
  // Renders hexagonal badge with rank insignia
  // Officers get gold glow, NCOs silver, enlisted bronze
}

// Unit Card Widget  
class UnitCard extends StatelessWidget {
  final Unit unit;
  final bool isExpanded;
  final VoidCallback onTap;
  
  // Shows unit type icon, member count, health indicators
  // Expandable to show member list (anonymized)
  // Pulsing border for units near split threshold
}

// Task Card Widget
class TaskCard extends StatelessWidget {
  final Task task;
  final TaskState state;
  
  // Priority indicator (color coded)
  // Progress bar with cyber styling
  // Reward preview
  // Due date with urgency animation
}

// Progress Ring Widget
class CyberProgressRing extends StatelessWidget {
  final double progress;
  final String label;
  final Color glowColor;
  
  // Animated ring with scan line effect
  // Holographic text overlay
}

// Network Graph Widget
class ArmyNetworkGraph extends StatelessWidget {
  final List<Unit> units;
  final String? highlightUnitId;
  
  // Force-directed graph layout
  // Interactive zoom/pan
  // Tap to select unit
  // Highlight user's position
}
```

### 6.2 Animation Specifications

```dart
// Promotion Animation
// Full-screen cinematic when user ranks up
// Shows old rank transforming to new rank
// Particle effects, sound feedback
// Duration: 3 seconds
// Can be skipped after 1 second

// Unit Split Animation
// Organic cell-division visual
// Shows parent unit dividing into children
// New leader highlighted with spotlight
// Duration: 2 seconds

// Task Completion Animation
// Checkmark with ripple effect
// VLTC token shower effect
// XP bar increment animation
// Duration: 1.5 seconds

// Message Send Animation
// Cyber-pulse effect on send
// Message appears with fade-in + slight scale
// Timestamp types in character by character
```

---

## 7. Data Models

### 7.1 Core Entities

```dart
// lib/core/models/army/soldier.dart
@freezed
class Soldier with _$Soldier {
  const factory Soldier({
    required String id,
    required String walletAddress,
    required String callsign,          // Auto-generated pseudonym
    required Rank rank,
    required String squadId,
    String? sectionId,
    String? platoonId,
    String? companyId,
    required int tasksCompleted,
    required int xp,
    required BigInt vltcEarned,
    required int votingPower,
    required DateTime enlistedAt,
    String? invitedByWallet,
    required List<String> promotionHistory,
  }) = _Soldier;
}

// lib/core/models/army/unit.dart
@freezed
class Unit with _$Unit {
  const factory Unit({
    required String id,
    required UnitType type,            // SQUAD, SECTION, PLATOON, COMPANY
    required String name,
    required String leaderId,
    String? secondInCommandId,
    required List<String> memberIds,
    String? parentUnitId,
    required List<String> childUnitIds,
    required String chatChannelId,
    required List<String> objectiveIds,
    required int maxSize,
    required DateTime createdAt,
  }) = _Unit;
}

// lib/core/models/army/rank.dart
enum Rank {
  guest(0, 0, 'Guest', 0),
  pvt(1, 1, 'Private', 1),
  pv2(2, 1.2, 'Private 2nd Class', 2),
  pfc(3, 1.5, 'Private First Class', 3),
  cpl(5, 2, 'Corporal', 5),
  sgt(10, 3, 'Sergeant', 10),
  ssg(15, 4, 'Staff Sergeant', 15),
  sfc(20, 5, 'Sergeant First Class', 20),
  firstSgt(25, 6, 'First Sergeant', 25),
  secondLt(30, 8, 'Second Lieutenant', 30),
  firstLt(35, 10, 'First Lieutenant', 35),
  cpt(50, 15, 'Captain', 50);

  const Rank(this.votingPower, this.tokenMultiplier, this.displayName, this.xpRequired);
  
  final int votingPower;
  final double tokenMultiplier;
  final String displayName;
  final int xpRequired;
  
  bool get isOfficer => index >= Rank.secondLt.index;
  bool get isNCO => index >= Rank.sgt.index && index < Rank.secondLt.index;
}

// lib/core/models/army/objective.dart
@freezed
class Objective with _$Objective {
  const factory Objective({
    required String id,
    required String title,
    required String description,
    required String unitId,
    required String bountyId,
    required ObjectiveStatus status,
    required List<String> taskIds,
    required BigInt allocatedVltc,
    required DateTime deadline,
    required DateTime createdAt,
  }) = _Objective;
}

// lib/core/models/army/task.dart
@freezed
class Task with _$Task {
  const factory Task({
    required String id,
    required String title,
    required String description,
    required String objectiveId,
    String? assigneeId,
    required TaskStatus status,
    required TaskPriority priority,
    required BigInt rewardVltc,
    required DateTime deadline,
    String? submissionIpfsHash,
    DateTime? completedAt,
    required DateTime createdAt,
  }) = _Task;
}
```

### 7.2 Network Graph Model

```dart
// lib/core/models/network/graph_node.dart
@freezed
class GraphNode with _$GraphNode {
  const factory GraphNode.soldier({
    required String id,
    required Rank rank,
    required String callsign,
  }) = SoldierNode;
  
  const factory GraphNode.unit({
    required String id,
    required UnitType type,
    required String name,
    required int memberCount,
  }) = UnitNode;
  
  const factory GraphNode.bounty({
    required String id,
    required String title,
    required BigInt reward,
  }) = BountyNode;
}

// lib/core/models/network/graph_edge.dart
@freezed
class GraphEdge with _$GraphEdge {
  const factory GraphEdge({
    required String fromId,
    required String toId,
    required EdgeType type,
    Map<String, dynamic>? metadata,
  }) = _GraphEdge;
}

enum EdgeType {
  memberOf,
  leads,
  secondInCommand,
  parentUnit,
  childUnit,
  assignedTo,
  contributesTo,
  fulfills,
  canView,
  canPromote,
  appliedTo,
  invitedBy,
}
```

---

## 8. Backend API Specifications

### 8.1 New Endpoints Required

```yaml
# Mission Control Army Service Extensions

/api/army/soldiers:
  GET:
    description: List soldiers (filtered by visibility rules)
    query:
      - unitId: string (optional)
      - rank: string (optional)
    response: Soldier[] (anonymized based on viewer permissions)
  
  POST:
    description: Enlist new soldier (from guest)
    body:
      walletAddress: string
      squadId: string
    response: Soldier

/api/army/soldiers/{walletAddress}:
  GET:
    description: Get soldier profile
    response: Soldier (with visibility filtering)
  
  PATCH:
    description: Update soldier (promote, assign, etc.)
    body:
      rank?: Rank
      squadId?: string
    response: Soldier

/api/army/units:
  GET:
    description: List all units (hierarchy)
    query:
      - type: UnitType (optional)
      - parentId: string (optional)
    response: Unit[]
  
  POST:
    description: Create new unit (split or manual)
    body:
      type: UnitType
      name: string
      leaderId: string
      parentUnitId?: string
    response: Unit

/api/army/units/{unitId}:
  GET:
    description: Get unit details
    response: Unit (with members if permitted)
  
  PATCH:
    description: Update unit
    body:
      name?: string
      leaderId?: string
      secondInCommandId?: string
    response: Unit

/api/army/units/{unitId}/split:
  POST:
    description: Trigger unit split
    body:
      newSquadLeaderId: string
      memberDistribution: { squadA: string[], squadB: string[] }
    response: { originalUnit: Unit, newUnit: Unit }

/api/army/applications:
  GET:
    description: List pending applications (for leaders)
    query:
      - unitId: string
    response: Application[]
  
  POST:
    description: Apply to join squad
    body:
      walletAddress: string
      squadId: string
      message?: string
    response: Application

/api/army/applications/{applicationId}:
  PATCH:
    description: Accept/reject application
    body:
      status: 'accepted' | 'rejected'
    response: Application

/api/army/promotions:
  POST:
    description: Promote a soldier
    body:
      targetWalletAddress: string
      newRank: Rank
      promoterWalletAddress: string
    response: Promotion

/api/army/chat/channels:
  GET:
    description: Get accessible channels for soldier
    query:
      - walletAddress: string
    response: Channel[]

/api/army/chat/channels/{channelId}/messages:
  GET:
    description: Get channel messages
    query:
      - limit: number
      - before: string (cursor)
    response: Message[]
  
  POST:
    description: Send message
    body:
      content: string
      senderWalletAddress: string
    response: Message

/api/army/objectives:
  GET:
    description: List objectives
    query:
      - unitId?: string
      - bountyId?: string
      - status?: ObjectiveStatus
    response: Objective[]
  
  POST:
    description: Create objective (leader only)
    body:
      title: string
      description: string
      unitId: string
      bountyId: string
      allocatedVltc: string
      deadline: string
    response: Objective

/api/army/tasks:
  GET:
    description: List tasks
    query:
      - assigneeId?: string
      - objectiveId?: string
      - status?: TaskStatus
    response: Task[]
  
  POST:
    description: Create task
    body:
      title: string
      description: string
      objectiveId: string
      priority: TaskPriority
      rewardVltc: string
      deadline: string
    response: Task

/api/army/tasks/{taskId}:
  PATCH:
    description: Update task (assign, status change, submit)
    body:
      assigneeId?: string
      status?: TaskStatus
      submissionIpfsHash?: string
    response: Task

/api/army/network/graph:
  GET:
    description: Get network graph data
    query:
      - walletAddress: string (viewer)
      - depth: number (1-3)
    response: { nodes: GraphNode[], edges: GraphEdge[] }

/api/army/network/visibility:
  GET:
    description: Check what a soldier can see
    query:
      - walletAddress: string
    response: VisibilityMatrix

/api/army/stats:
  GET:
    description: Get army-wide statistics
    response: ArmyStats

/api/army/leaderboard:
  GET:
    description: Get leaderboard
    query:
      - scope: 'squad' | 'section' | 'platoon' | 'company' | 'army'
      - unitId?: string
      - metric: 'tasks' | 'vltc' | 'streak'
    response: LeaderboardEntry[]
```

### 8.2 Database Schema Extensions

```sql
-- Soldier table (extends existing user concept)
CREATE TABLE soldiers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wallet_address VARCHAR(42) UNIQUE NOT NULL,
    callsign VARCHAR(50) UNIQUE NOT NULL,
    rank VARCHAR(20) NOT NULL DEFAULT 'pvt',
    squad_id UUID REFERENCES units(id),
    tasks_completed INT DEFAULT 0,
    xp INT DEFAULT 0,
    vltc_earned NUMERIC(78, 0) DEFAULT 0,
    enlisted_at TIMESTAMP DEFAULT NOW(),
    invited_by_wallet VARCHAR(42),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Units table (squads, sections, platoons, companies)
CREATE TABLE units (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type VARCHAR(20) NOT NULL, -- SQUAD, SECTION, PLATOON, COMPANY
    name VARCHAR(100) NOT NULL,
    leader_id UUID REFERENCES soldiers(id),
    second_in_command_id UUID REFERENCES soldiers(id),
    parent_unit_id UUID REFERENCES units(id),
    chat_channel_id UUID,
    max_size INT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Unit membership (for tracking history)
CREATE TABLE unit_memberships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    soldier_id UUID REFERENCES soldiers(id),
    unit_id UUID REFERENCES units(id),
    joined_at TIMESTAMP DEFAULT NOW(),
    left_at TIMESTAMP,
    UNIQUE(soldier_id, unit_id, joined_at)
);

-- Squad applications
CREATE TABLE squad_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wallet_address VARCHAR(42) NOT NULL,
    squad_id UUID REFERENCES units(id),
    message TEXT,
    status VARCHAR(20) DEFAULT 'pending',
    reviewed_by UUID REFERENCES soldiers(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Promotions history
CREATE TABLE promotions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    soldier_id UUID REFERENCES soldiers(id),
    from_rank VARCHAR(20) NOT NULL,
    to_rank VARCHAR(20) NOT NULL,
    promoted_by_id UUID REFERENCES soldiers(id),
    reason TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Objectives (unit-level goals)
CREATE TABLE objectives (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    unit_id UUID REFERENCES units(id),
    bounty_id UUID REFERENCES bounties(id),
    status VARCHAR(20) DEFAULT 'active',
    allocated_vltc NUMERIC(78, 0) NOT NULL,
    deadline TIMESTAMP NOT NULL,
    created_by_id UUID REFERENCES soldiers(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tasks (individual assignments)
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    objective_id UUID REFERENCES objectives(id),
    assignee_id UUID REFERENCES soldiers(id),
    status VARCHAR(20) DEFAULT 'created',
    priority VARCHAR(20) DEFAULT 'medium',
    reward_vltc NUMERIC(78, 0) NOT NULL,
    deadline TIMESTAMP NOT NULL,
    submission_ipfs_hash VARCHAR(100),
    completed_at TIMESTAMP,
    created_by_id UUID REFERENCES soldiers(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Chat channels
CREATE TABLE chat_channels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    unit_id UUID REFERENCES units(id),
    type VARCHAR(20) NOT NULL, -- SQUAD, SECTION_ANNOUNCE, PLATOON_ANNOUNCE, COMPANY_BROADCAST
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Chat messages
CREATE TABLE chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    channel_id UUID REFERENCES chat_channels(id),
    sender_id UUID REFERENCES soldiers(id),
    content TEXT NOT NULL,
    message_type VARCHAR(20) DEFAULT 'text', -- text, system, task_created, etc.
    metadata JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Callsign generator words
CREATE TABLE callsign_words (
    id SERIAL PRIMARY KEY,
    word VARCHAR(50) NOT NULL,
    type VARCHAR(20) NOT NULL -- PREFIX, SUFFIX
);
```

---

## 9. Training Courses

### 9.1 PLDC (Primary Leadership Development Course)

```
Required for: CPL → SGT promotion
Duration: Complete 5 modules
Content:
  1. Leadership Fundamentals
     - Squad management basics
     - Task delegation principles
     - Communication protocols
  
  2. Recruitment & Growth
     - How to recruit effectively
     - Onboarding new soldiers
     - Building squad cohesion
  
  3. Objective Management
     - Breaking bounties into tasks
     - Progress tracking
     - Quality assurance
  
  4. Promotion Authority
     - Understanding rank requirements
     - Fair evaluation practices
     - Documentation
  
  5. Split Preparation
     - Recognizing split readiness
     - Leader selection
     - Transition planning

Completion: Pass quiz (80%+), verified on-chain
```

### 9.2 OBC (Officer Basic Course)

```
Required for: 2LT → 1LT promotion
Duration: Complete 7 modules
Content:
  1. Strategic Planning
  2. Multi-Section Coordination
  3. Resource Allocation
  4. Conflict Resolution
  5. Performance Analytics
  6. DAO Governance Participation
  7. Command Staff Protocols

Completion: Pass comprehensive exam, endorsed by existing officer
```

---

## 10. Token Economics Integration

### 10.1 Reward Distribution

```typescript
interface RewardDistribution {
  // When task completed
  calculateTaskReward(task: Task, soldier: Soldier): BigInt {
    const baseReward = task.rewardVltc;
    const multiplier = soldier.rank.tokenMultiplier;
    return baseReward * BigInt(Math.floor(multiplier * 100)) / 100n;
  }
  
  // When objective completed
  distributeObjectiveBonus(objective: Objective, leader: Soldier): BigInt {
    // Leader gets 10% bonus of objective allocation
    return objective.allocatedVltc * 10n / 100n;
  }
  
  // When bounty completed
  distributeBountyCompletion(bounty: Bounty) {
    const platformFee = bounty.amount * 25n / 1000n; // 2.5%
    const commandAllocation = bounty.amount * 10n / 100n; // 10% to creating CPT
    const workerPool = bounty.amount - platformFee - commandAllocation;
    
    // workerPool distributed to objectives based on allocation %
  }
}
```

### 10.2 Voting Power

```typescript
interface VotingPower {
  // DAO proposal voting
  calculateVotes(soldier: Soldier): number {
    return soldier.rank.votingPower;
  }
  
  // Company-level decisions
  calculateCompanyVotes(soldier: Soldier, company: Unit): number {
    if (!company.memberIds.includes(soldier.id)) return 0;
    return soldier.rank.votingPower;
  }
  
  // Threshold calculations
  isQuorumMet(proposal: Proposal, votes: Vote[]): boolean {
    const totalPower = this.getTotalVotingPower(proposal.scope);
    const castPower = votes.reduce((sum, v) => sum + v.power, 0);
    return castPower >= totalPower * 0.3; // 30% quorum
  }
}
```

---

## 11. Implementation Phases

### Phase 1: Foundation (2 weeks)
- [ ] Soldier registration and callsign generation
- [ ] Basic rank system (PVT only)
- [ ] Squad creation and membership
- [ ] Unit visualization (list view)
- [ ] Apply to squad flow

### Phase 2: Hierarchy (2 weeks)
- [ ] Section and Platoon unit types
- [ ] Promotion mechanics (PVT → PV2 → PFC → CPL)
- [ ] Squad split logic (→ Section)
- [ ] Section leader role (SSG)
- [ ] Network graph visualization

### Phase 3: Leadership (2 weeks)
- [ ] PLDC training course
- [ ] SGT promotion and squad command
- [ ] Section split (→ Platoon)
- [ ] Lieutenant roles (2LT, 1LT)
- [ ] OBC training course

### Phase 4: Command (2 weeks)
- [ ] Company formation
- [ ] Captain role
- [ ] Command staff network
- [ ] 2IC appointments (SFC, 1SG)
- [ ] Cross-unit coordination

### Phase 5: Coordination (2 weeks)
- [ ] Objective system
- [ ] Task management
- [ ] Bounty → Objective → Task flow
- [ ] Reward distribution
- [ ] Leaderboards

### Phase 6: Communication (1 week)
- [ ] Chat channels per unit
- [ ] Visibility rules
- [ ] Announcement channels
- [ ] System messages

### Phase 7: Polish (1 week)
- [ ] Animations
- [ ] Sound effects
- [ ] Achievement system
- [ ] Onboarding tutorial

---

## 12. Security Considerations

### 12.1 Anonymity Preservation
- Wallet addresses never exposed in UI
- Callsigns auto-generated, cannot be chosen
- Graph visualization uses callsigns only
- Leaders can see promotion history but not wallet addresses

### 12.2 Permission Validation
- All promotions validated server-side
- Promotion authority checked against rank relationships
- Unit membership verified before chat access
- Rate limiting on applications

### 12.3 Anti-Gaming
- Minimum time-in-rank before promotion eligibility
- Task completion verification (IPFS hash + leader approval)
- Split thresholds prevent artificial inflation
- Cooldown on squad switches

---

*Document Version: 1.0*
*Last Updated: January 2026*
*For: DigitalVault Mission Control*
