// ═══════════════════════════════════════════════════════════════
// InstructorStore — the cohort as its instructor sees it: each week's
// objective and assignment copies, the work waiting for review, and
// every student's progress and promotion standing. Read from the
// chain; weeks are matched by brief fingerprints like the student view.
// ═══════════════════════════════════════════════════════════════

import {
	isLate,
	loadMember,
	loadMultipliers,
	loadObjectives,
	loadPromotionCooldown,
	loadPromotionRecords,
	loadRoles,
	loadTasks,
	loadUnit,
	loadUnitMembers,
	sameAddress,
	type ChainMember,
	type ChainObjective,
	type ChainTask,
	type ChainUnit,
	type PromotionRecord,
	type Roles,
	type TaskState,
} from '$lib/contracts/chain';
import { fingerprintText } from '$lib/contracts/fingerprint';
import { weekBrief, type Cohort, type CohortWeek } from './cohorts';

export interface WeekBoard {
	week: CohortWeek;
	objective: ChainObjective | null;
	tasks: ChainTask[];
	open: ChainTask[];
	counts: Record<TaskState, number>;
}

export interface StudentRow {
	member: ChainMember;
	/** The student's task for each week, by week number: the latest that is still live, if several. */
	byWeek: Map<number, ChainTask>;
	promotion: PromotionRecord;
}

export interface Submission {
	task: ChainTask;
	week: CohortWeek;
	student: ChainMember | null;
}

const NO_ROLES: Roles = { taskAdmin: false, rankAdmin: false };
const NO_PROMOTION: PromotionRecord = { lastPromotion: null, pldc: false, canPromote: false };

class InstructorStore {
	loading = $state(false);
	loaded = $state(false);
	error = $state<string | null>(null);

	cohortId = $state<string | null>(null);
	account = $state<string | null>(null);
	squad = $state<ChainUnit | null>(null);
	/** The connected wallet's own member record (its rank decides what it can promote). */
	me = $state<ChainMember | null>(null);
	roles = $state<Roles>(NO_ROLES);
	multipliers = $state<number[]>([]);
	cooldownSeconds = $state(7 * 24 * 3600);
	weeks = $state<WeekBoard[]>([]);
	students = $state<StudentRow[]>([]);
	submissions = $state<Submission[]>([]);

	isLeader = $derived(!!this.squad && sameAddress(this.squad.leader, this.account));
	isSecond = $derived(!!this.squad && sameAddress(this.squad.secondInCommand, this.account));
	/** Can post, assign and review work in this squad (the contract's own rule). */
	canManage = $derived(this.isLeader || this.isSecond || this.roles.taskAdmin);

	#request = 0;

	async refresh(cohort: Cohort, account: string | null): Promise<void> {
		const request = ++this.#request;
		this.cohortId = cohort.id;
		this.loading = true;
		this.error = null;
		try {
			const squadId = cohort.squadId;
			const [squad, members, objectives, tasks, multipliers, cooldownSeconds, me, roles] = await Promise.all([
				squadId ? loadUnit(squadId) : null,
				squadId ? loadUnitMembers(squadId) : [],
				squadId ? loadObjectives() : [],
				squadId ? loadTasks() : [],
				loadMultipliers(),
				loadPromotionCooldown(),
				account ? loadMember(account) : null,
				account ? loadRoles(account) : NO_ROLES,
			]);
			// The instructor and their second lead the squad; everyone else is a student.
			const students = members.filter((m) => !sameAddress(m.address, squad?.leader) && !sameAddress(m.address, squad?.secondInCommand));
			const promotions = await loadPromotionRecords(students, account);
			if (request !== this.#request) return; // the wallet changed while we were loading

			const weeks: WeekBoard[] = cohort.weeks.map((week) => {
				const brief = fingerprintText(weekBrief(cohort, week));
				const objective = objectives.find((o) => o.unitId === squadId && o.briefHash === brief) ?? null;
				const weekTasks = objective ? tasks.filter((t) => t.objectiveId === objective.id) : [];
				const counts: Record<TaskState, number> = { open: 0, assigned: 0, submitted: 0, approved: 0, rejected: 0 };
				for (const t of weekTasks) counts[t.state]++;
				return { week, objective, tasks: weekTasks, open: weekTasks.filter((t) => t.state === 'open'), counts };
			});

			this.account = account;
			this.squad = squad;
			this.me = me;
			this.roles = roles;
			this.multipliers = multipliers;
			this.cooldownSeconds = cooldownSeconds;
			this.weeks = weeks;
			this.students = students.map((member) => {
				const byWeek = new Map<number, ChainTask>();
				for (const board of weeks) {
					const theirs = board.tasks.filter((t) => sameAddress(t.assignee, member.address));
					// A copy that went past its deadline only counts when it's all they have.
					const pick = theirs.filter((t) => !isLate(t)).at(-1) ?? theirs.at(-1);
					if (pick) byWeek.set(board.week.week, pick);
				}
				return { member, byWeek, promotion: promotions.get(member.address.toLowerCase()) ?? NO_PROMOTION };
			});
			this.submissions = weeks.flatMap((board) =>
				board.tasks
					.filter((t) => t.state === 'submitted')
					.map((task) => ({ task, week: board.week, student: members.find((m) => sameAddress(m.address, task.assignee)) ?? null }))
			);
			this.loaded = true;
		} catch (e) {
			if (request !== this.#request) return;
			this.error = e instanceof Error ? e.message : 'Could not read the chain.';
		} finally {
			if (request === this.#request) this.loading = false;
		}
	}
}

export const instructor = new InstructorStore();
