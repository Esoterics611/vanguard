# Token Vertical Deployment — Vanguard on Base Sepolia

**Status:** live · **Date deployed:** 2026-04-27 · **Network:** Base Sepolia (chain id 84532)

This doc replaces the obsolete `contracts/DEPLOYED_CONTRACTS.md` and `contracts/VANGUARD_TESTNET_SUMMARY.md` (archived under `contracts/docs/`). It is the canonical reference for the current Vanguard testnet deployment and the engine + verticals architecture it sits inside.

---

## 1. The new approach: engine + verticals

Vanguard is no longer a single product. After the 2026-04-26 refactor (commit `5607cf4`) the codebase is split into:

| Layer | What it is | Where it lives |
|---|---|---|
| **Engine** | Rank-agnostic base contracts: `BaseGovernance`, `BaseRegistry`, `BaseTreasury`. Implement EIP-712 rank-attestation voting, soldier/unit registry, treasury & streaming. | `contracts/contracts/base/` |
| **Vertical** | A concrete deployment that picks a rank schema, token, and theme on top of the engine. | `contracts/contracts/*.sol`, `vanguard-ui/`, `chayolei/`, etc. |

Each vertical re-uses the engine and ships its own:
- token (e.g. **VGRD** for Vanguard, **TMIM** for Chayolei),
- rank enum + multiplier table (Vanguard: 12 slots GUEST..CPT, multipliers 1.0x..12.0x),
- registry/dao concrete contracts that extend the base,
- UI app and Firebase schema.

**Why this matters:** spinning up a new vertical now means writing a new concrete contract trio (Token / Registry / DAO) + UI theme — not forking the whole protocol. Chayolei is already shipped as a separate vertical and is several specs ahead of Vanguard.

---

## 2. Vanguard vertical — what's deployed

All 8 contracts deployed in a single run on 2026-04-27 from deployer `0x41521c37dB02956185437C4e2461261A321073E1`. Initial wiring (roles, registrations, token transfers) was completed in the same script.

### Addresses (Base Sepolia)

