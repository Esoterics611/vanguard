// ═══════════════════════════════════════════════════════════════
// Demo mode's simulated chain and wallet.
//
// An in-memory stand-in for the deployed contracts, answering the same
// calls through the app's own ABIs, plus an EIP-1193 wallet that starts
// disconnected on the wrong network with no test ETH. A cohort is in
// week three: classmates have handed in work, and one assignment is
// open. After a submission, a simulated instructor approves it, pays
// it, and promotes the student a few seconds later.
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
import { DEMO_SQUAD_ID } from './flag';

const abi = (artifact: unknown) => (artifact as { abi: InterfaceAbi }).abi;
const CONTRACTS: Record<string, { name: string; iface: Interface }> = {
	[addresses.ArmyRegistry.toLowerCase()]: { name: 'ArmyRegistry', iface: new Interface(abi(ArmyRegistryArtifact)) },
	[addresses.RankManager.toLowerCase()]: { name: 'RankManager', iface: new Interface(abi(RankManagerArtifact)) },
	[addresses.RewardPool.toLowerCase()]: { name: 'RewardPool', iface: new Interface(abi(RewardPoolArtifact)) },
	[addresses.TaskRegistry.toLowerCase()]: { name: 'TaskRegistry', iface: new Interface(abi(TaskRegistryArtifact)) },
};

const MULTIPLIERS = [0, 100, 120, 150, 200, 300, 400, 500, 600, 800, 1000, 1500];
const REWARD = parseEther('100');
const REVIEW_DELAY_MS = 6000;

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
}
interface Unit { name: string; leader: string; createdAt: number; members: string[] }
interface Objective { unitId: number; brief: string; taskCount: number; completedTasks: number }
interface Task { objectiveId: number; assignee: string; brief: string; reward: bigint; status: number; submission: string }

const now = () => Math.floor(Date.now() / 1000);
const DAY = 86400;

// ── State ──────────────────────────────────────────────────────

const cohort = COHORTS[0];
const state = {
	walletChainId: 1, // starts on Ethereum mainnet, so the network step shows
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
};

function enlist(address: string, soldier: Soldier) {
	state.soldiers.set(address.toLowerCase(), soldier);
	state.units.get(soldier.unitId)?.members.push(address);
}

const veteran = (cs: string, rank: number, tasks: number, invitedBy = INSTRUCTOR): Soldier => ({
	callsign: cs,
	rank,
	unitId: DEMO_SQUAD_ID,
	tasksCompleted: tasks,
	totalEarned: (REWARD * BigInt(MULTIPLIERS[rank]) * BigInt(tasks)) / 100n,
	enlistedAt: now() - 16 * DAY,
	invitedBy,
});

enlist(INSTRUCTOR, { ...veteran(callsign(4, 0), 9, 14, ZeroAddress), enlistedAt: now() - 90 * DAY });
enlist(CLASSMATES[0], veteran(callsign(0, 1), 3, 2));
enlist(CLASSMATES[1], veteran(callsign(2, 2), 2, 2));
enlist(CLASSMATES[2], veteran(callsign(3, 3), 2, 1, CLASSMATES[0]));
enlist(CLASSMATES[3], veteran(callsign(5, 4), 1, 1));
enlist(CLASSMATES[4], veteran(callsign(6, 5), 1, 0, CLASSMATES[1]));

// Weeks 1–3 are posted; week 3's assignment has one open copy for the visitor.
cohort.weeks.slice(0, 3).forEach((week) => {
	state.objectives.push({ unitId: DEMO_SQUAD_ID, brief: keccak256(toUtf8Bytes(weekBrief(cohort, week))), taskCount: 0, completedTasks: 0 });
});
function addTask(week: number, assignee: string, status: number) {
	const objective = state.objectives[week - 1];
	state.tasks.push({
		objectiveId: week,
		assignee,
		brief: keccak256(toUtf8Bytes(cohort.weeks[week - 1].assignment)),
		reward: REWARD,
		status,
		submission: status >= 2 ? keccak256(toUtf8Bytes(`${assignee}-${week}`)) : ZeroHash,
	});
	objective.taskCount++;
	if (status === 3) objective.completedTasks++;
}
CLASSMATES.slice(0, 4).forEach((c) => addTask(1, c, 3));
CLASSMATES.slice(0, 2).forEach((c) => addTask(2, c, 3));
addTask(2, CLASSMATES[2], 2);
addTask(3, CLASSMATES[0], 2);
addTask(3, ZeroAddress, 0);

// ── Change notifications (the simulated instructor acts on a timer) ──

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

// ── Contract calls ─────────────────────────────────────────────

class Revert extends Error {
	code = 3;
	data: string;
	constructor(reason: string, data?: string) {
		super(`execution reverted: ${reason}`);
		this.data = data ?? '0x08c379a0' + AbiCoder.defaultAbiCoder().encode(['string'], [reason]).slice(2);
	}
}
const PANIC_OUT_OF_BOUNDS = '0x4e487b71' + AbiCoder.defaultAbiCoder().encode(['uint256'], [0x32]).slice(2);

function call(to: string, data: string): string {
	const contract = CONTRACTS[to.toLowerCase()];
	if (!contract) throw new Revert('unknown contract');
	const parsed = contract.iface.parseTransaction({ data });
	if (!parsed) throw new Revert('unknown function');
	const out = (...values: unknown[]) => contract.iface.encodeFunctionResult(parsed.fragment, values);
	const [a0] = parsed.args;
	const soldier = (addr: string) => state.soldiers.get(String(addr).toLowerCase());

	switch (`${contract.name}.${parsed.name}`) {
		case 'ArmyRegistry.getSoldier': {
			const s = soldier(a0);
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
			return out(!!soldier(a0));
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
			return out([t.objectiveId, t.assignee, t.brief, t.reward, 0, t.status, t.submission, INSTRUCTOR]);
		}
		case 'RankManager.MULTIPLIERS':
			return out(MULTIPLIERS[Number(a0)] ?? 0);
		case 'RewardPool.pendingRewards':
		case 'RewardPool.getPendingRewards':
			return out(state.pending.get(String(a0).toLowerCase()) ?? 0n);
	}
	throw new Revert(`${parsed.name} is not simulated`);
}

