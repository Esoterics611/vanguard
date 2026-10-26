# Vanguard workplan

> Read this first in any new session. It says what we are building, in what order, what is done, and what is waiting on a decision. Add a line to the session log at the bottom before you finish.

Last updated: 2026-10-26

## The goal

From the Republic decks (*The Vanguard Guild* and *The Guild Library*, Oct 2026):

- **Months 1–3:** deploy the guild on Base testnet and publish the courses. **By month 3, cohort 1 is trained and ranked on testnet.**
- **Months 4–6:** graduates source deals and bring new DAOs online.
- **Month 6:** mainnet.

The Library's Accelerator format is the model for a cohort: apply, orient in week one, weekly modules, form teams, build on a live project, Demo Day. Course completion is meant to gate promotion.

## Order of work

1. **Student onboarding for the first cohorts (now).** Everything a student sees, from the invite link to their first submitted assignment. Most of the effort goes into this UI.
2. **Running a cohort on the contracts we already have.** Admin transactions and instructor routines; no contract changes.
3. **Instructor tooling.** Reviewing and approving work, creating assignments, promotions.
4. **Technical hardening, adjusted once cohort 1 has started**, ending in one redeploy (the "Academy release").

**Rule:** the eight contracts deployed on Base Sepolia on 27 Apr 2026 stay as they are until the Academy release. Steps 1–3 work with them as deployed. Anything that needs a contract change goes on the Academy release list below; don't change a `.sol` file outside it.

---

## 1. Student onboarding (UI)

The student's path: **invite link → wallet → Base Sepolia → test ETH for fees → enlist in the cohort squad → callsign and rank → cohort home → first assignment submitted.**

