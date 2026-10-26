<script lang="ts">
	import { page } from '$app/stores';
	import { resolve } from '$app/paths';
	import type { RouteId } from '$app/types';
	import { app } from '$stores/app.svelte';
	import ConnectWallet from '$components/ConnectWallet.svelte';
	import { Menu } from 'lucide-svelte';

	const routeTitles: Partial<Record<RouteId, string>> = {
		'/academy': 'Academy',
		'/academy/guide': 'Handing in work',
		'/instructor': 'Instructor',
		'/dashboard': 'Dashboard',
		'/bounties': 'Bounties',
		'/objectives': 'Objectives',
		'/tasks': 'My Tasks',
		'/team': 'Team',
		'/review': 'Commander Review',
		'/settings': 'Settings',
	};

	// Route ids rather than URL paths, so the deploy base path doesn't matter.
	let routeId = $derived($page.route.id);
	let title = $derived((routeId && routeTitles[routeId]) ?? 'Vanguard');

	// Breadcrumb from the route id: /team/[id] → Team
	const SECTIONS: Record<string, string> = {
		academy: resolve('/academy'),
		bounties: resolve('/bounties'),
		objectives: resolve('/objectives'),
		team: resolve('/team'),
	};
	let breadcrumbs = $derived(() => {
		const parts = (routeId ?? '').split('/').filter(Boolean);
		if (parts.length <= 1) return [];
		return parts
			.slice(0, -1)
			.filter((part) => part in SECTIONS)
			.map((part) => ({ label: part.charAt(0).toUpperCase() + part.slice(1), href: SECTIONS[part] }));
	});
</script>

<header class="h-14 border-b border-vanguard-border bg-vanguard-surface/80 backdrop-blur-sm flex items-center justify-between gap-3 px-4 sm:px-6 sticky top-0 z-20">
	<div class="flex items-center gap-3 sm:gap-4 min-w-0">
		<button
			onclick={() => (app.mobileNavOpen = !app.mobileNavOpen)}
			class="lg:hidden -ml-1 p-1.5 rounded-lg text-vanguard-text-muted hover:text-vanguard-text hover:bg-vanguard-surface-2"
			aria-label="Menu"
			aria-expanded={app.mobileNavOpen}
		>
			<Menu size={18} />
		</button>
		<!-- Breadcrumbs -->
		{#if breadcrumbs().length > 0}
			<div class="flex items-center gap-1 text-xs text-vanguard-text-muted">
				{#each breadcrumbs() as crumb}
					<a href={crumb.href} class="hover:text-vanguard-text transition-colors">{crumb.label}</a>
					<span class="text-vanguard-border">/</span>
				{/each}
			</div>
		{/if}
		<h1 class="text-base font-semibold text-vanguard-text">{title}</h1>
	</div>

	<div class="flex items-center gap-3">
		<!-- Search / Command Palette Trigger -->
		<button
			onclick={() => app.toggleCommandPalette()}
			class="hidden sm:flex items-center gap-2 px-3 py-1.5 rounded-lg border border-vanguard-border bg-vanguard-surface-2 text-vanguard-text-muted text-xs hover:border-vanguard-border-bright hover:text-vanguard-text transition-all"
		>
			<span>Search...</span>
			<kbd class="text-[10px] bg-vanguard-surface-3 px-1.5 py-0.5 rounded border border-vanguard-border">⌘K</kbd>
		</button>

		<!-- Notifications -->
		<button class="relative hidden sm:block p-2 rounded-lg text-vanguard-text-muted hover:text-vanguard-text hover:bg-vanguard-surface-2 transition-colors">
			<span class="text-sm">◉</span>
			{#if app.stats.pendingReviews > 0}
				<span class="absolute top-1 right-1 w-2 h-2 rounded-full bg-cyan-400"></span>
			{/if}
		</button>

		<!-- Wallet connect -->
		<ConnectWallet />
	</div>
</header>
