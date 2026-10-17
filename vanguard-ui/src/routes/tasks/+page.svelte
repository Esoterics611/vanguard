<script lang="ts">
	import { app } from '$stores/app.svelte';
	import { formatVgrd, formatDeadline, priorityColor } from '$lib/utils/format';
	import StatusBadge from '$components/StatusBadge.svelte';
	import SoldierAvatar from '$components/SoldierAvatar.svelte';
	import EmptyState from '$components/EmptyState.svelte';
	import type { TaskStatus } from '$lib/types';

	let viewMode = $state<'my' | 'all'>('my');
	let filterStatus = $state<TaskStatus | 'all'>('all');

	let displayTasks = $derived(() => {
		let result = viewMode === 'my' ? app.myTasks : app.tasks;
		if (filterStatus !== 'all') result = result.filter(t => t.status === filterStatus);
		return result;
	});

	// Kanban columns for my tasks
	let kanbanColumns = $derived(() => {
		const tasks = app.myTasks;
		return [
			{ key: 'todo', label: 'To Do', icon: '○', color: 'border-zinc-600', tasks: tasks.filter(t => t.status === 'todo' || t.status === 'assigned') },
			{ key: 'in_progress', label: 'In Progress', icon: '◐', color: 'border-amber-500/50', tasks: tasks.filter(t => t.status === 'in_progress') },
			{ key: 'submitted', label: 'Submitted', icon: '◑', color: 'border-purple-500/50', tasks: tasks.filter(t => t.status === 'submitted') },
			{ key: 'done', label: 'Done', icon: '●', color: 'border-emerald-500/50', tasks: tasks.filter(t => t.status === 'approved') },
		];
	});

	let showKanban = $state(true);

	const statusFilters: { label: string; value: TaskStatus | 'all' }[] = [
		{ label: 'All', value: 'all' },
		{ label: 'To Do', value: 'todo' },
		{ label: 'In Progress', value: 'in_progress' },
		{ label: 'Submitted', value: 'submitted' },
		{ label: 'Approved', value: 'approved' },
		{ label: 'Blocked', value: 'blocked' },
	];
</script>

