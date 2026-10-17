// Vanguard live demo on Base Sepolia: one due-diligence bounty, end to end.
// Resumable: every completed step is recorded in demo/run.json and skipped on re-run.
const hre = require("hardhat");
const { ethers } = hre;
const fs = require("fs");
const path = require("path");

const dep = require("../deployed/base-sepolia.json");
const A = dep.addresses;
const OUT = path.join(__dirname, "..", process.env.FORK ? "demo-fork" : "demo");
const RUN = path.join(OUT, "run.json");
const WALLETS = path.join(OUT, "wallets.json"); // throwaway testnet wallets created by this script
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

const run = fs.existsSync(RUN) ? JSON.parse(fs.readFileSync(RUN, "utf8")) : { steps: [] };
const save = () => fs.writeFileSync(RUN, JSON.stringify(run, null, 2));
const done = (id) => run.steps.find((s) => s.id === id);

async function step(id, actor, label, fn) {
  if (done(id)) { console.log(`skip  ${id}`); return done(id); }
  for (let i = 1; i <= 4; i++) {
    try {
      const tx = await fn();
      const rc = await tx.wait(1);
      const rec = { id, actor, label, tx: rc.hash, block: rc.blockNumber, gasUsed: rc.gasUsed.toString() };
      run.steps.push(rec); save();
      console.log(`done  ${id}  ${rc.hash}`);
      await sleep(1500);
      return rec;
    } catch (e) {
      console.log(`retry ${id} (${i}): ${e.shortMessage || e.message}`);
      await sleep(5000 * i);
    }
  }
  throw new Error(`step ${id} failed`);
}

