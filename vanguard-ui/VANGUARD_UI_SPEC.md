# Vanguard DAO — Web UI Specification

## Overview

A SvelteKit-based web interface for the Vanguard DAO coordination platform. Built around the mental model of **GitHub for decentralized investment banking teams** — where bounties are repositories, objectives are pull requests, and tasks are commits.

## Stack

| Layer | Technology | Why |
|-------|-----------|-----|
| Framework | **SvelteKit 2 + Svelte 5** | Compiled reactivity, no VDOM overhead, smallest bundles |
| Styling | **Tailwind CSS v4** | Utility-first with `@theme` design tokens |
| State | **Svelte 5 runes** (`$state`, `$derived`) | Zero-boilerplate reactive stores |
| Icons | **SVG rank insignia** + Unicode glyphs | Custom military insignia, lightweight |
| Types | **TypeScript** strict mode | Full type safety across all components |

## Core Mental Model

| GitHub | Vanguard | Created By | Analogy |
|--------|----------|-----------|---------|
| Repository | **Bounty** | Commander (CPT+) | A deal / engagement |
| Pull Request | **Objective** | Unit Lead | A workstream |
| Commit | **Task** | Individual Soldier | A deliverable |
| Code Review | **Commander Review** | Commander | Quality gate |
| Merge | **Acceptance** | Commander | Work approved → rewards flow |
| Contributors | **Soldiers** | Self-enlisted | Specialists |
| Organization | **Company** | Hierarchical | The firm |

## MVP Workflows

### 1. Deal Origination (Commander Creates Bounty)
```
Commander identifies opportunity
  → Creates Bounty with VGRD allocation + skill tags
  → Defines objectives (workstreams)
  → Bounty appears on the board for units to claim
```

### 2. Workstream Checkout (Unit Lead Claims Objective)
```
Unit Lead browses active bounties
  → Sees objective breakdowns
  → "Checks out" an objective for their unit
  → Objective moves to "In Progress"
  → Gets VGRD allocation from bounty pool
```

### 3. Task Execution (Soldier Works a Task)
```
Soldier sees assigned tasks in dashboard/kanban
  → Starts task → works locally
  → Submits deliverable (IPFS hash)
  → Task moves to "Submitted"
```

### 4. Review & Merge (Commander Accepts)
```
Commander sees submitted objectives in Review page
  → Reviews all task submissions
  → Accepts → objective "merged", VGRD distributed
  → Or requests changes → objective returns to "In Progress"
```

### 5. Progression
```
XP accumulates from completed tasks
  → Soldier reaches rank threshold
  → Commander promotes → new capabilities unlocked
```

## Project Structure

```
vanguard-ui/
├── src/
│   ├── app.html                    # HTML shell
│   ├── app.css                     # Tailwind + design system
│   ├── lib/
│   │   ├── types/index.ts          # Full type system (Rank, Soldier, Bounty, Objective, Task, etc.)
│   │   ├── stores/
│   │   │   ├── app.svelte.ts       # Global reactive state (Svelte 5 class with runes)
│   │   │   └── mock-data.ts        # Realistic IB team mock data
│   │   ├── utils/format.ts         # Formatting helpers (VGRD, dates, status colors)
│   │   └── components/
│   │       ├── Sidebar.svelte      # Main navigation with badges + user card
│   │       ├── TopBar.svelte       # Top bar with breadcrumbs + search
│   │       ├── StatusBadge.svelte  # Reusable status pill
│   │       ├── ProgressBar.svelte  # Animated progress bar with shine effect
│   │       ├── RankBadge.svelte    # Rank display with tier colors
│   │       ├── RankInsignia.svelte # SVG military rank insignia (chevrons/bars)
│   │       ├── SoldierAvatar.svelte # Avatar with online indicator
│   │       └── EmptyState.svelte   # Empty state placeholder
│   └── routes/
│       ├── +layout.svelte          # App shell (sidebar + topbar + content)
│       ├── +page.svelte            # Dashboard
│       ├── bounties/
│       │   ├── +page.svelte        # Bounty list (filterable, searchable)
│       │   ├── new/+page.svelte    # Create new bounty form (officers only)
│       │   └── [id]/+page.svelte   # Bounty detail (objectives, tasks, contributors tabs)
│       ├── objectives/
│       │   ├── +page.svelte        # All objectives list
│       │   └── [id]/+page.svelte   # Objective detail (task pipeline, review actions)
│       ├── tasks/+page.svelte      # My tasks (kanban board + list views)
│       ├── team/
│       │   ├── +page.svelte        # Team roster + hierarchy views
│       │   └── [id]/+page.svelte   # Soldier profile (stats, tasks, bounties)
│       ├── review/+page.svelte     # Commander review (merge/reject objectives)
│       └── settings/+page.svelte   # User switcher for testing + role capabilities
├── static/favicon.svg
├── svelte.config.js
├── vite.config.ts
├── tsconfig.json
└── package.json
```

