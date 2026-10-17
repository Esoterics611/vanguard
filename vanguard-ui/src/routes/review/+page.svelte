<script lang="ts">
	import { app } from '$stores/app.svelte';
	import { formatVgrd, formatDate, formatDeadline, priorityColor } from '$lib/utils/format';
	import StatusBadge from '$components/StatusBadge.svelte';
	import ProgressBar from '$components/ProgressBar.svelte';
	import SoldierAvatar from '$components/SoldierAvatar.svelte';
	import EmptyState from '$components/EmptyState.svelte';

	// Objectives pending review
	let pendingReview = $derived(app.objectives.filter(o => o.status === 'in_review'));

	// Submitted tasks (across all objectives)
	let submittedTasks = $derived(app.tasks.filter(t => t.status === 'submitted'));

	// Tab
	let activeTab = $state<'objectives' | 'tasks'>('objectives');

	// Expanded objective ID for inline review
	let expandedId = $state<string | null>(null);
</script>

<div class="space-y-5">
	<div class="flex items-center justify-between">
		<div>
			<h2 class="text-lg font-semibold text-vanguard-text">Commander Review</h2>
			<p class="text-xs text-vanguard-text-muted mt-0.5">Accept or reject submitted work — merge completed objectives</p>
		</div>
		<div class="flex items-center gap-4">
			<div class="flex items-center gap-2 px-3 py-1.5 rounded-lg border border-purple-500/20 bg-purple-500/5">
				<span class="w-2 h-2 rounded-full bg-purple-400 pulse-online"></span>
				<span class="text-xs text-purple-400 font-medium">{pendingReview.length} objectives pending</span>
			</div>
			<div class="flex items-center gap-2 px-3 py-1.5 rounded-lg border border-amber-500/20 bg-amber-500/5">
				<span class="text-xs text-amber-400 font-medium">{submittedTasks.length} tasks submitted</span>
			</div>
		</div>
	</div>

	<!-- Tabs -->
	<div class="flex items-center gap-1 border-b border-vanguard-border">
		<button
			onclick={() => activeTab = 'objectives'}
			class="px-4 py-2.5 text-sm transition-all border-b-2 -mb-px
				{activeTab === 'objectives'
					? 'text-purple-400 border-purple-400 font-medium'
					: 'text-vanguard-text-muted border-transparent hover:text-vanguard-text'}"
		>
			Objectives to Merge <span class="text-xs ml-1 text-vanguard-text-muted">{pendingReview.length}</span>
		</button>
		<button
			onclick={() => activeTab = 'tasks'}
			class="px-4 py-2.5 text-sm transition-all border-b-2 -mb-px
				{activeTab === 'tasks'
					? 'text-amber-400 border-amber-400 font-medium'
					: 'text-vanguard-text-muted border-transparent hover:text-vanguard-text'}"
		>
			Task Submissions <span class="text-xs ml-1 text-vanguard-text-muted">{submittedTasks.length}</span>
		</button>
	</div>

	<!-- Objectives Review -->
	{#if activeTab === 'objectives'}
		<div class="space-y-3">
			{#each pendingReview as obj}
				{@const bounty = app.getBounty(obj.bountyId)}
				{@const tasks = app.getObjectiveTasks(obj.id)}
				{@const assignee = obj.assigneeId ? app.getSoldier(obj.assigneeId) : null}
				{@const unit = obj.unitId ? app.getUnit(obj.unitId) : null}
				{@const progress = app.getObjectiveProgress(obj.id)}
				{@const isExpanded = expandedId === obj.id}

				<div class="rounded-xl border border-purple-500/20 bg-vanguard-surface overflow-hidden">
					<!-- Objective Header -->
					<button
						onclick={() => expandedId = isExpanded ? null : obj.id}
						class="w-full text-left p-5 flex items-center gap-4 card-hover"
					>
						<span class="text-lg text-purple-400 flex-shrink-0">◑</span>
						<div class="flex-1 min-w-0">
							<div class="flex items-center gap-2 mb-1">
								<h4 class="text-sm font-medium text-vanguard-text">{obj.title}</h4>
								<StatusBadge status={obj.status} />
							</div>
							<div class="flex items-center gap-3 text-xs text-vanguard-text-muted">
								{#if bounty}
									<span>◈ {bounty.title}</span>
								{/if}
								{#if assignee}
									<span>by {assignee.callsign}</span>
								{/if}
								{#if unit}
									<span>⬡ {unit.name}</span>
								{/if}
								<span class="font-mono text-amber-400">{formatVgrd(obj.allocatedVgrd)} VGRD</span>
							</div>
						</div>
						<div class="flex-shrink-0 w-20">
							<ProgressBar value={progress} showLabel color="purple" />
						</div>
						<span class="text-vanguard-text-muted text-xs flex-shrink-0">{isExpanded ? '▾' : '▸'}</span>
					</button>

					<!-- Expanded: Task Details + Review Actions -->
					{#if isExpanded}
						<div class="border-t border-vanguard-border">
							<!-- Task List -->
							<div class="divide-y divide-vanguard-border">
								{#each tasks as task}
									{@const taskAssignee = task.assigneeId ? app.getSoldier(task.assigneeId) : null}
									<div class="flex items-center gap-4 px-5 py-3 bg-vanguard-surface-2">
										<div class="w-2 h-2 rounded-full flex-shrink-0 {priorityColor(task.priority)}" style="background: currentColor"></div>
										<div class="flex-1 min-w-0">
											<div class="flex items-center gap-2">
												<span class="text-sm text-vanguard-text">{task.title}</span>
												<StatusBadge status={task.status} />
											</div>
										</div>
										{#if taskAssignee}
											<div class="flex items-center gap-1.5 flex-shrink-0">
												<SoldierAvatar callsign={taskAssignee.callsign} rank={taskAssignee.rank} isOnline={taskAssignee.isOnline} size="sm" />
												<span class="text-xs text-vanguard-text-muted">{taskAssignee.callsign}</span>
											</div>
										{/if}
										<span class="text-xs font-mono text-amber-400 flex-shrink-0">{formatVgrd(task.rewardVgrd)}</span>
										{#if task.submissionHash}
											<span class="text-[10px] font-mono text-cyan-400 flex-shrink-0" title={task.submissionHash}>
												{task.submissionHash.slice(0, 8)}...
											</span>
										{/if}
									</div>
								{/each}
							</div>

							<!-- Review Actions -->
							<div class="p-5 bg-vanguard-surface-2 border-t border-vanguard-border">
								<div class="flex items-center gap-3">
									<textarea
										placeholder="Review comment (optional)..."
										class="flex-1 px-3 py-2 rounded-lg border border-vanguard-border bg-vanguard-surface text-sm text-vanguard-text placeholder:text-vanguard-text-muted focus:outline-none focus:border-purple-500/50 resize-none h-10"
									></textarea>
									<button class="px-5 py-2 rounded-lg bg-emerald-500/10 text-emerald-400 text-sm font-medium border border-emerald-500/20 hover:bg-emerald-500/20 transition-all flex items-center gap-1.5">
										<span>✓</span> Merge
									</button>
									<button class="px-5 py-2 rounded-lg bg-red-500/10 text-red-400 text-sm font-medium border border-red-500/20 hover:bg-red-500/20 transition-all flex items-center gap-1.5">
										<span>✕</span> Request Changes
									</button>
								</div>
								<p class="text-[10px] text-vanguard-text-muted mt-2">
									Merging will approve all tasks and distribute {formatVgrd(obj.allocatedVgrd)} VGRD to contributors
								</p>
							</div>
						</div>
					{/if}
				</div>
			{:else}
				<EmptyState icon="✓" title="No objectives pending review" description="All clear — submitted objectives will appear here" />
			{/each}
		</div>

	<!-- Task Submissions -->
	{:else}
		<div class="rounded-xl border border-vanguard-border bg-vanguard-surface divide-y divide-vanguard-border">
			{#each submittedTasks as task}
				{@const assignee = task.assigneeId ? app.getSoldier(task.assigneeId) : null}
				{@const objective = app.getObjective(task.objectiveId)}
				{@const bounty = app.getBounty(task.bountyId)}
				<div class="p-5">
					<div class="flex items-start gap-4">
						{#if assignee}
							<SoldierAvatar callsign={assignee.callsign} rank={assignee.rank} isOnline={assignee.isOnline} size="md" />
						{/if}
						<div class="flex-1 min-w-0">
							<div class="flex items-center gap-2 mb-1">
								<span class="text-sm font-medium text-vanguard-text">{task.title}</span>
								<StatusBadge status={task.status} />
								<span class="tag {priorityColor(task.priority)} bg-transparent text-[10px]">{task.priority}</span>
							</div>
							<p class="text-xs text-vanguard-text-muted mb-2">{task.description}</p>
							<div class="flex items-center gap-3 text-xs text-vanguard-text-muted mb-3">
								{#if bounty}
									<span>◈ {bounty.title}</span>
								{/if}
								{#if objective}
									<span>⎇ {objective.title}</span>
								{/if}
								{#if assignee}
									<span>by {assignee.callsign}</span>
								{/if}
								<span class="font-mono text-amber-400">{formatVgrd(task.rewardVgrd)} VGRD</span>
							</div>

							<!-- Submission proof -->
							{#if task.submissionHash}
								<div class="flex items-center gap-2 px-3 py-2 rounded-lg bg-vanguard-surface-2 border border-vanguard-border mb-3 w-fit">
									<span class="text-xs text-vanguard-text-muted">Submission:</span>
									<span class="text-xs font-mono text-cyan-400">{task.submissionHash}</span>
								</div>
							{/if}

							<!-- Actions -->
							<div class="flex items-center gap-2">
								<button class="px-4 py-1.5 rounded-lg bg-emerald-500/10 text-emerald-400 text-xs font-medium border border-emerald-500/20 hover:bg-emerald-500/20 transition-all">
									✓ Approve
								</button>
								<button class="px-4 py-1.5 rounded-lg bg-red-500/10 text-red-400 text-xs font-medium border border-red-500/20 hover:bg-red-500/20 transition-all">
									✕ Reject
								</button>
								<span class="text-[10px] text-vanguard-text-muted">Submitted {formatDate(task.updatedAt)}</span>
							</div>
						</div>
					</div>
				</div>
			{:else}
				<EmptyState icon="▸" title="No submitted tasks" description="Tasks awaiting review will appear here" />
			{/each}
		</div>
	{/if}
</div>
