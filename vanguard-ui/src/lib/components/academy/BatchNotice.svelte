<script lang="ts">
	import { LoaderCircle, Check, CircleAlert } from 'lucide-svelte';
	import type { BatchRunner } from '$lib/contracts/batch.svelte';

	let { batch, doneText = 'Done.' }: { batch: BatchRunner; doneText?: string } = $props();

	let step = $derived(batch.mode === 'sequential' && batch.total > 1 ? ` (${Math.min(batch.done + 1, batch.total)} of ${batch.total})` : '');
</script>

{#if batch.phase !== 'idle'}
	<div
		class="flex items-start gap-2.5 rounded-lg border px-3.5 py-2.5 text-sm
			{batch.phase === 'failed'
				? 'border-red-500/30 bg-red-500/5 text-red-300'
				: batch.phase === 'done'
					? 'border-emerald-500/30 bg-emerald-500/5 text-emerald-300'
					: 'border-cyan-500/30 bg-cyan-500/5 text-cyan-200'}"
		role={batch.phase === 'failed' ? 'alert' : 'status'}
	>
		<span class="mt-0.5 flex-shrink-0">
			{#if batch.phase === 'failed'}
				<CircleAlert size={16} />
			{:else if batch.phase === 'done'}
				<Check size={16} />
			{:else}
				<LoaderCircle size={16} class="animate-spin" />
			{/if}
		</span>
		<span class="min-w-0 flex-1">
			{#if batch.phase === 'signing'}
				{#if batch.mode === 'batch'}
					Confirm “{batch.label}” in your wallet: one confirmation covers all {batch.total}.
				{:else}
					Confirm “{batch.label}” in your wallet{step}.
				{/if}
			{:else if batch.phase === 'pending'}
				Recording{step}. This usually takes a few seconds.
			{:else if batch.phase === 'done'}
				{doneText}
			{:else}
				{batch.error}
			{/if}
		</span>
	</div>
{/if}
