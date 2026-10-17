<script lang="ts">
	import { RANK_META, type Rank } from '$lib/types';

	interface Props {
		rank: Rank;
		size?: 'sm' | 'md' | 'lg' | 'xl';
		showLabel?: boolean;
		glow?: boolean;
	}

	let { rank, size = 'md', showLabel = false, glow = false }: Props = $props();
	let meta = $derived(RANK_META[rank]);

	// SVG rank insignia designs
	const insignia: Record<Rank, string> = {
		// Enlisted: chevrons pointing up
		PVT: `<path d="M12 18L6 12h12L12 18z" fill="currentColor" opacity="0.4"/>`,
		PV2: `<path d="M12 16L6 10h12L12 16z" fill="currentColor" opacity="0.6"/>
		      <path d="M12 20L6 14h12L12 20z" fill="currentColor" opacity="0.3"/>`,
		PFC: `<path d="M12 14L6 8h12L12 14z" fill="currentColor"/>
		      <path d="M12 18L6 12h12L12 18z" fill="currentColor" opacity="0.6"/>
		      <path d="M12 22L6 16h12L12 22z" fill="currentColor" opacity="0.3"/>`,
		CPL: `<path d="M12 12L6 6h12L12 12z" fill="currentColor"/>
		      <path d="M12 16L6 10h12L12 16z" fill="currentColor" opacity="0.8"/>
		      <path d="M12 20L6 14h12L12 20z" fill="currentColor" opacity="0.5"/>`,
		// NCO: chevrons with rockers
		SGT: `<path d="M12 10L5 4h14L12 10z" fill="currentColor"/>
		      <path d="M12 15L5 9h14L12 15z" fill="currentColor" opacity="0.8"/>
		      <path d="M12 20L5 14h14L12 20z" fill="currentColor" opacity="0.6"/>
		      <path d="M5 22Q12 25 19 22" stroke="currentColor" stroke-width="1.5" fill="none"/>`,
		SSG: `<path d="M12 8L5 2h14L12 8z" fill="currentColor"/>
		      <path d="M12 13L5 7h14L12 13z" fill="currentColor" opacity="0.85"/>
		      <path d="M12 18L5 12h14L12 18z" fill="currentColor" opacity="0.7"/>
		      <path d="M5 20Q12 23 19 20" stroke="currentColor" stroke-width="1.5" fill="none"/>
		      <path d="M5 23Q12 26 19 23" stroke="currentColor" stroke-width="1.5" fill="none"/>`,
		SFC: `<path d="M12 7L5 1h14L12 7z" fill="currentColor"/>
		      <path d="M12 12L5 6h14L12 12z" fill="currentColor" opacity="0.85"/>
		      <path d="M12 17L5 11h14L12 17z" fill="currentColor" opacity="0.7"/>
		      <path d="M5 19Q12 22 19 19" stroke="currentColor" stroke-width="1.5" fill="none"/>
		      <path d="M5 22Q12 25 19 22" stroke="currentColor" stroke-width="1.5" fill="none"/>
		      <circle cx="12" cy="2" r="1.5" fill="currentColor" opacity="0.6"/>`,
		'1SG': `<path d="M12 7L5 1h14L12 7z" fill="currentColor"/>
		       <path d="M12 12L5 6h14L12 12z" fill="currentColor" opacity="0.85"/>
		       <path d="M12 17L5 11h14L12 17z" fill="currentColor" opacity="0.7"/>
		       <path d="M5 19Q12 22 19 19" stroke="currentColor" stroke-width="1.5" fill="none"/>
		       <path d="M5 22Q12 25 19 22" stroke="currentColor" stroke-width="1.5" fill="none"/>
		       <path d="M5 25Q12 28 19 25" stroke="currentColor" stroke-width="1.5" fill="none"/>
		       <circle cx="12" cy="1.5" r="2" fill="currentColor"/>`,
		// Officers: bars and diamonds
		'2LT': `<rect x="8" y="9" width="8" height="6" rx="1" fill="currentColor"/>
		        <rect x="9" y="10" width="6" height="4" rx="0.5" fill="black" opacity="0.3"/>`,
		'1LT': `<rect x="5" y="9" width="6" height="6" rx="1" fill="currentColor"/>
		        <rect x="13" y="9" width="6" height="6" rx="1" fill="currentColor"/>`,
		CPT: `<rect x="5" y="9" width="5" height="6" rx="1" fill="currentColor"/>
		      <rect x="11.5" y="9" width="5" height="6" rx="1" fill="currentColor"/>
		      <path d="M12 5L14.5 9h-5L12 5z" fill="currentColor"/>
		      <path d="M12 19L14.5 15h-5L12 19z" fill="currentColor"/>`,
	};

	const sizeMap = {
		sm: { box: 'w-6 h-6', svg: 18, text: 'text-[9px]' },
		md: { box: 'w-8 h-8', svg: 24, text: 'text-[10px]' },
		lg: { box: 'w-11 h-11', svg: 32, text: 'text-xs' },
		xl: { box: 'w-16 h-16', svg: 48, text: 'text-sm' },
	};

	let s = $derived(sizeMap[size]);
</script>

<div class="flex items-center gap-1.5" title="{meta.label}">
	<div
		class="relative flex items-center justify-center {s.box} rounded-md"
		style="color: {meta.color}; background: color-mix(in srgb, {meta.color} 12%, transparent); border: 1px solid color-mix(in srgb, {meta.color} 25%, transparent);"
		class:glow-cyan={glow && meta.tier === 'nco'}
		class:glow-gold={glow && meta.tier === 'officer'}
	>
		<svg viewBox="0 0 24 24" width={s.svg * 0.65} height={s.svg * 0.65}>
			{@html insignia[rank]}
		</svg>
	</div>
	{#if showLabel}
		<div class="flex flex-col">
			<span class="{s.text} font-bold" style="color: {meta.color}">{rank}</span>
			<span class="text-[9px] text-vanguard-text-muted leading-tight">{meta.label}</span>
		</div>
	{/if}
</div>
