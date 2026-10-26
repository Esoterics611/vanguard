# Vanguard DAO

[![Contract tests](https://github.com/Esoterics611/vanguard/actions/workflows/test.yml/badge.svg)](https://github.com/Esoterics611/vanguard/actions/workflows/test.yml)

**A DAO that runs like a disciplined firm.** Members hold ranks, work is posted as funded bounties, and pay follows rank and delivered work, all enforced on chain. Vanguard is the coordination layer for teams that need to ship, not just vote.

| | |
|---|---|
| **Network** | Base Sepolia (chain 84532) |
| **Contracts** | 8 deployed 27 Apr 2026, all source verified on Blockscout |
| **Proven end to end** | A full bounty ran on the live contracts in 21 transactions ([record](contracts/demo/run.json)) |
| **Academy** | [esoterics611.github.io/vanguard](https://esoterics611.github.io/vanguard/): cohort onboarding; [try the demo](https://esoterics611.github.io/vanguard/join?demo=1) with a simulated wallet |
| **Live view** | [esoterics611.github.io/vanguard/live](https://esoterics611.github.io/vanguard/live/) reads the contracts in your browser |
| **Tests** | 15 passing (`contracts/`) |
| **Token** | VGRD, 1 billion supply, rank-weighted governance |

## How it works

```
 Member enlists ──► ArmyRegistry (squad, rank, callsign)
                         │
 Command posts bounty ──► BountyEscrow (VGRD locked)
                         │
 Leader splits it ──────► TaskRegistry (objective → tasks → assignees)
                         │
 Member submits work ───► TaskRegistry (deliverable fingerprint on chain)
                         │
 Leader approves ───────► RewardPool pays base reward × rank multiplier
                         │
 Escrow releases ───────► bounty closes; RankManager promotes on record
```

Governance runs through **VanguardDAO**: votes are weighted by VGRD held and by rank, and each vote carries a signed rank attestation so nobody can claim a rank they do not hold.

## The live run

On 16 Oct 2026, [`contracts/scripts/demo.js`](contracts/scripts/demo.js) drove one bounty through the live contracts:

1. Two fresh analyst wallets enlist in Alpha Squad; command promotes analyst B to Private First Class (1.5× pay).
2. A 2,000 VGRD due-diligence bounty is locked in escrow and split into two tasks: a smart-contract audit and a tokenomics review.
3. Each analyst submits a fingerprint of their memo on chain.
4. The leader approves both: analyst A is paid **1,000 VGRD** (1.0×), analyst B **1,500 VGRD** (1.5×).
5. The escrow releases and the bounty closes.

The run exposed a real wiring gap (the reward pool could not record completed tasks in the registry), which was fixed on chain mid-run and is part of the record. The script is resumable and can rehearse on a local fork first; see [deployment notes](vanguard-docs/docs/developer-guide/deployment.md).

## Live contracts (Base Sepolia)

| Contract | Role | Address |
|---|---|---|
| VGRDToken | Governance and reward token | [`0x2Ef7…7493`](https://base-sepolia.blockscout.com/address/0x2Ef78A107b20eb4263448e70E643bA9621657493?tab=contract) |
| Treasury | DAO reserve | [`0x55B8…1d54`](https://base-sepolia.blockscout.com/address/0x55B811D87CFBbb149ea436BD5F57671602D91d54?tab=contract) |
| ArmyRegistry | Members, squads, ranks | [`0xBf3B…F270`](https://base-sepolia.blockscout.com/address/0xBf3BEE33090fb5f9b147a72cAac6f4f44CE1F270?tab=contract) |
| RankManager | Promotions and pay multipliers | [`0xcbB1…c0f2`](https://base-sepolia.blockscout.com/address/0xcbB1fB5E862D7e339619B55fE2E58dA6f35bc0f2?tab=contract) |
| RewardPool | Pays approved work | [`0x840E…429C`](https://base-sepolia.blockscout.com/address/0x840E56bAA0774b41eec0448F81a802281799429C?tab=contract) |
| TaskRegistry | Objectives, tasks, submissions | [`0xd583…7e5A`](https://base-sepolia.blockscout.com/address/0xd5832E767C76FbCBbee6F071b80B7F78Ad5F7e5A?tab=contract) |
| BountyEscrow | Locks and releases bounty funds | [`0x19F1…B143`](https://base-sepolia.blockscout.com/address/0x19F1A7F9d4A3d36BEAF2e4fb5A5E42F3f080B143?tab=contract) |
| VanguardDAO | Rank-weighted proposals and votes | [`0x1F6F…A7Af`](https://base-sepolia.blockscout.com/address/0x1F6FB4dB93691747420d0fb9d397E4f97443A7Af?tab=contract) |

The contracts are built as a reusable **engine** (`contracts/contracts/base/`: registry, treasury, governance) with Vanguard as one vertical on top, so another organisation can reuse the engine with its own ranks and rules.

## Repository

```
vanguard/
├── contracts/       Solidity engine + Vanguard vertical, tests, deploy and demo scripts
├── vanguard-ui/     Academy web app (SvelteKit 2, Svelte 5, Tailwind v4), built as a static site
├── backend/         Firebase Cloud Functions (TypeScript): applications, members, units, promotions
├── vanguard-docs/   Protocol guide (MkDocs): concepts, contract reference, integration
├── vanguard-site/   Landing page
├── lib/             Flutter mobile app (early stage)
└── docs/            Specifications and training material
```

## Run it locally

```bash
# contracts
cd contracts && npm install && npx hardhat test

# web app
cd vanguard-ui && npm install && npm run dev          # http://localhost:5173/join?demo=1

# backend (Firebase emulators)
cd backend/functions && npm install && cd ../.. && firebase emulators:start

# protocol guide
pip install mkdocs-material && mkdocs serve -f vanguard-docs/mkdocs.yml
```

## Documentation

- [Protocol guide](vanguard-docs/docs/index.md) — how ranks, bounties, rewards and governance work, with a reference page per contract
- [`docs/specs/`](docs/specs/) — contract specification, UX design, business overview, capital markets
- [`docs/guides/`](docs/guides/) — DAO investment-banking handbook and training manual
- [ROADMAP.md](ROADMAP.md) — status and next steps

## Status

Testnet only and not audited. Admin roles are held by a single deployer key today; moving them to a 2-of-3 Safe multisig is the next operational step.
