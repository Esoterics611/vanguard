# Vanguard: Gap Analysis & Integration Plan

> Where we are, what's missing, and exactly what to do about it.

## Current State Summary

We have **two halves that don't talk to each other yet:**

| Layer | Status | Details |
|-------|--------|---------|
| **Smart Contracts** | Deployed, wired up, lightly tested | 8 contracts on Base Sepolia. Post-deploy config done. Basic read-only tests pass. No workflow tests. |
| **Web UI** | Fully built, 100% mock data | 11 pages, 8 components, complete mock dataset. Zero blockchain integration. |

**The gap is the bridge between them.** The UI shows fake data. The contracts sit idle. Nothing connects wallet -> contract -> UI state.

---

## Gap Analysis: UI vs Contract Coverage

For each contract workflow, here's what the UI can show today vs what actually works end-to-end.

### Can the user DO this through the UI today?

| Workflow | UI Page Exists? | Shows Data? | Calls Contract? | Verdict |
|----------|----------------|-------------|-----------------|---------|
| **Connect wallet** | No | No | No | GAP |
| **View VGRD balance** | Dashboard (mock) | Mock number | No | GAP |
| **Enlist as soldier** | No | No | No | GAP |
| **View roster/team** | /team | Mock soldiers | No | GAP |
| **View own profile** | /team/[id] | Mock stats | No | GAP |
| **Create objective** | No form | No | No | GAP |
| **Create task** | No form | No | No | GAP |
| **View objectives** | /objectives | Mock list | No | GAP |
| **View tasks** | /tasks | Mock kanban | No | GAP |
| **Assign task** | No button | No | No | GAP |
| **Submit task** | No button | No | No | GAP |
| **Approve/reject task** | /review page (mock) | Mock data | No | GAP |
| **Claim rewards** | No | No | No | GAP |
| **Create bounty** | /bounties/new (form) | Form exists | No | PARTIAL |
| **View bounties** | /bounties | Mock list | No | GAP |
| **Fund bounty** | No | No | No | GAP |
| **Promote soldier** | No | No | No | GAP |
| **Create DAO proposal** | No | No | No | GAP |
| **Vote on proposal** | No | No | No | GAP |
| **Treasury streams** | No | No | No | GAP |

