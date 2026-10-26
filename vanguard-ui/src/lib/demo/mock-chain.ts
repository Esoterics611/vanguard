// ═══════════════════════════════════════════════════════════════
// Demo mode's simulated chain and wallet.
//
// An in-memory stand-in for the deployed contracts, answering the same
// calls through the app's own ABIs and enforcing the same rules for the
// calls the Academy makes, plus an EIP-1193 wallet. A cohort is in week
// three: classmates have handed in work, and assignments are open.
//
// As a student (?demo=1) the wallet starts disconnected on the wrong
// network with no test ETH; after a submission a simulated instructor
// approves it, pays it and promotes the student a few seconds later.
// As the instructor (?demo=instructor) the wallet is the squad leader,
// ready on Base Sepolia, and simulated classmates take, hand in and fix
// the assignments the instructor posts. The wallet supports EIP-5792
// batches, so posting to a whole cohort takes one confirmation.
// Nothing here reaches Base Sepolia.
// ═══════════════════════════════════════════════════════════════

import {
	AbiCoder,
	BrowserProvider,
	Interface,
	ZeroAddress,
	ZeroHash,
	concat,
	encodeBytes32String,
	getAddress,
	keccak256,
	parseEther,
	toQuantity,
	toUtf8Bytes,
	type InterfaceAbi,
} from 'ethers';
import { addresses, BASE_SEPOLIA_CHAIN_ID } from '$lib/contracts/addresses';
import type { Eip1193Provider } from '$lib/contracts/eip1193';
import ArmyRegistryArtifact from '$lib/contracts/abis/ArmyRegistry.json';
import RankManagerArtifact from '$lib/contracts/abis/RankManager.json';
import RewardPoolArtifact from '$lib/contracts/abis/RewardPool.json';
import TaskRegistryArtifact from '$lib/contracts/abis/TaskRegistry.json';
import { COHORTS, weekBrief } from '$lib/academy/cohorts';
import { DEMO_SQUAD_ID, demoRole } from './flag';

const abi = (artifact: unknown) => (artifact as { abi: InterfaceAbi }).abi;
const CONTRACTS: Record<string, { name: string; iface: Interface }> = {
	[addresses.ArmyRegistry.toLowerCase()]: { name: 'ArmyRegistry', iface: new Interface(abi(ArmyRegistryArtifact)) },
	[addresses.RankManager.toLowerCase()]: { name: 'RankManager', iface: new Interface(abi(RankManagerArtifact)) },
	[addresses.RewardPool.toLowerCase()]: { name: 'RewardPool', iface: new Interface(abi(RewardPoolArtifact)) },
	[addresses.TaskRegistry.toLowerCase()]: { name: 'TaskRegistry', iface: new Interface(abi(TaskRegistryArtifact)) },
};

const cohort = COHORTS[0];
const MULTIPLIERS = [0, 100, 120, 150, 200, 300, 400, 500, 600, 800, 1000, 1500];
const REWARD = parseEther(cohort.assignmentReward);
const COOLDOWN = 7 * 86400;
const REVIEW_DELAY_MS = 6000;
const CHAIN_HEX = toQuantity(BASE_SEPOLIA_CHAIN_ID);

const fakeAddress = (seed: string) => getAddress(keccak256(toUtf8Bytes(seed)).slice(0, 42));
export const DEMO_STUDENT = fakeAddress('vanguard demo student');
const INSTRUCTOR = fakeAddress('vanguard demo instructor');
const CLASSMATES = ['a', 'b', 'c', 'd', 'e'].map((s) => fakeAddress(`vanguard demo classmate ${s}`));

const PREFIXES = ['CIPHER', 'GHOST', 'NOVA', 'VIPER', 'RAVEN', 'FALCON', 'TITAN', 'ECHO', 'ONYX', 'COBALT', 'JADE', 'ORACLE'].map(encodeBytes32String);
const SUFFIXES = ['7X4', '9K2', '3Z7', '1A8', '5M3', '2R6', '8P1', '4W9', '6Y5', '0T2', 'K1X', 'Q6C'].map(encodeBytes32String);
const callsign = (p: number, s: number) => keccak256(concat([PREFIXES[p], SUFFIXES[s]]));

