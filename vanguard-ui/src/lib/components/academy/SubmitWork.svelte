<script lang="ts">
	import { Send } from 'lucide-svelte';
	import { getTaskRegistry } from '$lib/contracts/contracts.svelte';
	import { TxRunner, requireSigner } from '$lib/contracts/tx.svelte';
	import type { ChainTask } from '$lib/contracts/chain';
	import FingerprintInput from './FingerprintInput.svelte';
	import TxNotice from './TxNotice.svelte';

	let { task, onsubmitted }: { task: ChainTask; onsubmitted?: () => void } = $props();

	const tx = new TxRunner();
	let fingerprint = $state<string | null>(null);

	let resubmit = $derived(task.state === 'rejected');
	let pastDeadline = $derived(task.deadline > 0 && Date.now() / 1000 > task.deadline);

	async function submit() {
		if (!fingerprint) return;
		const hash = fingerprint;
		const ok = await tx.run(resubmit ? 'Resubmit your work' : 'Submit your work', () => {
			const registry = getTaskRegistry(requireSigner());
			return resubmit ? registry.resubmitTask(task.id, hash) : registry.submitTask(task.id, hash);
		});
		if (ok) onsubmitted?.();
	}
</script>

<div class="space-y-3">
	{#if pastDeadline && !resubmit}
		<p class="text-sm text-amber-300">The deadline for this assignment has passed, so it can’t be submitted. Ask your instructor to reopen it.</p>
	{:else}
		<FingerprintInput bind:fingerprint />

		{#if fingerprint}
			<div class="rounded-lg border border-vanguard-border bg-vanguard-bg/60 px-3.5 py-2.5">
				<div class="text-[11px] uppercase tracking-wider text-vanguard-text-muted">Fingerprint</div>
				<code class="block break-all font-mono text-xs text-cyan-300">{fingerprint}</code>
			</div>
		{/if}

		<p class="text-xs leading-relaxed text-vanguard-text-muted">
			Only this fingerprint goes on chain. Your file stays on your device: send it to your instructor, who checks that it matches before approving.
		</p>

		<button
			type="button"
			onclick={submit}
			disabled={!fingerprint || tx.busy}
			class="inline-flex items-center gap-2 rounded-lg bg-cyan-500 px-4 py-2 text-sm font-semibold text-vanguard-bg transition-colors hover:bg-cyan-400 disabled:cursor-not-allowed disabled:opacity-40 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-cyan-300"
		>
			<Send size={15} />
			{resubmit ? 'Resubmit' : 'Submit'}
		</button>

		<TxNotice {tx} doneText="Submitted. Your instructor will review it." />
	{/if}
</div>
