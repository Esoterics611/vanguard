<script lang="ts">
	import { RANK_META, type Rank } from '$lib/types';

	interface Props {
		rank: Rank;
		showLabel?: boolean;
		size?: 'sm' | 'md' | 'lg';
	}

	let { rank, showLabel = false, size = 'sm' }: Props = $props();
	let meta = $derived(RANK_META[rank]);

	const sizeClasses = {
		sm: 'w-7 h-7 text-[10px]',
		md: 'w-9 h-9 text-xs',
		lg: 'w-12 h-12 text-sm',
	};
</script>

<div class="flex items-center gap-1.5">
	<div
		class="rounded-md bg-vanguard-surface-3 flex items-center justify-center font-bold border border-vanguard-border {sizeClasses[size]}"
		style="color: {meta.color}; border-color: color-mix(in srgb, {meta.color} 30%, transparent)"
	>
		{rank}
	</div>
	{#if showLabel}
		<span class="text-xs text-vanguard-text-muted">{meta.label}</span>
	{/if}
</div>