## Pages

### Dashboard (`/`)
- Welcome card with rank, XP progress to next rank, specialty
- Stat cards (active bounties, pending reviews)
- My active tasks list with priority indicators
- Activity feed (recent events across the DAO)
- Active bounties overview with progress bars
- Online team members

### Bounties (`/bounties`)
- Filterable list by status (All/Active/In Progress/Draft/Completed)
- Search by title or skill tags
- Each card shows: title, description, creator, VGRD amount, objective count, deadline, skill tags, progress
- Objective summary bar at bottom of each card

### Bounty Detail (`/bounties/[id]`)
- Full bounty header with creator, VGRD allocation, stats, skill tags
- Progress card with task breakdown (approved/submitted/in progress)
- Three tabs: Objectives, All Tasks, Contributors
- Objectives tab: PR-style cards with status icons, assignee, unit, task pills
- Contributors tab: grid cards linking to soldier profiles

### Objectives (`/objectives`)
- All objectives across all bounties
- Status filter tabs
- PR-style list with status icon (○ open, ◐ in progress, ◑ in review, ● merged)
- Checkout button for unassigned objectives

### Objective Detail (`/objectives/[id]`)
- Breadcrumb navigation back to parent bounty
- Full description, assignee, unit, VGRD allocation, deadline
- Progress circle with task counts
- Action buttons (Checkout / Submit for Review / Awaiting Review / Merged)
- Task pipeline with priority, status, assignee, reward, deadline

### Tasks (`/tasks`)
- Toggle: My Tasks / All Tasks
- **Kanban board** (My Tasks): 4 columns — To Do, In Progress, Submitted, Done
- **List view**: Filterable by status, shows bounty/objective breadcrumbs
- Each task card: priority dot, title, bounty reference, VGRD reward, deadline, action buttons

### Team (`/team`)
- **Roster view**: Grouped by tier (Officers / NCOs / Enlisted) with gold/silver/bronze styling
- Each card: avatar, rank badge, specialty, stats (tasks, VGRD, XP)
- **Hierarchy view**: Nested unit tree (Company → Platoon → Section → Squad)
- Shows leader at each level, member badges with online indicators

### Soldier Profile (`/team/[id]`)
- Full profile header with rank-colored border
- XP progress bar to next rank
- Stats card: tasks completed, VGRD earned, voting power, multiplier
- Assigned tasks list
- Contributing bounties sidebar

### Commander Review (`/review`)
- Two tabs: Objectives to Merge / Task Submissions
- **Objectives tab**: Expandable cards showing all tasks, submission hashes, review textarea, Merge/Request Changes buttons
- **Task Submissions tab**: Individual task review with description, submission proof, Approve/Reject buttons
- Pending count badges

## Design System

### Color Tokens
| Token | Hex | Usage |
|-------|-----|-------|
| `vanguard-bg` | `#06080f` | Page background |
| `vanguard-surface` | `#0c1017` | Card backgrounds |
| `vanguard-surface-2` | `#121620` | Hover states, nested surfaces |
| `vanguard-surface-3` | `#1a1f2e` | Tertiary surfaces |
| `vanguard-border` | `#1e2536` | Default borders |
| `vanguard-cyan` | `#06b6d4` | Primary accent (system actions) |
| `vanguard-gold` | `#fbbf24` | Officers, XP, VGRD amounts |

### Rank Tier Colors
- **Officer (CPT, 1LT, 2LT)**: Gold `#fbbf24`
- **NCO (SGT, SSG, SFC, 1SG)**: Silver `#94a3b8`
- **Enlisted (PVT, PV2, PFC, CPL)**: Bronze `#a17c5a`

