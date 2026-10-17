// ═══════════════════════════════════════════════════════════════
// Global reactive stores using Svelte 5 runes
// Extensible: add new stores as features grow
// ═══════════════════════════════════════════════════════════════

import {
	MOCK_SOLDIERS, MOCK_BOUNTIES, MOCK_OBJECTIVES, MOCK_TASKS,
	MOCK_ACTIVITIES, MOCK_UNITS, CURRENT_USER_ID
} from './mock-data';
import type { Soldier, Bounty, Objective, Task, Activity, Unit, DashboardStats, Rank } from '$lib/types';
import { RANK_META } from '$lib/types';

// ── Chain helpers (roster read) ────────────────────────────────

function bytes32ToString(hex: string): string {
	const trimmed = hex.replace(/^0x/, '');
	let result = '';
	for (let i = 0; i < trimmed.length; i += 2) {
		const code = parseInt(trimmed.slice(i, i + 2), 16);
		if (code === 0) break;
		result += String.fromCharCode(code);
	}
	return result;
}

// 12 on-chain rank slots: GUEST=0, PVT=1 … CPT=11
const CHAIN_RANK_MAP: Record<number, Rank> = {
	0: 'PVT', 1: 'PVT', 2: 'PV2', 3: 'PFC', 4: 'CPL',
	5: 'SGT', 6: 'SSG', 7: 'SFC', 8: '1SG', 9: '2LT', 10: '1LT', 11: 'CPT',
};

// ── App State ──────────────────────────────────────────────────

class AppStore {
	// Core data (replace with API calls later)
	soldiers = $state<Soldier[]>(MOCK_SOLDIERS);
	bounties = $state<Bounty[]>(MOCK_BOUNTIES);
	objectives = $state<Objective[]>(MOCK_OBJECTIVES);
	tasks = $state<Task[]>(MOCK_TASKS);
	activities = $state<Activity[]>(MOCK_ACTIVITIES);
	units = $state<Unit[]>(MOCK_UNITS);

	// Chain data — roster only (other pages stay on mock)
	chainSoldiers = $state<Soldier[]>([]);
	chainSoldiersLoading = $state(true);

	// UI state
	sidebarCollapsed = $state(false);
	currentUserId = $state(CURRENT_USER_ID);
	commandPaletteOpen = $state(false);

	// Derived: current user
	currentUser = $derived(this.soldiers.find(s => s.id === this.currentUserId));

	// Derived: dashboard stats
	stats = $derived<DashboardStats>({
		activeBounties: this.bounties.filter(b => b.status === 'active' || b.status === 'in_progress').length,
		openObjectives: this.objectives.filter(o => o.status === 'open' || o.status === 'in_progress').length,
		pendingTasks: this.tasks.filter(t => t.assigneeId === this.currentUserId && t.status !== 'approved').length,
		pendingReviews: this.objectives.filter(o => o.status === 'in_review').length,
		totalVgrdDistributed: this.soldiers.reduce((sum, s) => sum + s.vgrdEarned, 0),
		activeSoldiers: this.soldiers.filter(s => s.isOnline).length
	});

	// Derived: my tasks
	myTasks = $derived(this.tasks.filter(t => t.assigneeId === this.currentUserId));

	// Lookup helpers
	getSoldier(id: string) { return this.soldiers.find(s => s.id === id); }
	getBounty(id: string) { return this.bounties.find(b => b.id === id); }
	getObjective(id: string) { return this.objectives.find(o => o.id === id); }
	getTask(id: string) { return this.tasks.find(t => t.id === id); }
	getUnit(id: string) { return this.units.find(u => u.id === id); }

	getBountyObjectives(bountyId: string) { return this.objectives.filter(o => o.bountyId === bountyId); }
	getObjectiveTasks(objectiveId: string) { return this.tasks.filter(t => t.objectiveId === objectiveId); }
	getSoldierTasks(soldierId: string) { return this.tasks.filter(t => t.assigneeId === soldierId); }

	// Bounty completion percentage
	getBountyProgress(bountyId: string): number {
		const objs = this.getBountyObjectives(bountyId);
		if (objs.length === 0) return 0;
		const merged = objs.filter(o => o.status === 'merged').length;
		return Math.round((merged / objs.length) * 100);
	}

	// Objective completion percentage
	getObjectiveProgress(objectiveId: string): number {
		const tasks = this.getObjectiveTasks(objectiveId);
		if (tasks.length === 0) return 0;
		const done = tasks.filter(t => t.status === 'approved').length;
		return Math.round((done / tasks.length) * 100);
	}

	async loadSoldiersFromChain(): Promise<void> {
		this.chainSoldiersLoading = true;
		try {
			const { JsonRpcProvider } = await import('ethers');
			const { getArmyRegistry } = await import('$lib/contracts/contracts.svelte');
			const { BASE_SEPOLIA_RPC_URL } = await import('$lib/contracts/addresses');

			const provider = new JsonRpcProvider(BASE_SEPOLIA_RPC_URL);
			const registry = getArmyRegistry(provider) as any;

			// Short-circuit if no soldiers enlisted yet
			const total = Number(await registry.totalSoldiers());
			if (total === 0) {
				this.chainSoldiers = [];
				return;
			}

			// Enumerate all units (view calls, no log range limit) to collect wallet addresses
			const nextId = Number(await registry.nextUnitId());
			const unitIds = Array.from({ length: nextId - 1 }, (_, i) => i + 1);
			const memberLists: string[][] = await Promise.all(unitIds.map((id: number) => registry.getUnitMembers(id)));
			const ZERO = '0x0000000000000000000000000000000000000000';
			const wallets = [...new Set(memberLists.flat().filter((w: string) => w !== ZERO))];

			if (wallets.length === 0) {
				this.chainSoldiers = [];
				return;
			}

			const rawSoldiers = await Promise.all(wallets.map((w: string) => registry.getSoldier(w)));

			this.chainSoldiers = rawSoldiers.map((s: any, i: number) => {
				const rankIdx = Number(s.rank);
				const rank: Rank = CHAIN_RANK_MAP[rankIdx] ?? 'PVT';
				const callsign = bytes32ToString(s.callsign as string);
				return {
					id: wallets[i].toLowerCase(),
					callsign: callsign || `RECRUIT-${wallets[i].slice(2, 6).toUpperCase()}`,
					walletAddress: wallets[i].toLowerCase(),
					rank,
					xp: Number(s.tasksCompleted) * 100,
					vgrdEarned: Number(s.totalEarned) / 1e18,
					votingPower: RANK_META[rank].votingPower,
					tasksCompleted: Number(s.tasksCompleted),
					squadId: s.unitId > 0n ? s.unitId.toString() : null,
					sectionId: null,
					platoonId: null,
					companyId: null,
					specialty: '',
					avatarUrl: null,
					enlistedAt: new Date(Number(s.enlistedAt) * 1000).toISOString(),
					isOnline: false,
				} satisfies Soldier;
			});
		} catch (e) {
			console.error('[chain] loadSoldiersFromChain error:', e);
			this.chainSoldiers = [];
		} finally {
			this.chainSoldiersLoading = false;
		}
	}

	toggleSidebar() { this.sidebarCollapsed = !this.sidebarCollapsed; }
	toggleCommandPalette() { this.commandPaletteOpen = !this.commandPaletteOpen; }
}

export const app = new AppStore();