| | Item | Where |
|---|---|---|
| [x] | Cohort definition: name, dates, squad id, instructor, intake link, week-by-week syllabus | `vanguard-ui/src/lib/academy/cohorts.ts` |
| [x] | `/join`: guided setup that detects each step (wallet, connection, network, fee balance, enlistment) and enlists the student in the cohort squad, crediting whoever invited them | `vanguard-ui/src/routes/join/` |
| [x] | `/academy`: cohort home with the student's standing, this week, the syllabus with on-chain progress, assignments with in-browser submission, and classmates | `vanguard-ui/src/routes/academy/` |
| [x] | Readable callsigns (decoded from the registry's word lists, fallback from the address) | `vanguard-ui/src/lib/contracts/callsigns.ts` |
| [x] | Sidebar puts the cohort pages first; pages still on sample data are labelled as such | `Sidebar.svelte`, `+layout.svelte` |
| [x] | The app works on a phone: below desktop width the sidebar becomes a menu | `+layout.svelte`, `TopBar.svelte` |
| [x] | Wallet reconnects on reload; switching network mid-flow no longer breaks the next transaction | `provider.svelte.ts` |
| [x] | The web app is a static site that runs at a domain root or under a path; `/` opens the cohort page and the sample dashboard moved to `/dashboard` | `svelte.config.js`, `+layout.ts` |
| [x] | GitHub Pages deploy: on every push to `main` the Academy goes to esoterics611.github.io/vanguard/ and the live contracts page to `/live/`; a check-and-build job runs on pull requests | `.github/workflows/pages.yml`, `web.yml` |
| [x] | Demo mode (`/join?demo=1`): a simulated wallet and chain to click through the whole student path before the cohort exists on chain, including a simulated instructor who approves, pays and promotes | `vanguard-ui/src/lib/demo/` |
| [ ] | **Merge to `main` to publish the site.** Optional: a custom domain (Settings → Pages); the build adapts to it automatically | |
| [ ] | Seed the callsign words on chain (section 2) before the first student enlists; until then callsigns show as `RECRUIT-XXXX` | |
| [ ] | Hebrew edition of `/join` and `/academy` (the landing site and the flagship course are bilingual) | |
| [ ] | Intake: an application form link in the cohort definition for now; Firebase `reviewApplication` flow later | `cohorts.ts` `intakeUrl` |
| [ ] | Landing site: replace the dead "Enlist your formation" form with a "Join cohort 1" button to `/join` | `vanguard-site/index.html` |
| [ ] | Fees without a faucet: smart wallet plus a paymaster so students never need test ETH | |
| [ ] | A short "how to submit work" guide for students, linked from `/academy` | |

## 2. Running a cohort on the existing contracts

All of these are transactions on the deployed contracts, with no code changes. "Admin" means the deployer key today, and the multisig once that move is done.

| Step | Call | Who |
|---|---|---|
| Create the cohort squad | `ArmyRegistry.createUnit(0 /* SQUAD */, encodeBytes32String("Cohort 1"), 0)` | admin |
| Make the instructor its leader (and a TA its second) | `ArmyRegistry.setUnitLeader(squadId, instructor)`, `setUnit2IC(squadId, ta)` | admin |
| Turn on enlistment in the app | put `squadId` and the instructor's address in `cohorts.ts`; the invite link is `/join?cohort=cohort-1&invite=<address>` | us |
| Readable callsigns for everyone who enlists afterwards | `ArmyRegistry.seedCallsignWords(prefixes, suffixes)` with the word list in `backend/functions/src/seed.ts` (as `encodeBytes32String`) | admin |
| One objective per week | `TaskRegistry.createObjective(0 /* no bounty */, squadId, keccak256(utf8(week.objectiveBrief)), 0)`. The brief text must match `objectiveBrief` in `cohorts.ts` exactly; that's how `/academy` finds it. | instructor |
| One task per student per assignment (or open for students to take) | `createTask(objectiveId, keccak256(utf8(brief)), reward, deadline)`, then `assignTask(taskId, student)`. A reward of 0 is allowed; the approval still counts on the student's record. | instructor |
| Student submits | `/academy` fingerprints the file or text in the browser and calls `submitTask` / `resubmitTask` | student |
| Instructor reviews and approves or rejects | `approveTask(taskId)` / `rejectTask(taskId, reason)`. Approval adds to the student's tasks-completed count and pays `reward × rank multiplier` from the reward pool. | instructor |
| Instructor rank (so they can promote) | `RankManager.daoPromote(instructor, 9 /* 2LT */)` | admin |
| Promotions | PVT→PV2 needs a promoter at SSG or above; PFC and CPL need 2LT+; SGT needs CPT and the PLDC flag; SSG and above need CPT; `daoPromote` works any time. 7-day cooldown (`setPromotionCooldown` changes it). | instructor / admin |
| Leadership course done | `RankManager.completePLDC(student)` | admin |
| Graduation | Members can't move between squads on these contracts, so the cohort squad becomes the graduates' first working squad. Past 10 members the leader can `splitSquad`. | — |
| Real bounties | `approve` then `BountyEscrow.createBounty`, `linkObjective`, and after approvals a manual `releaseObjectiveReward`. Approving tasks doesn't release escrow on its own. | admin |

## 3. Other work that needs no redeploy

**Safety**
- [ ] Move every admin role to a Safe multisig (`grantRole` to the Safe, then the deployer renounces).
- [ ] Separate attestation signer: `VanguardDAO.setAttestationSigner`.
- [ ] Limit what a unit leader can pay out. Any leader can create a task with any reward and approve it, and the reward comes out of the reward pool, which holds 400M VGRD. Keep only a cohort's budget in the pool (`RewardPool.withdrawToTreasury` the rest), give unit leadership only to trusted people, and watch `TaskApproved` events.

**Configuration** (waiting on the rank numbers, see decisions)
- [ ] Make pay and vote multipliers agree: `RankManager.setMultipliers` (captain pays 15×) and `VanguardDAO.setRankMultipliers` (captain votes 12×).
- [ ] Make the docs' promotion table (`vanguard-docs/docs/rank-system/progression.md`) match who the contract actually lets promote whom.

**Code**
- [ ] Contract tests for the deployed money path: RankManager, TaskRegistry, BountyEscrow, RewardPool. Nothing is redeployed; CI runs them.
- [ ] Instructor page: review queue that checks each file against its fingerprint, approve/reject, create the weekly objective and assignments, assign, promote, record PLDC.
- [ ] Command page: create, link and release bounties.
- [ ] Read history from events (or an indexer) instead of scanning every id.
- [ ] Move the remaining sample-data pages (dashboard, bounties, objectives, tasks, review) onto chain data, or remove them. Four of them carry type errors that predate this plan (`npm run check`: `bounties/[id]`, `bounties/new`, `objectives/[id]`, `team/[id]`).
- [ ] Publish the Protocol Guide (`vanguard-docs`, MkDocs) next to the live page.

## 4. Academy release (needs a redeploy; adjust after cohort 1 starts)

Bundle these, redeploy once with the multisig as admin and a separate signer, then update the app, the live page and the docs.

- Course records (many courses, who certified, which cohort) and a course list per rank. Today there are two yes/no flags; PLDC gates sergeant (`RankManager.sol:113`) but OBC is recorded and never checked.
- Moving a member between units, for graduation. `BaseRegistry._transferMember` is internal and only `splitSquad` uses it.
- Invite-only or capped squads. Anyone can enlist in any squad (`BaseRegistry.sol:107`).
- Task rewards limited by the objective's allocation or the bounty. Today they aren't limited at all.
- Escrow released automatically when work is approved.
- Pay design. The rank multiplier is paid on top of the bounty from the pool (`RewardPool.sol:62`): the 2,000 VGRD demo bounty paid out 2,500.
- Names readable on chain (callsigns, unit names, task briefs), or content addressing through IPFS or Vault.

## Decisions waiting on the owner

1. **Where the web app lives:** GitHub Pages is wired up and works now; a custom domain or another host (Vercel, Netlify, Firebase) only needs the build command in `vanguard-ui/README.md`.
2. **Hebrew:** should onboarding ship in Hebrew too, and for cohort 1?
3. **Cohort 1 details:** dates, size, instructor(s) and their wallet addresses, intake form link. Placeholders are in `cohorts.ts`.
4. **Coursework pay:** zero, or a small test-VGRD reward per assignment.
5. **Rank numbers:** one table for pay and votes; which is right, the docs or the contract?
6. **Real money** (stipends, client bounties): needs the legal entity first.

## Session log

- **2026-10-26:** Reviewed the repo against the Republic decks and wrote this plan. Built the onboarding path: cohort definition, `/join` (five detected steps, invite credit, welcome and invite link), `/academy` (standing, next assignment with in-browser fingerprinting and submission, syllabus with on-chain status, rank path, classmates, claim pay), readable callsigns, the sidebar regrouped with sample-data pages labelled, and a phone layout. No contract changes. This session's network blocked the Solidity compiler download and the Base Sepolia RPC, so the contracts weren't compiled and nothing ran against the live chain. Instead the whole student path (connect, switch network, faucet, enlist, take, submit, claim) was driven in Chromium against a simulated chain and wallet built from the app's ABIs, on desktop and phone sizes. `npm run check` is clean for the new code and `npm run build` passes. Next: pick hosting, fill in cohort 1's details, then the instructor page.
- **2026-10-26 (later):** Made the web app deployable. It's a static build (adapter-static, 404.html fallback, base path from `BASE_PATH`); every internal link goes through `resolve()` and route matching uses route ids, so it works under `/vanguard/` on GitHub Pages or at any domain root. The Pages workflow now publishes the Academy at the root and the live contracts page at `/live/`; a new workflow type-checks and builds on pull requests. Added demo mode. Fixed the type errors that predated this plan, so `npm run check` is fully clean. Verified by serving the assembled site the way GitHub Pages does and clicking through demo mode in Chromium on desktop and phone: no real chain requests, and the deep-link fallback, the `/` redirect and "Leave demo" all work. Contract addresses and the redeploy are still for later.
