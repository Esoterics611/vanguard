// ═══════════════════════════════════════════════════════════════
// StudentStore — everything the cohort pages show for the connected
// wallet: member record, the cohort squad and classmates, pay, and
// per-week progress matched from the chain by brief fingerprints.
// ═══════════════════════════════════════════════════════════════

import {
	isLate,
	loadEthBalance,
	loadMember,
	loadMultipliers,
	loadObjectives,
	loadPendingPay,
	loadTasks,
	loadUnit,
	loadUnitMembers,
	sameAddress,
	type ChainMember,
	type ChainObjective,
	type ChainTask,
	type ChainUnit,
} from '$lib/contracts/chain';
import { fingerprintText } from '$lib/contracts/fingerprint';
import { weekBrief, type Cohort, type CohortWeek } from './cohorts';

/** Where a student stands on one week, most urgent first. */
export type WeekStatus =
	| 'changes' // sent back by the instructor
	| 'todo' // assigned, not yet submitted
	| 'late' // the deadline passed before it was handed in, and no fresh copy is open
	| 'available' // open assignment the student can take
	| 'review' // submitted, waiting for the instructor
	| 'done' // approved
	| 'posted' // the week is on chain but nothing is assigned to this student
	| 'not-posted'; // the instructor hasn't created the week yet

export interface WeekProgress {
	week: CohortWeek;
	objective: ChainObjective | null;
	/** This student's tasks for the week. */
	mine: ChainTask[];
	/** Unassigned tasks in the week anyone in the squad can take. */
	open: ChainTask[];
	status: WeekStatus;
}

function weekStatus(objective: ChainObjective | null, mine: ChainTask[], open: ChainTask[]): WeekStatus {
	if (!objective) return 'not-posted';
	if (mine.some((t) => t.state === 'rejected')) return 'changes';
	if (mine.some((t) => t.state === 'assigned' && !isLate(t))) return 'todo';
	if (mine.some((t) => t.state === 'submitted')) return 'review';
	if (mine.some((t) => t.state === 'approved')) return 'done';
	if (open.length > 0) return 'available';
	return mine.length > 0 ? 'late' : 'posted';
}

class StudentStore {
	loading = $state(false);
	loaded = $state(false);
	error = $state<string | null>(null);

	cohortId = $state<string | null>(null);
	account = $state<string | null>(null);
	member = $state<ChainMember | null>(null);
	squad = $state<ChainUnit | null>(null);
	/** The squad's leader on chain: the cohort's instructor. */
	leader = $state<ChainMember | null>(null);
	classmates = $state<ChainMember[]>([]);
	weeks = $state<WeekProgress[]>([]);
	multipliers = $state<number[]>([]);
	ethBalance = $state<bigint | null>(null);
	pendingPay = $state<bigint>(0n);

	/** The connected wallet leads the cohort squad (its instructor or their second). */
	isInstructor = $derived(
		!!this.squad && (sameAddress(this.squad.leader, this.account) || sameAddress(this.squad.secondInCommand, this.account))
	);
	/** Enlisted, and in this cohort's squad. */
	inCohort = $derived(this.member !== null && this.squad !== null && this.member.unitId === this.squad.id);
	multiplier = $derived(this.member ? (this.multipliers[this.member.rankIndex] ?? 100) : 100);

	#request = 0;

	async refresh(cohort: Cohort, account: string | null): Promise<void> {
		const request = ++this.#request;
		this.cohortId = cohort.id;
		this.loading = true;
		this.error = null;
		try {
			const squadId = cohort.squadId;
			const [squad, classmates, objectives, tasks, multipliers, member, ethBalance, pendingPay] = await Promise.all([
				squadId ? loadUnit(squadId) : null,
				squadId ? loadUnitMembers(squadId) : [],
				squadId ? loadObjectives() : [],
				squadId ? loadTasks() : [],
				loadMultipliers(),
				account ? loadMember(account) : null,
				account ? loadEthBalance(account) : null,
				account ? loadPendingPay(account) : 0n,
			]);
			const leader = squad?.leader ? await loadMember(squad.leader) : null;
			if (request !== this.#request) return; // the wallet changed while we were loading

			this.account = account;
			this.leader = leader;
			this.member = member;
			this.squad = squad;
			this.classmates = classmates;
			this.multipliers = multipliers;
			this.ethBalance = ethBalance;
			this.pendingPay = pendingPay;
			this.weeks = cohort.weeks.map((week) => {
				const brief = fingerprintText(weekBrief(cohort, week));
				const objective = objectives.find((o) => o.unitId === squadId && o.briefHash === brief) ?? null;
				const weekTasks = objective ? tasks.filter((t) => t.objectiveId === objective.id) : [];
				const mine = weekTasks.filter((t) => sameAddress(t.assignee, account));
				const open = weekTasks.filter((t) => t.state === 'open');
				return { week, objective, mine, open, status: weekStatus(objective, mine, open) };
			});
			this.loaded = true;
		} catch (e) {
			if (request !== this.#request) return;
			this.error = e instanceof Error ? e.message : 'Could not read the chain.';
		} finally {
			if (request === this.#request) this.loading = false;
		}
	}
}

export const student = new StudentStore();

/** The text of a task's brief when it is the week's standard assignment. */
export function assignmentText(week: CohortWeek, task: ChainTask): string | null {
	return task.briefHash === fingerprintText(week.assignment) ? week.assignment : null;
}
