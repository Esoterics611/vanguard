<script lang="ts">
	interface Props {
		value: number;
		max?: number;
		color?: 'cyan' | 'gold' | 'green' | 'purple';
		showLabel?: boolean;
		size?: 'sm' | 'md';
	}

	let { value, max = 100, color = 'cyan', showLabel = false, size = 'sm' }: Props = $props();

	let pct = $derived(Math.min(Math.round((value / max) * 100), 100));

	const colorMap = {
		cyan: 'bg-cyan-500',
		gold: 'bg-amber-500',
		green: 'bg-emerald-500',
		purple: 'bg-purple-500',
	};
</script>

<div class="flex items-center gap-2">
	<div class="flex-1 rounded-full overflow-hidden relative {size === 'sm' ? 'h-1.5' : 'h-2.5'} bg-vanguard-surface-3">
		<div
			class="h-full rounded-full transition-all duration-500 ease-out relative progress-shine {colorMap[color]}"
			style="width: {pct}%"
		></div>
	</div>
	{#if showLabel}
		<span class="text-xs text-vanguard-text-muted font-mono w-10 text-right">{pct}%</span>
	{/if}
</div>
