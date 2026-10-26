<script lang="ts">
	import { LoaderCircle, Check, CircleAlert, ExternalLink } from 'lucide-svelte';
	import { BASE_SEPOLIA_EXPLORER_URL } from '$lib/contracts/addresses';
	import type { TxRunner } from '$lib/contracts/tx.svelte';

	let { tx, doneText = 'Done.' }: { tx: TxRunner; doneText?: string } = $props();
</script>

{#if tx.phase !== 'idle'}
	<div
		class="flex items-start gap-2.5 rounded-lg border px-3.5 py-2.5 text-sm
			{tx.phase === 'failed'
				? 'border-red-500/30 bg-red-500/5 text-red-300'
				: tx.phase === 'done'
					? 'border-emerald-500/30 bg-emerald-500/5 text-emerald-300'
					: 'border-cyan-500/30 bg-cyan-500/5 text-cyan-200'}"
		role={tx.phase === 'failed' ? 'alert' : 'status'}
	>
		<span class="mt-0.5 flex-shrink-0">
			{#if tx.phase === 'failed'}
				<CircleAlert size={16} />
			{:else if tx.phase === 'done'}
				<Check size={16} />
			{:else}
				<LoaderCircle size={16} class="animate-spin" />
			{/if}
		</span>
		<span class="flex-1 min-w-0">
			{#if tx.phase === 'signing'}
				Confirm “{tx.label}” in your wallet.
			{:else if tx.phase === 'pending'}
				Recording on Base Sepolia. This usually takes a few seconds.
			{:else if tx.phase === 'done'}
				{doneText}
			{:else}
				{tx.error}
			{/if}
			{#if tx.hash}
				<a
					href="{BASE_SEPOLIA_EXPLORER_URL}/tx/{tx.hash}"
					target="_blank"
					rel="noopener"
					class="ml-1 inline-flex items-center gap-1 text-xs underline decoration-dotted underline-offset-2 opacity-80 hover:opacity-100"
				>
					View transaction <ExternalLink size={11} />
				</a>
			{/if}
		</span>
	</div>
{/if}
