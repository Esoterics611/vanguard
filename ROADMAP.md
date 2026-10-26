# Vanguard DAO — Roadmap

> Current priorities, status and open decisions live in [WORKPLAN.md](WORKPLAN.md). This file is the earlier roadmap, kept for reference.

> Last updated: 2026-10-17

## Where we are

| Component | Status | Deployed |
|---|---|---|
| **Smart Contracts** (8 Solidity, engine + Vanguard vertical) | Done, source verified | Base Sepolia, 27 Apr 2026 |
| **Bounty lifecycle on chain** | Proven end to end: enlist, promote, escrow, tasks, approval, payout | Live run 16 Oct 2026 ([record](contracts/demo/run.json)) |
| **Web UI** (SvelteKit + Svelte 5) | 10 pages; team roster reads the live ArmyRegistry, other pages on mock data | No |
| **Backend** (Firebase Functions) | 6 functions, emulator-tested | No |
| **Protocol guide** (MkDocs) | Done, addresses current | No |
| **Landing Site** (static HTML) | Done | No |
| **Flutter App** | Models + theme defined | No |

Contracts are live and exercised. The web app, backend and site work locally but are not yet deployed or connected end to end.

---

## Phase 1 — Clean up & deploy what exists

Goal: get a working URL people can visit.

### 1.1 Repo hygiene
- [ ] Fix `.gitignore` — stop excluding `docs/`, add `node_modules/`, contract artifacts, Firebase emulator logs
- [ ] Delete junk files (`nul`, `firestore-debug.log`, stale `build/`)
- [ ] Move Flutter-specific files (`pubspec.yaml`, `analysis_options.yaml`, `lib/`, `android/`, `ios/`, `web/`, `test/`) into `app/` subdirectory (or keep at root — decide)
- [ ] Organize `docs/` — separate specs, prompts, marketing, generated assets
- [ ] Write a real top-level `README.md` with project overview and getting-started
- [ ] First real git commit with clean history

### 1.2 Deploy backend
- [ ] `firebase deploy --only functions` — get cloud functions live
- [ ] `firebase deploy --only firestore:rules` — push security rules
- [ ] Seed Firestore with callsign words + demo data
- [ ] Verify `quickStart` function works from cloud (not just emulator)

### 1.3 Deploy web UI
- [ ] Pick host: Vercel (easiest for SvelteKit) or Firebase Hosting
- [ ] Set up deploy pipeline (push to deploy)
- [ ] Get a working URL: `vanguard-dao.vercel.app` or similar
- [ ] Landing site can go on same host or a subdomain

---

## Phase 2 — Connect the dots

Goal: replace mock data with real backend, add auth.

### 2.1 Onboarding (keep it dead simple)
- [ ] "Enter" button on landing site → web UI
- [ ] Web UI login: wallet connect OR email (Firebase Auth)
- [ ] On first login, call `quickStart` → auto-enlist, assign callsign, join default squad
- [ ] User lands on dashboard with their real data — done in 2 clicks

### 2.2 Wire web UI to Firebase
- [ ] Add Firebase SDK to SvelteKit app
- [ ] Replace mock soldiers/units with Firestore reads
- [ ] Replace mock bounties/tasks with Firestore reads
- [ ] Wire up create/update forms to cloud functions
- [ ] Real-time listeners for dashboard updates

### 2.3 Wire web UI to contracts (read-only first)
- [ ] Add ethers.js / viem to web UI
- [ ] Read VGRD balance from contract
- [ ] Read rank from RankManager
- [ ] Display on-chain data alongside Firestore data

---

## Phase 3 — Core workflows

Goal: people can actually do things.

### 3.1 Bounty lifecycle
- [ ] Create bounty (officer) → writes to Firestore + BountyEscrow contract
- [ ] Create objectives under bounty
- [ ] Assign tasks to soldiers
- [ ] Submit work (IPFS upload or link)
- [ ] Review & approve (commander) → triggers reward distribution

### 3.2 Rank & promotion
- [ ] Display rank progression in profile
- [ ] Promotion flow: nominate → review → execute on-chain via RankManager
- [ ] Rank-weighted voting on proposals

### 3.3 Team management
- [ ] Squad creation and join flow
- [ ] Squad split at 11 members (auto via `splitSquad` function)
- [ ] Unit hierarchy visualization

---

## Phase 4 — Polish & expand

### 4.1 Missing pages
- [ ] Comms (chat) — per-unit channels, Firestore-backed
- [ ] Intel (analytics) — activity metrics, token flow, rank distribution

### 4.2 Contract event indexer
- [ ] Listen to on-chain events (transfers, promotions, bounty completions)
- [ ] Sync to Firestore for fast queries
- [ ] Options: custom indexer, The Graph subgraph, or Alchemy webhooks

### 4.3 Mobile app (if needed)
- [ ] Flutter app connects to same Firebase backend
- [ ] Shares Firestore data with web UI
- [ ] Wallet integration via WalletConnect

### 4.4 Mainnet
- [ ] Audit contracts
- [ ] Deploy to Base mainnet
- [ ] Update all contract addresses in config

---

## Repo organization (proposed)

```
vanguard/
├── README.md              # Project overview, getting started
├── ROADMAP.md             # This file
├── .gitignore             # Proper ignores for all sub-projects
├── firebase.json          # Firebase config (functions, hosting, firestore)
├── .firebaserc
├── firestore.rules
├── firestore.indexes.json
│
├── contracts/             # Solidity smart contracts (Hardhat)
│   ├── contracts/
│   ├── scripts/
│   ├── test/
│   ├── hardhat.config.ts
│   ├── deployed-addresses.json
│   └── README.md
│
├── backend/               # Firebase Cloud Functions (TypeScript)
│   └── functions/
│       ├── src/
│       ├── package.json
│       └── tsconfig.json
│
├── vanguard-ui/           # Web app (SvelteKit 2 + Svelte 5)
│   ├── src/
│   ├── package.json
│   └── README.md
│
├── vanguard-site/         # Landing/marketing site (static HTML)
│   └── index.html
│
├── app/                   # Flutter mobile app (optional, move later)
│   ├── lib/
│   ├── android/
│   ├── ios/
│   ├── web/
│   ├── pubspec.yaml
│   └── test/
│
└── docs/                  # Documentation
    ├── specs/             # Technical specs (contracts, UX, business)
    ├── guides/            # Training manual, quickref, handbook
    ├── prompts/           # Claude Code prompts used to build this
    └── assets/            # PDFs, images, generated marketing
```

---

## Decisions to make

1. **Where to deploy web UI?** Vercel (zero-config SvelteKit) vs Firebase Hosting (keeps everything in one place)
2. **Move Flutter app into `app/` subdirectory?** Keeps root clean but changes all Flutter paths. Could also just leave it at root since it was the original project.
3. **Auth strategy for web UI?** Firebase Auth only (email/Google) → simple. Or wallet-first → more crypto-native but harder onboarding. Or both with wallet optional.
4. **Do you need the Flutter app soon?** Web UI is further along. Could focus entirely on web and revisit mobile later.
