<script lang="ts">
	import { Upload, FileText } from 'lucide-svelte';
	import { fingerprintFile, fingerprintText } from '$lib/contracts/fingerprint';

	let {
		fingerprint = $bindable(null),
		prompt = 'Choose your file',
		hint = 'PDF, document, spreadsheet: any file works',
		placeholder = 'Paste your work here',
		compact = false,
	}: { fingerprint?: string | null; prompt?: string; hint?: string; placeholder?: string; compact?: boolean } = $props();

	let mode = $state<'file' | 'text'>('file');
	let fileName = $state<string | null>(null);
	let fileHash = $state<string | null>(null);
	let text = $state('');
	let reading = $state(false);

	// Pasted text is fingerprinted exactly as pasted, the same as a .txt file with that content.
	$effect(() => {
		fingerprint = mode === 'file' ? fileHash : text.trim() ? fingerprintText(text) : null;
	});

	async function pickFile(event: Event) {
		const file = (event.currentTarget as HTMLInputElement).files?.[0];
		if (!file) return;
		reading = true;
		fileName = file.name;
		fileHash = await fingerprintFile(file);
		reading = false;
	}
</script>

<div class="space-y-2.5">
	<div class="flex w-fit gap-1 rounded-lg border border-vanguard-border bg-vanguard-bg/60 p-1" role="tablist">
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
			class="flex cursor-pointer flex-col items-center justify-center gap-1.5 rounded-xl border border-dashed border-vanguard-border-bright bg-vanguard-bg/40 px-4 text-center transition-colors hover:border-cyan-500/50 hover:bg-cyan-500/5 focus-within:border-cyan-400 {compact ? 'py-3' : 'py-6'}"
		>
			<Upload size={compact ? 16 : 20} class="text-vanguard-text-muted" />
			<span class="text-sm text-vanguard-text">{fileName ?? prompt}</span>
			{#if !compact}<span class="text-xs text-vanguard-text-muted">{hint}</span>{/if}
			<input type="file" class="sr-only" onchange={pickFile} />
		</label>
	{:else}
		<textarea
			bind:value={text}
			rows={compact ? 3 : 5}
			{placeholder}
			class="w-full rounded-xl border border-vanguard-border bg-vanguard-bg/40 px-3.5 py-3 text-sm text-vanguard-text placeholder:text-vanguard-text-muted focus:border-cyan-500/60 focus:outline-none"
		></textarea>
	{/if}

	{#if reading}
		<p class="text-xs text-vanguard-text-muted">Reading the file…</p>
	{/if}
</div>
