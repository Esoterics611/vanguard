<script lang="ts">
	import { resolve } from '$app/paths';
	import { page } from '$app/stores';
	import { app } from '$stores/app.svelte';
	import { formatVgrd, formatDate, formatDeadline, priorityColor } from '$lib/utils/format';
	import StatusBadge from '$components/StatusBadge.svelte';
	import ProgressBar from '$components/ProgressBar.svelte';
	import SoldierAvatar from '$components/SoldierAvatar.svelte';
	import RankBadge from '$components/RankBadge.svelte';
	import EmptyState from '$components/EmptyState.svelte';

	let bountyId = $derived($page.params.id ?? '');
	let bounty = $derived(app.getBounty(bountyId));
	let objectives = $derived(app.getBountyObjectives(bountyId));
	let creator = $derived(bounty ? app.getSoldier(bounty.creatorId) : null);
	let progress = $derived(bounty ? app.getBountyProgress(bountyId) : 0);

	// All tasks across all objectives in this bounty
	let allTasks = $derived(
		objectives.flatMap(o => app.getObjectiveTasks(o.id))
	);
	let taskStats = $derived({
		total: allTasks.length,
		completed: allTasks.filter(t => t.status === 'approved').length,
		inProgress: allTasks.filter(t => t.status === 'in_progress').length,
		submitted: allTasks.filter(t => t.status === 'submitted').length,
	});

	// Tab state
	let activeTab = $state<'objectives' | 'tasks' | 'contributors'>('objectives');

	// Contributors: unique soldiers working on this bounty
	let contributors = $derived(() => {
		const ids = new Set<string>();
		allTasks.forEach(t => { if (t.assigneeId) ids.add(t.assigneeId); });
		objectives.forEach(o => { if (o.assigneeId) ids.add(o.assigneeId); });
		if (bounty) ids.add(bounty.creatorId);
		return [...ids].map(id => app.getSoldier(id)).filter(Boolean);
	});
</script>