interface Soldier {
	callsign: string;
	rank: number;
	unitId: number;
	tasksCompleted: number;
	totalEarned: bigint;
	enlistedAt: number;
	invitedBy: string;
	lastPromotion: number;
	pldc: boolean;
}
interface Unit { name: string; leader: string; createdAt: number; members: string[] }
interface Objective { unitId: number; brief: string; taskCount: number; completedTasks: number }
interface Task { objectiveId: number; assignee: string; brief: string; reward: bigint; deadline: number; status: number; submission: string }

const OPEN = 0, ASSIGNED = 1, SUBMITTED = 2, APPROVED = 3, REJECTED = 4;
const now = () => Math.floor(Date.now() / 1000);
const DAY = 86400;
const later = (minMs: number, maxMs: number, fn: () => void) => setTimeout(fn, minMs + Math.random() * (maxMs - minMs));

// ── State ──────────────────────────────────────────────────────

const state = {
	walletChainId: 1, // a student starts on Ethereum mainnet, so the network step shows
	connected: false,
	block: 0x2a0000,
	eth: new Map<string, bigint>(),
	soldiers: new Map<string, Soldier>(),
	units: new Map<number, Unit>([
		[1, { name: keccak256(toUtf8Bytes('Alpha Squad')), leader: INSTRUCTOR, createdAt: now() - 90 * DAY, members: [] }],
		[DEMO_SQUAD_ID, { name: encodeBytes32String(cohort.name), leader: INSTRUCTOR, createdAt: now() - 20 * DAY, members: [] }],
	]),
	objectives: [] as Objective[],
	tasks: [] as Task[],
	pending: new Map<string, bigint>(),
	receipts: new Map<string, { tx: object; receipt: object }>(),
	batches: new Map<string, object>(),
};

const soldierOf = (addr: string) => state.soldiers.get(String(addr).toLowerCase());

function enlist(address: string, soldier: Soldier) {
	state.soldiers.set(address.toLowerCase(), soldier);
	state.units.get(soldier.unitId)?.members.push(address);
}

const veteran = (cs: string, rank: number, tasks: number, invitedBy = INSTRUCTOR, promotedDaysAgo = 10): Soldier => ({
	callsign: cs,
	rank,
	unitId: DEMO_SQUAD_ID,
	tasksCompleted: tasks,
	totalEarned: (REWARD * BigInt(MULTIPLIERS[rank]) * BigInt(tasks)) / 100n,
	enlistedAt: now() - 16 * DAY,
	invitedBy,
	lastPromotion: rank > 1 ? now() - promotedDaysAgo * DAY : 0,
	pldc: false,
});

enlist(INSTRUCTOR, { ...veteran(callsign(4, 0), 9, 14, ZeroAddress), enlistedAt: now() - 90 * DAY });
enlist(CLASSMATES[0], veteran(callsign(0, 1), 3, 2));
enlist(CLASSMATES[1], veteran(callsign(2, 2), 2, 2, INSTRUCTOR, 2)); // promoted two days ago: still in cooldown
enlist(CLASSMATES[2], veteran(callsign(3, 3), 2, 1, CLASSMATES[0]));
enlist(CLASSMATES[3], veteran(callsign(5, 4), 1, 1));
enlist(CLASSMATES[4], veteran(callsign(6, 5), 1, 0, CLASSMATES[1]));