### Status Colors
- Open/Active: Cyan
- In Progress: Amber
- In Review/Submitted: Purple
- Merged/Approved/Completed: Emerald
- Blocked/Rejected/Cancelled: Red
- Draft/Closed: Zinc

## Mock Data Summary

The app ships with realistic mock data simulating an **investment banking team**:

### 8 Soldiers
| Callsign | Rank | Specialty | Online |
|----------|------|-----------|--------|
| IRONFORGE | CPT | Deal Structuring | Yes |
| NIGHTHAWK | 1LT | M&A Advisory | Yes |
| VIPER | SSG | Financial Modeling | No |
| PHOENIX | SGT | Due Diligence | Yes |
| SPECTER | CPL | Market Research | Yes |
| RAVEN | PFC | Pitch Decks | No |
| WRAITH | SGT | Valuation | Yes |
| SENTINEL | PV2 | Data Analysis | Yes |

### 4 Bounties
1. **Series B Due Diligence — TechCorp Acquisition** (50K VGRD, In Progress)
2. **DeFi Protocol Tokenomics Audit** (30K VGRD, Active)
3. **DAO Treasury Diversification Strategy** (25K VGRD, Active)
4. **Cross-Chain Bridge Security Assessment** (40K VGRD, Draft)

### 6 Objectives across bounties with 12 Tasks

### 7 Units (1 Company → 1 Platoon → 2 Sections → 3 Squads)

### Current User: PHOENIX (SGT) — for demo perspective

## Running the Project

```bash
cd vanguard-ui
npm install
npm run dev     # Development server at http://localhost:5173
npm run build   # Production build
npm run preview # Preview production build
```

## Next Steps (V2)

### Connect to Firebase Backend
- Replace `mock-data.ts` with Firestore real-time subscriptions
- Use existing `army_service.dart` patterns adapted for JS/TS
- Firebase Auth integration (wallet-based)

### Connect to Smart Contracts
- Web3 wallet connection (MetaMask / WalletConnect)
- Read bounty/task data from `TaskRegistry.sol` and `BountyEscrow.sol`
- VGRD token balance from `VGRDToken.sol`
- Rank verification from `RankManager.sol`

### UI Enhancements
- Command palette (⌘K) for quick navigation
- Real-time activity feed via Firestore streams
- Notifications system
- Bounty/Objective/Task creation forms with validation
- IPFS file upload for task submissions
- Drag-and-drop kanban board
- Unit hierarchy graph visualization (port `graphview` logic)
- Dark/light theme toggle
- Responsive mobile layout
- Keyboard shortcuts throughout

### Workflow Enhancements
- Objective diff view (before/after merge)
- Task comments and discussion threads
- Inline code/document review
- Bounty templates for common deal types
- Automated task assignment based on soldier specialty
- Deadline alerts and overdue escalation
- VGRD staking for bounty creation

### Governance
- Proposal creation and voting UI
- Treasury overview dashboard
- Token distribution visualization
- Governance analytics

## Architecture Decisions

1. **Svelte 5 runes over Svelte stores**: Class-based reactive state (`$state`, `$derived`) is more ergonomic and performant than writable/readable stores. The `AppStore` class is a single source of truth.

2. **No component library dependency**: All components are custom-built with Tailwind. Keeps the bundle small and fully customizable. Components follow the design system precisely.

3. **Mock data as module**: `mock-data.ts` is a separate module from the store. When connecting to Firebase, only the store initialization changes — components don't change at all.

4. **Unicode icons over icon library**: Saves ~50KB+ of bundle size. The cyberpunk aesthetic actually benefits from geometric Unicode glyphs (◈ ⎇ ▸ ⬡).

5. **Path aliases**: `$lib`, `$components`, `$stores`, `$types` — keeps imports clean and refactoring-safe.

6. **Type system mirrors Dart models**: The TypeScript types in `types/index.ts` are structurally identical to the Flutter/Dart models in `lib/core/models/`. This ensures consistency when connecting to the shared Firebase backend.

## Workflow Audit

### Complete Workflows (end-to-end paths exist)