**Score: 0/20 workflows work end-to-end. 1 partial (bounty creation form exists but doesn't submit).**

---

## Gap Categories

### Gap 1: No Web3 Foundation (blocks everything else)

The UI has zero blockchain dependencies. No ethers.js, no wallet connection, no provider, no ABI files. This must be built first.

**What's needed:**
- Install a web3 library (ethers.js v6 recommended — matches the contracts/Hardhat setup)
- Wallet connection flow (MetaMask / WalletConnect)
- Contract instance factory (load ABIs + addresses, create typed contract objects)
- Transaction state management (pending/confirmed/failed)
- Network switching (detect wrong network, prompt to switch to Base Sepolia)

### Gap 2: No Contract ABIs in the UI

The compiled ABIs live in `contracts/artifacts/` but aren't copied to or imported by the UI. The UI needs them to call contract functions.

### Gap 3: Mock Data Not Mapped to Contract Calls

The UI's mock data structure is close to the contract data structures but not identical. The store (`app.svelte.ts`) needs methods that call contracts instead of reading mock arrays.

### Gap 4: Missing UI for Key Workflows

Several contract workflows have no UI at all:
- Enlistment flow
- Task creation/assignment/submission
- Reward claiming
- Promotions
- DAO governance

### Gap 5: Existing Tests Are Read-Only

The deployed test script only checks that contracts were set up correctly. It doesn't test any of the actual user workflows (create task -> assign -> submit -> approve -> claim reward).

---

## The Plan: 6 Phases

Each phase builds on the previous one. Complete them in order.

---

### Phase 0: Housekeeping (do this first)

**Time: ~1 hour | Difficulty: Easy**

These are quick wins that unblock everything else.

| Step | What to Do | Why |
|------|-----------|-----|
| 0.1 | Get a BaseScan API key from https://basescan.org | Need it to verify contracts |
| 0.2 | Add the key to `contracts/.env` as `BASESCAN_API_KEY=yourkey` | Config |
| 0.3 | Run the 8 verification commands from [CONTRACTS_GUIDE.md](./CONTRACTS_GUIDE.md#verifying-contracts-on-basescan) | Verified contracts let you test via BaseScan's Read/Write UI |
| 0.4 | Run `npm run test:deployed` from `contracts/` to confirm current state | Baseline — make sure nothing broke since Feb |
| 0.5 | Get Base Sepolia ETH from a faucet (search "Base Sepolia faucet") | Need testnet ETH for gas fees |

**Done when:** All 8 contracts show green checkmarks on BaseScan, tests pass, you have testnet ETH.

---

### Phase 1: Web3 Foundation in the UI

**Time: ~1 day | Difficulty: Medium**

Add wallet connection and contract interaction capability to the SvelteKit app.

| Step | What to Do | Files to Create/Edit |
|------|-----------|---------------------|
| 1.1 | Install ethers.js v6: `cd vanguard-ui && npm install ethers` | `package.json` |
| 1.2 | Copy compiled ABIs from `contracts/artifacts/contracts/*.sol/*.json` to `vanguard-ui/src/lib/contracts/abis/` (just the ABI arrays, not full artifacts) | New: `src/lib/contracts/abis/` |
| 1.3 | Create `src/lib/contracts/addresses.ts` — export the deployed addresses object (copy from `deployed-addresses.json`) | New file |
| 1.4 | Create `src/lib/contracts/provider.svelte.ts` — Svelte 5 runes store for wallet state: `account`, `chainId`, `provider`, `signer`, `isConnected`, `connect()`, `disconnect()`, `switchNetwork()` | New file |
| 1.5 | Create `src/lib/contracts/contracts.svelte.ts` — factory that creates typed contract instances from the provider + ABIs + addresses | New file |
| 1.6 | Add a "Connect Wallet" button to the TopBar component | Edit: `TopBar.svelte` |
| 1.7 | Add network detection — show a warning banner if user is on wrong chain, with a "Switch to Base Sepolia" button | Edit: `+layout.svelte` |
| 1.8 | Replace the Settings page user-switcher with the real connected wallet address | Edit: `settings/+page.svelte` |

**Done when:** You can click "Connect Wallet", MetaMask pops up, your address shows in the UI, and switching to the wrong network shows a warning.

---

### Phase 2: Read Live Data (Replace Mock Data)

**Time: ~1-2 days | Difficulty: Medium**

Make the UI display real on-chain data instead of mock data. Start read-only — no transactions yet.

| Step | What to Do | Contract Calls |
|------|-----------|---------------|
| 2.1 | Dashboard: show real VGRD balance | `VGRDToken.balanceOf(account)` |
| 2.2 | Dashboard: show real soldier stats (rank, tasks completed, VGRD earned) | `ArmyRegistry.getSoldier(account)` |
| 2.3 | Dashboard: show pending rewards | `RewardPool.pendingRewards(account)` |
| 2.4 | Team page: load real enlisted soldiers (this is harder — need to listen to Enlist events or index them) | `ArmyRegistry.isEnlisted(addr)`, event logs |
| 2.5 | Objectives page: load real objectives | `TaskRegistry.getObjective(id)` for ids 1..nextObjectiveId |
| 2.6 | Tasks page: load real tasks | `TaskRegistry.getTask(id)` for ids 1..nextTaskId |
| 2.7 | Bounties page: load real bounties | `BountyEscrow.getBounty(id)` for ids 1..nextBountyId |
| 2.8 | Keep mock data as fallback when wallet isn't connected | Conditional in store |

**Architecture note:** Contract reads are cheap (no gas), but there's no "get all soldiers" function — you'll need to either index events or add pagination. For testnet with few users, iterating is fine.

**Done when:** With wallet connected, the dashboard shows your real VGRD balance and rank. Disconnected, it falls back to mock data.

---

### Phase 3: Write Transactions (Core Workflows)

**Time: ~2-3 days | Difficulty: Medium-Hard**

Add the ability to actually DO things on-chain through the UI.

**Priority order (most impactful first):**

| Step | Workflow | UI Changes | Contract Call |
|------|----------|-----------|---------------|
| 3.1 | **Enlist** | Add "Enlist" button on dashboard (if not enlisted) or team page | `ArmyRegistry.enlist(squadId)` |
| 3.2 | **Create objective** | Add form on objectives page | `TaskRegistry.createObjective(unitId, title, desc, bountyId)` |
| 3.3 | **Create task** | Add form on objective detail page | `TaskRegistry.createTask(objectiveId, title, desc, reward)` |
| 3.4 | **Self-assign task** | Add "Claim Task" button on task cards | `TaskRegistry.selfAssignTask(taskId)` |
| 3.5 | **Submit task** | Add submit form (IPFS hash input) on assigned tasks | `TaskRegistry.submitTask(taskId, ipfsHash)` |
| 3.6 | **Approve/reject task** | Wire up the Review page buttons | `TaskRegistry.approveTask(taskId)` / `rejectTask(taskId)` |
| 3.7 | **Claim rewards** | Add "Claim" button to dashboard | `RewardPool.claimRewards()` |
| 3.8 | **Create bounty** | Wire up the existing /bounties/new form | `token.approve()` then `BountyEscrow.createBounty(...)` |

**Each transaction needs:**
- Loading state (spinner while tx is pending)
- Success feedback (toast/notification)
- Error handling (user rejected, insufficient gas, contract revert)
- UI refresh after confirmation

**Done when:** You can enlist, create an objective with tasks, assign yourself a task, submit it, have it approved (from another wallet), and claim the reward — all through the UI.

---

### Phase 4: Advanced Workflows

**Time: ~2-3 days | Difficulty: Hard**

| Step | Workflow | Details |
|------|----------|---------|
| 4.1 | **Promotions** | Add promotion UI for leaders. Calls `RankManager.promote(soldier)`. Show eligibility requirements. |
| 4.2 | **DAO Proposals** | New page: /governance. Create proposal form, voting UI, execution. |
| 4.3 | **Treasury Streams** | New page or section: view/claim payment streams. |
| 4.4 | **Bounty Lifecycle** | Fund, cancel, complete bounty actions on bounty detail page. |
| 4.5 | **Squad Management** | Create units, view hierarchy, handle squad splits. |

**Done when:** All 8 contracts are fully exercisable through the UI.

---

### Phase 5: Comprehensive Testing

**Time: ~2-3 days | Difficulty: Medium**

Expand the test suite to cover real workflows, not just deployment checks.

| Step | Test to Add | What It Proves |
|------|------------|----------------|
| 5.1 | **Full task lifecycle** | Create objective -> create task -> assign -> submit -> approve -> verify reward accrued |
| 5.2 | **Reward claiming** | Complete a task, claim reward, verify VGRD balance increased |
| 5.3 | **Bounty escrow flow** | Create bounty -> fund -> complete objectives -> verify funds released |
| 5.4 | **Rank promotion** | Enlist -> complete tasks -> promote -> verify multiplier changed |
| 5.5 | **DAO governance** | Create proposal -> vote -> execute -> verify state change |
| 5.6 | **Access control** | Verify unauthorized users can't approve tasks, create bounties, etc. |
| 5.7 | **Edge cases** | Double-enlist, assign already-assigned task, vote after period ends, etc. |
| 5.8 | **Multi-wallet tests** | Use 2+ wallets to test leader/soldier interactions |

**Done when:** `npm run test:deployed` runs 50+ checks covering all major workflows and error cases.

---

### Phase 6: Polish & Production Readiness

**Time: ~1-2 days | Difficulty: Medium**

| Step | What to Do |
|------|-----------|
| 6.1 | Add event indexing / subgraph for efficient data loading (instead of iterating IDs) |
| 6.2 | Add transaction history view (past rewards, completed tasks) |
| 6.3 | IPFS integration for task submission artifacts |
| 6.4 | Real-time updates via contract event listeners |
| 6.5 | Mobile-responsive testing for the wallet flows |
| 6.6 | Security review of all contract interactions (reentrancy, access control) |

---

## Quick Reference: What to Do Right Now

If you're a new team member and want to start contributing today:

1. **Read** `docs/CONTRACTS_GUIDE.md` (the companion to this doc)
2. **Set up** your environment:
   - Clone the repo
   - `cd contracts && npm install`
   - Add your `PRIVATE_KEY` and `BASESCAN_API_KEY` to `contracts/.env`
   - Get Base Sepolia ETH from a faucet
   - Add Base Sepolia to MetaMask (RPC: `https://sepolia.base.org`, Chain ID: `84532`)
3. **Run the tests:** `npm run test:deployed` to see the current state
4. **Verify the contracts** (8 commands in CONTRACTS_GUIDE.md)
5. **Pick a Phase 1 task** from the plan above and start building

---

## File Map: Where Things Live

```
vanguard/
  contracts/
    contracts/           <-- Solidity source files (8 contracts)
    scripts/
      deploy.js          <-- Deployment script
      test-deployed.js   <-- Test script (run with: npm run test:deployed)
      verify-enlistment.js <-- Quick enlistment check
    deployed-addresses.json <-- All 8 contract addresses
    hardhat.config.js    <-- Network config (Base Sepolia)
    .env                 <-- PRIVATE_KEY, BASESCAN_API_KEY

  vanguard-ui/
    src/
      lib/
        stores/
          app.svelte.ts  <-- Global state (currently mock data)
          mock-data.ts   <-- Fake soldiers, tasks, bounties
        types/index.ts   <-- TypeScript types
        components/      <-- Reusable UI components
        contracts/       <-- [DOES NOT EXIST YET] Web3 integration goes here
      routes/            <-- SvelteKit pages (11 routes)

  docs/
    CONTRACTS_GUIDE.md   <-- How the contracts work (you are here)
    GAP_ANALYSIS_AND_PLAN.md <-- This file
```
