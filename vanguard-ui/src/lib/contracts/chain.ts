// ═══════════════════════════════════════════════════════════════
// Chain reads for the live pages: one read-only provider (independent
// of the network the wallet is on), typed records for members, units,
// objectives and tasks, and loaders that scan the registries by id.
// The counts are small on testnet; an event indexer replaces the scans
// later (WORKPLAN.md, section 3).
// ═══════════════════════════════════════════════════════════════

import {
	JsonRpcProvider,
	ZeroAddress,
	type JsonRpcApiProvider,
	decodeBytes32String,
	formatEther,
	keccak256,
	toUtf8Bytes,
} from 'ethers';
import { RANKS, type Rank } from '$lib/types';
import { BASE_SEPOLIA_CHAIN_ID, RPC_URL_OVERRIDE } from './addresses';
import { getArmyRegistry, getRankManager, getRewardPool, getTaskRegistry } from './contracts.svelte';
import { callsignFor, loadCallsignTable, type CallsignTable } from './callsigns';
import { isDemo } from '$lib/demo/flag';
import { demoReadProvider } from '$lib/demo/mock-chain';

const READ_RPC_URLS = RPC_URL_OVERRIDE ? [RPC_URL_OVERRIDE] : ['https://sepolia.base.org', 'https://base-sepolia-rpc.publicnode.com'];

let providerPromise: Promise<JsonRpcProvider> | null = null;

async function connectRead(): Promise<JsonRpcProvider> {
	for (const url of READ_RPC_URLS) {
		const provider = new JsonRpcProvider(url, BASE_SEPOLIA_CHAIN_ID, { staticNetwork: true });
		try {
			await provider.getBlockNumber();
			return provider;
		} catch {
			provider.destroy();
		}
	}
	throw new Error('Could not reach Base Sepolia. Check your connection and try again.');
}

/** Shared read-only provider for Base Sepolia (the simulated chain in demo mode). */
export function readProvider(): Promise<JsonRpcApiProvider> {
	if (isDemo()) return Promise.resolve(demoReadProvider());
	providerPromise ??= connectRead().catch((e) => {
		providerPromise = null;
		throw e;
	});
	return providerPromise;
}

// ── Records ────────────────────────────────────────────────────

export interface ChainMember {
	address: string;
	callsign: string;
	/** On-chain rank index: 0 = not enlisted, 1 = PVT … 11 = CPT. */
	rankIndex: number;
	rank: Rank;
	unitId: number;
	tasksCompleted: number;
	totalEarned: bigint;
	enlistedAt: Date;
	invitedBy: string | null;
}

export interface ChainUnit {
	id: number;
	name: string;
	leader: string | null;
	secondInCommand: string | null;
	memberCount: number;
	active: boolean;
}

export type ObjectiveState = 'active' | 'completed' | 'cancelled';

export interface ChainObjective {
	id: number;
	bountyId: number;
	unitId: number;
	briefHash: string;
	taskCount: number;
	completedTasks: number;
	state: ObjectiveState;
}

export type TaskState = 'open' | 'assigned' | 'submitted' | 'approved' | 'rejected';

export interface ChainTask {
	id: number;
	objectiveId: number;
	assignee: string | null;
	briefHash: string;
	reward: bigint;
	/** Unix seconds; 0 means no deadline. */
	deadline: number;
	state: TaskState;
	submission: string | null;
}

const OBJECTIVE_STATES: ObjectiveState[] = ['active', 'completed', 'cancelled'];
const TASK_STATES: TaskState[] = ['open', 'assigned', 'submitted', 'approved', 'rejected'];

/** UI rank code for an on-chain rank index (GUEST shows as PVT). */
export function rankCode(rankIndex: number): Rank {
	return RANKS[Math.max(0, rankIndex - 1)] ?? 'PVT';
}

export function sameAddress(a: string | null | undefined, b: string | null | undefined): boolean {
	return !!a && !!b && a.toLowerCase() === b.toLowerCase();
}

const orNull = (address: string) => (address === ZeroAddress ? null : address);

// Units named with a hash rather than a short string.
const KNOWN_UNIT_NAMES = new Map([[keccak256(toUtf8Bytes('Alpha Squad')), 'Alpha Squad']]);

