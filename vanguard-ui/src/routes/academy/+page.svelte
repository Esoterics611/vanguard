<script lang="ts">
	import { resolve } from '$app/paths';
	import { page } from '$app/stores';
	import { ArrowRight, BookOpen, Check, ChevronDown, Coins, ExternalLink, Hand } from 'lucide-svelte';
	import { wallet } from '$lib/contracts/provider.svelte';
	import { getRewardPool, getTaskRegistry } from '$lib/contracts/contracts.svelte';
	import { TxRunner, requireSigner } from '$lib/contracts/tx.svelte';
	import { formatMultiplier, formatToken, payFor, sameAddress, type ChainTask } from '$lib/contracts/chain';
	import { cohortPhase, currentWeek, daysUntilStart, formatCohortDates, getCohort, inviteLink } from '$lib/academy/cohorts';
	import { assignmentText, student, type WeekProgress, type WeekStatus } from '$lib/academy/student.svelte';
	import { isDemo } from '$lib/demo/flag';
	import { onDemoChange } from '$lib/demo/mock-chain';
	import { RANK_META, RANKS } from '$lib/types';
	import RankInsignia from '$components/RankInsignia.svelte';
	import SoldierAvatar from '$components/SoldierAvatar.svelte';
	import SubmitWork from '$components/academy/SubmitWork.svelte';
	import TxNotice from '$components/academy/TxNotice.svelte';
	import CopyField from '$components/academy/CopyField.svelte';

	let cohort = $derived(getCohort($page.url.searchParams.get('cohort')));

	// The layout loads the default cohort when the wallet changes; load here for any other.
	$effect(() => {
		if (student.cohortId !== cohort.id && !student.loading) void student.refresh(cohort, wallet.account);
	});

	function reload() {
		return student.refresh(cohort, wallet.account);
	}

	// In demo mode the simulated instructor reviews work on a timer; show it when it lands.
	const demo = isDemo();
	$effect(() => (demo ? onDemoChange(() => void reload()) : undefined));

	let phase = $derived(cohortPhase(cohort));
	let week = $derived(currentWeek(cohort));
	let daysLeft = $derived(daysUntilStart(cohort));

	const STATUS: Record<WeekStatus, { label: string; tone: string }> = {
		changes: { label: 'Changes requested', tone: 'text-red-300 bg-red-400/10 border-red-400/25' },
		todo: { label: 'To hand in', tone: 'text-cyan-300 bg-cyan-400/10 border-cyan-400/25' },
		available: { label: 'Ready to take', tone: 'text-cyan-300 bg-cyan-400/10 border-cyan-400/25' },
		review: { label: 'In review', tone: 'text-purple-300 bg-purple-400/10 border-purple-400/25' },
		done: { label: 'Approved', tone: 'text-emerald-300 bg-emerald-400/10 border-emerald-400/25' },
		posted: { label: 'Posted', tone: 'text-vanguard-text-muted bg-vanguard-surface-2 border-vanguard-border' },
		'not-posted': { label: 'Not posted yet', tone: 'text-vanguard-text-muted bg-transparent border-vanguard-border' },
	};
	const TASK_LABEL: Record<ChainTask['state'], string> = {
		open: 'Open',
		assigned: 'To hand in',
		submitted: 'In review',
		approved: 'Approved',
		rejected: 'Sent back',
	};
	const SEGMENT: Record<WeekStatus, string> = {
		changes: 'bg-red-400',
		todo: 'bg-cyan-400',
		available: 'bg-cyan-400/60',
		review: 'bg-purple-400',
		done: 'bg-emerald-400',
		posted: 'bg-vanguard-border-bright',
		'not-posted': 'bg-vanguard-surface-3',
	};

	let progress = $derived<WeekProgress[]>(
		student.weeks.length === cohort.weeks.length && student.cohortId === cohort.id
			? student.weeks
			: cohort.weeks.map((w) => ({ week: w, objective: null, mine: [], open: [], status: 'not-posted' as WeekStatus }))
	);
	let approvedCount = $derived(progress.filter((p) => p.status === 'done').length);

	// The one thing to do next: work sent back, then work due, then work to take.
	let nextUp = $derived.by(() => {
		for (const status of ['changes', 'todo', 'available'] as WeekStatus[]) {
			const p = progress.find((w) => w.status === status);
			if (!p) continue;
			const task =
				status === 'available'
					? p.open[0]
					: p.mine.find((t) => t.state === (status === 'changes' ? 'rejected' : 'assigned'));
			if (task) return { progress: p, task };
		}
		return null;
	});
	let waitingReview = $derived(progress.filter((p) => p.status === 'review'));

	let expanded = $state<number | null>(null);
	let openWeek = $derived(expanded ?? nextUp?.progress.week.week ?? week ?? 1);

	// ── Writes ─────────────────────────────────────────────────
	const takeTx = new TxRunner();
	const claimTx = new TxRunner();

	async function take(task: ChainTask) {
		if (await takeTx.run('Take this assignment', () => getTaskRegistry(requireSigner()).selfAssignTask(task.id))) await reload();
	}

	async function claim() {
		if (await claimTx.run('Claim your pay', () => getRewardPool(requireSigner()).claimRewards())) await reload();
	}

	function payText(task: ChainTask): string | null {
		if (task.reward === 0n) return null;
		return `${formatToken(payFor(task.reward, student.multiplier))} VGRD at your rank`;
	}

	function deadlineText(task: ChainTask): string | null {
		if (!task.deadline) return null;
		const d = new Date(task.deadline * 1000);
		return `Due ${d.toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric' })}`;
	}

	const LADDER = RANKS.slice(0, 5); // PVT … SGT: the path a cohort walks
	let myInviteLink = $derived(wallet.account ? inviteLink($page.url.origin + resolve('/join'), cohort, wallet.account) : '');