// Weeks 1–3 are posted; week 3 has an open copy for a visiting student.
cohort.weeks.slice(0, 3).forEach((week) => {
	state.objectives.push({ unitId: DEMO_SQUAD_ID, brief: keccak256(toUtf8Bytes(weekBrief(cohort, week))), taskCount: 0, completedTasks: 0 });
});
const assignmentBrief = (week: number) => keccak256(toUtf8Bytes(cohort.weeks[week - 1]?.assignment ?? ''));
function addTask(week: number, assignee: string, status: number) {
	const objective = state.objectives[week - 1];
	state.tasks.push({
		objectiveId: week,
		assignee,
		brief: assignmentBrief(week),
		reward: REWARD,
		deadline: 0,
		status,
		submission: status >= SUBMITTED ? keccak256(toUtf8Bytes(`${assignee}-${week}`)) : ZeroHash,
	});
	objective.taskCount++;
	if (status === APPROVED) objective.completedTasks++;
}
CLASSMATES.slice(0, 4).forEach((c) => addTask(1, c, APPROVED));
CLASSMATES.slice(0, 2).forEach((c) => addTask(2, c, APPROVED));
addTask(2, CLASSMATES[2], SUBMITTED);
addTask(2, CLASSMATES[3], ASSIGNED);
addTask(3, CLASSMATES[0], SUBMITTED);
addTask(3, CLASSMATES[1], ASSIGNED);
addTask(3, ZeroAddress, OPEN);

// ── Change notifications (simulated people act on timers) ──────

const listeners = new Set<() => void>();
export function onDemoChange(fn: () => void): () => void {
	listeners.add(fn);
	return () => listeners.delete(fn);
}
const notify = () => listeners.forEach((fn) => fn());

/** The faucet, simulated: credit the demo wallet with test ETH. */
export function demoFaucet(): void {
	state.eth.set(DEMO_STUDENT.toLowerCase(), parseEther('0.01'));
	notify();
}

// ── Contract rules ─────────────────────────────────────────────

class Revert extends Error {
	code = 3;
	data: string;
	constructor(reason: string, data?: string) {
		super(`execution reverted: ${reason}`);
		this.data = data ?? '0x08c379a0' + AbiCoder.defaultAbiCoder().encode(['string'], [reason]).slice(2);
	}
}
const PANIC_OUT_OF_BOUNDS = '0x4e487b71' + AbiCoder.defaultAbiCoder().encode(['uint256'], [0x32]).slice(2);

/** RankManager.canPromote. */
function canPromote(promoter: string, target: string, newRank: number): boolean {
	const p = soldierOf(promoter)?.rank ?? 0;
	const t = soldierOf(target);
	if (!t || newRank !== t.rank + 1) return false;
	if (now() < t.lastPromotion + COOLDOWN) return false;
	if (newRank === 2) return p >= 6;
	if (newRank === 3 || newRank === 4) return p >= 9;
	if (newRank === 5) return p >= 11 && t.pldc;
	if (newRank >= 6) return p === 11;
	return false;
}

/** TaskRegistry's "unit leader, second in command or DAO" check. */
function requireLeader(from: string, unitId: number) {
	if (state.units.get(unitId)?.leader.toLowerCase() !== from.toLowerCase()) throw new Revert('Not authorized');
}

function pay(task: Task) {
	const s = soldierOf(task.assignee);
	if (!s) return;
	const amount = (task.reward * BigInt(MULTIPLIERS[s.rank])) / 100n;
	task.status = APPROVED;
	state.objectives[task.objectiveId - 1].completedTasks++;
	s.tasksCompleted++;
	s.totalEarned += amount;
	state.pending.set(task.assignee.toLowerCase(), (state.pending.get(task.assignee.toLowerCase()) ?? 0n) + amount);
}

/** Student demo: the simulated instructor approves the visitor's work, pays it and promotes them. */
function simulatedReview(taskIndex: number) {
	const task = state.tasks[taskIndex];
	const s = soldierOf(task.assignee);
	if (!s || task.status !== SUBMITTED) return;
	pay(task);
	if (s.rank < 2) {
		s.rank = 2;
		s.lastPromotion = now();
	}
	notify();
}

/** Instructor demo: a simulated classmate hands in (or fixes) their work after a while. */
function simulatedSubmit(taskIndex: number, minMs = 5000, maxMs = 9000) {
	later(minMs, maxMs, () => {
		const task = state.tasks[taskIndex];
		if (!task || (task.status !== ASSIGNED && task.status !== REJECTED)) return;
		task.submission = keccak256(toUtf8Bytes(`${task.assignee}-${taskIndex}-${Date.now()}`));
		task.status = SUBMITTED;
		notify();
	});
}

