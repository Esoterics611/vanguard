#!/usr/bin/env node
// Sets up a Vanguard Academy cohort on the deployed contracts, using the admin key.
//
//   node scripts/academy-setup.js --cohort cohort-1 --name "Cohort 1" --instructor 0x… [--second 0x…]
//
// Without --execute it only reports what it would do. Each step is skipped when it is
// already done, so it is safe to run again:
//
//   1. Load the callsign word lists (once per deployment), so members get readable callsigns.
//      Do this before the first student enlists: callsigns are fixed at enlistment.
//   2. Create the cohort squad and record its id under "academy" in the deployment record
//      (contracts/deployed/base-sepolia.json). Commit that file: the web app reads it, and
//      enlistment opens on the site.
//   3. Make the instructor (and an optional second in command) the squad's leader.
//   4. Once the instructor has enlisted (through the site's /join page), raise them to
//      Second Lieutenant, so the contracts let them promote students up to Corporal.
//
// Environment: PRIVATE_KEY (the admin key), RPC_URL (default https://sepolia.base.org).
// Options: --deployment <path> (default deployed/base-sepolia.json), --instructor-rank <n> (default 9).

const fs = require('fs');
const path = require('path');
const { ethers } = require('ethers');
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });

const SQUAD = 0; // BaseRegistry.UnitType.SQUAD
const RANK_NAMES = ['Guest', 'Private', 'Private Second Class', 'Private First Class', 'Corporal', 'Sergeant', 'Staff Sergeant', 'Sergeant First Class', 'First Sergeant', 'Second Lieutenant', 'First Lieutenant', 'Captain'];
const WORDS_PER_TX = 50;
const SITE = 'https://esoterics611.github.io/vanguard';

const REGISTRY_ABI = [
  'function ADMIN_ROLE() view returns (bytes32)',
  'function hasRole(bytes32 role, address account) view returns (bool)',
  'function createUnit(uint8 uType, bytes32 name, uint256 parentId) returns (uint256)',
  'function setUnitLeader(uint256 unitId, address newLeader)',
  'function setUnit2IC(uint256 unitId, address new2IC)',
  'function seedCallsignWords(bytes32[] _prefixes, bytes32[] _suffixes)',
  'function prefixes(uint256) view returns (bytes32)',
  'function suffixes(uint256) view returns (bytes32)',
  'function getUnit(uint256 unitId) view returns (tuple(uint8 unitType, bytes32 name, address leader, address secondInCommand, uint256 parentUnitId, uint256 memberCount, uint256 createdAt, bool active))',
  'function getSoldier(address wallet) view returns (tuple(bytes32 callsign, uint8 rank, uint256 unitId, uint256 tasksCompleted, uint256 totalEarned, uint256 enlistedAt, address invitedBy))',
  'event UnitCreated(uint256 indexed unitId, uint8 unitType, bytes32 name)',
];
const RANK_MANAGER_ABI = [
  'function DAO_ROLE() view returns (bytes32)',
  'function hasRole(bytes32 role, address account) view returns (bool)',
  'function daoPromote(address target, uint8 newRank)',
];
const REWARD_POOL_ABI = ['function getPoolBalance() view returns (uint256)'];

function parseArgs(argv) {
  const args = { execute: false, instructorRank: 9, deployment: path.join(__dirname, '..', 'deployed', 'base-sepolia.json') };
  for (let i = 0; i < argv.length; i++) {
    const key = argv[i];
    const next = () => argv[++i];
    if (key === '--execute') args.execute = true;
    else if (key === '--cohort') args.cohort = next();
    else if (key === '--name') args.name = next();
    else if (key === '--instructor') args.instructor = next();
    else if (key === '--second') args.second = next();
    else if (key === '--instructor-rank') args.instructorRank = Number(next());
    else if (key === '--deployment') args.deployment = path.resolve(next());
    else throw new Error(`Unknown option ${key}`);
  }
  if (!args.cohort || !args.name || !args.instructor) {
    throw new Error('Usage: node scripts/academy-setup.js --cohort cohort-1 --name "Cohort 1" --instructor 0x… [--second 0x…] [--execute]');
  }
  for (const key of ['instructor', 'second']) if (args[key]) args[key] = ethers.getAddress(args[key]);
  return args;
}

const same = (a, b) => !!a && !!b && a.toLowerCase() === b.toLowerCase();

