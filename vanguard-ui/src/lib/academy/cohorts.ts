// ═══════════════════════════════════════════════════════════════
// Vanguard Academy cohorts.
//
// One entry per cohort. The pages read everything from here; to open
// enlistment, command creates the cohort squad on chain and puts its id
// in `squadId` (WORKPLAN.md, section 2).
//
// Each week's objective is found on chain by its brief: the instructor
// creates the objective with exactly `weekBrief(cohort, week)` as its
// text, and each assignment task with exactly `week.assignment`.
// ═══════════════════════════════════════════════════════════════

import { DEMO_SQUAD_ID, isDemo } from '$lib/demo/flag';
import { deployment } from '$lib/contracts/addresses';

const REPO = 'https://github.com/Esoterics611/vanguard/blob/main';

export interface Reading {
	label: string;
	/** null while the material isn't published yet. */
	href: string | null;
}

export interface CohortWeek {
	week: number;
	title: string;
	summary: string;
	reading: Reading[];
	/** What the student hands in; also the exact brief of the week's assignment task. */
	assignment: string;
}

export interface Cohort {
	id: string;
	name: string;
	track: string;
	pitch: string;
	/** First day of week 1 (YYYY-MM-DD), or null until the dates are set. */
	startDate: string | null;
	/** ArmyRegistry unit id of the cohort squad. Leave null: the setup script records it in contracts/deployed/. */
	squadId: number | null;
	instructor: { name: string; address: string | null };
	seats: number | null;
	/** Application form, if seats are allocated by application. */
	intakeUrl: string | null;
	/** Base pay per approved assignment, in VGRD; the student's rank multiplier applies on top. */
	assignmentReward: string;
	outcomes: string[];
	weeks: CohortWeek[];
}

export const COHORTS: Cohort[] = [
	{
		id: 'cohort-1',
		name: 'Cohort 1',
		track: 'DeFi investment banking',
		pitch:
			'Eight weeks from first principles to a live due-diligence engagement. You learn the work, do it on chain, and finish with a rank and a record anyone can check.',
		startDate: '2026-11-11',
		squadId: null,
		instructor: { name: 'To be announced', address: null },
		seats: 25,
		intakeUrl: null,
		assignmentReward: '100',
		outcomes: [
			'Paid coursework: every approved assignment pays VGRD at your rank',
			'A callsign and a work record on chain that anyone can verify',
			'Rank in the guild, earned through approved work',
			'A capstone diligence deliverable with your name on its fingerprint',
			'A place in the squad that takes on the guild’s first bounties',
		],
		weeks: [
			{
				week: 1,
				title: 'Orientation',
				summary: 'How the guild runs: ranks, bounties, tasks and governance. Set up, meet your squad, and hand in your first piece of work.',
				reading: [
					{ label: 'Protocol Guide: the rank system', href: `${REPO}/vanguard-docs/docs/rank-system/overview.md` },
					{ label: 'Protocol Guide: how work moves', href: `${REPO}/vanguard-docs/docs/operations/overview.md` },
				],
				assignment: 'A one-page introduction: your background, what you want to learn, and one protocol you would like to diligence.',
			},
			{
				week: 2,
				title: 'Foundations: the DAO as a firm',
				summary: 'What an investment bank does, and how each function maps onto a DAO: treasury, revenue, governance and reporting.',
				reading: [
					{ label: 'DAO IB Handbook, Part 1: Foundations', href: `${REPO}/docs/guides/DAO_IB_HANDBOOK/handbook_part1_foundations_1.md` },
					{ label: 'Training Manual, Chapter 1: The paradigm shift', href: `${REPO}/docs/guides/VANGUARD_IB_TRAINING_MANUAL.md` },
				],
				assignment: 'A one-page profile of a DAO: its treasury, where its revenue comes from, and how it makes decisions.',
			},
			{
				week: 3,
				title: 'Token economics',
				summary: 'Supply, distribution, vesting and value accrual, and the mistakes that sink token launches.',
				reading: [
					{ label: 'Training Manual, Chapter 2: Token economics', href: `${REPO}/docs/guides/VANGUARD_IB_TRAINING_MANUAL.md` },
				],
				assignment: 'A tokenomics teardown of your week-two DAO: supply, distribution, vesting and value accrual.',
			},
			{
				week: 4,
				title: 'Operational security',
				summary: 'People who handle capital are targets. Lock down your devices, accounts and keys before you touch a live deal.',
				reading: [{ label: 'Sentinel Shield: Operator’s Manual', href: null }],
				assignment: 'Your completed security checklist, reviewed with your instructor.',
			},
			{
				week: 5,
				title: 'Valuation',
				summary: 'Pricing a protocol: cost of capital, discounted cash flow, comparables and network-value models.',
				reading: [
					{ label: 'DAO IB Handbook, Part 2: Valuation', href: `${REPO}/docs/guides/DAO_IB_HANDBOOK/handbook_part2_valuation.md` },
				],
				assignment: 'A comparables table and a simple cash-flow valuation of your week-two DAO.',
			},
			{
				week: 6,
				title: 'Diligence and teams',
				summary: 'How a diligence workstream runs: technical, tokenomic and governance review. Teams form for the capstone.',
				reading: [
					{ label: 'DAO IB Handbook, Part 3: M&A and diligence', href: `${REPO}/docs/guides/DAO_IB_HANDBOOK/handbook_part3_manda.md` },
					{ label: 'Protocol Guide: the full workflow', href: `${REPO}/vanguard-docs/docs/operations/complete-workflow.md` },
				],
				assignment: 'Your team’s diligence plan: workstreams, owners and deadlines.',
			},
			{
				week: 7,
				title: 'Capstone: a live diligence bounty',
				summary: 'Your team runs a real due-diligence engagement through the guild: audit, tokenomics and team research, paid through escrow.',
				reading: [{ label: 'The engagement brief, shared by your instructor', href: null }],
				assignment: 'Your workstream’s deliverable for the capstone bounty.',
			},
			{
				week: 8,
				title: 'Demo Day',
				summary: 'Present your work to partners. Promotions are reviewed and graduates join the guild’s working squads.',
				reading: [],
				assignment: 'Your final memo and presentation.',
			},
		],
	},
];

