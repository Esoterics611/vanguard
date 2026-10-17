# Vanguard DAO — Command Center Web UI

A web-based coordination platform for decentralized investment banking teams. Built with **SvelteKit 2**, **Svelte 5**, and **Tailwind CSS v4**.

## Quick Start

```bash
cd vanguard-ui
npm install
npm run dev
```

Open [http://localhost:5173](http://localhost:5173)

## Navigation

| Page | URL | Description |
|------|-----|-------------|
| Dashboard | `/` | Personal overview: stats, tasks, activity feed, team status |
| Bounties | `/bounties` | Browse and filter all deals/engagements |
| Bounty Detail | `/bounties/[id]` | Objectives, tasks, and contributors for a bounty |
| Create Bounty | `/bounties/new` | Create a new bounty (officer rank required) |
| Objectives | `/objectives` | All workstreams across bounties (like PRs) |
| Objective Detail | `/objectives/[id]` | Task pipeline, progress, checkout/review actions |
| Tasks | `/tasks` | Kanban board + list view of your assigned work |
| Team | `/team` | Roster (by rank tier) and hierarchy (org chart) views |
| Soldier Profile | `/team/[id]` | Individual stats, tasks, contributing bounties |
| Commander Review | `/review` | Merge/reject objectives and approve task submissions |
| Settings | `/settings` | Switch active user to test different role perspectives |

## Testing Different Roles

Go to **Settings** (`/settings`) to switch between users. Each role has different capabilities:

| Role | Ranks | Can Do |
|------|-------|--------|
| **Officer** | 2LT, 1LT, CPT | Create bounties, review/merge work, promote soldiers |
| **NCO** | SGT, SSG, SFC, 1SG | Lead units, checkout objectives, assign tasks |
| **Enlisted** | PVT, PV2, PFC, CPL | Execute tasks, submit work, earn XP and VGRD |

### Recommended Test Flow

1. **Start as PHOENIX (SGT)** — default user. View dashboard, browse tasks.
2. **Switch to IRONFORGE (CPT)** in Settings. Create a bounty, review submitted objectives.
3. **Switch to SPECTER (CPL)** in Settings. See enlisted perspective, limited actions.
4. **Switch to NIGHTHAWK (1LT)**. View officer dashboard with different task assignments.

## Mock Data

The app ships with realistic data simulating an IB team:

- **8 Soldiers**: From PV2 (Data Analysis) to CPT (Deal Structuring)
- **4 Bounties**: TechCorp acquisition, DeFi audit, treasury strategy, bridge security
- **6 Objectives**: Financial modeling, market analysis, valuation, tokenomics, governance, yield
- **12 Tasks**: Revenue models, DCF, comps, TAM analysis, governance review, etc.
- **7 Units**: Company → Platoon → Sections → Squads

All data is in-memory. Changes (e.g., creating bounties) persist during the session but reset on page refresh.

## Project Structure

```
src/
├── app.html              # HTML shell
├── app.css               # Design system (Tailwind @theme tokens)
├── lib/
│   ├── types/index.ts    # TypeScript type system
│   ├── stores/
│   │   ├── app.svelte.ts # Reactive state (Svelte 5 runes)
│   │   └── mock-data.ts  # Mock data
│   ├── utils/format.ts   # Formatting helpers
│   └── components/       # Shared UI components
│       ├── Sidebar.svelte
│       ├── TopBar.svelte
│       ├── StatusBadge.svelte
│       ├── ProgressBar.svelte
│       ├── RankInsignia.svelte   # SVG military insignia
│       ├── RankBadge.svelte
│       ├── SoldierAvatar.svelte
│       └── EmptyState.svelte
└── routes/               # SvelteKit file-based routing
    ├── +layout.svelte
    ├── +page.svelte         (Dashboard)
    ├── bounties/
    ├── objectives/
    ├── tasks/
    ├── team/
    ├── review/
    └── settings/
```

## Commands

```bash
npm run dev       # Start dev server (http://localhost:5173)
npm run build     # Production build
npm run preview   # Preview production build
npm run check     # TypeScript type checking
```

## Design System

- **Theme**: Cyberpunk dark — deep space black backgrounds, cyan accents
- **Rank colors**: Gold (officers), Silver (NCOs), Bronze (enlisted)
- **Status colors**: Cyan (open), Amber (in progress), Purple (in review), Green (done), Red (blocked)
- **Font**: Inter for body, monospace for data values

## Full Specification

See [VANGUARD_UI_SPEC.md](./VANGUARD_UI_SPEC.md) for complete technical specification, workflow audit, architecture decisions, and V2 roadmap.