</script>

<svelte:head>
	<title>{cohort.name} · Vanguard Academy</title>
</svelte:head>

<div class="mx-auto max-w-6xl space-y-6">
	<!-- Header -->
	<section class="academy-hero relative overflow-hidden rounded-2xl border border-vanguard-border px-6 py-6 sm:px-8">
		<p class="font-mono text-[11px] uppercase tracking-[0.18em] text-cyan-300">{cohort.name} · {cohort.track}</p>
		<h2 class="mt-2 text-2xl font-semibold tracking-tight text-vanguard-text sm:text-3xl">
			{#if phase === 'running' && week}
				Week {week} of {cohort.weeks.length}: {cohort.weeks[week - 1].title}
			{:else if phase === 'upcoming' && daysLeft}
				Starts in {daysLeft} {daysLeft === 1 ? 'day' : 'days'}
			{:else if phase === 'finished'}
				Cohort complete
			{:else}
				Your cohort
			{/if}
		</h2>
		<p class="mt-1 text-sm text-vanguard-text-muted">{formatCohortDates(cohort)} · {cohort.weeks.length} weeks · Instructor: {student.leader?.callsign ?? cohort.instructor.name}</p>

		<div class="mt-5 flex items-center gap-4">
			<div class="grid flex-1 gap-1" style="grid-template-columns: repeat({cohort.weeks.length}, minmax(0, 1fr))" aria-hidden="true">
				{#each progress as p}
					<div class="h-1.5 rounded-full {SEGMENT[p.status]} {week === p.week.week ? 'ring-2 ring-cyan-300/40 ring-offset-1 ring-offset-vanguard-surface' : ''}"></div>
				{/each}
			</div>
			<span class="flex-shrink-0 font-mono text-xs text-vanguard-text-muted">{approvedCount}/{cohort.weeks.length} approved</span>
		</div>
	</section>

	{#if !wallet.isConnected || (student.loaded && !student.member)}
		<!-- Not enlisted yet -->
		<section class="flex flex-col items-start gap-4 rounded-2xl border border-cyan-500/25 bg-cyan-500/5 p-6 sm:flex-row sm:items-center sm:justify-between">
			<div>
				<h3 class="text-base font-semibold text-vanguard-text">
					{wallet.isConnected ? 'You haven’t enlisted yet' : 'Join the cohort'}
				</h3>
				<p class="mt-1 max-w-xl text-sm text-vanguard-text-muted">
					Five quick steps: a wallet, the test network, a little free test ETH for fees, and you’re in. Nothing costs real money.
				</p>
			</div>
			<div class="flex flex-wrap gap-2">
				<a href={resolve('/join') + `?cohort=${cohort.id}`} class="btn-primary">Get set up <ArrowRight size={15} /></a>
				{#if !demo}
					<a href={resolve('/join') + `?cohort=${cohort.id}&demo=1`} data-sveltekit-reload class="btn-ghost">Try the demo</a>
				{/if}
			</div>
		</section>
	{:else if student.loaded && student.member && cohort.squadId !== null && !student.inCohort}
		<section class="rounded-2xl border border-amber-400/25 bg-amber-400/5 p-6 text-sm text-vanguard-text-muted">
			You’re enlisted as <span class="font-mono text-vanguard-text">{student.member.callsign}</span> in another squad, so this page shows {cohort.name}’s syllabus without your progress. Talk to your instructor about joining.
		</section>
	{/if}

	{#if student.error}
		<p class="rounded-xl border border-red-500/30 bg-red-500/5 px-4 py-3 text-sm text-red-300" role="alert">
			{student.error} <button class="ml-2 underline" onclick={reload}>Try again</button>
		</p>
	{/if}

	<div class="grid grid-cols-1 gap-6 lg:grid-cols-[minmax(0,1fr)_340px]">
		<div class="space-y-6">
			<!-- Next up -->
			{#if student.inCohort}
				<section class="rounded-2xl border border-vanguard-border bg-vanguard-surface p-6">
					<h3 class="text-xs font-semibold uppercase tracking-wider text-vanguard-text-muted">Next up</h3>
					{#if nextUp}
						{@const { progress: p, task } = nextUp}
						{@const brief = assignmentText(p.week, task)}
						<div class="mt-3 space-y-4">
							<div>
								<p class="font-mono text-xs text-cyan-300">Week {p.week.week} · {p.week.title}</p>
								<p class="mt-1 text-lg font-medium leading-snug text-vanguard-text">{brief ?? `Assignment #${task.id}`}</p>
								<div class="mt-2 flex flex-wrap gap-x-4 gap-y-1 text-xs text-vanguard-text-muted">
									{#if deadlineText(task)}<span>{deadlineText(task)}</span>{/if}
									{#if payText(task)}<span class="text-amber-300">{payText(task)}</span>{/if}
								</div>
							</div>
							{#if p.status === 'changes'}
								<p class="rounded-lg border border-red-400/25 bg-red-400/5 px-3.5 py-2.5 text-sm text-red-200">
									Your instructor sent this back. Check their notes, update your work, and hand it in again.
								</p>
							{/if}
							{#if p.status === 'available'}
								<p class="text-sm text-vanguard-text-muted">This assignment is open. Take it, and it’s yours to hand in.</p>
								<button class="btn-primary" onclick={() => take(task)} disabled={takeTx.busy}><Hand size={15} /> Take this assignment</button>
								<TxNotice tx={takeTx} doneText="It’s yours. Hand it in below when it’s ready." />
							{:else}
								<SubmitWork {task} onsubmitted={reload} />
							{/if}
						</div>
					{:else}
						<div class="mt-3 flex items-start gap-3">
							<span class="mt-0.5 flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-full bg-emerald-400/10 text-emerald-300"><Check size={16} /></span>
							<div>
								<p class="text-base font-medium text-vanguard-text">You’re all caught up.</p>
								<p class="mt-0.5 text-sm text-vanguard-text-muted">
									{#if waitingReview.length > 0}
										Week {waitingReview.map((w) => w.week.week).join(', ')} is with your instructor for review.
									{:else}
										Your instructor posts each week’s assignment here. Meanwhile, start on the reading below.
									{/if}
								</p>
							</div>
						</div>
					{/if}
				</section>
			{/if}

			<!-- Syllabus -->
			<section class="rounded-2xl border border-vanguard-border bg-vanguard-surface">
				<div class="flex items-baseline justify-between border-b border-vanguard-border px-6 py-4">
					<h3 class="text-base font-semibold text-vanguard-text">Syllabus</h3>
					{#if student.loading}<span class="text-xs text-vanguard-text-muted">Reading the chain…</span>{/if}
				</div>
				<ol class="divide-y divide-vanguard-border">
					{#each progress as p}
						{@const isOpen = openWeek === p.week.week}
						{@const isCurrent = week === p.week.week}
						<li>
							<button
								class="flex w-full items-center gap-4 px-6 py-4 text-left transition-colors hover:bg-vanguard-surface-2 focus-visible:bg-vanguard-surface-2 focus-visible:outline-none"
								aria-expanded={isOpen}
								onclick={() => (expanded = isOpen ? 0 : p.week.week)}
							>
								<span
									class="flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-lg border font-mono text-xs
										{p.status === 'done'
											? 'border-emerald-400/30 bg-emerald-400/10 text-emerald-300'
											: isCurrent
												? 'border-cyan-400/50 bg-cyan-400/10 text-cyan-300'
												: 'border-vanguard-border text-vanguard-text-muted'}"
								>
									{#if p.status === 'done'}<Check size={14} />{:else}{p.week.week}{/if}
								</span>
								<span class="min-w-0 flex-1">
									<span class="flex flex-wrap items-center gap-2">
										<span class="text-sm font-medium text-vanguard-text">{p.week.title}</span>
										{#if isCurrent}<span class="rounded-full bg-cyan-400/15 px-2 py-0.5 text-[10px] font-semibold uppercase tracking-wider text-cyan-300">This week</span>{/if}
									</span>
									{#if !isOpen}<span class="mt-0.5 block truncate text-xs text-vanguard-text-muted">{p.week.summary}</span>{/if}
								</span>
								{#if student.inCohort}
									<span class="hidden flex-shrink-0 rounded-full border px-2.5 py-0.5 text-[11px] sm:inline {STATUS[p.status].tone}">{STATUS[p.status].label}</span>
								{/if}
								<ChevronDown size={16} class="flex-shrink-0 text-vanguard-text-muted transition-transform {isOpen ? 'rotate-180' : ''}" />
							</button>

							{#if isOpen}
								<div class="space-y-4 px-6 pb-5 pl-[4.5rem]">
									<p class="text-sm leading-relaxed text-vanguard-text-muted">{p.week.summary}</p>
									{#if p.week.reading.length > 0}
										<div>
											<p class="mb-1.5 text-[11px] font-semibold uppercase tracking-wider text-vanguard-text-muted">Reading</p>
											<ul class="space-y-1">
												{#each p.week.reading as r}
													<li class="flex items-center gap-2 text-sm">
														<BookOpen size={14} class="flex-shrink-0 text-vanguard-text-muted" />
														{#if r.href}
															<a href={r.href} target="_blank" rel="noopener" class="inline-flex items-center gap-1 text-cyan-300 hover:underline">{r.label} <ExternalLink size={11} /></a>
														{:else}
															<span class="text-vanguard-text">{r.label}</span>
															<span class="text-xs text-vanguard-text-muted">(shared in class)</span>
														{/if}
													</li>
												{/each}
											</ul>
										</div>
									{/if}
									<div>
										<p class="mb-1 text-[11px] font-semibold uppercase tracking-wider text-vanguard-text-muted">You hand in</p>
										<p class="text-sm text-vanguard-text">{p.week.assignment}</p>
									</div>
									{#if p.mine.length > 0}
										<ul class="space-y-1.5">
											{#each p.mine as task}
												<li class="flex flex-wrap items-center gap-x-3 gap-y-1 text-xs text-vanguard-text-muted">
													<span class="font-mono">#{task.id}</span>
													<span>{TASK_LABEL[task.state]}</span>
													{#if task.submission}<span class="font-mono" title={task.submission}>fingerprint {task.submission.slice(0, 10)}…</span>{/if}
													{#if payText(task)}<span class="text-amber-300">{payText(task)}</span>{/if}
												</li>
											{/each}
										</ul>
									{/if}
								</div>
							{/if}
						</li>
					{/each}
				</ol>
			</section>
		</div>

		<!-- Side column -->
		<div class="space-y-6">
			{#if student.member}
				{@const member = student.member}
				<section class="rounded-2xl border border-vanguard-border bg-vanguard-surface p-5">
					<div class="flex items-center gap-3.5">
						<RankInsignia rank={member.rank} size="lg" glow />
						<div class="min-w-0">
							<p class="truncate font-mono text-lg font-semibold text-vanguard-text">{member.callsign}</p>
							<p class="text-xs text-vanguard-text-muted">{RANK_META[member.rank].label}</p>
						</div>
					</div>
					<dl class="mt-5 grid grid-cols-3 gap-2 text-center">
						<div class="rounded-lg bg-vanguard-surface-2 px-2 py-2.5">
							<dt class="text-[10px] uppercase tracking-wider text-vanguard-text-muted">Pay rate</dt>
							<dd class="mt-0.5 font-mono text-sm text-vanguard-text">{formatMultiplier(student.multiplier)}</dd>
						</div>
						<div class="rounded-lg bg-vanguard-surface-2 px-2 py-2.5">
							<dt class="text-[10px] uppercase tracking-wider text-vanguard-text-muted">Approved</dt>
							<dd class="mt-0.5 font-mono text-sm text-vanguard-text">{member.tasksCompleted}</dd>
						</div>
						<div class="rounded-lg bg-vanguard-surface-2 px-2 py-2.5">
							<dt class="text-[10px] uppercase tracking-wider text-vanguard-text-muted">Earned</dt>
							<dd class="mt-0.5 font-mono text-sm text-vanguard-text">{formatToken(member.totalEarned, 0)}</dd>
						</div>
					</dl>
					{#if student.pendingPay > 0n || claimTx.phase === 'done'}
						<div class="mt-4 space-y-2 rounded-xl border border-amber-400/25 bg-amber-400/5 p-3.5">
							{#if student.pendingPay > 0n}
								<p class="flex items-center gap-2 text-sm text-amber-200"><Coins size={15} /> {formatToken(student.pendingPay)} VGRD ready to claim</p>
								<button class="btn-primary w-full" onclick={claim} disabled={claimTx.busy}>Claim to your wallet</button>
							{/if}
							<TxNotice tx={claimTx} doneText="Claimed. It’s in your wallet." />
						</div>
					{/if}
				</section>

				<!-- Rank path -->
				<section class="rounded-2xl border border-vanguard-border bg-vanguard-surface p-5">
					<h3 class="text-sm font-semibold text-vanguard-text">Your path</h3>
					<ol class="mt-3 space-y-1">
						{#each LADDER as rank, i}
							{@const reached = member.rankIndex >= i + 1}
							{@const here = member.rankIndex === i + 1}
							<li class="flex items-center gap-3 rounded-lg px-2 py-1.5 {here ? 'bg-cyan-400/10' : ''}">
								<span class={reached ? '' : 'opacity-40'}><RankInsignia {rank} size="sm" /></span>
								<span class="flex-1 text-sm {here ? 'font-medium text-vanguard-text' : reached ? 'text-vanguard-text-muted' : 'text-vanguard-text-muted/60'}">
									{RANK_META[rank].label}
									{#if rank === 'SGT'}<span class="block text-[11px] text-amber-300/80">after the leadership course</span>{/if}
								</span>
								<span class="font-mono text-xs text-vanguard-text-muted">{formatMultiplier(student.multipliers[i + 1] ?? RANK_META[rank].multiplier * 100)}</span>
							</li>
						{/each}
					</ol>
					<p class="mt-3 text-xs leading-relaxed text-vanguard-text-muted">
						Your instructor promotes you as your work is approved. Each rank raises the pay rate on every task you complete.
					</p>
				</section>
			{/if}

			{#if !student.member}
				<section class="rounded-2xl border border-vanguard-border bg-vanguard-surface p-5">
					<h3 class="text-sm font-semibold text-vanguard-text">What you leave with</h3>
					<ul class="mt-3 space-y-2.5">
						{#each cohort.outcomes as outcome}
							<li class="flex gap-2.5 text-sm text-vanguard-text-muted">
								<Check size={15} class="mt-0.5 flex-shrink-0 text-emerald-400" />
								{outcome}
							</li>
						{/each}
					</ul>
				</section>
			{/if}

			{#if student.squad}
				<section class="rounded-2xl border border-vanguard-border bg-vanguard-surface p-5">
					<div class="flex items-baseline justify-between">
						<h3 class="text-sm font-semibold text-vanguard-text">{student.squad.name}</h3>
						<span class="text-xs text-vanguard-text-muted">{student.classmates.length} enlisted</span>
					</div>
					<ul class="mt-3 grid grid-cols-1 gap-1.5">
						{#each student.classmates as mate}
							<li class="flex items-center gap-2.5 rounded-lg px-1.5 py-1 {sameAddress(mate.address, wallet.account) ? 'bg-vanguard-surface-2' : ''}">
								<SoldierAvatar callsign={mate.callsign} rank={mate.rank} size="sm" />
								<span class="min-w-0 flex-1 truncate font-mono text-xs text-vanguard-text">{mate.callsign}</span>
								{#if sameAddress(mate.address, student.squad.leader)}
									<span class="text-[10px] uppercase tracking-wider text-amber-300">Instructor</span>
								{:else if sameAddress(mate.address, wallet.account)}
									<span class="text-[10px] uppercase tracking-wider text-cyan-300">You</span>
								{:else}
									<span class="text-[10px] text-vanguard-text-muted">{mate.rank}</span>
								{/if}
							</li>
						{:else}
							<li class="text-xs text-vanguard-text-muted">Nobody has enlisted yet.</li>
						{/each}
					</ul>
					{#if student.inCohort && myInviteLink}
						<div class="mt-4 space-y-1.5 border-t border-vanguard-border pt-4">
							<p class="text-xs text-vanguard-text-muted">Know someone who should be here? People who enlist through your link are recorded as your recruits.</p>
							<CopyField value={myInviteLink} label="Copy" />
						</div>
					{/if}
				</section>
			{/if}
		</div>
	</div>
</div>

<style>
	.academy-hero {
		background:
			radial-gradient(ellipse 60% 120% at 100% 0%, rgba(6, 182, 212, 0.12), transparent 60%),
			var(--color-vanguard-surface);
	}
</style>