/** Instructor demo: a classmate without a copy of this week's assignment takes an open one. */
const claiming = new Set<string>();
function simulatedTake(taskIndex: number) {
	const task = state.tasks[taskIndex];
	if (!task) return;
	const taken = new Set(state.tasks.filter((t) => t.objectiveId === task.objectiveId).map((t) => t.assignee.toLowerCase()));
	const mate = CLASSMATES.find((c) => !taken.has(c.toLowerCase()) && !claiming.has(`${task.objectiveId}:${c}`));
	if (!mate) return;
	claiming.add(`${task.objectiveId}:${mate}`);
	later(2500, 5000, () => {
		claiming.delete(`${task.objectiveId}:${mate}`);
		if (state.tasks[taskIndex] !== task || task.status !== OPEN) return; // rolled back, or taken meanwhile
		task.assignee = mate;
		task.status = ASSIGNED;
		notify();
		simulatedSubmit(taskIndex);
	});
}

const isClassmate = (addr: string) => CLASSMATES.some((c) => c.toLowerCase() === addr.toLowerCase());

// ── Contract calls ─────────────────────────────────────────────

function call(to: string, data: string): string {
	const contract = CONTRACTS[to.toLowerCase()];
	if (!contract) throw new Revert('unknown contract');
	const parsed = contract.iface.parseTransaction({ data });
	if (!parsed) throw new Revert('unknown function');
	const out = (...values: unknown[]) => contract.iface.encodeFunctionResult(parsed.fragment, values);
	const args = parsed.args;
	const a0 = args.length > 0 ? args[0] : undefined;

	switch (`${contract.name}.${parsed.name}`) {
		case 'ArmyRegistry.getSoldier': {
			const s = soldierOf(a0);
			return out(s ? [s.callsign, s.rank, s.unitId, s.tasksCompleted, s.totalEarned, s.enlistedAt, s.invitedBy] : [ZeroHash, 0, 0, 0, 0, 0, ZeroAddress]);
		}
		case 'ArmyRegistry.getUnit': {
			const u = state.units.get(Number(a0));
			return out(u ? [0, u.name, u.leader, ZeroAddress, 0, u.members.length, u.createdAt, true] : [0, ZeroHash, ZeroAddress, ZeroAddress, 0, 0, 0, false]);
		}
		case 'ArmyRegistry.getUnitMembers':
			return out(state.units.get(Number(a0))?.members ?? []);
		case 'ArmyRegistry.nextUnitId':
			return out(state.units.size + 1);
		case 'ArmyRegistry.isEnlisted':
			return out(!!soldierOf(a0));
		case 'ArmyRegistry.prefixes':
		case 'ArmyRegistry.suffixes': {
			const list = parsed.name === 'prefixes' ? PREFIXES : SUFFIXES;
			if (Number(a0) >= list.length) throw new Revert('array out of bounds', PANIC_OUT_OF_BOUNDS);
			return out(list[Number(a0)]);
		}
		case 'TaskRegistry.nextObjectiveId':
			return out(state.objectives.length + 1);
		case 'TaskRegistry.nextTaskId':
			return out(state.tasks.length + 1);
		case 'TaskRegistry.getObjective': {
			const o = state.objectives[Number(a0) - 1];
			return out([0, o.unitId, o.brief, 0, o.taskCount, o.completedTasks, 0, INSTRUCTOR]);
		}
		case 'TaskRegistry.getTask': {
			const t = state.tasks[Number(a0) - 1];
			return out([t.objectiveId, t.assignee, t.brief, t.reward, t.deadline, t.status, t.submission, INSTRUCTOR]);
		}
		case 'TaskRegistry.hasRole':
		case 'RankManager.hasRole':
			return out(false); // nobody in the demo holds command's role
		case 'RankManager.MULTIPLIERS':
			return out(MULTIPLIERS[Number(a0)] ?? 0);
		case 'RankManager.promotionCooldown':
			return out(COOLDOWN);
		case 'RankManager.lastPromotionTime':
			return out(soldierOf(a0)?.lastPromotion ?? 0);
		case 'RankManager.hasCompletedPLDC':
			return out(soldierOf(a0)?.pldc ?? false);
		case 'RankManager.canPromote':
			return out(canPromote(a0, args[1], Number(args[2])));
		case 'RewardPool.pendingRewards':
		case 'RewardPool.getPendingRewards':
			return out(state.pending.get(String(a0).toLowerCase()) ?? 0n);
	}
	throw new Revert(`${parsed.name} is not simulated`);
}

