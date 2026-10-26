<script lang="ts">
	import { Upload, FileText, Send } from 'lucide-svelte';
	import { getTaskRegistry } from '$lib/contracts/contracts.svelte';
	import { fingerprintFile, fingerprintText } from '$lib/contracts/fingerprint';
	import { TxRunner, requireSigner } from '$lib/contracts/tx.svelte';
	import type { ChainTask } from '$lib/contracts/chain';
	import TxNotice from './TxNotice.svelte';

	let { task, onsubmitted }: { task: ChainTask; onsubmitted?: () => void } = $props();

	const tx = new TxRunner();
	let mode = $state<'file' | 'text'>('file');
	let fileName = $state<string | null>(null);
	let fileHash = $state<string | null>(null);
	let text = $state('');
	let reading = $state(false);

	let resubmit = $derived(task.state === 'rejected');
	let fingerprint = $derived(mode === 'file' ? fileHash : text.trim() ? fingerprintText(text) : null);
	let pastDeadline = $derived(task.deadline > 0 && Date.now() / 1000 > task.deadline);

	async function pickFile(event: Event) {
		const file = (event.currentTarget as HTMLInputElement).files?.[0];
		if (!file) return;
		reading = true;
		fileName = file.name;
		fileHash = await fingerprintFile(file);
		reading = false;
	}

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
		<div class="flex gap-1 rounded-lg border border-vanguard-border bg-vanguard-bg/60 p-1 w-fit" role="tablist">
			{#each [{ key: 'file', label: 'Upload a file', icon: Upload }, { key: 'text', label: 'Paste text', icon: FileText }] as option}
				<button
					type="button"
					role="tab"
					aria-selected={mode === option.key}
					onclick={() => (mode = option.key as 'file' | 'text')}
					class="flex items-center gap-1.5 rounded-md px-3 py-1.5 text-xs transition-colors
						{mode === option.key ? 'bg-vanguard-surface-3 text-cyan-300' : 'text-vanguard-text-muted hover:text-vanguard-text'}"
				>
					<option.icon size={13} />
					{option.label}
				</button>
			{/each}
		</div>

		{#if mode === 'file'}
			<label
				class="flex cursor-pointer flex-col items-center justify-center gap-1.5 rounded-xl border border-dashed border-vanguard-border-bright bg-vanguard-bg/40 px-4 py-6 text-center transition-colors hover:border-cyan-500/50 hover:bg-cyan-500/5 focus-within:border-cyan-400"
			>
				<Upload size={20} class="text-vanguard-text-muted" />
				<span class="text-sm text-vanguard-text">{fileName ?? 'Choose your file'}</span>
				<span class="text-xs text-vanguard-text-muted">PDF, document, spreadsheet: any file works</span>
				<input type="file" class="sr-only" onchange={pickFile} />
			</label>
		{:else}
			<textarea
				bind:value={text}
				rows="5"
				placeholder="Paste your work here"
				class="w-full rounded-xl border border-vanguard-border bg-vanguard-bg/40 px-3.5 py-3 text-sm text-vanguard-text placeholder:text-vanguard-text-muted focus:border-cyan-500/60 focus:outline-none"
			></textarea>
		{/if}

		{#if reading}
			<p class="text-xs text-vanguard-text-muted">Reading your file…</p>
		{:else if fingerprint}
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
