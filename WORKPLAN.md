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

## Launching cohort 1 (before Wed 11 Nov 2026)

Everything below runs on the deployed contracts. The whole sequence was rehearsed on a local chain running the same contracts (see the session log).

1. **Choose the instructor** and get their wallet address (and a second in command's, if any).
2. **Run the setup script with the admin key**, first as a dry run, then with `--execute`. Put `PRIVATE_KEY` (and `RPC_URL`, if not `https://sepolia.base.org`) in `contracts/.env`.
   ```
   cd contracts
   node scripts/academy-setup.js --cohort cohort-1 --name "Cohort 1" --instructor 0x… [--second 0x…]
   node scripts/academy-setup.js --cohort cohort-1 --name "Cohort 1" --instructor 0x… --execute
   ```
   It loads the callsign words, creates the squad, records it in `contracts/deployed/base-sepolia.json` and makes the instructor its leader.
3. **Commit `contracts/deployed/base-sepolia.json` to `main`.** The Pages deploy picks it up and enlistment opens on the site.
4. **The instructor enlists** at `/join?cohort=cohort-1` with their wallet, then **run the script again**: it promotes them to Second Lieutenant, so they can promote students up to Corporal.
5. **Check the reward pool.** The script prints its balance; coursework pay comes from it. See the payout limit under Safety in section 3.
6. **The instructor shares their invite link** (Instructor page, Students tab) and **posts week 1** from the Weeks tab. Week 1 can go up before the start date.

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
| [x] | Published: the site is live at esoterics611.github.io/vanguard/ (merged 26 Oct). Optional: a custom domain (Settings → Pages); the build adapts to it automatically | |
| [x] | Contract addresses and each cohort's squad are read from the deployment record, so opening enlistment is a commit of that file | `addresses.ts`, `contracts/deployed/base-sepolia.json` |
| [x] | Student guide to handing in work, linked from `/academy` | `vanguard-ui/src/routes/academy/guide/` |
| [x] | Missed deadlines: the contracts can't extend one, so a late student is told to ask for a new copy, and the instructor page counts them and posts and hands out fresh copies | `isLate()` in `chain.ts` |
| [x] | Landing site: the dead "Enlist your formation" form is now a "Join Cohort 1" card linking to `/join`. The landing site isn't deployed anywhere yet | `vanguard-site/index.html` |
| [ ] | Callsign words on chain before the first student enlists (callsigns are fixed at enlistment; until then they show as `RECRUIT-XXXX`): step 2 of the launch, done by the setup script | |
| [ ] | Intake: an application form link in the cohort definition for now; Firebase `reviewApplication` flow later | `cohorts.ts` `intakeUrl` |
| [ ] | Fees without a faucet: smart wallet plus a paymaster so students never need test ETH | |

## 2. Running a cohort on the existing contracts

All of these are transactions on the deployed contracts, with no code changes. "Admin" means the deployer key today, and the multisig once that move is done. The admin steps are what `contracts/scripts/academy-setup.js` sends; the instructor steps are buttons on `/instructor`.

| Step | Call | Who |
|---|---|---|
| Create the cohort squad | `ArmyRegistry.createUnit(0 /* SQUAD */, encodeBytes32String("Cohort 1"), 0)` | admin (setup script) |
| Make the instructor its leader (and a TA its second) | `ArmyRegistry.setUnitLeader(squadId, instructor)`, `setUnit2IC(squadId, ta)` | admin (setup script) |
| Turn on enlistment in the app | the setup script records the squad under `academy` in `contracts/deployed/base-sepolia.json`; commit it. The invite link is `/join?cohort=cohort-1&invite=<address>` | us |
| Readable callsigns for everyone who enlists afterwards | `ArmyRegistry.seedCallsignWords(prefixes, suffixes)` with `contracts/scripts/callsign-words.json` (from `backend/functions/src/seed.ts`), 50 words a transaction | admin (setup script) |
| One objective per week | `TaskRegistry.createObjective(0 /* no bounty */, squadId, keccak256(utf8(weekBrief(cohort, week))), 0)`. The brief must match `weekBrief()` in `cohorts.ts` exactly (`Cohort 1 · Week 1 · Orientation`); that's how both pages find the week. | instructor (Weeks tab) |
| One task per student per assignment (or open for students to take) | `createTask(objectiveId, keccak256(utf8(week.assignment)), reward, deadline)`, then `assignTask(taskId, student)`. A reward of 0 is allowed; the approval still counts on the student's record. A deadline can't be extended: a late student gets a fresh copy. | instructor (Weeks tab, batched when the wallet supports EIP-5792) |
| Student submits | `/academy` fingerprints the file or text in the browser and calls `submitTask` / `resubmitTask` | student |
| Instructor reviews and approves or rejects | `approveTask(taskId)` / `rejectTask(taskId, reason)`. Approval adds to the student's tasks-completed count and pays `reward × rank multiplier` from the reward pool. | instructor (Review tab) |
| Instructor rank (so they can promote) | `RankManager.daoPromote(instructor, 9 /* 2LT */)` | admin (setup script) |
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
- [x] Instructor page: review queue that checks each file against its fingerprint, approve/reject (one by one or all checked at once), post the weekly objective and assignments, hand them out, promote, record PLDC (command only).
- [x] Cohort setup script for the admin key (`contracts/scripts/academy-setup.js`).
- [ ] Turn the local rehearsal (a hardhat node with chain id 84532, the contracts deployed from the app's artifacts, the site driven in Chromium) into a script in the repo, so CI can run it.
- [ ] Command page: create, link and release bounties.
- [ ] Read history from events (or an indexer) instead of scanning every id.
- [ ] Move the remaining sample-data pages (dashboard, bounties, objectives, tasks, review) onto chain data, or remove them.
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
2. ~~Hebrew~~ **Decided 2026-10-26:** no Hebrew edition for the cohorts.
3. **Cohort 1 details:** starts **Wed 11 Nov 2026** (decided; in `cohorts.ts`). Still open: size (the site says 25 seats), instructor(s) and their wallet addresses, intake form link. The instructor's address is all the launch (above) is waiting on.
4. ~~Coursework pay~~ **Decided 2026-10-26:** coursework is paid. Default 100 test VGRD per approved assignment, times the student's rank multiplier (`assignmentReward` in `cohorts.ts`; the instructor can change it per week).
5. **Rank numbers:** one table for pay and votes; which is right, the docs or the contract?
6. **Real money** (stipends, client bounties): needs the legal entity first.

## Session log

- **2026-10-26:** Reviewed the repo against the Republic decks and wrote this plan. Built the onboarding path: cohort definition, `/join` (five detected steps, invite credit, welcome and invite link), `/academy` (standing, next assignment with in-browser fingerprinting and submission, syllabus with on-chain status, rank path, classmates, claim pay), readable callsigns, the sidebar regrouped with sample-data pages labelled, and a phone layout. No contract changes. This session's network blocked the Solidity compiler download and the Base Sepolia RPC, so the contracts weren't compiled and nothing ran against the live chain. Instead the whole student path (connect, switch network, faucet, enlist, take, submit, claim) was driven in Chromium against a simulated chain and wallet built from the app's ABIs, on desktop and phone sizes. `npm run check` is clean for the new code and `npm run build` passes. Next: pick hosting, fill in cohort 1's details, then the instructor page.
- **2026-10-26 (later):** Made the web app deployable. It's a static build (adapter-static, 404.html fallback, base path from `BASE_PATH`); every internal link goes through `resolve()` and route matching uses route ids, so it works under `/vanguard/` on GitHub Pages or at any domain root. The Pages workflow now publishes the Academy at the root and the live contracts page at `/live/`; a new workflow type-checks and builds on pull requests. Added demo mode. Fixed the type errors that predated this plan, so `npm run check` is fully clean. Verified by serving the assembled site the way GitHub Pages does and clicking through demo mode in Chromium on desktop and phone: no real chain requests, and the deep-link fallback, the `/` redirect and "Leave demo" all work. Contract addresses and the redeploy are still for later.
- **2026-10-26 (instructor page and launch prep):** Decisions: no Hebrew edition, coursework paid (100 VGRD default), cohort 1 starts 11 Nov. Built `/instructor`: a review queue that checks each student's file against its on-chain fingerprint, approve or send back with a note, approve all checked in one go; a Weeks tab that posts a week and its paid copies and hands them out (one wallet confirmation when the wallet supports EIP-5792 batching, one per call otherwise); a Students tab with each student's weeks and promotion standing under the contract's rules (authority, cooldown, leadership course). Instructor demo at `/instructor?demo=instructor`. Added `contracts/scripts/academy-setup.js` and moved addresses and cohort squads into the deployment record. Refreshed three stale ABIs (ArmyRegistry, Treasury, VanguardDAO) from the current sources. Rehearsed a whole cohort against the real contracts: compiled the current sources in a scratch directory (solc-js; the repo's build config untouched), deployed them to a local hardhat node with Base Sepolia's chain id and the live wiring, ran the setup script, and drove the built site in Chromium through enlistment by invite, posting and handing out week 1, submission, a file check, a send-back and resubmission, approvals, a pay claim and a promotion, then checked the chain directly. The rehearsal found two problems, both fixed: before the start date, posting week 1 collapsed its card and hid the confirmation and "Hand out"; and a student who misses a deadline was stuck, since the contracts can't extend one. A second rehearsal moved the chain and browser clocks past a deadline and recovered with a fresh copy. Also: the student guide to handing in work (`/academy/guide`) and the landing site's "Join Cohort 1" card. Next: the instructor's wallet address, then the launch steps at the top of this file.