function write(from: string, to: string, data: string) {
	const contract = CONTRACTS[to.toLowerCase()];
	const parsed = contract?.iface.parseTransaction({ data });
	if (!contract || !parsed) throw new Revert('unknown function');
	const me = from.toLowerCase();
	const args = parsed.args;
	const task = (id: unknown) => {
		const t = state.tasks[Number(id) - 1];
		if (!t) throw new Revert('Task not found');
		return t;
	};
	const unitOfTask = (t: Task) => state.objectives[t.objectiveId - 1].unitId;

	switch (`${contract.name}.${parsed.name}`) {
		// ── Students ──
		case 'ArmyRegistry.enlist':
		case 'ArmyRegistry.enlistWithInvite': {
			if (state.soldiers.has(me)) throw new Revert('Already enlisted');
			const taken = new Set([...state.soldiers.values()].map((s) => s.callsign));
			let cs = callsign(Math.floor(Math.random() * PREFIXES.length), Math.floor(Math.random() * SUFFIXES.length));
			while (taken.has(cs)) cs = callsign(Math.floor(Math.random() * PREFIXES.length), Math.floor(Math.random() * SUFFIXES.length));
			enlist(getAddress(from), {
				callsign: cs, rank: 1, unitId: Number(args[0]), tasksCompleted: 0, totalEarned: 0n, enlistedAt: now(),
				invitedBy: parsed.name === 'enlistWithInvite' ? args[1] : ZeroAddress, lastPromotion: 0, pldc: false,
			});
			return;
		}
		case 'TaskRegistry.selfAssignTask': {
			const t = task(args[0]);
			if (t.status !== OPEN) throw new Revert('Task not open');
			t.assignee = getAddress(from);
			t.status = ASSIGNED;
			return;
		}
		case 'TaskRegistry.submitTask':
		case 'TaskRegistry.resubmitTask': {
			const t = task(args[0]);
			if (t.assignee.toLowerCase() !== me) throw new Revert('Not assignee');
			t.submission = args[1];
			t.status = SUBMITTED;
			if (demoRole() === 'student') setTimeout(() => simulatedReview(Number(args[0]) - 1), REVIEW_DELAY_MS);
			return;
		}
		case 'RewardPool.claimRewards':
			if (!state.pending.get(me)) throw new Revert('No rewards to claim');
			state.pending.set(me, 0n);
			return;

		// ── Instructor ──
		case 'TaskRegistry.createObjective': {
			const unitId = Number(args[1]);
			requireLeader(from, unitId);
			state.objectives.push({ unitId, brief: args[2], taskCount: 0, completedTasks: 0 });
			return;
		}
		case 'TaskRegistry.createTask': {
			const objective = state.objectives[Number(args[0]) - 1];
			if (!objective) throw new Revert('Objective not active');
			requireLeader(from, objective.unitId);
			state.tasks.push({ objectiveId: Number(args[0]), assignee: ZeroAddress, brief: args[1], reward: args[2], deadline: Number(args[3]), status: OPEN, submission: ZeroHash });
			objective.taskCount++;
			simulatedTake(state.tasks.length - 1);
			return;
		}
		case 'TaskRegistry.assignTask': {
			const t = task(args[0]);
			if (t.status !== OPEN) throw new Revert('Task not open');
			requireLeader(from, unitOfTask(t));
			if (!soldierOf(args[1])) throw new Revert('Soldier not enlisted');
			t.assignee = getAddress(args[1]);
			t.status = ASSIGNED;
			if (isClassmate(t.assignee)) simulatedSubmit(Number(args[0]) - 1);
			return;
		}
		case 'TaskRegistry.approveTask': {
			const t = task(args[0]);
			if (t.status !== SUBMITTED) throw new Revert('Task not submitted');
			requireLeader(from, unitOfTask(t));
			pay(t);
			return;
		}
		case 'TaskRegistry.rejectTask': {
			const t = task(args[0]);
			if (t.status !== SUBMITTED) throw new Revert('Task not submitted');
			requireLeader(from, unitOfTask(t));
			t.status = REJECTED;
			if (isClassmate(t.assignee)) simulatedSubmit(Number(args[0]) - 1, 7000, 11000);
			return;
		}
		case 'RankManager.promote': {
			const newRank = Number(args[1]);
			if (!canPromote(from, args[0], newRank)) throw new Revert('Not authorized to promote');
			const s = soldierOf(args[0])!;
			s.rank = newRank;
			s.lastPromotion = now();
			return;
		}
		case 'RankManager.daoPromote':
		case 'RankManager.completePLDC':
			throw new Revert('AccessControl: account is missing role');
	}
	throw new Revert(`${parsed.name} is not simulated`);
}