{#if bounty}
	<div class="space-y-6">
		<!-- Bounty Header -->
		<div class="rounded-xl border border-vanguard-border bg-vanguard-surface p-6">
			<div class="flex items-start justify-between gap-6">
				<div class="flex-1 min-w-0">
					<div class="flex items-center gap-2 mb-2">
						<a href={resolve('/bounties')} class="text-xs text-vanguard-text-muted hover:text-cyan-400 transition-colors">← Bounties</a>
						<span class="text-vanguard-border">/</span>
					</div>
					<div class="flex items-center gap-3 mb-2">
						<span class="text-cyan-500 text-lg">◈</span>
						<h1 class="text-xl font-bold text-vanguard-text">{bounty.title}</h1>
						<StatusBadge status={bounty.status} size="md" />
					</div>
					<p class="text-sm text-vanguard-text-muted leading-relaxed mb-4">{bounty.description}</p>
					<div class="flex items-center gap-5 flex-wrap">
						{#if creator}
							<div class="flex items-center gap-2">
								<SoldierAvatar callsign={creator.callsign} rank={creator.rank} isOnline={creator.isOnline} size="sm" />
								<div>
									<span class="text-xs text-vanguard-text">{creator.callsign}</span>
									<span class="text-[10px] text-vanguard-text-muted block">Commander</span>
								</div>
							</div>
						{/if}
						<div class="text-center">
							<span class="text-sm font-bold text-amber-400 font-mono block">{formatVgrd(bounty.totalAmount)}</span>
							<span class="text-[10px] text-vanguard-text-muted">VGRD Total</span>
						</div>
						<div class="text-center">
							<span class="text-sm font-bold text-vanguard-text font-mono block">{objectives.length}</span>
							<span class="text-[10px] text-vanguard-text-muted">Objectives</span>
						</div>
						<div class="text-center">
							<span class="text-sm font-bold text-vanguard-text font-mono block">{taskStats.total}</span>
							<span class="text-[10px] text-vanguard-text-muted">Tasks</span>
						</div>
						<div>
							<span class="text-xs {formatDeadline(bounty.deadline).overdue ? 'text-red-400' : 'text-vanguard-text-muted'}">
								Deadline: {formatDeadline(bounty.deadline).text}
							</span>
						</div>
					</div>
					<!-- Skill Tags -->
					<div class="flex gap-1.5 mt-3">
						{#each bounty.skillTags as tag}
							<span class="tag bg-cyan-500/10 text-cyan-400">{tag}</span>
						{/each}
					</div>
				</div>

				<!-- Progress Card -->
				<div class="flex-shrink-0 w-48 rounded-lg border border-vanguard-border bg-vanguard-surface-2 p-4 text-center">
					<div class="text-3xl font-bold text-cyan-400 font-mono mb-1">{progress}%</div>
					<span class="text-[10px] text-vanguard-text-muted uppercase tracking-wider">Complete</span>
					<div class="mt-3 space-y-1.5">
						<div class="flex justify-between text-xs">
							<span class="text-emerald-400">● Approved</span>
							<span class="font-mono text-vanguard-text">{taskStats.completed}</span>
						</div>
						<div class="flex justify-between text-xs">
							<span class="text-purple-400">● Submitted</span>
							<span class="font-mono text-vanguard-text">{taskStats.submitted}</span>
						</div>
						<div class="flex justify-between text-xs">
							<span class="text-amber-400">● In Progress</span>
							<span class="font-mono text-vanguard-text">{taskStats.inProgress}</span>
						</div>
					</div>
				</div>
			</div>
		</div>

		<!-- Tabs -->
		<div class="flex items-center gap-1 border-b border-vanguard-border">
			{#each [
				{ key: 'objectives' as const, label: 'Objectives', count: objectives.length },
				{ key: 'tasks' as const, label: 'All Tasks', count: allTasks.length },
				{ key: 'contributors' as const, label: 'Contributors', count: contributors().length },
			] as tab}
				<button
					onclick={() => activeTab = tab.key}
					class="px-4 py-2.5 text-sm transition-all border-b-2 -mb-px
						{activeTab === tab.key
							? 'text-cyan-400 border-cyan-400 font-medium'
							: 'text-vanguard-text-muted border-transparent hover:text-vanguard-text'}"
				>
					{tab.label} <span class="text-xs text-vanguard-text-muted ml-1">{tab.count}</span>
				</button>
			{/each}
		</div>

		<!-- Tab Content: Objectives (like PRs) -->
		{#if activeTab === 'objectives'}
			<div class="space-y-3">
				{#each objectives as obj}
					{@const objTasks = app.getObjectiveTasks(obj.id)}
					{@const objProgress = app.getObjectiveProgress(obj.id)}
					{@const assignee = obj.assigneeId ? app.getSoldier(obj.assigneeId) : null}
					{@const unit = obj.unitId ? app.getUnit(obj.unitId) : null}
					<a href={resolve(`/objectives/${obj.id}`)} class="block rounded-xl border border-vanguard-border bg-vanguard-surface card-hover group">
						<div class="p-5">
							<div class="flex items-start justify-between gap-4">
								<div class="flex-1 min-w-0">
									<div class="flex items-center gap-2 mb-1">
										<span class="text-sm"
											class:text-cyan-400={obj.status === 'open'}
											class:text-amber-400={obj.status === 'in_progress'}
											class:text-purple-400={obj.status === 'in_review'}
											class:text-emerald-400={obj.status === 'merged'}
										>⎇</span>
										<h4 class="text-sm font-medium text-vanguard-text group-hover:text-cyan-400 transition-colors truncate">
											{obj.title}
										</h4>
										<StatusBadge status={obj.status} />
									</div>
									<p class="text-xs text-vanguard-text-muted leading-relaxed mb-2">{obj.description}</p>
									<div class="flex items-center gap-4">
										{#if assignee}
											<div class="flex items-center gap-1.5">
												<SoldierAvatar callsign={assignee.callsign} rank={assignee.rank} isOnline={assignee.isOnline} size="sm" />
												<span class="text-xs text-vanguard-text-muted">{assignee.callsign}</span>
											</div>
										{:else}
											<span class="text-xs text-vanguard-text-muted italic">Unassigned</span>
										{/if}
										{#if unit}
											<span class="text-xs text-vanguard-text-muted">⬡ {unit.name}</span>
										{/if}
										<span class="text-xs font-mono text-amber-400">{formatVgrd(obj.allocatedVgrd)} VGRD</span>
										<span class="text-xs text-vanguard-text-muted">{objTasks.length} tasks</span>
									</div>
								</div>
								<div class="flex-shrink-0 w-24">
									<ProgressBar value={objProgress} showLabel color={obj.status === 'in_review' ? 'purple' : 'cyan'} />
								</div>
							</div>
						</div>

						<!-- Task pills -->
						{#if objTasks.length > 0}
							<div class="border-t border-vanguard-border px-5 py-2.5 flex items-center gap-2 flex-wrap">
								{#each objTasks as task}
									<div class="flex items-center gap-1.5 px-2 py-1 rounded-md bg-vanguard-surface-2 border border-vanguard-border">
										<div class="w-1.5 h-1.5 rounded-full {priorityColor(task.priority)}" style="background: currentColor"></div>
										<span class="text-[11px] text-vanguard-text-muted truncate max-w-28">{task.title}</span>
										<StatusBadge status={task.status} />
									</div>
								{/each}
							</div>
						{/if}
					</a>
				{:else}
					<EmptyState icon="⎇" title="No objectives yet" description="Add objectives to break this bounty into workstreams" />
				{/each}
			</div>

		<!-- Tab Content: All Tasks -->
		{:else if activeTab === 'tasks'}
			<div class="rounded-xl border border-vanguard-border bg-vanguard-surface divide-y divide-vanguard-border">
				{#each allTasks as task}
					{@const assignee = task.assigneeId ? app.getSoldier(task.assigneeId) : null}
					{@const objective = app.getObjective(task.objectiveId)}
					<div class="flex items-center gap-4 px-5 py-3.5 card-hover">
						<div class="w-2 h-2 rounded-full {priorityColor(task.priority)}" style="background: currentColor"></div>
						<div class="flex-1 min-w-0">
							<div class="flex items-center gap-2">
								<span class="text-sm text-vanguard-text truncate">{task.title}</span>
								<StatusBadge status={task.status} />
							</div>
							<p class="text-xs text-vanguard-text-muted mt-0.5">
								{objective?.title ?? 'Unknown'} · {formatVgrd(task.rewardVgrd)} VGRD
							</p>
						</div>
						{#if assignee}
							<div class="flex items-center gap-1.5 flex-shrink-0">
								<SoldierAvatar callsign={assignee.callsign} rank={assignee.rank} isOnline={assignee.isOnline} size="sm" />
								<span class="text-xs text-vanguard-text-muted">{assignee.callsign}</span>
							</div>
						{:else}
							<span class="text-xs text-vanguard-text-muted italic flex-shrink-0">Unassigned</span>
						{/if}
					</div>
				{:else}
					<EmptyState icon="▸" title="No tasks" description="Tasks will appear when objectives are broken down" />
				{/each}
			</div>

		<!-- Tab Content: Contributors -->
		{:else if activeTab === 'contributors'}
			<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
				{#each contributors() as soldier}
					{#if soldier}
						{@const tasks = app.getSoldierTasks(soldier.id).filter(t => t.bountyId === bountyId)}
						<a href={resolve(`/team/${soldier.id}`)} class="rounded-xl border border-vanguard-border bg-vanguard-surface p-4 card-hover group">
							<div class="flex items-center gap-3 mb-3">
								<SoldierAvatar callsign={soldier.callsign} rank={soldier.rank} isOnline={soldier.isOnline} size="md" />
								<div>
									<span class="text-sm font-medium text-vanguard-text group-hover:text-cyan-400 transition-colors">{soldier.callsign}</span>
									<div class="flex items-center gap-1.5">
										<RankBadge rank={soldier.rank} size="sm" />
										<span class="text-xs text-vanguard-text-muted">{soldier.specialty}</span>
									</div>
								</div>
							</div>
							<div class="flex items-center gap-3 text-xs text-vanguard-text-muted">
								<span>{tasks.length} tasks</span>
								<span>{tasks.filter(t => t.status === 'approved').length} completed</span>
							</div>
						</a>
					{/if}
				{/each}
			</div>
		{/if}
	</div>
{:else}
	<EmptyState icon="◈" title="Bounty not found" description="This bounty may have been removed" />
{/if}