| Contract | Address | Role |
|---|---|---|
| **VGRDToken** | [`0x2Ef78A107b20eb4263448e70E643bA9621657493`](https://sepolia.basescan.org/address/0x2Ef78A107b20eb4263448e70E643bA9621657493) | ERC-20 + Permit, 1B supply |
| **Treasury** | [`0x55B811D87CFBbb149ea436BD5F57671602D91d54`](https://sepolia.basescan.org/address/0x55B811D87CFBbb149ea436BD5F57671602D91d54) | Vertical treasury (extends `BaseTreasury`) |
| **ArmyRegistry** | [`0xBf3BEE33090fb5f9b147a72cAac6f4f44CE1F270`](https://sepolia.basescan.org/address/0xBf3BEE33090fb5f9b147a72cAac6f4f44CE1F270) | Soldiers + units (extends `BaseRegistry`) |
| **RankManager** | [`0xcbB1fB5E862D7e339619B55fE2E58dA6f35bc0f2`](https://sepolia.basescan.org/address/0xcbB1fB5E862D7e339619B55fE2E58dA6f35bc0f2) | Promotions, reward multipliers |
| **RewardPool** | [`0x840E56bAA0774b41eec0448F81a802281799429C`](https://sepolia.basescan.org/address/0x840E56bAA0774b41eec0448F81a802281799429C) | Distributes task rewards by rank |
| **TaskRegistry** | [`0xd5832E767C76FbCBbee6F071b80B7F78Ad5F7e5A`](https://sepolia.basescan.org/address/0xd5832E767C76FbCBbee6F071b80B7F78Ad5F7e5A) | Objectives + tasks |
| **BountyEscrow** | [`0x19F1A7F9d4A3d36BEAF2e4fb5A5E42F3f080B143`](https://sepolia.basescan.org/address/0x19F1A7F9d4A3d36BEAF2e4fb5A5E42F3f080B143) | Holds bounty funds, releases on completion |
| **VanguardDAO** | [`0x1F6FB4dB93691747420d0fb9d397E4f97443A7Af`](https://sepolia.basescan.org/address/0x1F6FB4dB93691747420d0fb9d397E4f97443A7Af) | Governance (extends `BaseGovernance`, EIP-712 rank attestation) |

Machine-readable copy: `contracts/deployed/base-sepolia.json`. Frontend copy: `vanguard-ui/src/lib/contracts/addresses.ts`.

### Token distribution (1B VGRD)

| Allocation | Amount | Destination |
|---|---|---|
| RewardPool | 400,000,000 (40%) | RewardPool contract |
| Treasury | 250,000,000 (25%) | Treasury contract |
| Deployer (team / liquidity) | 350,000,000 (35%) | Deployer EOA |

### Post-deploy wiring

The deploy script ran these txs after deployment — all landed first try:

1. `VGRDToken.MINTER_ROLE` → RewardPool
2. `ArmyRegistry.RANK_MANAGER_ROLE` → RankManager
3. `TaskRegistry.setRewardPool(RewardPool)`
4. `RewardPool.DISTRIBUTOR_ROLE` → TaskRegistry
5. `BountyEscrow.setTaskRegistry(TaskRegistry)`
6. `BountyEscrow.setRewardPool(RewardPool)`
7. `ArmyRegistry.ADMIN_ROLE` → TaskRegistry
8. Transfer 400M VGRD → RewardPool
9. Transfer 250M VGRD → Treasury

---

## 3. Firebase integration approach

Decision: **public Base Sepolia is the shared environment.** Firebase will be wired to read from these contracts directly — no separate dev/staging chain.

Pattern (mirroring Chayolei):

- **Source of truth** — on-chain registry + token + DAO state.
- **Cache** — Firestore stores soldier/unit/task projections for fast reads in the UI; updated by an event indexer.
- **Backend signer** — a Cloud Function holds the **attestation signer** key. When a wallet wants to vote in `VanguardDAO`, the backend reads the voter's rank from `ArmyRegistry`, signs an EIP-712 `RankAttestation`, and the contract verifies the signature on `castVote`.

Currently the attestation signer is set to the **deployer address**. This is deliberately temporary — see "Next session" below.

---

## 4. What's stable, what's not

- **Stable:** all 15 hardhat tests pass against the engine (`Engine: VanguardDAO + ArmyRegistry`, `Engine: Treasury`). Constructor signatures and post-deploy wiring match the script and tests.
- **Not yet verified on Basescan.** Skipped this session — no `BASESCAN_API_KEY` in `.env`. Source code is not yet visible on the explorer.
- **Known multiplier mismatch.** `VanguardDAO.rankMultipliersBps[CPT] = 1200` (12.0x voting weight) vs. `RankManager.MULTIPLIERS[CPT] = 1500` (15.0x reward). These are intentionally separate concerns (voting vs. payout) but the values diverge. Decide if both should align before mainnet.
- **No Basescan-verified ABIs in `vanguard-ui/`** — the UI copies ABIs from `contracts/artifacts/` at build time; that path still works.

---

## 5. Session log — 2026-04-27

**Goal:** ship the Vanguard vertical onto public Base Sepolia and prepare for Firebase wiring.

**Done:**
- Confirmed engine refactor (`contracts/contracts/base/`) compiles and 15/15 hardhat tests pass.
- Updated `contracts/scripts/deploy.ts` to emit `deployed/base-sepolia.json` (kebab-case) instead of `baseSepolia.json`.
- Deployed all 8 contracts + 7 wiring txs + 2 token transfers in one run. No retries needed.
- Wrote new addresses into `vanguard-ui/src/lib/contracts/addresses.ts`.
- Archived stale docs (`DEPLOYED_CONTRACTS.md`, `VANGUARD_TESTNET_SUMMARY.md`, `deployed-addresses.json`) into `contracts/docs/`.

**Skipped (blocked):**
- Basescan source verification — no API key configured.

**Open repo hygiene:**
- `contracts/.env` contains a plaintext `PRIVATE_KEY`. It's a Base Sepolia test wallet, but it's checked into the repo — rotate before mainnet and add `.env` to `.gitignore`.
- `docs/CONTRACTS_GUIDE.md` still references the old (Feb 2026) addresses and old verification commands. Needs a refresh.

---

## 6. Next session — things to do

In rough priority order:

1. **Wire Firebase to Base Sepolia.**
   - Add the new addresses to the Cloud Functions config (`firebase functions:config:set`) or a versioned config file.
   - Stand up an event indexer that listens on `ArmyRegistry`, `TaskRegistry`, `RewardPool`, `VanguardDAO` and writes Firestore projections.
   - Add the contracts.svelte.ts wiring in `vanguard-ui/` so the AppStore reads from chain instead of `mock-data.ts`.

2. **Stand up a separate attestation signer.**
   - Generate a fresh key, store in Firebase Functions secrets.
   - Call `dao.setAttestationSigner(newSigner)` from the deployer.
   - Document the signer rotation procedure.

3. **Get a Basescan API key and verify all 8 contracts.** Verification commands exist in the old `contracts/docs/DEPLOYED_CONTRACTS.md` — same shape, just sub in the new addresses. (Or write a `verify.ts` script that reads `deployed/base-sepolia.json`.)

4. **Refresh `docs/CONTRACTS_GUIDE.md`** — addresses, the engine + verticals framing, and the verification command list.

5. **Resolve the CPT multiplier mismatch** (12x voting in `VanguardDAO` vs 15x reward in `RankManager`). Either align values or add a comment explaining the intentional split.

6. **Rotate the deployer key** and remove `PRIVATE_KEY` from the committed `.env`. Add `.env` to `.gitignore` if it isn't already.

7. **Smoke-test the UI end-to-end** against the new deployment: connect wallet, enlist, see roster, post a bounty, vote on a proposal.

---

## 7. How to redeploy (runbook)

```bash
cd contracts/

# 1. Sanity check: all tests green on local hardhat
npx hardhat test

# 2. Deploy + wire + initial distribution
npx hardhat run scripts/deploy.ts --network baseSepolia
# → writes contracts/deployed/base-sepolia.json

# 3. (When BASESCAN_API_KEY is set) verify each contract
#    See section 3 of the archived contracts/docs/DEPLOYED_CONTRACTS.md
#    for the constructor-arg pattern.

# 4. Copy addresses into the UI
#    Edit vanguard-ui/src/lib/contracts/addresses.ts
```

The deploy script is idempotent in the sense that re-running it deploys *new* instances — it does not reuse existing addresses. Treat each run as a fresh deployment.