/** How many words a registry list holds: its public getter reverts past the end. */
async function countWords(registry, kind, max) {
  const has = (i) => registry[kind](i).then(() => true, () => false);
  if (!(await has(0))) return 0;
  let lo = 0; // known present
  let hi = max; // treat as absent
  if (await has(max - 1)) return max;
  while (hi - lo > 1) {
    const mid = (lo + hi) >> 1;
    if (await has(mid)) lo = mid;
    else hi = mid;
  }
  return lo + 1;
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  const record = JSON.parse(fs.readFileSync(args.deployment, 'utf8'));
  const provider = new ethers.JsonRpcProvider(process.env.RPC_URL || 'https://sepolia.base.org');
  const { chainId } = await provider.getNetwork();
  if (Number(chainId) !== record.chainId) throw new Error(`Connected to chain ${chainId}, but ${path.basename(args.deployment)} is for chain ${record.chainId}.`);
  if (!process.env.PRIVATE_KEY) throw new Error('Set PRIVATE_KEY (the admin key) in contracts/.env or the environment.');
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
  // Tracks nonces locally: back-to-back sends would otherwise reuse a cached one.
  const admin = new ethers.NonceManager(wallet);

  const registry = new ethers.Contract(record.addresses.ArmyRegistry, REGISTRY_ABI, admin);
  const rankManager = new ethers.Contract(record.addresses.RankManager, RANK_MANAGER_ABI, admin);
  const pool = new ethers.Contract(record.addresses.RewardPool, REWARD_POOL_ABI, provider);

  const mode = args.execute ? 'Executing' : 'Dry run (add --execute to send)';
  console.log(`${mode} · ${record.network} · admin ${wallet.address}\n`);

  const [isRegistryAdmin, isRankAdmin] = await Promise.all([
    registry.hasRole(await registry.ADMIN_ROLE(), wallet.address),
    rankManager.hasRole(await rankManager.DAO_ROLE(), wallet.address),
  ]);
  if (!isRegistryAdmin) throw new Error('This key lacks ADMIN_ROLE on ArmyRegistry, so it cannot create squads or set leaders.');

  const send = async (label, fn) => {
    if (!args.execute) {
      console.log(`  would: ${label}`);
      return null;
    }
    const tx = await fn();
    const receipt = await tx.wait();
    console.log(`  done:  ${label}  (${receipt.hash})`);
    return receipt;
  };

  // 1. Callsign words. The registry appends, so resume from however many are already on chain.
  console.log('1. Callsign words');
  const words = JSON.parse(fs.readFileSync(path.join(__dirname, 'callsign-words.json'), 'utf8'));
  for (const kind of ['prefixes', 'suffixes']) {
    const list = words[kind];
    const loaded = await countWords(registry, kind, list.length);
    if (loaded >= list.length) {
      console.log(`  ${kind}: all ${list.length} loaded`);
      continue;
    }
    for (let i = loaded; i < list.length; i += WORDS_PER_TX) {
      const chunk = list.slice(i, i + WORDS_PER_TX).map((w) => ethers.encodeBytes32String(w));
      await send(`load ${kind} ${i + 1}–${i + chunk.length} of ${list.length}`, () =>
        kind === 'prefixes' ? registry.seedCallsignWords(chunk, []) : registry.seedCallsignWords([], chunk)
      );
    }
  }

  // 2. Cohort squad
  console.log(`\n2. Squad for ${args.cohort}`);
  record.academy = record.academy || {};
  let squadId = record.academy[args.cohort]?.squadId ?? null;
  if (squadId !== null) {
    console.log(`  already created: unit ${squadId}`);
  } else {
    const receipt = await send(`create squad "${args.name}"`, () => registry.createUnit(SQUAD, ethers.encodeBytes32String(args.name), 0));
    if (receipt) {
      const created = receipt.logs.map((log) => registry.interface.parseLog(log)).find((e) => e?.name === 'UnitCreated');
      squadId = Number(created.args.unitId);
      record.academy[args.cohort] = { squadId, instructor: args.instructor, name: args.name, createdAt: new Date().toISOString(), tx: receipt.hash };
      fs.writeFileSync(args.deployment, JSON.stringify(record, null, 2) + '\n');
      const shown = path.relative(process.cwd(), args.deployment);
      console.log(`  recorded unit ${squadId} in ${shown.startsWith('..') ? args.deployment : shown}: commit it to open enlistment on the site`);
    }
  }

  // 3. Leadership
  console.log('\n3. Squad leadership');
  if (squadId === null) {
    console.log(`  would: make ${args.instructor} the leader${args.second ? ` and ${args.second} second in command` : ''}`);
  } else {
    const unit = await registry.getUnit(squadId);
    if (same(unit.leader, args.instructor)) console.log('  instructor already leads the squad');
    else await send(`make ${args.instructor} the leader`, () => registry.setUnitLeader(squadId, args.instructor));
    if (args.second) {
      if (same(unit.secondInCommand, args.second)) console.log('  second in command already set');
      else await send(`make ${args.second} second in command`, () => registry.setUnit2IC(squadId, args.second));
    }
    if (record.academy[args.cohort] && !same(record.academy[args.cohort].instructor, args.instructor)) {
      record.academy[args.cohort].instructor = args.instructor;
      if (args.execute) fs.writeFileSync(args.deployment, JSON.stringify(record, null, 2) + '\n');
    }
  }

  // 4. Instructor rank
  console.log('\n4. Instructor rank');
  const soldier = await registry.getSoldier(args.instructor);
  if (soldier.enlistedAt === 0n) {
    const link = `${SITE}/join?cohort=${args.cohort}`;
    console.log(`  the instructor hasn't enlisted yet: open ${link} with their wallet, then run this again`);
  } else if (Number(soldier.rank) >= args.instructorRank) {
    console.log(`  already ${RANK_NAMES[Number(soldier.rank)]}`);
  } else if (!isRankAdmin) {
    console.log('  this key lacks DAO_ROLE on RankManager, so it cannot promote the instructor');
  } else {
    await send(`promote the instructor to ${RANK_NAMES[args.instructorRank]}`, () => rankManager.daoPromote(args.instructor, args.instructorRank));
  }

  // Funding check: approved coursework is paid from the reward pool.
  const balance = await pool.getPoolBalance();
  console.log(`\nReward pool holds ${Number(ethers.formatEther(balance)).toLocaleString('en-US')} VGRD for coursework pay.`);
  console.log(`Invite link for students: ${SITE}/join?cohort=${args.cohort}&invite=${args.instructor}`);
}

main().catch((e) => {
  console.error(`\n${e.shortMessage || e.message}`);
  process.exit(1);
});