| # | Workflow | Path |
|---|----------|------|
| 1 | Commander creates bounty | `/bounties` → `+ New Bounty` → `/bounties/new` → form → redirects to `/bounties/[id]` |
| 2 | Browse and filter bounties | `/bounties` → status filters + search → click card → `/bounties/[id]` |
| 3 | View bounty detail with objectives | `/bounties/[id]` → Objectives/Tasks/Contributors tabs |
| 4 | View all objectives across bounties | `/objectives` → status filters → click → `/objectives/[id]` |
| 5 | View objective detail with tasks | `/objectives/[id]` → task pipeline, progress, actions |
| 6 | Checkout an objective (claim for unit) | `/objectives/[id]` → "Checkout Objective" button |
| 7 | Submit objective for review | `/objectives/[id]` → "Submit for Review" button |
| 8 | View my tasks in kanban board | `/tasks` → Board view (4 columns) |
| 9 | View my tasks in list | `/tasks` → List view with filters |
| 10 | View all tasks across all bounties | `/tasks` → "All Tasks" toggle |
| 11 | Start / Submit a task | Task cards have "Start →" and "Submit →" action buttons |
| 12 | Commander reviews submitted objectives | `/review` → Objectives tab → expand → Merge / Request Changes |
| 13 | Commander approves individual tasks | `/review` → Tasks tab → Approve / Reject buttons |
| 14 | View team roster by rank tier | `/team` → Roster view (Officers/NCOs/Enlisted groups) |
| 15 | View unit hierarchy | `/team` → Hierarchy view (Company → Platoon → Section → Squad tree) |
| 16 | View soldier profile | `/team/[id]` → full profile with stats, tasks, contributing bounties |
| 17 | View dashboard overview | `/` → welcome card, stats, active tasks, activity feed, bounties, online team |
| 18 | Switch active user for testing | `/settings` → click any soldier to switch perspective |
| 19 | View XP progress to next rank | Dashboard + soldier profile show XP bar |

### Partially Implemented (buttons exist, need backend connection)

| Feature | Current State | V2 Action |
|---------|--------------|-----------|
| Task assignment | "Assign" button shown, no modal | Add assignment modal/dropdown |
| Add task to objective | "Add Task" button shown | Add task creation form |
| Task submission with IPFS | "Submit" button shown | Add file upload + IPFS integration |
| Objective creation | Can be done from bounty detail in V2 | Add objective creation form |
| Soldier promotion | Visible on team page | Add promote action for authorized ranks |

### Not Yet Implemented (V2+)

| Feature | Priority | Notes |
|---------|----------|-------|
| Comms (chat) | Medium | Mobile app has full chat — port to web |
| Intel (analytics) | Medium | Leaderboards, earnings charts, completion metrics |
| Notifications | Medium | In-app notifications for task assignments, reviews |
| Command palette (Cmd+K) | Low | Quick navigation search |
| IPFS file upload | High | Required for task submission proof |
| Wallet connection | High | MetaMask / WalletConnect integration |
| Real-time updates | High | Firestore subscriptions replace mock data |

## Consistency with Mobile App (MISSION_CONTROL_ARMY_UX_DESIGN_2.md)

### Verified Consistent
- **Ranks**: Same 11 ranks (PVT → CPT), same voting power and multiplier values
- **Unit hierarchy**: Squad (2-10) → Section (10-25) → Platoon (20-50) → Company (40-100)
- **Work hierarchy**: Bounty → Objective → Task
- **Task states**: Created → Assigned → In Progress → Blocked/Submitted → Completed
- **Color system**: Dark base, cyan accent, gold for officers, silver for NCOs, bronze for enlisted
- **Design language**: Cyberpunk dark theme, "Cyber Command" aesthetic

### Token Symbol
- Mobile app UX doc uses **VLTC** (legacy)
- Smart contracts use **VGRD** (canonical)
- Web UI uses **VGRD** (correct — follows smart contracts)
- **Action**: Update mobile app to use VGRD when syncing

### Mobile-Only Screens to Port Later
- **Comms**: Full chat system with channels per unit level
- **Intel**: Analytics dashboard with leaderboards, earnings charts, promotion progress
- **Guest Landing**: Onboarding flow for new users
- **Network Graph**: Force-directed visualization of army structure