/** The simulated instructor's review: approve, pay at the student's rank, promote. */
function review(taskIndex: number) {
	const task = state.tasks[taskIndex];
	const s = state.soldiers.get(task.assignee.toLowerCase());
	if (!s || task.status !== 2) return;
	const pay = (task.reward * BigInt(MULTIPLIERS[s.rank])) / 100n;
	task.status = 3;
	state.objectives[task.objectiveId - 1].completedTasks++;
	s.tasksCompleted++;
	s.totalEarned += pay;
	state.pending.set(task.assignee.toLowerCase(), (state.pending.get(task.assignee.toLowerCase()) ?? 0n) + pay);
	if (s.rank < 2) s.rank = 2;
	notify();
}

function write(from: string, to: string, data: string) {
	const contract = CONTRACTS[to.toLowerCase()];
	const parsed = contract?.iface.parseTransaction({ data });
	if (!contract || !parsed) throw new Revert('unknown function');
	const me = from.toLowerCase();
	const args = parsed.args;

	switch (`${contract.name}.${parsed.name}`) {
		case 'ArmyRegistry.enlist':
		case 'ArmyRegistry.enlistWithInvite': {
			if (state.soldiers.has(me)) throw new Revert('Already enlisted');
			const taken = new Set([...state.soldiers.values()].map((s) => s.callsign));
			let cs = callsign(Math.floor(Math.random() * PREFIXES.length), Math.floor(Math.random() * SUFFIXES.length));
			while (taken.has(cs)) cs = callsign(Math.floor(Math.random() * PREFIXES.length), Math.floor(Math.random() * SUFFIXES.length));
			enlist(getAddress(from), { callsign: cs, rank: 1, unitId: Number(args[0]), tasksCompleted: 0, totalEarned: 0n, enlistedAt: now(), invitedBy: parsed.name === 'enlistWithInvite' ? args[1] : ZeroAddress });
			return;
		}
		case 'TaskRegistry.selfAssignTask': {
			const task = state.tasks[Number(args[0]) - 1];
			if (task.status !== 0) throw new Revert('Task not open');
			task.assignee = getAddress(from);
			task.status = 1;
			return;
		}
		case 'TaskRegistry.submitTask':
		case 'TaskRegistry.resubmitTask': {
			const index = Number(args[0]) - 1;
			state.tasks[index].submission = args[1];
			state.tasks[index].status = 2;
			setTimeout(() => review(index), REVIEW_DELAY_MS);
			return;
		}
		case 'RewardPool.claimRewards':
			if (!state.pending.get(me)) throw new Revert('No rewards to claim');
			state.pending.set(me, 0n);
			return;
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

function sendTransaction(tx: Record<string, string>): string {
	write(tx.from, tx.to, tx.data);
	const hash = keccak256(toUtf8Bytes(`${tx.data}-${Date.now()}-${Math.random()}`));
	const blockNumber = toQuantity(++state.block);
	const blockHash = keccak256(toUtf8Bytes(`block-${state.block}`));
	state.receipts.set(hash, {
		tx: {
			hash, from: tx.from, to: tx.to, input: tx.data, value: '0x0', nonce: '0x1', gas: toQuantity(200_000),
			gasPrice: toQuantity(1_000_000), chainId: toQuantity(BASE_SEPOLIA_CHAIN_ID), type: '0x0', blockNumber, blockHash,
			transactionIndex: '0x0', v: '0x1b', r: '0x' + '11'.repeat(32), s: '0x' + '22'.repeat(32),
		},
		receipt: {
			transactionHash: hash, blockHash, blockNumber, transactionIndex: '0x0', from: tx.from, to: tx.to,
			contractAddress: null, cumulativeGasUsed: toQuantity(100_000), gasUsed: toQuantity(100_000),
			effectiveGasPrice: toQuantity(1_000_000), logs: [], logsBloom: '0x' + '00'.repeat(256), status: '0x1', type: '0x0',
		},
	});
	return hash;
}

// ── Wallet and read provider ───────────────────────────────────

const walletListeners: Record<string, ((...args: unknown[]) => void)[]> = {};
const emit = (event: string, value: unknown) => (walletListeners[event] ?? []).forEach((fn) => fn(value));

const demoWallet: Eip1193Provider = {
	isMetaMask: true,
	async request<T = unknown>({ method, params }: { method: string; params?: readonly unknown[] | object }): Promise<T> {
		const list = (Array.isArray(params) ? params : []) as unknown[];
		await new Promise((r) => setTimeout(r, method.startsWith('eth_send') || method.startsWith('wallet_') || method === 'eth_requestAccounts' ? 600 : 0));
		switch (method) {
			case 'eth_accounts':
				return (state.connected ? [DEMO_STUDENT] : []) as T;
			case 'eth_requestAccounts':
				state.connected = true;
				return [DEMO_STUDENT] as T;
			case 'wallet_switchEthereumChain':
			case 'wallet_addEthereumChain': {
				state.walletChainId = parseInt((list[0] as { chainId: string }).chainId, 16);
				setTimeout(() => emit('chainChanged', toQuantity(state.walletChainId)), 0);
				return null as T;
			}
			case 'eth_sendTransaction':
				return sendTransaction(list[0] as Record<string, string>) as T;
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
