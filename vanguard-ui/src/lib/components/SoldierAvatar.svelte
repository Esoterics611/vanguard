<script lang="ts">
	import { RANK_META, type Rank } from '$lib/types';

	interface Props {
		callsign: string;
		rank: Rank;
		isOnline?: boolean;
		size?: 'sm' | 'md' | 'lg';
	}

	let { callsign, rank, isOnline = false, size = 'md' }: Props = $props();
	let meta = $derived(RANK_META[rank]);
	let initials = $derived(callsign.slice(0, 2));

	const sizeClasses = {
		sm: 'w-7 h-7 text-[10px]',
		md: 'w-9 h-9 text-xs',
		lg: 'w-12 h-12 text-sm',
	};

	const dotSize = {
		sm: 'w-2 h-2 border',
		md: 'w-2.5 h-2.5 border-2',
		lg: 'w-3 h-3 border-2',
	};
</script>

<div class="relative flex-shrink-0">
	<div
		class="rounded-lg flex items-center justify-center font-bold {sizeClasses[size]}"
		style="background: color-mix(in srgb, {meta.color} 15%, var(--color-vanguard-surface-3)); color: {meta.color}"
	>
		{initials}
	</div>
	<div
		class="absolute -bottom-0.5 -right-0.5 rounded-full border-vanguard-surface {dotSize[size]}"
		class:bg-emerald-400={isOnline}
		class:bg-zinc-600={!isOnline}
		class:pulse-online={isOnline}
	></div>
</div>
