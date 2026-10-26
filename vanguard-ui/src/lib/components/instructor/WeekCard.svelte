<script lang="ts">
	import { untrack } from 'svelte';
	import { ChevronDown, Send, UserPlus } from 'lucide-svelte';
	import { parseEther } from 'ethers';
	import { addresses } from '$lib/contracts/addresses';
	import { encoders, getTaskRegistry } from '$lib/contracts/contracts.svelte';
	import { TxRunner, requireSigner } from '$lib/contracts/tx.svelte';
	import { BatchRunner, type Call } from '$lib/contracts/batch.svelte';
	import { fingerprintText } from '$lib/contracts/fingerprint';
	import { formatToken } from '$lib/contracts/chain';
	import { weekBrief, type Cohort } from '$lib/academy/cohorts';
	import type { StudentRow, WeekBoard } from '$lib/academy/instructor.svelte';
	import TxNotice from '$components/academy/TxNotice.svelte';
	import BatchNotice from '$components/academy/BatchNotice.svelte';

	let {
		board,
		cohort,
		students,
		canManage,
		current = false,
		currentLabel = 'This week',
		onchange,
	}: {
		board: WeekBoard;
		cohort: Cohort;
		students: StudentRow[];
		canManage: boolean;
		current?: boolean;
		currentLabel?: string;
		/** Reloads the cohort; resolves to the refreshed board for this week. */
		onchange: () => Promise<WeekBoard | undefined>;
	} = $props();

	const DAY = 86_400_000;
	const tx = new TxRunner();
	const batch = new BatchRunner();

	// End of the week by default (week 1 runs from the start date for 7 days).
	function defaultDeadline(): string {
		if (!cohort.startDate) return '';
		const end = new Date(new Date(`${cohort.startDate}T00:00:00`).getTime() + (board.week.week * 7 - 1) * DAY);
		return `${end.getFullYear()}-${String(end.getMonth() + 1).padStart(2, '0')}-${String(end.getDate()).padStart(2, '0')}`;
	}

	// The current week starts open for the instructor; a click overrides either way.
	let expanded = $state<boolean | null>(null);
	let open = $derived(expanded ?? (current && canManage));
	// Form fields start from the cohort's defaults; the instructor can change them per week.
	let reward = $state(untrack(() => cohort.assignmentReward));
	let deadline = $state(defaultDeadline());

	let posted = $derived(board.objective !== null);
	// Students with no copy of this week's assignment yet.
	let without = $derived(students.filter((s) => !s.byWeek.has(board.week.week)));
	let neededCopies = $derived(Math.max(0, without.length - board.open.length));
	let copies = $state(0);
	$effect(() => {
		copies = posted ? neededCopies : students.length;
	});

	let rewardWei = $derived.by(() => {
		try {
			return parseEther(reward.trim() || '0');
		} catch {
			return null;
		}
	});
	let deadlineSeconds = $derived(deadline ? Math.floor(new Date(`${deadline}T23:59:59`).getTime() / 1000) : 0);

	function copyCalls(objectiveId: number, count: number): Call[] {
		const data = encoders.TaskRegistry.encodeFunctionData('createTask', [
			objectiveId,
			fingerprintText(board.week.assignment),
			rewardWei ?? 0n,
			deadlineSeconds,
		]);
		return Array.from({ length: count }, () => ({ to: addresses.TaskRegistry, data }));
	}

	async function post() {
		if (!cohort.squadId || rewardWei === null) return;
		expanded = true; // keep the card open for the progress notices, whatever `current` does
		let objectiveId = board.objective?.id;
		if (objectiveId === undefined) {
			const brief = fingerprintText(weekBrief(cohort, board.week));
			const squadId = cohort.squadId;
			const ok = await tx.run(`Post week ${board.week.week}`, () => getTaskRegistry(requireSigner()).createObjective(0, squadId, brief, 0));
			if (!ok) return;
			objectiveId = (await onchange())?.objective?.id;
			if (objectiveId === undefined) return;
		}
		if (copies > 0) {
			await batch.run(`Post ${copies} ${copies === 1 ? 'copy' : 'copies'} of week ${board.week.week}`, copyCalls(objectiveId, copies));
			await onchange();
		}
	}

	async function handOut() {
		expanded = true;
		const pairs = without.slice(0, board.open.length).map((s, i) => [board.open[i].id, s.member.address] as const);
		const calls = pairs.map(([taskId, student]) => ({
			to: addresses.TaskRegistry,
			data: encoders.TaskRegistry.encodeFunctionData('assignTask', [taskId, student]),
		}));
		await batch.run(`Hand out week ${board.week.week}`, calls);
		await onchange();
	}

	let summary = $derived(
		posted
			? [
					`${board.tasks.length} ${board.tasks.length === 1 ? 'copy' : 'copies'}`,
					board.counts.open && `${board.counts.open} open`,
					board.counts.assigned && `${board.counts.assigned} to hand in`,
					board.counts.submitted && `${board.counts.submitted} in review`,
					board.counts.approved && `${board.counts.approved} approved`,
					board.counts.rejected && `${board.counts.rejected} sent back`,
				]
					.filter(Boolean)
					.join(' · ')
			: 'Not posted yet'
	);
