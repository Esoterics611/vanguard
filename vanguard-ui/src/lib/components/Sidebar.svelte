<script lang="ts">
	import { page } from '$app/stores';
	import { app } from '$stores/app.svelte';
	import { RANK_META } from '$lib/types';
	import { formatVgrd } from '$lib/utils/format';
	import RankInsignia from '$components/RankInsignia.svelte';

	interface NavItem {
		label: string;
		href: string;
		icon: string;
		badge?: number;
	}

	const mainNav: NavItem[] = [
		{ label: 'Dashboard', href: '/', icon: '⌂' },
		{ label: 'Bounties', href: '/bounties', icon: '◈' },
		{ label: 'Objectives', href: '/objectives', icon: '⎇' },
		{ label: 'Tasks', href: '/tasks', icon: '▸' },
		{ label: 'Team', href: '/team', icon: '⬡' },
		{ label: 'Review', href: '/review', icon: '✓' },
	];

	const bottomNav: NavItem[] = [
		{ label: 'Settings', href: '/settings', icon: '⚙' },
	];

	function isActive(href: string, currentPath: string): boolean {
		if (href === '/') return currentPath === '/';
		return currentPath.startsWith(href);
	}

	let currentPath = $derived($page.url.pathname);
	let user = $derived(app.currentUser);
	let rankMeta = $derived(user ? RANK_META[user.rank] : null);
	let pendingReviews = $derived(app.objectives.filter(o => o.status === 'in_review').length);

	function navBadge(href: string): number | undefined {
		if (href === '/review' && pendingReviews > 0) return pendingReviews;
		if (href === '/tasks') {
			const myActive = app.myTasks.filter(t => t.status !== 'approved').length;
			return myActive > 0 ? myActive : undefined;
		}
		return undefined;
	}
</script>

<aside
	class="fixed left-0 top-0 bottom-0 z-40 flex flex-col border-r border-vanguard-border bg-vanguard-surface transition-all duration-200"
	class:w-60={!app.sidebarCollapsed}
	class:w-16={app.sidebarCollapsed}
>
	<!-- Logo -->
	<div class="flex items-center gap-3 px-4 h-14 border-b border-vanguard-border">
		<a href="/" class="w-8 h-8 rounded-lg bg-gradient-to-br from-cyan-500 to-cyan-700 flex items-center justify-center text-white font-bold text-sm flex-shrink-0">
			V
		</a>
		{#if !app.sidebarCollapsed}
			<div class="flex flex-col min-w-0">
				<span class="text-sm font-semibold text-vanguard-text tracking-wide">VANGUARD</span>
				<span class="text-[10px] text-vanguard-text-muted tracking-widest">COMMAND CENTER</span>
			</div>
		{/if}
	</div>

	<!-- Main Navigation -->
	<nav class="flex-1 py-3 px-2 space-y-0.5 overflow-y-auto">
		{#each mainNav as item}
			{@const active = isActive(item.href, currentPath)}
			{@const badge = navBadge(item.href)}
			<a
				href={item.href}
				class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-all duration-150 group relative
					{active
						? 'bg-cyan-500/10 text-cyan-400 font-medium'
						: 'text-vanguard-text-muted hover:text-vanguard-text hover:bg-vanguard-surface-2'}"
			>
				{#if active}
					<div class="absolute left-0 top-1/2 -translate-y-1/2 w-0.5 h-5 bg-cyan-400 rounded-r"></div>
				{/if}
				<span class="text-base flex-shrink-0 w-5 text-center" class:text-cyan-400={active}>{item.icon}</span>
				{#if !app.sidebarCollapsed}
					<span class="flex-1 truncate">{item.label}</span>
					{#if badge}
						<span class="tag bg-cyan-500/20 text-cyan-400">{badge}</span>
					{/if}
				{/if}
			</a>
		{/each}
	</nav>

	<!-- Bottom Nav -->
	<div class="px-2 pb-1">
		{#each bottomNav as item}
			{@const active = isActive(item.href, currentPath)}
			<a
				href={item.href}
				class="flex items-center gap-3 px-3 py-2 rounded-lg text-sm transition-all duration-150
					{active
						? 'bg-cyan-500/10 text-cyan-400'
						: 'text-vanguard-text-muted hover:text-vanguard-text hover:bg-vanguard-surface-2'}"
			>
				<span class="text-base flex-shrink-0 w-5 text-center">{item.icon}</span>
				{#if !app.sidebarCollapsed}
					<span class="flex-1 truncate">{item.label}</span>
				{/if}
			</a>
		{/each}
	</div>

	<!-- User Card -->
	{#if user && rankMeta}
		<div class="border-t border-vanguard-border p-3">
			<a href="/settings" class="block">
				{#if !app.sidebarCollapsed}
					<div class="flex items-center gap-3 group">
						<div class="relative flex-shrink-0">
							<RankInsignia rank={user.rank} size="md" />
							<div class="absolute -bottom-0.5 -right-0.5 w-2.5 h-2.5 rounded-full border-2 border-vanguard-surface"
								 class:bg-emerald-400={user.isOnline}
								 class:bg-zinc-500={!user.isOnline}
								 class:pulse-online={user.isOnline}></div>
						</div>
						<div class="flex flex-col min-w-0">
							<span class="text-sm font-medium text-vanguard-text truncate group-hover:text-cyan-400 transition-colors">{user.callsign}</span>
							<span class="text-[10px] text-vanguard-text-muted">{rankMeta.label} · {formatVgrd(user.vgrdEarned)} VGRD</span>
						</div>
					</div>
				{:else}
					<div class="flex justify-center">
						<RankInsignia rank={user.rank} size="md" />
					</div>
				{/if}
			</a>
		</div>
	{/if}

	<!-- Collapse Toggle -->
	<button
		onclick={() => app.toggleSidebar()}
		class="border-t border-vanguard-border p-2 text-vanguard-text-muted hover:text-vanguard-text hover:bg-vanguard-surface-2 transition-colors text-xs text-center"
	>
		{app.sidebarCollapsed ? '→' : '← Collapse'}
	</button>
</aside>