async function main() {
  fs.mkdirSync(OUT, { recursive: true });
  const cmd = process.env.FORK ? await ethers.getImpersonatedSigner(dep.deployer) : (await ethers.getSigners())[0];
  if (cmd.address.toLowerCase() !== dep.deployer.toLowerCase()) throw new Error(`signer ${cmd.address} is not the deployer`);
  const p = ethers.provider;

  let w = fs.existsSync(WALLETS) ? JSON.parse(fs.readFileSync(WALLETS, "utf8")) : null;
  if (!w) {
    const mk = () => { const x = ethers.Wallet.createRandom(); return { address: x.address, privateKey: x.privateKey }; };
    w = { analystA: mk(), analystB: mk() };
    fs.writeFileSync(WALLETS, JSON.stringify(w, null, 2));
  }
  const a = new ethers.Wallet(w.analystA.privateKey, p);
  const b = new ethers.Wallet(w.analystB.privateKey, p);
  run.actors = { command: cmd.address, analystA: a.address, analystB: b.address }; save();

  const at = async (n, s) => new ethers.Contract(A[n], (await hre.artifacts.readArtifact(n)).abi, s);
  const tok = await at("VGRDToken", cmd), reg = await at("ArmyRegistry", cmd), rm = await at("RankManager", cmd);
  const be = await at("BountyEscrow", cmd), tr = await at("TaskRegistry", cmd), rp = await at("RewardPool", cmd);

  // Deliverables: their keccak256 fingerprints go on-chain at submission.
  const deliverables = {
    audit: "Protocol X smart-contract audit memo. Scope: Vault.sol, Router.sol. Findings: 0 critical, 1 medium (re-entrancy guard missing on withdrawAll), 2 low. Recommendation: fix medium before launch.",
    tokenomics: "Protocol X tokenomics review. Supply 100M, 18% team with 12-month cliff, 30% community emissions over 4 years. Risk: emissions front-loaded in year one. Recommendation: flatten the year-one curve.",
  };
  for (const [k, v] of Object.entries(deliverables)) fs.writeFileSync(path.join(OUT, `deliverable-${k}.txt`), v);
  const hash = (s) => ethers.keccak256(ethers.toUtf8Bytes(s));
  run.deliverables = { audit: hash(deliverables.audit), tokenomics: hash(deliverables.tokenomics) }; save();

  const BASE = ethers.parseEther("1000");
  const TOTAL = BASE * 2n;

  await step("fund-a", "command", "Fund analyst A with test ETH for gas", () => cmd.sendTransaction({ to: a.address, value: ethers.parseEther("0.003") }));
  await step("fund-b", "command", "Fund analyst B with test ETH for gas", () => cmd.sendTransaction({ to: b.address, value: ethers.parseEther("0.003") }));

  await step("enlist-a", "analystA", "Analyst A enlists in Alpha Squad", () => reg.connect(a).enlist(1));
  await step("enlist-b", "analystB", "Analyst B enlists in Alpha Squad", () => reg.connect(b).enlist(1));
  await step("promote-b", "command", "Command promotes analyst B to Private First Class (1.5x)", () => rm.daoPromote(b.address, 3));

  await step("approve-escrow", "command", "Command approves escrow to hold the bounty", () => tok.approve(A.BountyEscrow, TOTAL));
  const deadline = Math.floor(Date.now() / 1000) + 14 * 86400;
  await step("create-bounty", "command", "Bounty: due diligence on Protocol X, 2,000 VGRD locked in escrow",
    () => be.createBounty(hash("Due diligence on Protocol X"), TOTAL, deadline, [TOTAL]));
  const bountyId = run.bountyId ? BigInt(run.bountyId) : (await be.nextBountyId()) - 1n;
  run.bountyId = bountyId.toString(); save();

  await step("create-objective", "command", "Objective assigned to Alpha Squad",
    () => tr.createObjective(bountyId, 1, hash("Protocol X diligence package"), TOTAL));
  const objectiveId = run.objectiveId ? BigInt(run.objectiveId) : (await tr.nextObjectiveId()) - 1n;
  run.objectiveId = objectiveId.toString(); save();
  await step("link-objective", "command", "Objective linked to the bounty", () => be.linkObjective(bountyId, objectiveId));

  await step("task-audit", "command", "Task: smart-contract audit, base reward 1,000 VGRD", () => tr.createTask(objectiveId, hash("Smart-contract audit"), BASE, 0));
  await sleep(4000); const auditTask = run.tasks ? BigInt(run.tasks.audit) : (await tr.nextTaskId()) - 1n;
  await step("task-tokenomics", "command", "Task: tokenomics review, base reward 1,000 VGRD", () => tr.createTask(objectiveId, hash("Tokenomics review"), BASE, 0));
  await sleep(4000); const tokTask = run.tasks ? BigInt(run.tasks.tokenomics) : (await tr.nextTaskId()) - 1n;
  run.tasks = { audit: auditTask.toString(), tokenomics: tokTask.toString() }; save();

  await step("assign-audit", "command", "Audit assigned to analyst A", () => tr.assignTask(auditTask, a.address));
  await step("assign-tokenomics", "command", "Tokenomics assigned to analyst B", () => tr.assignTask(tokTask, b.address));

  await step("submit-audit", "analystA", "Analyst A submits the audit memo fingerprint", () => tr.connect(a).submitTask(auditTask, run.deliverables.audit));
  await step("submit-tokenomics", "analystB", "Analyst B submits the tokenomics memo fingerprint", () => tr.connect(b).submitTask(tokTask, run.deliverables.tokenomics));

  const ADMIN_ROLE = await reg.ADMIN_ROLE();
  if (!(await reg.hasRole(ADMIN_ROLE, A.RewardPool)))
    await step("grant-rewardpool", "command", "Fix: let the reward pool record completed tasks in the registry", () => reg.grantRole(ADMIN_ROLE, A.RewardPool));

  await step("approve-audit", "command", "Leader approves the audit: paid 1,000 x 1.0", () => tr.approveTask(auditTask));
  await step("approve-tokenomics", "command", "Leader approves the tokenomics review: paid 1,000 x 1.5", () => tr.approveTask(tokTask));

  await step("release-escrow", "command", "Escrow releases the 2,000 VGRD and the bounty closes", () => be.releaseObjectiveReward(bountyId, objectiveId, TOTAL));

  await step("claim-a", "analystA", "Analyst A claims rewards", () => rp.connect(a).claimRewards());
  await step("claim-b", "analystB", "Analyst B claims rewards", () => rp.connect(b).claimRewards());

  const bounty = await be.getBounty(bountyId);
  const sa = await reg.getSoldier(a.address), sb = await reg.getSoldier(b.address);
  run.final = {
    analystA: { rank: (await reg.getRankIndex(a.address)).toString(), vgrd: ethers.formatEther(await tok.balanceOf(a.address)), tasksCompleted: sa.tasksCompleted.toString(), callsign: sa.callsign },
    analystB: { rank: (await reg.getRankIndex(b.address)).toString(), vgrd: ethers.formatEther(await tok.balanceOf(b.address)), tasksCompleted: sb.tasksCompleted.toString(), callsign: sb.callsign },
    bounty: { status: bounty.status.toString(), remaining: ethers.formatEther(bounty.remainingAmount) },
    objectiveProgress: (await tr.getObjectiveProgress(objectiveId)).map(String),
  };
  save();
  console.log(JSON.stringify(run.final, null, 2));
}

main().catch((e) => { console.error(e); process.exit(1); });
