<script lang="ts">
	import { app } from '$stores/app.svelte';
	import { formatVgrd, formatDeadline } from '$lib/utils/format';
	import StatusBadge from '$components/StatusBadge.svelte';
	import ProgressBar from '$components/ProgressBar.svelte';
	import SoldierAvatar from '$components/SoldierAvatar.svelte';
	import EmptyState from '$components/EmptyState.svelte';
	import type { BountyStatus } from '$lib/types';

	let filterStatus = $state<BountyStatus | 'all'>('all');
	let searchQuery = $state('');

	let filtered = $derived(() => {
		let result = app.bounties;
		if (filterStatus !== 'all') result = result.filter(b => b.status === filterStatus);
		if (searchQuery.trim()) {
			const q = searchQuery.toLowerCase();
			result = result.filter(b =>
				b.title.toLowerCase().includes(q) ||
				b.skillTags.some(t => t.toLowerCase().includes(q))
			);
		}
		return result;
	});

	const statusFilters: { label: string; value: BountyStatus | 'all' }[] = [
		{ label: 'All', value: 'all' },
		{ label: 'Active', value: 'active' },
		{ label: 'In Progress', value: 'in_progress' },
		{ label: 'Draft', value: 'draft' },
		{ label: 'Completed', value: 'completed' },
	];
</script>

<div class="space-y-5">
	<!-- Header -->
	<div class="flex items-center justify-between">
		<div>
			<h2 class="text-lg font-semibold text-vanguard-text">Bounties</h2>
			<p class="text-xs text-vanguard-text-muted mt-0.5">Deal flow — each bounty is a collaboration repository</p>
		</div>
		<a href="/bounties/new" class="px-4 py-2 rounded-lg bg-cyan-500/10 text-cyan-400 text-sm font-medium border border-cyan-500/20 hover:bg-cyan-500/20 transition-all">
			+ New Bounty
		</a>
	</div>

	<!-- Filters -->
	<div class="flex items-center gap-3">
		<div class="flex rounded-lg border border-vanguard-border bg-vanguard-surface overflow-hidden">
			{#each statusFilters as sf}
				<button
					onclick={() => filterStatus = sf.value}
					class="px-3 py-1.5 text-xs transition-all
						{filterStatus === sf.value
							? 'bg-vanguard-surface-3 text-cyan-400 font-medium'
							: 'text-vanguard-text-muted hover:text-vanguard-text hover:bg-vanguard-surface-2'}"
				>
					{sf.label}
				</button>
			{/each}
		</div>
		<input
			type="text"
			placeholder="Search bounties..."
			bind:value={searchQuery}
			class="px-3 py-1.5 rounded-lg border border-vanguard-border bg-vanguard-surface text-sm text-vanguard-text placeholder:text-vanguard-text-muted focus:outline-none focus:border-cyan-500/50 w-64"
		/>
	</div>

	<!-- Bounty List -->
	<div class="space-y-3">
		{#each filtered() as bounty}
			{@const objectives = app.getBountyObjectives(bounty.id)}
			{@const progress = app.getBountyProgress(bounty.id)}
			{@const creator = app.getSoldier(bounty.creatorId)}
			{@const deadline = formatDeadline(bounty.deadline)}
			<a href="/bounties/{bounty.id}" class="block rounded-xl border border-vanguard-border bg-vanguard-surface card-hover group">
				<div class="p-5">
					<div class="flex items-start justify-between gap-4">
						<div class="flex-1 min-w-0">
							<!-- Title row -->
							<div class="flex items-center gap-2 mb-1.5">
								<span class="text-cyan-500 text-sm">◈</span>
								<h3 class="text-sm font-semibold text-vanguard-text group-hover:text-cyan-400 transition-colors truncate">
									{bounty.title}
								</h3>
								<StatusBadge status={bounty.status} />
							</div>

							<!-- Description -->
							<p class="text-xs text-vanguard-text-muted leading-relaxed line-clamp-2 mb-3">
								{bounty.description}
							</p>

							<!-- Meta row -->
							<div class="flex items-center gap-4 flex-wrap">
								{#if creator}
									<div class="flex items-center gap-1.5">
										<SoldierAvatar callsign={creator.callsign} rank={creator.rank} isOnline={creator.isOnline} size="sm" />
										<span class="text-xs text-vanguard-text-muted">{creator.callsign}</span>
									</div>
								{/if}
								<span class="text-xs font-mono text-amber-400">{formatVgrd(bounty.totalAmount)} VGRD</span>
								<span class="text-xs text-vanguard-text-muted">{objectives.length} objectives</span>
								<span class="text-xs {deadline.overdue ? 'text-red-400' : deadline.urgent ? 'text-amber-400' : 'text-vanguard-text-muted'}">
									{deadline.text}
								</span>
								<div class="flex gap-1">
									{#each bounty.skillTags as tag}
										<span class="tag bg-vanguard-surface-3 text-vanguard-text-muted">{tag}</span>
									{/each}
								</div>
							</div>
						</div>

						<!-- Progress -->
						<div class="flex-shrink-0 w-28 text-right">
							<div class="text-xs text-vanguard-text-muted mb-1">
								{formatVgrd(bounty.totalAmount - bounty.remainingAmount)} / {formatVgrd(bounty.totalAmount)}
							</div>
							<ProgressBar value={progress} showLabel color="cyan" />
						</div>
					</div>
				</div>

				<!-- Objective summary bar -->
				{#if objectives.length > 0}
					<div class="border-t border-vanguard-border px-5 py-2.5 flex items-center gap-3">
						{#each objectives.slice(0, 4) as obj}
							<div class="flex items-center gap-1.5">
								<div class="w-1.5 h-1.5 rounded-full"
									class:bg-cyan-400={obj.status === 'open'}
									class:bg-amber-400={obj.status === 'in_progress'}
									class:bg-purple-400={obj.status === 'in_review'}
									class:bg-emerald-400={obj.status === 'merged'}
									class:bg-zinc-500={obj.status === 'closed'}
								></div>
								<span class="text-[11px] text-vanguard-text-muted truncate max-w-32">{obj.title}</span>
							</div>
						{/each}
						{#if objectives.length > 4}
							<span class="text-[11px] text-vanguard-text-muted">+{objectives.length - 4} more</span>
						{/if}
					</div>
				{/if}
			</a>
		{:else}
			<EmptyState icon="◈" title="No bounties found" description="Adjust your filters or create a new bounty" />
		{/each}
	</div>
</div>
