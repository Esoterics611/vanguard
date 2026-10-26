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

	let objectiveId = $derived($page.params.id ?? '');
	let objective = $derived(app.getObjective(objectiveId));
	let bounty = $derived(objective ? app.getBounty(objective.bountyId) : null);
	let tasks = $derived(objective ? app.getObjectiveTasks(objectiveId) : []);
	let progress = $derived(objective ? app.getObjectiveProgress(objectiveId) : 0);
	let assignee = $derived(objective?.assigneeId ? app.getSoldier(objective.assigneeId) : null);
	let unit = $derived(objective?.unitId ? app.getUnit(objective.unitId) : null);

	const statusIcon: Record<string, string> = {
		open: '○', in_progress: '◐', in_review: '◑', merged: '●', closed: '✕',
	};

	// Task status pipeline
	const pipeline = ['todo', 'assigned', 'in_progress', 'submitted', 'approved'] as const;
</script>

{#if objective}
	<div class="space-y-6">
		<!-- Header -->
		<div class="rounded-xl border border-vanguard-border bg-vanguard-surface p-6">
			<div class="flex items-center gap-2 mb-3 text-xs text-vanguard-text-muted">
				<a href={resolve('/bounties')} class="hover:text-cyan-400 transition-colors">Bounties</a>
				<span class="text-vanguard-border">/</span>
				{#if bounty}
					<a href={resolve(`/bounties/${bounty.id}`)} class="hover:text-cyan-400 transition-colors">{bounty.title}</a>
					<span class="text-vanguard-border">/</span>
				{/if}
			</div>

			<div class="flex items-start justify-between gap-6">
				<div class="flex-1 min-w-0">
					<div class="flex items-center gap-3 mb-2">
						<span class="text-xl"
							class:text-cyan-400={objective.status === 'open'}
							class:text-amber-400={objective.status === 'in_progress'}
							class:text-purple-400={objective.status === 'in_review'}
							class:text-emerald-400={objective.status === 'merged'}
						>{statusIcon[objective.status] ?? '○'}</span>
						<h1 class="text-xl font-bold text-vanguard-text">{objective.title}</h1>
						<StatusBadge status={objective.status} size="md" />
					</div>
					<p class="text-sm text-vanguard-text-muted leading-relaxed mb-4">{objective.description}</p>

					<div class="flex items-center gap-5">
						{#if assignee}
							<div class="flex items-center gap-2">
								<SoldierAvatar callsign={assignee.callsign} rank={assignee.rank} isOnline={assignee.isOnline} size="sm" />
								<div>
									<span class="text-xs text-vanguard-text">{assignee.callsign}</span>
									<span class="text-[10px] text-vanguard-text-muted block">Assigned</span>
								</div>
							</div>
						{/if}
						{#if unit}
							<div>
								<span class="text-xs text-vanguard-text">⬡ {unit.name}</span>
								<span class="text-[10px] text-vanguard-text-muted block">{unit.type}</span>
							</div>
						{/if}
						<div class="text-center">
							<span class="text-sm font-bold font-mono text-amber-400 block">{formatVgrd(objective.allocatedVgrd)}</span>
							<span class="text-[10px] text-vanguard-text-muted">VGRD</span>
						</div>
						<div>
							<span class="text-xs {formatDeadline(objective.deadline).overdue ? 'text-red-400' : 'text-vanguard-text-muted'}">
								{formatDeadline(objective.deadline).text}
							</span>
						</div>
					</div>
				</div>

				<!-- Progress circle -->
				<div class="flex-shrink-0 w-32 rounded-lg border border-vanguard-border bg-vanguard-surface-2 p-4 text-center">
					<div class="text-3xl font-bold font-mono mb-1"
						class:text-cyan-400={progress < 100}
						class:text-emerald-400={progress === 100}
					>{progress}%</div>
					<span class="text-[10px] text-vanguard-text-muted">{tasks.filter(t => t.status === 'approved').length}/{tasks.length} tasks done</span>
					<div class="mt-2">
						<ProgressBar value={progress} color={objective.status === 'in_review' ? 'purple' : 'cyan'} size="md" />
					</div>
				</div>
			</div>

			<!-- Action buttons -->
			<div class="flex items-center gap-2 mt-4 pt-4 border-t border-vanguard-border">
				{#if objective.status === 'open'}
					<button class="px-4 py-2 rounded-lg bg-cyan-500/10 text-cyan-400 text-sm font-medium border border-cyan-500/20 hover:bg-cyan-500/20 transition-all">
						Checkout Objective
					</button>
				{:else if objective.status === 'in_progress'}
					<button class="px-4 py-2 rounded-lg bg-purple-500/10 text-purple-400 text-sm font-medium border border-purple-500/20 hover:bg-purple-500/20 transition-all">
						Submit for Review
					</button>
					<button class="px-4 py-2 rounded-lg bg-vanguard-surface-2 text-vanguard-text-muted text-sm border border-vanguard-border hover:border-vanguard-border-bright transition-all">
						+ Add Task
					</button>
				{:else if objective.status === 'in_review'}
					<div class="flex items-center gap-2 text-xs text-purple-400">
						<span class="w-2 h-2 rounded-full bg-purple-400 pulse-online"></span>
						Awaiting commander review
					</div>
				{:else if objective.status === 'merged'}
					<div class="flex items-center gap-2 text-xs text-emerald-400">
						<span>✓</span> Merged and rewards distributed
					</div>
				{/if}
			</div>
		</div>

		<!-- Task Pipeline -->
		<div>
			<h3 class="text-sm font-medium text-vanguard-text mb-3">Tasks</h3>
			<div class="space-y-2">
				{#each tasks as task}
					{@const taskAssignee = task.assigneeId ? app.getSoldier(task.assigneeId) : null}
					{@const deadline = formatDeadline(task.deadline)}
					<div class="flex items-center gap-4 px-5 py-4 rounded-xl border border-vanguard-border bg-vanguard-surface card-hover">
						<!-- Priority dot -->
						<div class="w-2 h-2 rounded-full flex-shrink-0 {priorityColor(task.priority)}" style="background: currentColor"></div>

						<!-- Task info -->
						<div class="flex-1 min-w-0">
							<div class="flex items-center gap-2 mb-0.5">
								<span class="text-sm text-vanguard-text">{task.title}</span>
								<StatusBadge status={task.status} />
								<span class="tag {priorityColor(task.priority)} bg-transparent text-[10px]">{task.priority}</span>
							</div>
							<p class="text-xs text-vanguard-text-muted truncate">{task.description}</p>
						</div>

						<!-- Reward -->
						<span class="text-xs font-mono text-amber-400 flex-shrink-0">{formatVgrd(task.rewardVgrd)} VGRD</span>

						<!-- Deadline -->
						<span class="text-xs flex-shrink-0 {deadline.overdue ? 'text-red-400' : deadline.urgent ? 'text-amber-400' : 'text-vanguard-text-muted'}">
							{deadline.text}
						</span>

						<!-- Assignee -->
						{#if taskAssignee}
							<div class="flex items-center gap-1.5 flex-shrink-0">
								<SoldierAvatar callsign={taskAssignee.callsign} rank={taskAssignee.rank} isOnline={taskAssignee.isOnline} size="sm" />
								<span class="text-xs text-vanguard-text-muted">{taskAssignee.callsign}</span>
							</div>
						{:else}
							<button class="text-xs text-cyan-400/60 hover:text-cyan-400 border border-dashed border-vanguard-border px-2 py-1 rounded-lg transition-colors flex-shrink-0">
								Assign
							</button>
						{/if}

						<!-- Actions -->
						{#if task.status === 'assigned' || task.status === 'todo'}
							<button class="text-xs text-cyan-400 hover:text-cyan-300 transition-colors flex-shrink-0">Start</button>
						{:else if task.status === 'in_progress'}
							<button class="text-xs text-purple-400 hover:text-purple-300 transition-colors flex-shrink-0">Submit</button>
						{/if}
					</div>
				{:else}
					<EmptyState icon="▸" title="No tasks yet" description="Break this objective into individual tasks" />
				{/each}
			</div>
		</div>
	</div>
{:else}
	<EmptyState icon="⎇" title="Objective not found" />
{/if}