export function getCohort(id: string | null | undefined): Cohort {
	const cohort = withSetup(COHORTS.find((c) => c.id === id) ?? COHORTS[0]);
	return isDemo() ? demoSchedule(cohort) : cohort;
}

/** The squad (and instructor) the setup script recorded in the deployment record, if any. */
function withSetup(cohort: Cohort): Cohort {
	const record = deployment.academy?.[cohort.id];
	if (!record || cohort.squadId !== null) return cohort;
	return {
		...cohort,
		squadId: record.squadId,
		instructor: { ...cohort.instructor, address: record.instructor ?? cohort.instructor.address },
	};
}

/** In demo mode the cohort is open on the simulated chain and in its third week. */
function demoSchedule(cohort: Cohort): Cohort {
	const start = new Date(Date.now() - 15 * DAY);
	const startDate = `${start.getFullYear()}-${String(start.getMonth() + 1).padStart(2, '0')}-${String(start.getDate()).padStart(2, '0')}`;
	return { ...cohort, startDate, squadId: DEMO_SQUAD_ID, instructor: { name: 'Demo instructor', address: null } };
}

/** The exact text the instructor fingerprints when creating a week's objective. */
export function weekBrief(cohort: Cohort, week: CohortWeek): string {
	return `${cohort.name} · Week ${week.week} · ${week.title}`;
}

const DAY = 24 * 60 * 60 * 1000;

function startOf(cohort: Cohort): Date | null {
	return cohort.startDate ? new Date(`${cohort.startDate}T00:00:00`) : null;
}

export type CohortPhase = 'unscheduled' | 'upcoming' | 'running' | 'finished';

export function cohortPhase(cohort: Cohort, now = new Date()): CohortPhase {
	const start = startOf(cohort);
	if (!start) return 'unscheduled';
	if (now < start) return 'upcoming';
	if (now.getTime() >= start.getTime() + cohort.weeks.length * 7 * DAY) return 'finished';
	return 'running';
}

/** The week number the cohort is in (1-based), or null when it isn't running. */
export function currentWeek(cohort: Cohort, now = new Date()): number | null {
	const start = startOf(cohort);
	if (!start || cohortPhase(cohort, now) !== 'running') return null;
	return Math.floor((now.getTime() - start.getTime()) / (7 * DAY)) + 1;
}

export function daysUntilStart(cohort: Cohort, now = new Date()): number | null {
	const start = startOf(cohort);
	if (!start || now >= start) return null;
	return Math.ceil((start.getTime() - now.getTime()) / DAY);
}

export function formatCohortDates(cohort: Cohort): string {
	const start = startOf(cohort);
	if (!start) return 'Dates to be announced';
	const end = new Date(start.getTime() + (cohort.weeks.length * 7 - 1) * DAY);
	const fmt = (d: Date) => d.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
	return `${fmt(start)} – ${fmt(end)}, ${end.getFullYear()}`;
}

/** joinUrl: the absolute URL of the /join page, including any deploy base path. */
export function inviteLink(joinUrl: string, cohort: Cohort, inviter: string): string {
	return `${joinUrl}?cohort=${encodeURIComponent(cohort.id)}&invite=${inviter}`;
}
