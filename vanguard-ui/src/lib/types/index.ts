// ═══════════════════════════════════════════════════════════════
// VANGUARD DAO — Core Type System
// Mirrors the Dart/Solidity domain model for the web UI
// Designed for extensibility: add new fields, don't remove old ones
// ═══════════════════════════════════════════════════════════════

// ── Ranks ──────────────────────────────────────────────────────
export const RANKS = [
	'PVT', 'PV2', 'PFC', 'CPL',   // Enlisted
	'SGT', 'SSG', 'SFC', '1SG',   // NCO
	'2LT', '1LT', 'CPT'           // Officer
] as const;

export type Rank = typeof RANKS[number];

export interface RankMeta {
	rank: Rank;
	label: string;
	tier: 'enlisted' | 'nco' | 'officer';
	votingPower: number;
	multiplier: number;
	xpRequired: number;
	color: string;
}

export const RANK_META: Record<Rank, RankMeta> = {
	PVT:  { rank: 'PVT',  label: 'Private',              tier: 'enlisted', votingPower: 1,  multiplier: 1.0,  xpRequired: 0,     color: '#a17c5a' },
	PV2:  { rank: 'PV2',  label: 'Private Second Class',  tier: 'enlisted', votingPower: 2,  multiplier: 1.2, xpRequired: 100,   color: '#a17c5a' },
	PFC:  { rank: 'PFC',  label: 'Private First Class',   tier: 'enlisted', votingPower: 3,  multiplier: 1.5,  xpRequired: 300,   color: '#a17c5a' },
	CPL:  { rank: 'CPL',  label: 'Corporal',              tier: 'enlisted', votingPower: 5,  multiplier: 2.0,  xpRequired: 600,   color: '#a17c5a' },
	SGT:  { rank: 'SGT',  label: 'Sergeant',              tier: 'nco',      votingPower: 10, multiplier: 3.0,  xpRequired: 1000,  color: '#94a3b8' },
	SSG:  { rank: 'SSG',  label: 'Staff Sergeant',         tier: 'nco',      votingPower: 15, multiplier: 4.0,  xpRequired: 2000,  color: '#94a3b8' },
	SFC:  { rank: 'SFC',  label: 'Sergeant First Class',   tier: 'nco',      votingPower: 20, multiplier: 5.0,  xpRequired: 4000,  color: '#94a3b8' },
	'1SG': { rank: '1SG', label: 'First Sergeant',         tier: 'nco',      votingPower: 25, multiplier: 6.0,  xpRequired: 7000,  color: '#94a3b8' },
	'2LT': { rank: '2LT', label: 'Second Lieutenant',      tier: 'officer',  votingPower: 30, multiplier: 8.0,  xpRequired: 12000, color: '#fbbf24' },
	'1LT': { rank: '1LT', label: 'First Lieutenant',       tier: 'officer',  votingPower: 35, multiplier: 10.0, xpRequired: 20000, color: '#fbbf24' },
	CPT:  { rank: 'CPT',  label: 'Captain',                tier: 'officer',  votingPower: 50, multiplier: 15.0, xpRequired: 35000, color: '#fbbf24' },
};

// ── Soldier ────────────────────────────────────────────────────
export interface Soldier {
	id: string;
	callsign: string;
	walletAddress: string;
	rank: Rank;
	xp: number;
	vgrdEarned: number;
	votingPower: number;
	tasksCompleted: number;
	squadId: string | null;
	sectionId: string | null;
	platoonId: string | null;
	companyId: string | null;
	specialty: string;
	avatarUrl: string | null;
	enlistedAt: string;
	isOnline: boolean;
}

// ── Unit ───────────────────────────────────────────────────────
export type UnitType = 'squad' | 'section' | 'platoon' | 'company';

export interface Unit {
	id: string;
	type: UnitType;
	name: string;
	leaderId: string;
	secondInCommandId: string | null;
	memberIds: string[];
	parentUnitId: string | null;
	childUnitIds: string[];
	objectiveIds: string[];
}

// ── Bounty (= Repository) ─────────────────────────────────────
export type BountyStatus = 'draft' | 'active' | 'in_progress' | 'completed' | 'cancelled';
export type BountyCategory = 'deal' | 'academy' | 'research' | 'operations';

export interface Bounty {
	id: string;
	title: string;
	description: string;
	creatorId: string;
	totalAmount: number;
	remainingAmount: number;
	status: BountyStatus;
	category: BountyCategory;
	objectiveIds: string[];
	skillTags: string[];
	deadline: string;
	createdAt: string;
	updatedAt: string;
}

// ── Objective (= Pull Request) ─────────────────────────────────
export type ObjectiveStatus = 'open' | 'in_progress' | 'in_review' | 'merged' | 'closed';

export interface Objective {
	id: string;
	title: string;
	description: string;
	bountyId: string;
	unitId: string | null;
	assigneeId: string | null;
	status: ObjectiveStatus;
	taskIds: string[];
	allocatedVgrd: number;
	deadline: string;
	createdAt: string;
	updatedAt: string;
	reviewComment: string | null;
}

// ── Task (= Commit) ───────────────────────────────────────────
export type TaskStatus = 'todo' | 'assigned' | 'in_progress' | 'blocked' | 'submitted' | 'approved' | 'rejected';
export type TaskPriority = 'low' | 'medium' | 'high' | 'critical';

export interface Task {
	id: string;
	title: string;
	description: string;
	objectiveId: string;
	bountyId: string;
	assigneeId: string | null;
	status: TaskStatus;
	priority: TaskPriority;
	rewardVgrd: number;
	deadline: string;
	submissionHash: string | null;
	createdAt: string;
	updatedAt: string;
}

// ── Activity Feed ──────────────────────────────────────────────
export type ActivityType =
	| 'bounty_created'
	| 'objective_opened'
	| 'objective_merged'
	| 'objective_closed'
	| 'task_completed'
	| 'task_submitted'
	| 'soldier_promoted'
	| 'soldier_enlisted'
	| 'reward_distributed';

export interface Activity {
	id: string;
	type: ActivityType;
	actorId: string;
	actorCallsign: string;
	targetId: string;
	targetTitle: string;
	description: string;
	timestamp: string;
	metadata: Record<string, unknown>;
}

// ── Navigation ─────────────────────────────────────────────────
export interface NavItem {
	label: string;
	href: string;
	icon: string;
	badge?: number;
	children?: NavItem[];
}

// ── Stats ──────────────────────────────────────────────────────
export interface DashboardStats {
	activeBounties: number;
	openObjectives: number;
	pendingTasks: number;
	pendingReviews: number;
	totalVgrdDistributed: number;
	activeSoldiers: number;
}
