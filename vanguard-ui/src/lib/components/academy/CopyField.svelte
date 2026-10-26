<script lang="ts">
	import { Copy, Check } from 'lucide-svelte';

	let { value, label = 'Copy' }: { value: string; label?: string } = $props();

	let copied = $state(false);
	let timer: ReturnType<typeof setTimeout> | undefined;

	async function copy() {
		try {
			await navigator.clipboard.writeText(value);
			copied = true;
			clearTimeout(timer);
			timer = setTimeout(() => (copied = false), 1800);
		} catch {
			// clipboard blocked; the text is still selectable
		}
	}
</script>

<div class="flex items-stretch rounded-lg border border-vanguard-border bg-vanguard-bg/60 overflow-hidden">
	<code class="flex-1 min-w-0 px-3 py-2 text-xs font-mono text-vanguard-text truncate select-all" title={value}>{value}</code>
	<button
		type="button"
		onclick={copy}
		class="flex items-center gap-1.5 px-3 border-l border-vanguard-border text-xs text-vanguard-text-muted hover:text-cyan-300 hover:bg-vanguard-surface-2 transition-colors focus-visible:outline-2 focus-visible:outline-cyan-400"
	>
		{#if copied}
			<Check size={13} /> Copied
		{:else}
			<Copy size={13} /> {label}
		{/if}
	</button>
</div>