function decodeName(raw: string, fallback: string): string {
	const known = KNOWN_UNIT_NAMES.get(raw);
	if (known) return known;
	try {
		const text = decodeBytes32String(raw);
		if (/^[\x20-\x7e]+$/.test(text)) return text;
	} catch {
		// a hash, not a short string
	}
	return fallback;
}

// ── Callsigns (cached for the session) ─────────────────────────

let callsignPromise: Promise<CallsignTable> | null = null;

function callsignTable(): Promise<CallsignTable> {
	callsignPromise ??= readProvider()
		.then((p) => loadCallsignTable(getArmyRegistry(p)))
		.catch(() => {
			callsignPromise = null;
			return new Map();
		});
	return callsignPromise;
}

// ── Loaders ────────────────────────────────────────────────────

/** Read ids 1..count in batches so a public RPC isn't flooded. */
async function readIds<T>(count: number, read: (id: number) => Promise<T>): Promise<T[]> {
	const out: T[] = [];
	for (let start = 1; start <= count; start += 25) {
		const ids = Array.from({ length: Math.min(25, count - start + 1) }, (_, i) => start + i);
		out.push(...(await Promise.all(ids.map(read))));
	}
	return out;
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
function toMember(address: string, s: any, table: CallsignTable): ChainMember {
	const rankIndex = Number(s.rank);
	return {
		address,
		callsign: callsignFor(table, s.callsign, address),
		rankIndex,
		rank: rankCode(rankIndex),
		unitId: Number(s.unitId),
		tasksCompleted: Number(s.tasksCompleted),
		totalEarned: s.totalEarned as bigint,
		enlistedAt: new Date(Number(s.enlistedAt) * 1000),
		invitedBy: orNull(s.invitedBy),
	};
}

/** The member record for a wallet, or null if it hasn't enlisted. */
export async function loadMember(address: string): Promise<ChainMember | null> {
	const registry = getArmyRegistry(await readProvider());
	const [soldier, table] = await Promise.all([registry.getSoldier(address), callsignTable()]);
	if (soldier.enlistedAt === 0n) return null;
	return toMember(address, soldier, table);
}

export async function loadUnit(unitId: number): Promise<ChainUnit | null> {
	const unit = await getArmyRegistry(await readProvider()).getUnit(unitId);
	if (unit.createdAt === 0n) return null;
	return {
		id: unitId,
		name: decodeName(unit.name, `Squad ${unitId}`),
		leader: orNull(unit.leader),
		secondInCommand: orNull(unit.secondInCommand),
		memberCount: Number(unit.memberCount),
		active: unit.active,
	};
}

export async function loadUnitMembers(unitId: number): Promise<ChainMember[]> {
	const registry = getArmyRegistry(await readProvider());
	const [addresses, table] = await Promise.all([
		registry.getUnitMembers(unitId) as Promise<string[]>,
		callsignTable(),
	]);
	const records = await Promise.all(addresses.map((a) => registry.getSoldier(a)));
	return addresses.map((a, i) => toMember(a, records[i], table));
}

/** Every enlisted member, across all units. */
export async function loadAllMembers(): Promise<ChainMember[]> {
	const registry = getArmyRegistry(await readProvider());
	const nextUnitId = Number(await registry.nextUnitId());
	const lists = await readIds(nextUnitId - 1, (id) => registry.getUnitMembers(id) as Promise<string[]>);
	const seen = new Set<string>();
	const addresses = lists.flat().filter((a) => {
		const key = a.toLowerCase();
		if (a === ZeroAddress || seen.has(key)) return false;
		seen.add(key);
		return true;
	});
	const [records, table] = await Promise.all([
		Promise.all(addresses.map((a) => registry.getSoldier(a))),
		callsignTable(),
	]);
	return addresses.map((a, i) => toMember(a, records[i], table));
}

export async function loadObjectives(): Promise<ChainObjective[]> {
	const registry = getTaskRegistry(await readProvider());
	const next = Number(await registry.nextObjectiveId());
	return readIds(next - 1, async (id) => {
		const o = await registry.getObjective(id);
		return {
			id,
			bountyId: Number(o.bountyId),
			unitId: Number(o.unitId),
			briefHash: o.descriptionHash as string,
			taskCount: Number(o.taskCount),
			completedTasks: Number(o.completedTasks),
			state: OBJECTIVE_STATES[Number(o.status)] ?? 'active',
		};
	});
}

export async function loadTasks(): Promise<ChainTask[]> {
	const registry = getTaskRegistry(await readProvider());
	const next = Number(await registry.nextTaskId());
	return readIds(next - 1, async (id) => {
		const t = await registry.getTask(id);
		return {
			id,
			objectiveId: Number(t.objectiveId),
			assignee: orNull(t.assignee),
			briefHash: t.descriptionHash as string,
			reward: t.rewardAmount as bigint,
			deadline: Number(t.deadline),
			state: TASK_STATES[Number(t.status)] ?? 'open',
			submission: /^0x0+$/.test(t.submissionHash) ? null : (t.submissionHash as string),
		};
	});
}

/** Pay multipliers per rank index, in basis points (100 = 1.0×). */
export async function loadMultipliers(): Promise<number[]> {
	const rankManager = getRankManager(await readProvider());
	return Promise.all(Array.from({ length: 12 }, async (_, i) => Number(await rankManager.MULTIPLIERS(i))));
}

export async function loadEthBalance(address: string): Promise<bigint> {
	return (await readProvider()).getBalance(address);
}

export async function loadPendingPay(address: string): Promise<bigint> {
	return getRewardPool(await readProvider()).pendingRewards(address) as Promise<bigint>;
}

/** What a task pays a member: base reward × their rank multiplier. */
export function payFor(reward: bigint, multiplierBps: number): bigint {
	return (reward * BigInt(multiplierBps)) / 100n;
}

export function formatToken(wei: bigint, digits = 2): string {
	return Number(formatEther(wei)).toLocaleString('en-US', { maximumFractionDigits: digits });
}

export function formatMultiplier(bps: number): string {
	return `${(bps / 100).toFixed(bps % 10 === 0 ? 1 : 2)}×`;
}

// ── Roles and promotions ───────────────────────────────────────

/** keccak256("DAO_ROLE"): command's role on TaskRegistry and RankManager. */
export const DAO_ROLE = keccak256(toUtf8Bytes('DAO_ROLE'));

export interface Roles {
	/** Can create, assign and review work in any unit. */
	taskAdmin: boolean;
	/** Can promote anyone to any rank and record training (daoPromote, completePLDC). */
	rankAdmin: boolean;
}

export async function loadRoles(address: string): Promise<Roles> {
	const p = await readProvider();
	const [taskAdmin, rankAdmin] = await Promise.all([
		getTaskRegistry(p).hasRole(DAO_ROLE, address) as Promise<boolean>,
		getRankManager(p).hasRole(DAO_ROLE, address) as Promise<boolean>,
	]);
	return { taskAdmin, rankAdmin };
}

export interface PromotionRecord {
	/** When the member was last promoted, or null if never. */
	lastPromotion: Date | null;
	/** The leadership course (PLDC) is recorded: required for sergeant. */
	pldc: boolean;
	/** RankManager.canPromote(promoter, member, rank + 1); false at captain or without a promoter. */
	canPromote: boolean;
}

export async function loadPromotionRecords(members: ChainMember[], promoter: string | null): Promise<Map<string, PromotionRecord>> {
	const rankManager = getRankManager(await readProvider());
	const records = await Promise.all(
		members.map(async (m) => {
			const next = m.rankIndex + 1;
			const [last, pldc, can] = await Promise.all([
				rankManager.lastPromotionTime(m.address) as Promise<bigint>,
				rankManager.hasCompletedPLDC(m.address) as Promise<boolean>,
				promoter && next <= 11 ? (rankManager.canPromote(promoter, m.address, next) as Promise<boolean>) : false,
			]);
			return [m.address.toLowerCase(), { lastPromotion: last > 0n ? new Date(Number(last) * 1000) : null, pldc, canPromote: can }] as const;
		})
	);
	return new Map(records);
}

/** Minimum time between two promotions of the same member, in seconds. */
export async function loadPromotionCooldown(): Promise<number> {
	return Number(await getRankManager(await readProvider()).promotionCooldown());
}