// ── JSON-RPC ───────────────────────────────────────────────────

function rpc(method: string, params: unknown[], chainId: number): unknown {
	const p0 = params[0] as Record<string, string>;
	switch (method) {
		case 'eth_chainId':
			return toQuantity(chainId);
		case 'net_version':
			return String(chainId);
		case 'eth_blockNumber':
			return toQuantity(++state.block);
		case 'eth_getBalance':
			return toQuantity(state.eth.get(String(params[0]).toLowerCase()) ?? 0n);
		case 'eth_call':
			return call(p0.to, p0.data ?? p0.input);
		case 'eth_estimateGas':
			return toQuantity(200_000);
		case 'eth_gasPrice':
		case 'eth_maxPriorityFeePerGas':
			return toQuantity(1_000_000);
		case 'eth_getBlockByNumber':
			return {
				number: toQuantity(state.block),
				hash: keccak256(toUtf8Bytes(`block-${state.block}`)),
				parentHash: ZeroHash,
				timestamp: toQuantity(now()),
				baseFeePerGas: toQuantity(1_000_000),
				gasLimit: toQuantity(30_000_000),
				gasUsed: '0x0',
				miner: ZeroAddress,
				difficulty: '0x0',
				extraData: '0x',
				nonce: '0x0000000000000000',
				transactions: [],
			};
		case 'eth_getTransactionByHash':
			return state.receipts.get(String(params[0]))?.tx ?? null;
		case 'eth_getTransactionReceipt':
			return state.receipts.get(String(params[0]))?.receipt ?? null;
	}
	throw new Error(`${method} is not simulated`);
}

function record(from: string, to: string, data: string) {
	const hash = keccak256(toUtf8Bytes(`${data}-${Date.now()}-${Math.random()}`));
	const blockNumber = toQuantity(++state.block);
	const blockHash = keccak256(toUtf8Bytes(`block-${state.block}`));
	const receipt = {
		transactionHash: hash, blockHash, blockNumber, transactionIndex: '0x0', from, to,
		contractAddress: null, cumulativeGasUsed: toQuantity(100_000), gasUsed: toQuantity(100_000),
		effectiveGasPrice: toQuantity(1_000_000), logs: [], logsBloom: '0x' + '00'.repeat(256), status: '0x1', type: '0x0',
	};
	state.receipts.set(hash, {
		tx: {
			hash, from, to, input: data, value: '0x0', nonce: '0x1', gas: toQuantity(200_000),
			gasPrice: toQuantity(1_000_000), chainId: CHAIN_HEX, type: '0x0', blockNumber, blockHash,
			transactionIndex: '0x0', v: '0x1b', r: '0x' + '11'.repeat(32), s: '0x' + '22'.repeat(32),
		},
		receipt,
	});
	return { hash, receipt };
}