<div class="space-y-5">
	<!-- Header -->
	<div class="flex items-center justify-between">
		<div>
			<h2 class="text-lg font-semibold text-vanguard-text">Tasks</h2>
			<p class="text-xs text-vanguard-text-muted mt-0.5">Individual work items — like commits in your local environment</p>
		</div>
		<div class="flex items-center gap-2">
			<div class="flex rounded-lg border border-vanguard-border bg-vanguard-surface overflow-hidden">
				<button
					onclick={() => viewMode = 'my'}
					class="px-3 py-1.5 text-xs transition-all {viewMode === 'my' ? 'bg-vanguard-surface-3 text-cyan-400 font-medium' : 'text-vanguard-text-muted hover:text-vanguard-text'}"
				>My Tasks</button>
				<button
					onclick={() => viewMode = 'all'}
					class="px-3 py-1.5 text-xs transition-all {viewMode === 'all' ? 'bg-vanguard-surface-3 text-cyan-400 font-medium' : 'text-vanguard-text-muted hover:text-vanguard-text'}"
				>All Tasks</button>
			</div>
			{#if viewMode === 'my'}
				<button
					onclick={() => showKanban = !showKanban}
					class="px-3 py-1.5 text-xs rounded-lg border border-vanguard-border bg-vanguard-surface text-vanguard-text-muted hover:text-vanguard-text transition-all"
				>
					{showKanban ? '☰ List' : '▦ Board'}
				</button>
			{/if}
		</div>
	</div>

	<!-- Kanban Board View (My Tasks) -->
	{#if viewMode === 'my' && showKanban}
		<div class="grid grid-cols-4 gap-4">
			{#each kanbanColumns() as col}
				<div class="rounded-xl border border-vanguard-border bg-vanguard-surface">
					<div class="px-4 py-3 border-b {col.color} border-l-2 flex items-center justify-between">
						<div class="flex items-center gap-2">
							<span class="text-sm">{col.icon}</span>
							<span class="text-xs font-medium text-vanguard-text">{col.label}</span>
						</div>
						<span class="text-xs text-vanguard-text-muted font-mono">{col.tasks.length}</span>
					</div>
					<div class="p-2 space-y-2 min-h-32">
						{#each col.tasks as task}
							{@const bounty = app.getBounty(task.bountyId)}
							{@const deadline = formatDeadline(task.deadline)}
							<div class="rounded-lg border border-vanguard-border bg-vanguard-surface-2 p-3 card-hover cursor-pointer">
								<div class="flex items-start gap-2 mb-2">
									<div class="w-1.5 h-1.5 rounded-full mt-1.5 flex-shrink-0 {priorityColor(task.priority)}" style="background: currentColor"></div>
									<span class="text-xs font-medium text-vanguard-text leading-snug">{task.title}</span>
								</div>
								<div class="flex items-center justify-between">
									<span class="text-[10px] text-vanguard-text-muted truncate max-w-20">{bounty?.title?.split('—')[0]?.trim()}</span>
									<span class="text-[10px] font-mono text-amber-400">{formatVgrd(task.rewardVgrd)}</span>
								</div>
								<div class="flex items-center justify-between mt-1.5">
									<span class="text-[10px] {deadline.overdue ? 'text-red-400' : deadline.urgent ? 'text-amber-400' : 'text-vanguard-text-muted'}">
										{deadline.text}
									</span>
									{#if task.status === 'in_progress'}
										<button class="text-[10px] text-purple-400 hover:text-purple-300">Submit →</button>
									{:else if task.status === 'todo' || task.status === 'assigned'}
										<button class="text-[10px] text-cyan-400 hover:text-cyan-300">Start →</button>
									{/if}
								</div>
							</div>
						{:else}
							<div class="text-center py-6 text-xs text-vanguard-text-muted/50">Empty</div>
						{/each}
					</div>
				</div>
			{/each}
		</div>

	<!-- List View -->
	{:else}
		<!-- Status Filters (list view only) -->
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

		<div class="rounded-xl border border-vanguard-border bg-vanguard-surface divide-y divide-vanguard-border">
			{#each displayTasks() as task}
				{@const bounty = app.getBounty(task.bountyId)}
				{@const objective = app.getObjective(task.objectiveId)}
				{@const assignee = task.assigneeId ? app.getSoldier(task.assigneeId) : null}
				{@const deadline = formatDeadline(task.deadline)}
				<div class="flex items-center gap-4 px-5 py-3.5 card-hover">
					<div class="w-2 h-2 rounded-full flex-shrink-0 {priorityColor(task.priority)}" style="background: currentColor"></div>
					<div class="flex-1 min-w-0">
						<div class="flex items-center gap-2 mb-0.5">
							<span class="text-sm text-vanguard-text">{task.title}</span>
							<StatusBadge status={task.status} />
						</div>
						<div class="text-xs text-vanguard-text-muted">
							{#if bounty}
								<span>◈ {bounty.title}</span>
								<span class="text-vanguard-border mx-1">·</span>
							{/if}
							{#if objective}
								<span>⎇ {objective.title}</span>
							{/if}
						</div>
					</div>
					<span class="text-xs font-mono text-amber-400 flex-shrink-0">{formatVgrd(task.rewardVgrd)}</span>
					<span class="text-xs flex-shrink-0 w-16 text-right {deadline.overdue ? 'text-red-400' : deadline.urgent ? 'text-amber-400' : 'text-vanguard-text-muted'}">
						{deadline.text}
					</span>
					{#if assignee}
						<div class="flex items-center gap-1.5 flex-shrink-0 w-24">
							<SoldierAvatar callsign={assignee.callsign} rank={assignee.rank} isOnline={assignee.isOnline} size="sm" />
							<span class="text-xs text-vanguard-text-muted truncate">{assignee.callsign}</span>
						</div>
					{:else}
						<span class="text-xs text-vanguard-text-muted italic flex-shrink-0 w-24">Unassigned</span>
					{/if}
				</div>
			{:else}
				<EmptyState icon="▸" title="No tasks found" description={viewMode === 'my' ? 'You have no tasks. Browse bounties to find work.' : 'Adjust filters to see tasks.'} />
			{/each}
		</div>
	{/if}
</div>
