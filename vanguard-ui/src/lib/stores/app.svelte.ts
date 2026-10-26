// ═══════════════════════════════════════════════════════════════
// Global reactive stores using Svelte 5 runes
// Extensible: add new stores as features grow
// ═══════════════════════════════════════════════════════════════

import {
	MOCK_SOLDIERS, MOCK_BOUNTIES, MOCK_OBJECTIVES, MOCK_TASKS,
	MOCK_ACTIVITIES, MOCK_UNITS, CURRENT_USER_ID
} from './mock-data';
import type { Soldier, Bounty, Objective, Task, Activity, Unit, DashboardStats } from '$lib/types';
import { RANK_META } from '$lib/types';

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
	mobileNavOpen = $state(false);
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
			const { loadAllMembers } = await import('$lib/contracts/chain');
			const members = await loadAllMembers();
			this.chainSoldiers = members.map((m) => ({
				id: m.address.toLowerCase(),
				callsign: m.callsign,
				walletAddress: m.address.toLowerCase(),
				rank: m.rank,
				xp: m.tasksCompleted * 100,
				vgrdEarned: Number(m.totalEarned) / 1e18,
				votingPower: RANK_META[m.rank].votingPower,
				tasksCompleted: m.tasksCompleted,
				squadId: m.unitId > 0 ? String(m.unitId) : null,
				sectionId: null,
				platoonId: null,
				companyId: null,
				specialty: '',
				avatarUrl: null,
				enlistedAt: m.enlistedAt.toISOString(),
				isOnline: false,
			} satisfies Soldier));
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
