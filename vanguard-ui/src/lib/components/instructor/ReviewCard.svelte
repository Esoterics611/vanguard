<script lang="ts">
	import { Check, Undo2 } from 'lucide-svelte';
	import { encodeBytes32String, toUtf8Bytes } from 'ethers';
	import { getTaskRegistry } from '$lib/contracts/contracts.svelte';
	import { TxRunner, requireSigner } from '$lib/contracts/tx.svelte';
	import { formatMultiplier, formatToken, payFor } from '$lib/contracts/chain';
	import { assignmentText } from '$lib/academy/student.svelte';
	import type { Submission } from '$lib/academy/instructor.svelte';
	import { RANK_META } from '$lib/types';
	import SoldierAvatar from '$components/SoldierAvatar.svelte';
	import FingerprintCheck from '$components/academy/FingerprintCheck.svelte';
	import TxNotice from '$components/academy/TxNotice.svelte';

	let {
		submission,
		multiplier,
		canManage,
		onchange,
		onverified,
	}: {
		submission: Submission;
		/** The student's pay multiplier in basis points. */
		multiplier: number;
		canManage: boolean;
		onchange?: () => void;
		onverified?: (taskId: number, verified: boolean) => void;
	} = $props();

	const MAX_REASON_BYTES = 31; // the reason is stored on chain as a bytes32 string

	const tx = new TxRunner();
	let matched = $state<boolean | null>(null);
	let sendingBack = $state(false);
	let reason = $state('');

	let task = $derived(submission.task);
	let student = $derived(submission.student);
	let brief = $derived(assignmentText(submission.week, task));
	let reasonBytes = $derived(toUtf8Bytes(reason.trim()).length);

	$effect(() => onverified?.(task.id, matched === true));

	async function approve() {
		if (await tx.run('Approve this work', () => getTaskRegistry(requireSigner()).approveTask(task.id))) onchange?.();
	}

	async function sendBack() {
		const encoded = encodeBytes32String(reason.trim());
		if (await tx.run('Send it back', () => getTaskRegistry(requireSigner()).rejectTask(task.id, encoded))) onchange?.();
	}
</script>

<article class="rounded-2xl border border-vanguard-border bg-vanguard-surface p-5">
	<header class="flex flex-wrap items-start justify-between gap-3">
		<div class="flex items-center gap-3">
			{#if student}
				<SoldierAvatar callsign={student.callsign} rank={student.rank} size="md" />
				<div>
					<p class="font-mono text-sm font-semibold text-vanguard-text">{student.callsign}</p>
					<p class="text-xs text-vanguard-text-muted">{RANK_META[student.rank].label}</p>
				</div>
			{:else}
				<p class="font-mono text-sm text-vanguard-text-muted">Not in this squad: {task.assignee}</p>
			{/if}
		</div>
		<p class="font-mono text-xs text-cyan-300">Week {submission.week.week} · {submission.week.title}</p>
	</header>

	<p class="mt-3 text-sm leading-relaxed text-vanguard-text">{brief ?? `Assignment #${task.id}`}</p>
	<div class="mt-2 flex flex-wrap gap-x-4 gap-y-1 text-xs text-vanguard-text-muted">
		<span class="font-mono" title={task.submission ?? ''}>Fingerprint {task.submission?.slice(0, 12)}…</span>
		{#if task.reward > 0n}
			<span class="text-amber-300">
				Approving pays {formatToken(payFor(task.reward, multiplier))} VGRD ({formatToken(task.reward)} × {formatMultiplier(multiplier)})
			</span>
		{/if}
	</div>

	{#if task.submission}
		<div class="mt-4">
			<FingerprintCheck expected={task.submission} bind:matched />
		</div>
	{/if}

	{#if canManage}
		<div class="mt-4 flex flex-wrap items-center gap-2">
			<button class="btn-primary" onclick={approve} disabled={tx.busy}><Check size={15} /> Approve</button>
			<button class="btn-ghost" onclick={() => (sendingBack = !sendingBack)} disabled={tx.busy}><Undo2 size={14} /> Send back</button>
			{#if matched !== true}
				<span class="text-xs text-vanguard-text-muted">Not checked against the file yet.</span>
			{/if}
		</div>
		{#if sendingBack}
			<div class="mt-3 space-y-2 rounded-xl border border-vanguard-border bg-vanguard-bg/40 p-3.5">
				<label class="block text-xs text-vanguard-text-muted" for="reason-{task.id}">A short note for the student, recorded on chain</label>
				<div class="flex flex-wrap gap-2">
					<input
						id="reason-{task.id}"
						bind:value={reason}
						placeholder="e.g. Add the vesting schedule"
						class="min-w-0 flex-1 rounded-lg border border-vanguard-border bg-vanguard-surface px-3 py-2 text-sm text-vanguard-text placeholder:text-vanguard-text-muted focus:border-cyan-500/60 focus:outline-none"
					/>
					<button class="btn-ghost" onclick={sendBack} disabled={tx.busy || reasonBytes === 0 || reasonBytes > MAX_REASON_BYTES}>Send back</button>
				</div>
				<p class="text-[11px] {reasonBytes > MAX_REASON_BYTES ? 'text-red-300' : 'text-vanguard-text-muted'}">
					{reasonBytes}/{MAX_REASON_BYTES} characters. Put longer feedback in your message to the student.
				</p>
			</div>
		{/if}
		<div class="mt-3"><TxNotice {tx} doneText="Recorded." /></div>
	{/if}
</article>
