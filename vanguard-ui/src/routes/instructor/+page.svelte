<script lang="ts">
	import { untrack } from 'svelte';
	import { SvelteSet } from 'svelte/reactivity';
	import { page } from '$app/stores';
	import { resolve } from '$app/paths';
	import { ArrowRight, Check, CheckCheck, Circle, CircleAlert, Clock, Undo2, type Icon as IconType } from 'lucide-svelte';
	import { wallet } from '$lib/contracts/provider.svelte';
	import { addresses } from '$lib/contracts/addresses';
	import { encoders } from '$lib/contracts/contracts.svelte';
	import { BatchRunner } from '$lib/contracts/batch.svelte';
	import { isLate, type TaskState } from '$lib/contracts/chain';
	import { cohortPhase, currentWeek, daysUntilStart, formatCohortDates, getCohort, inviteLink } from '$lib/academy/cohorts';
	import { instructor } from '$lib/academy/instructor.svelte';
	import { promotesUpTo, rankLabel } from '$lib/academy/promotion';
	import { isDemo } from '$lib/demo/flag';
	import { onDemoChange } from '$lib/demo/mock-chain';
	import { RANK_META } from '$lib/types';
	import ConnectWallet from '$components/ConnectWallet.svelte';
	import SoldierAvatar from '$components/SoldierAvatar.svelte';
	import BatchNotice from '$components/academy/BatchNotice.svelte';
	import CopyField from '$components/academy/CopyField.svelte';
	import ReviewCard from '$components/instructor/ReviewCard.svelte';
	import WeekCard from '$components/instructor/WeekCard.svelte';
	import PromotionCell from '$components/instructor/PromotionCell.svelte';

	let cohort = $derived(getCohort($page.url.searchParams.get('cohort')));
	const demo = isDemo();

	function reload() {
		return instructor.refresh(cohort, wallet.account);
	}

	$effect(() => {
		const account = wallet.account;
		const c = cohort;
		untrack(() => instructor.refresh(c, account));
	});
	// In demo mode simulated students take and hand in work on a timer; show it as it lands.
	$effect(() => (demo ? onDemoChange(() => void reload()) : undefined));

	let phase = $derived(cohortPhase(cohort));
	let week = $derived(currentWeek(cohort));
	let daysLeft = $derived(daysUntilStart(cohort));

	type Tab = 'review' | 'weeks' | 'students';
	let tab = $state<Tab | null>(null);
	// Open on Review when work is waiting, else Weeks; chosen once, so the tab never changes under the instructor.
	$effect(() => {
		if (tab === null && instructor.loaded && instructor.cohortId === cohort.id) {
			tab = instructor.submissions.length > 0 ? 'review' : 'weeks';
		}
	});
	let activeTab = $derived<Tab>(tab ?? 'review');

	// Submissions the instructor has checked against the student's file.
	const verified = new SvelteSet<number>();
	function onverified(taskId: number, ok: boolean) {
		if (ok) verified.add(taskId);
		else verified.delete(taskId);
	}
	let checked = $derived(instructor.submissions.filter((s) => verified.has(s.task.id)));
	const approveAll = new BatchRunner();

	async function approveChecked() {
		const calls = checked.map((s) => ({
			to: addresses.TaskRegistry,
			data: encoders.TaskRegistry.encodeFunctionData('approveTask', [s.task.id]),
		}));
		await approveAll.run(`Approve ${calls.length} checked`, calls);
		verified.clear();
		await reload();
	}

	async function weekChanged(n: number) {
		await reload();
		return instructor.weeks.find((w) => w.week.week === n);
	}

	function multiplierOf(address: string | null): number {
		const s = instructor.students.find((r) => r.member.address.toLowerCase() === address?.toLowerCase());
		return instructor.multipliers[s?.member.rankIndex ?? 1] ?? 100;
	}

	let promoterRank = $derived(instructor.me?.rankIndex ?? 0);
	let upTo = $derived(promotesUpTo(promoterRank));
	let postedCount = $derived(instructor.weeks.filter((w) => w.objective).length);
	let myInviteLink = $derived(wallet.account ? inviteLink($page.url.origin + resolve('/join'), cohort, wallet.account) : '');

	// 'late': handed out, but the deadline passed before the student handed it in.
	type Cell = TaskState | 'late';
	const CELL: Record<Cell, { label: string; cls: string; icon: typeof IconType }> = {
		approved: { label: 'Approved', cls: 'bg-emerald-400/15 text-emerald-300', icon: Check },
		submitted: { label: 'In review', cls: 'bg-purple-400/15 text-purple-300', icon: Clock },
		assigned: { label: 'To hand in', cls: 'bg-cyan-400/10 text-cyan-300', icon: Circle },
		rejected: { label: 'Sent back', cls: 'bg-red-400/15 text-red-300', icon: Undo2 },
		open: { label: 'Open', cls: 'text-vanguard-text-muted', icon: Circle },
		late: { label: 'Missed the deadline', cls: 'bg-amber-400/15 text-amber-300', icon: CircleAlert },
	};
	const LEGEND: Cell[] = ['approved', 'submitted', 'assigned', 'rejected', 'late'];
