<script lang="ts">
	import { resolve } from '$app/paths';
	import { app } from '$stores/app.svelte';
	import { formatVgrd, formatDeadline } from '$lib/utils/format';
	import StatusBadge from '$components/StatusBadge.svelte';
	import ProgressBar from '$components/ProgressBar.svelte';
	import SoldierAvatar from '$components/SoldierAvatar.svelte';
	import EmptyState from '$components/EmptyState.svelte';
	import type { ObjectiveStatus } from '$lib/types';

	let filterStatus = $state<ObjectiveStatus | 'all'>('all');

	let filtered = $derived(() => {
		if (filterStatus === 'all') return app.objectives;
		return app.objectives.filter(o => o.status === filterStatus);
	});

	const statusFilters: { label: string; value: ObjectiveStatus | 'all' }[] = [
		{ label: 'All', value: 'all' },
		{ label: 'Open', value: 'open' },
		{ label: 'In Progress', value: 'in_progress' },
		{ label: 'In Review', value: 'in_review' },
		{ label: 'Merged', value: 'merged' },
	];

	const statusIcon: Record<string, string> = {
		open: '○',
		in_progress: '◐',
		in_review: '◑',
		merged: '●',
		closed: '✕',
	};
</script>

<div class="space-y-5">
	<div class="flex items-center justify-between">
		<div>
			<h2 class="text-lg font-semibold text-vanguard-text">Objectives</h2>
			<p class="text-xs text-vanguard-text-muted mt-0.5">Workstreams — like pull requests, checked out by units</p>
		</div>
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
	</div>

	<!-- Objectives List -->
	<div class="space-y-2">
		{#each filtered() as obj}
			{@const bounty = app.getBounty(obj.bountyId)}
			{@const tasks = app.getObjectiveTasks(obj.id)}
			{@const progress = app.getObjectiveProgress(obj.id)}
			{@const assignee = obj.assigneeId ? app.getSoldier(obj.assigneeId) : null}
			{@const unit = obj.unitId ? app.getUnit(obj.unitId) : null}
			{@const deadline = formatDeadline(obj.deadline)}
			<a href={resolve(`/objectives/${obj.id}`)} class="flex items-center gap-4 px-5 py-4 rounded-xl border border-vanguard-border bg-vanguard-surface card-hover group">
				<!-- Status icon -->
				<span class="text-lg flex-shrink-0"
					class:text-cyan-400={obj.status === 'open'}
					class:text-amber-400={obj.status === 'in_progress'}
					class:text-purple-400={obj.status === 'in_review'}
					class:text-emerald-400={obj.status === 'merged'}
					class:text-zinc-500={obj.status === 'closed'}
				>{statusIcon[obj.status] ?? '○'}</span>

				<div class="flex-1 min-w-0">
					<div class="flex items-center gap-2 mb-0.5">
						<h4 class="text-sm font-medium text-vanguard-text group-hover:text-cyan-400 transition-colors truncate">{obj.title}</h4>
						<StatusBadge status={obj.status} />
					</div>
					<div class="flex items-center gap-3 text-xs text-vanguard-text-muted">
						{#if bounty}
							<span>◈ {bounty.title}</span>
						{/if}
						{#if unit}
							<span>⬡ {unit.name}</span>
						{/if}
						<span class="font-mono text-amber-400">{formatVgrd(obj.allocatedVgrd)} VGRD</span>
						<span>{tasks.length} tasks</span>
						<span class="{deadline.overdue ? 'text-red-400' : deadline.urgent ? 'text-amber-400' : ''}">{deadline.text}</span>
					</div>
				</div>

				<!-- Assignee -->
				{#if assignee}
					<div class="flex items-center gap-1.5 flex-shrink-0">
						<SoldierAvatar callsign={assignee.callsign} rank={assignee.rank} isOnline={assignee.isOnline} size="sm" />
						<span class="text-xs text-vanguard-text-muted">{assignee.callsign}</span>
					</div>
				{:else}
					<button class="text-xs text-cyan-400/60 hover:text-cyan-400 border border-dashed border-vanguard-border px-2 py-1 rounded-lg transition-colors flex-shrink-0">
						Checkout
					</button>
				{/if}

				<!-- Progress -->
				<div class="flex-shrink-0 w-20">
					<ProgressBar value={progress} showLabel color={obj.status === 'in_review' ? 'purple' : 'cyan'} />
				</div>
			</a>
		{:else}
			<EmptyState icon="⎇" title="No objectives match filter" />
		{/each}
	</div>
</div>
