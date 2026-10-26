<script lang="ts">
	import { resolve } from '$app/paths';
	import { page } from '$app/stores';
	import type { RouteId } from '$app/types';
	import { app } from '$stores/app.svelte';
	import { student } from '$lib/academy/student.svelte';
	import { RANK_META } from '$lib/types';
	import { formatToken } from '$lib/contracts/chain';
	import RankInsignia from '$components/RankInsignia.svelte';

	interface NavItem {
		label: string;
		/** Route id, for highlighting the current page. */
		route: RouteId;
		href: string;
		icon: string;
		badge?: number;
	}

	interface NavSection {
		title: string;
		items: NavItem[];
	}

	const JOIN_ITEM: NavItem = { label: 'Join', route: '/join', href: resolve('/join'), icon: '+' };

	let sections = $derived<NavSection[]>([
		{
			title: 'Academy',
			items: [
				{ label: 'My cohort', route: '/academy', href: resolve('/academy'), icon: '◆' },
				...(student.member ? [] : [JOIN_ITEM]),
			],
		},
		{ title: 'Guild', items: [{ label: 'Team', route: '/team', href: resolve('/team'), icon: '⬡' }] },
		{
			title: 'Preview · sample data',
			items: [
				{ label: 'Dashboard', route: '/dashboard', href: resolve('/dashboard'), icon: '⌂' },
				{ label: 'Bounties', route: '/bounties', href: resolve('/bounties'), icon: '◈' },
				{ label: 'Objectives', route: '/objectives', href: resolve('/objectives'), icon: '⎇' },
				{ label: 'Tasks', route: '/tasks', href: resolve('/tasks'), icon: '▸' },
				{ label: 'Review', route: '/review', href: resolve('/review'), icon: '✓' },
			],
		},
	]);

	const bottomNav: NavItem[] = [
		{ label: 'Settings', route: '/settings', href: resolve('/settings'), icon: '⚙' },
	];

	// Match on route ids, which don't carry the deploy base path.
	function isActive(route: RouteId, current: string | null): boolean {
		return current === route || !!current?.startsWith(`${route}/`);
	}

	let currentPath = $derived($page.route.id);
	let member = $derived(student.member);
	let pendingReviews = $derived(app.objectives.filter(o => o.status === 'in_review').length);
	// Weeks where the student has something to do: sent back, due, or open to take.
	let cohortActions = $derived(student.weeks.filter(w => w.status === 'changes' || w.status === 'todo' || w.status === 'available').length);

	function navBadge(href: string): number | undefined {
		if (href === '/academy' && cohortActions > 0) return cohortActions;
		if (href === '/review' && pendingReviews > 0) return pendingReviews;
		if (href === '/tasks') {
			const myActive = app.myTasks.filter(t => t.status !== 'approved').length;
			return myActive > 0 ? myActive : undefined;
		}
		return undefined;
	}
</script>

<aside
	class="fixed left-0 top-0 bottom-0 z-40 flex-col border-r border-vanguard-border bg-vanguard-surface transition-all duration-200 {app.mobileNavOpen ? 'flex' : 'hidden'} lg:flex"
	class:w-60={!app.sidebarCollapsed}
	class:w-16={app.sidebarCollapsed}
>
	<!-- Logo -->
	<div class="flex items-center gap-3 px-4 h-14 border-b border-vanguard-border">
		<a href={resolve('/')} class="w-8 h-8 rounded-lg bg-gradient-to-br from-cyan-500 to-cyan-700 flex items-center justify-center text-white font-bold text-sm flex-shrink-0">
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
	<nav class="flex-1 py-3 px-2 space-y-4 overflow-y-auto">
		{#each sections as section}
			<div class="space-y-0.5">
				{#if !app.sidebarCollapsed}
					<div class="px-3 pb-1 text-[10px] font-semibold uppercase tracking-widest text-vanguard-text-muted/70">{section.title}</div>
				{/if}
				{#each section.items as item}
					{@const active = isActive(item.route, currentPath)}
					{@const badge = navBadge(item.route)}
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
			</div>
		{/each}
	</nav>

	<!-- Bottom Nav -->
	<div class="px-2 pb-1">
		{#each bottomNav as item}
			{@const active = isActive(item.route, currentPath)}
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

	<!-- User Card: the connected member, read from the chain -->
	{#if member}
		<div class="border-t border-vanguard-border p-3">
			<a href={resolve('/academy')} class="block">
				{#if !app.sidebarCollapsed}
					<div class="flex items-center gap-3 group">
						<RankInsignia rank={member.rank} size="md" />
						<div class="flex flex-col min-w-0">
							<span class="text-sm font-medium font-mono text-vanguard-text truncate group-hover:text-cyan-400 transition-colors">{member.callsign}</span>
							<span class="text-[10px] text-vanguard-text-muted">{RANK_META[member.rank].label} · {formatToken(member.totalEarned, 0)} VGRD</span>
						</div>
					</div>
				{:else}
					<div class="flex justify-center">
						<RankInsignia rank={member.rank} size="md" />
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