</script>

<svelte:head>
	<title>Instructor · {cohort.name} · Vanguard Academy</title>
</svelte:head>

<div class="mx-auto max-w-6xl space-y-6">
	<!-- Header -->
	<section class="instructor-hero rounded-2xl border border-vanguard-border px-6 py-6 sm:px-8">
		<p class="font-mono text-[11px] uppercase tracking-[0.18em] text-amber-300">Instructor · {cohort.name}</p>
		<h2 class="mt-2 text-2xl font-semibold tracking-tight text-vanguard-text sm:text-3xl">
			{#if phase === 'running' && week}
				Week {week} of {cohort.weeks.length}: {cohort.weeks[week - 1].title}
			{:else if phase === 'upcoming' && daysLeft}
				Starts in {daysLeft} {daysLeft === 1 ? 'day' : 'days'}
			{:else if phase === 'finished'}
				Cohort complete
			{:else}
				Running the cohort
			{/if}
		</h2>
		<p class="mt-1 text-sm text-vanguard-text-muted">
			{formatCohortDates(cohort)} · {instructor.squad?.name ?? cohort.name}
			{#if instructor.isLeader}· you lead this squad{:else if instructor.isSecond}· you’re second in command{:else if instructor.roles.taskAdmin}· you’re signed in as command{/if}
		</p>
		<dl class="mt-5 grid grid-cols-3 gap-3 sm:max-w-lg">
			{#each [
				{ label: 'Waiting for review', value: instructor.submissions.length },
				{ label: 'Weeks posted', value: `${postedCount}/${cohort.weeks.length}` },
				{ label: 'Students', value: instructor.students.length },
			] as stat}
				<div class="rounded-xl bg-vanguard-bg/50 px-3 py-2.5">
					<dt class="text-[10px] uppercase tracking-wider text-vanguard-text-muted">{stat.label}</dt>
					<dd class="mt-0.5 font-mono text-lg text-vanguard-text">{stat.value}</dd>
				</div>
			{/each}
		</dl>
	</section>

	<!-- Who's looking -->
	{#if cohort.squadId === null}
		<section class="rounded-2xl border border-amber-400/25 bg-amber-400/5 p-6">
			<h3 class="text-base font-semibold text-vanguard-text">{cohort.name}’s squad isn’t on chain yet</h3>
			<p class="mt-1 max-w-2xl text-sm text-vanguard-text-muted">
				Command creates it with the setup script and makes you its leader; then this page lets you post assignments, review work and promote students. Until then you can try every part of it in the demo.
			</p>
			{#if !demo}
				<a href={resolve('/instructor') + `?cohort=${cohort.id}&demo=instructor`} data-sveltekit-reload class="btn-primary mt-4">
					Preview the instructor view <ArrowRight size={15} />
				</a>
			{/if}
		</section>
	{:else if !wallet.isConnected}
		<section class="flex flex-col items-start gap-4 rounded-2xl border border-cyan-500/25 bg-cyan-500/5 p-6 sm:flex-row sm:items-center sm:justify-between">
			<div>
				<h3 class="text-base font-semibold text-vanguard-text">Connect the instructor’s wallet</h3>
				<p class="mt-1 text-sm text-vanguard-text-muted">Posting, reviewing and promoting use the wallet that leads {cohort.name}’s squad.</p>
			</div>
			<ConnectWallet />
		</section>
	{:else if instructor.loaded && !instructor.canManage}
		<section class="rounded-2xl border border-vanguard-border bg-vanguard-surface p-5 text-sm text-vanguard-text-muted">
			This wallet doesn’t lead {cohort.name}, so you can look around but not act. The squad’s leader posts and reviews work here.
		</section>
	{/if}

	{#if instructor.error}
		<p class="rounded-xl border border-red-500/30 bg-red-500/5 px-4 py-3 text-sm text-red-300" role="alert">
			{instructor.error} <button class="ml-2 underline" onclick={reload}>Try again</button>
		</p>
	{/if}

	{#if cohort.squadId !== null}
		<!-- Tabs -->
		<div class="flex items-center gap-1 border-b border-vanguard-border" role="tablist">
			{#each [
				{ key: 'review', label: 'Review', count: instructor.submissions.length },
				{ key: 'weeks', label: 'Weeks', count: null },
				{ key: 'students', label: 'Students', count: instructor.students.length },
			] as t}
				<button
					role="tab"
					aria-selected={activeTab === t.key}
					onclick={() => (tab = t.key as Tab)}
					class="-mb-px border-b-2 px-4 py-2.5 text-sm transition-colors
						{activeTab === t.key ? 'border-cyan-400 font-medium text-cyan-300' : 'border-transparent text-vanguard-text-muted hover:text-vanguard-text'}"
				>
					{t.label}
					{#if t.count}<span class="ml-1 rounded-full bg-vanguard-surface-3 px-1.5 py-0.5 font-mono text-[10px]">{t.count}</span>{/if}
				</button>
			{/each}
			{#if instructor.loading}<span class="ml-auto text-xs text-vanguard-text-muted">Reading the chain…</span>{/if}
		</div>

		{#if activeTab === 'review'}
			<section class="space-y-4">
				{#if instructor.canManage && checked.length > 1}
					<div class="flex flex-wrap items-center gap-3 rounded-xl border border-emerald-400/25 bg-emerald-400/5 p-3.5">
						<p class="min-w-0 flex-1 text-sm text-emerald-200">{checked.length} submissions checked against their files.</p>
						<button class="btn-primary" onclick={approveChecked} disabled={approveAll.busy}><CheckCheck size={15} /> Approve all {checked.length}</button>
					</div>
				{/if}
				<BatchNotice batch={approveAll} doneText="Approved and paid." />
				{#each instructor.submissions as submission (submission.task.id)}
					<ReviewCard {submission} multiplier={multiplierOf(submission.task.assignee)} canManage={instructor.canManage} onchange={reload} {onverified} />
				{:else}
					<div class="rounded-2xl border border-vanguard-border bg-vanguard-surface px-6 py-12 text-center">
						<p class="text-sm font-medium text-vanguard-text">Nothing waiting for review.</p>
						<p class="mt-1 text-xs text-vanguard-text-muted">Work shows up here as students hand it in. Ask them to send you the file they submitted, so you can check it here.</p>
					</div>
				{/each}
			</section>
		{:else if activeTab === 'weeks'}
			<section class="space-y-3">
				{#each instructor.weeks as board (board.week.week)}
					<WeekCard
						{board}
						{cohort}
						students={instructor.students}
						canManage={instructor.canManage}
						current={week === board.week.week || (phase === 'upcoming' && board.week.week === 1)}
						currentLabel={phase === 'running' ? 'This week' : 'First up'}
						onchange={() => weekChanged(board.week.week)}
					/>
				{/each}
			</section>
		{:else}
			<section class="space-y-4">
				<div class="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
					<p class="text-sm text-vanguard-text-muted">
						{#if instructor.roles.rankAdmin}
							You hold command’s role: you can promote anyone and record the leadership course.
						{:else if upTo}
							You’re a {rankLabel(promoterRank)}: you can promote students up to {rankLabel(upTo)}, one rank at a time, a week apart. Sergeant and above need command.
						{:else}
							Your rank can’t promote students yet; command can.
						{/if}
					</p>
					{#if instructor.canManage && myInviteLink}
						<div class="w-full space-y-1 sm:w-96">
							<p class="text-xs text-vanguard-text-muted">Your invite link for students:</p>
							<CopyField value={myInviteLink} />
						</div>
					{/if}
				</div>

				<div class="overflow-x-auto rounded-2xl border border-vanguard-border bg-vanguard-surface">
					<table class="w-full min-w-[760px] text-sm">
						<thead>
							<tr class="border-b border-vanguard-border text-left text-[10px] uppercase tracking-wider text-vanguard-text-muted">
								<th class="px-4 py-3 font-medium">Student</th>
								{#each cohort.weeks as w}
									<th class="px-1 py-3 text-center font-medium" title={w.title}>W{w.week}</th>
								{/each}
								<th class="px-3 py-3 text-center font-medium">Approved</th>
								<th class="px-4 py-3 font-medium">Promotion</th>
							</tr>
						</thead>
						<tbody class="divide-y divide-vanguard-border">
							{#each instructor.students as row (row.member.address)}
								{@const approved = [...row.byWeek.values()].filter((t) => t.state === 'approved').length}
								<tr>
									<td class="px-4 py-3">
										<div class="flex items-center gap-2.5">
											<SoldierAvatar callsign={row.member.callsign} rank={row.member.rank} size="sm" />
											<div class="min-w-0">
												<p class="truncate font-mono text-xs text-vanguard-text">{row.member.callsign}</p>
												<p class="text-[11px] text-vanguard-text-muted">{RANK_META[row.member.rank].label}</p>
											</div>
										</div>
									</td>
									{#each instructor.weeks as board (board.week.week)}
										{@const task = row.byWeek.get(board.week.week)}
										<td class="px-1 py-3 text-center">
											{#if task}
												{@const cell = CELL[isLate(task) ? 'late' : task.state]}
												<span class="inline-flex h-6 w-6 items-center justify-center rounded-md {cell.cls}" title="Week {board.week.week}: {cell.label}"><cell.icon size={13} strokeWidth={2.5} /></span>
											{:else if board.objective}
												<span class="text-xs text-vanguard-text-muted/60" title="Week {board.week.week}: no copy yet">–</span>
											{/if}
										</td>
									{/each}
									<td class="px-3 py-3 text-center font-mono text-xs text-vanguard-text">{approved}</td>
									<td class="px-4 py-3">
										<PromotionCell
											{row}
											{promoterRank}
											roles={instructor.roles}
											cooldownSeconds={instructor.cooldownSeconds}
											canManage={instructor.canManage}
											onchange={reload}
										/>
									</td>
								</tr>
							{:else}
								<tr><td colspan={cohort.weeks.length + 3} class="px-4 py-10 text-center text-sm text-vanguard-text-muted">Nobody has enlisted yet. Share your invite link.</td></tr>
							{/each}
						</tbody>
					</table>
				</div>
				<p class="flex flex-wrap items-center gap-x-4 gap-y-1 text-xs text-vanguard-text-muted">
					{#each LEGEND as state}
						{@const cell = CELL[state]}
						<span class="inline-flex items-center gap-1.5"><span class="inline-flex h-4 w-4 items-center justify-center rounded {cell.cls}"><cell.icon size={10} strokeWidth={2.5} /></span>{cell.label}</span>
					{/each}
					<span>– posted, no copy yet</span>
				</p>
			</section>
		{/if}
	{/if}
</div>

<style>
	.instructor-hero {
		background:
			radial-gradient(ellipse 60% 120% at 100% 0%, rgba(251, 191, 36, 0.1), transparent 60%),
			var(--color-vanguard-surface);
	}
</style>