</script>

<article class="rounded-2xl border bg-vanguard-surface {current ? 'border-cyan-500/40' : 'border-vanguard-border'}">
	<button class="flex w-full items-center gap-4 px-5 py-4 text-left" onclick={() => (expanded = !open)} aria-expanded={open}>
		<span
			class="flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-lg border font-mono text-xs
				{posted ? 'border-cyan-400/40 bg-cyan-400/10 text-cyan-300' : 'border-vanguard-border text-vanguard-text-muted'}"
		>
			{board.week.week}
		</span>
		<span class="min-w-0 flex-1">
			<span class="flex flex-wrap items-center gap-2">
				<span class="text-sm font-medium text-vanguard-text">{board.week.title}</span>
				{#if current}<span class="rounded-full bg-cyan-400/15 px-2 py-0.5 text-[10px] font-semibold uppercase tracking-wider text-cyan-300">{currentLabel}</span>{/if}
			</span>
			<span class="mt-0.5 block truncate text-xs text-vanguard-text-muted">{summary}</span>
		</span>
		<ChevronDown size={16} class="flex-shrink-0 text-vanguard-text-muted transition-transform {open ? 'rotate-180' : ''}" />
	</button>

	{#if open}
		<div class="space-y-4 border-t border-vanguard-border px-5 py-4">
			<div>
				<p class="mb-1 text-[11px] font-semibold uppercase tracking-wider text-vanguard-text-muted">Students hand in</p>
				<p class="text-sm text-vanguard-text">{board.week.assignment}</p>
			</div>

			{#if canManage}
				{#if !posted || neededCopies > 0 || copies > 0}
					<div class="grid gap-3 sm:grid-cols-3">
						<label class="space-y-1">
							<span class="block text-xs text-vanguard-text-muted">Pay per assignment (VGRD)</span>
							<input bind:value={reward} inputmode="decimal" class="field" class:invalid={rewardWei === null} />
						</label>
						<label class="space-y-1">
							<span class="block text-xs text-vanguard-text-muted">Deadline (optional)</span>
							<input type="date" bind:value={deadline} class="field" />
						</label>
						<label class="space-y-1">
							<span class="block text-xs text-vanguard-text-muted">{posted ? 'Extra copies' : 'Copies'}</span>
							<input type="number" min="0" max="200" bind:value={copies} class="field" />
						</label>
					</div>
					<p class="text-xs text-vanguard-text-muted">
						{#if rewardWei !== null && rewardWei > 0n}Each approved copy pays {formatToken(rewardWei)} VGRD times the student’s rank multiplier.{/if}
						Students take an open copy from their cohort page, or you hand them out below.
					</p>
					<button class="btn-primary" onclick={post} disabled={tx.busy || batch.busy || rewardWei === null || (posted && copies === 0)}>
						<Send size={14} />
						{posted ? `Post ${copies} more` : `Post week ${board.week.week}`}
					</button>
				{/if}

				{#if posted && board.open.length > 0 && without.length > 0}
					<div class="flex flex-wrap items-center gap-3 rounded-xl border border-vanguard-border bg-vanguard-bg/40 p-3.5">
						<p class="min-w-0 flex-1 text-sm text-vanguard-text-muted">
							{without.length} {without.length === 1 ? 'student hasn’t' : 'students haven’t'} got this week’s assignment; {board.open.length} open {board.open.length === 1 ? 'copy' : 'copies'} waiting.
						</p>
						<button class="btn-ghost" onclick={handOut} disabled={batch.busy}>
							<UserPlus size={14} /> Hand out {Math.min(without.length, board.open.length)}
						</button>
					</div>
				{/if}

				<TxNotice {tx} doneText="Week posted." />
				<BatchNotice {batch} doneText="Recorded on chain." />
			{/if}
		</div>
	{/if}
</article>

<style>
	.field {
		width: 100%;
		border-radius: 0.5rem;
		border: 1px solid var(--color-vanguard-border);
		background: var(--color-vanguard-bg);
		padding: 0.5rem 0.75rem;
		font-size: 0.875rem;
		color: var(--color-vanguard-text);
		color-scheme: dark;
	}
	.field:focus {
		outline: none;
		border-color: rgba(6, 182, 212, 0.6);
	}
	.field.invalid {
		border-color: rgba(248, 113, 113, 0.6);
	}
</style>