function sendTransaction(tx: Record<string, string>): string {
	write(tx.from, tx.to, tx.data);
	return record(tx.from, tx.to, tx.data).hash;
}

/** EIP-5792 wallet_sendCalls: all calls or none. */
function sendCalls(request: { from: string; calls: { to: string; data: string }[] }): { id: string } {
	const snapshot = structuredClone({
		soldiers: state.soldiers, units: state.units, objectives: state.objectives, tasks: state.tasks, pending: state.pending,
	});
	try {
		for (const c of request.calls) write(request.from, c.to, c.data);
	} catch (e) {
		Object.assign(state, snapshot);
		throw e;
	}
	const receipts = request.calls.map((c) => record(request.from, c.to, c.data).receipt);
	const id = keccak256(toUtf8Bytes(`batch-${Date.now()}-${Math.random()}`));
	state.batches.set(id, { version: '2.0.0', id, chainId: CHAIN_HEX, status: 200, atomic: true, receipts });
	return { id };
}

// ── Wallet and read provider ───────────────────────────────────

const account = () => (demoRole() === 'instructor' ? INSTRUCTOR : DEMO_STUDENT);
const walletListeners: Record<string, ((...args: unknown[]) => void)[]> = {};
const emit = (event: string, value: unknown) => (walletListeners[event] ?? []).forEach((fn) => fn(value));
const slow = (method: string) => method.startsWith('eth_send') || method === 'wallet_sendCalls' || method.startsWith('wallet_switch') || method === 'eth_requestAccounts';

const demoWallet: Eip1193Provider = {
	isMetaMask: true,
	async request<T = unknown>({ method, params }: { method: string; params?: readonly unknown[] | object }): Promise<T> {
		const list = (Array.isArray(params) ? params : []) as unknown[];
		await new Promise((r) => setTimeout(r, slow(method) ? 600 : 0));
		switch (method) {
			case 'eth_accounts':
				return (state.connected ? [account()] : []) as T;
			case 'eth_requestAccounts':
				state.connected = true;
				return [account()] as T;
			case 'wallet_switchEthereumChain':
			case 'wallet_addEthereumChain': {
				state.walletChainId = parseInt((list[0] as { chainId: string }).chainId, 16);
				setTimeout(() => emit('chainChanged', toQuantity(state.walletChainId)), 0);
				return null as T;
			}
			case 'eth_sendTransaction':
				return sendTransaction(list[0] as Record<string, string>) as T;
			case 'wallet_getCapabilities':
				return { [CHAIN_HEX]: { atomic: { status: 'supported' } } } as T;
			case 'wallet_sendCalls':
				return sendCalls(list[0] as { from: string; calls: { to: string; data: string }[] }) as T;
			case 'wallet_getCallsStatus': {
				const status = state.batches.get(String(list[0]));
				if (!status) throw Object.assign(new Error('Unknown bundle id'), { code: 5730 });
				return status as T;
			}
		}
		return rpc(method, list, state.walletChainId) as T;
	},
	on(event, listener) {
		(walletListeners[event] ??= []).push(listener);
	},
	removeListener(event, listener) {
		walletListeners[event] = (walletListeners[event] ?? []).filter((fn) => fn !== listener);
	},
};

/** Replace the browser wallet with the simulated one for this tab. */
export function installDemo(): void {
	if (demoRole() === 'instructor') {
		// The instructor arrives ready: connected, on Base Sepolia, with test ETH.
		state.connected = true;
		state.walletChainId = BASE_SEPOLIA_CHAIN_ID;
		state.eth.set(INSTRUCTOR.toLowerCase(), parseEther('0.05'));
	}
	window.ethereum = demoWallet;
}

let reader: BrowserProvider | null = null;

/** Read-only provider over the simulated chain, always on Base Sepolia. */
export function demoReadProvider(): BrowserProvider {
	reader ??= new BrowserProvider(
		{ request: async ({ method, params }) => rpc(method, (params ?? []) as unknown[], BASE_SEPOLIA_CHAIN_ID) },
		BASE_SEPOLIA_CHAIN_ID,
		{ staticNetwork: true }
	);
	return reader;
}
