<script lang="ts">
	import { resolve } from '$app/paths';
	import { app } from '$stores/app.svelte';
	import { RANK_META } from '$lib/types';
	import { formatVgrd, formatDate, statusColor, statusLabel, priorityColor } from '$lib/utils/format';
	import ProgressBar from '$components/ProgressBar.svelte';
	import StatusBadge from '$components/StatusBadge.svelte';
	import SoldierAvatar from '$components/SoldierAvatar.svelte';

	let user = $derived(app.currentUser);
	let rankMeta = $derived(user ? RANK_META[user.rank] : null);
	let myTasks = $derived(app.myTasks);
	let activeTasks = $derived(myTasks.filter(t => t.status !== 'approved'));
	let recentActivities = $derived(app.activities.slice(0, 6));

	// XP progress to next rank
	let nextRankXp = $derived(() => {
		if (!user) return { current: 0, required: 100, label: '' };
		const ranks = Object.values(RANK_META);
		const currentIdx = ranks.findIndex(r => r.rank === user!.rank);
		const next = ranks[currentIdx + 1];
		if (!next) return { current: user.xp, required: user.xp, label: 'Max Rank' };
		return { current: user.xp, required: next.xpRequired, label: next.rank };
	});

	const activityIcons: Record<string, string> = {
		bounty_created: '◈',
		objective_opened: '⎇',
		objective_merged: '✓',
		task_completed: '●',
		task_submitted: '▸',
		soldier_promoted: '★',
		soldier_enlisted: '⬡',
		reward_distributed: '◆',
	};
</script>

<div class="space-y-6">
	<!-- Welcome + Stats Row -->
	<div class="grid grid-cols-1 lg:grid-cols-4 gap-4">
		<!-- User Welcome Card -->
		<div class="lg:col-span-2 rounded-xl border border-vanguard-border bg-vanguard-surface p-5 glow-cyan">
			{#if user && rankMeta}
				<div class="flex items-start gap-4">
					<div
						class="w-14 h-14 rounded-xl flex items-center justify-center text-lg font-bold"
						style="background: color-mix(in srgb, {rankMeta.color} 15%, var(--color-vanguard-surface-3)); color: {rankMeta.color}"
					>
						{user.rank}
					</div>
					<div class="flex-1 min-w-0">
						<h2 class="text-lg font-semibold text-vanguard-text">{user.callsign}</h2>
						<p class="text-xs text-vanguard-text-muted mt-0.5">
							{rankMeta.label} · {user.specialty} · {formatVgrd(user.vgrdEarned)} VGRD earned
						</p>
						<div class="mt-3">
							<div class="flex items-center justify-between mb-1">
								<span class="text-[10px] text-vanguard-text-muted uppercase tracking-wider">Progress to {nextRankXp().label}</span>
								<span class="text-xs font-mono text-vanguard-text-muted">{user.xp.toLocaleString()} / {nextRankXp().required.toLocaleString()} XP</span>
							</div>
							<ProgressBar value={nextRankXp().current} max={nextRankXp().required} color="gold" size="md" />
						</div>
					</div>
				</div>
			{/if}
		</div>

		<!-- Stat Cards -->
		<div class="rounded-xl border border-vanguard-border bg-vanguard-surface p-5 flex flex-col justify-between">
			<span class="text-[10px] text-vanguard-text-muted uppercase tracking-wider">Active Bounties</span>
			<div class="flex items-end justify-between mt-2">
				<span class="text-3xl font-bold text-cyan-400 font-mono">{app.stats.activeBounties}</span>
				<span class="text-xs text-vanguard-text-muted">{app.bounties.length} total</span>
			</div>
		</div>
		<div class="rounded-xl border border-vanguard-border bg-vanguard-surface p-5 flex flex-col justify-between">
			<span class="text-[10px] text-vanguard-text-muted uppercase tracking-wider">Pending Reviews</span>
			<div class="flex items-end justify-between mt-2">
				<span class="text-3xl font-bold text-purple-400 font-mono">{app.stats.pendingReviews}</span>
				<span class="text-xs text-vanguard-text-muted">{app.stats.openObjectives} open obj.</span>
			</div>
		</div>
	</div>

	<!-- Two Column: My Tasks + Activity Feed -->
	<div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
		<!-- My Active Tasks -->
		<div class="lg:col-span-2 rounded-xl border border-vanguard-border bg-vanguard-surface">
			<div class="flex items-center justify-between px-5 py-3 border-b border-vanguard-border">
				<h3 class="text-sm font-medium text-vanguard-text">My Active Tasks</h3>
				<a href={resolve('/tasks')} class="text-xs text-cyan-400 hover:text-cyan-300 transition-colors">View all →</a>
			</div>
			<div class="divide-y divide-vanguard-border">
				{#each activeTasks as task}
					{@const bounty = app.getBounty(task.bountyId)}
					<a href={resolve(`/bounties/${task.bountyId}`) + `?task=${task.id}`} class="flex items-center gap-4 px-5 py-3.5 card-hover group">
						<div class="flex-shrink-0">
							<div class="w-2 h-2 rounded-full {priorityColor(task.priority)}"
								 style="background: currentColor"></div>
						</div>
						<div class="flex-1 min-w-0">
							<div class="flex items-center gap-2">
								<span class="text-sm text-vanguard-text group-hover:text-cyan-400 transition-colors truncate">{task.title}</span>
								<StatusBadge status={task.status} />
							</div>
							<p class="text-xs text-vanguard-text-muted mt-0.5 truncate">
								{bounty?.title ?? 'Unknown bounty'} · {formatVgrd(task.rewardVgrd)} VGRD
							</p>
						</div>
					</a>
				{:else}
					<div class="px-5 py-8 text-center text-xs text-vanguard-text-muted">
						No active tasks. Browse bounties to find work.
					</div>
				{/each}
			</div>
		</div>

		<!-- Activity Feed -->
		<div class="rounded-xl border border-vanguard-border bg-vanguard-surface">
			<div class="px-5 py-3 border-b border-vanguard-border">
				<h3 class="text-sm font-medium text-vanguard-text">Activity</h3>
			</div>
			<div class="divide-y divide-vanguard-border">
				{#each recentActivities as activity}
					<div class="px-5 py-3 flex gap-3">
						<span class="text-sm text-vanguard-text-muted mt-0.5 flex-shrink-0">
							{activityIcons[activity.type] ?? '·'}
						</span>
						<div class="min-w-0">
							<p class="text-xs text-vanguard-text">
								<span class="font-medium text-cyan-400">{activity.actorCallsign}</span>
								{' '}{activity.description}{' '}
								<span class="font-medium">{activity.targetTitle}</span>
							</p>
							<span class="text-[10px] text-vanguard-text-muted">{formatDate(activity.timestamp)}</span>
						</div>
					</div>
				{/each}
			</div>
		</div>
	</div>

	<!-- Bounty Overview Row -->
	<div class="rounded-xl border border-vanguard-border bg-vanguard-surface">
		<div class="flex items-center justify-between px-5 py-3 border-b border-vanguard-border">
			<h3 class="text-sm font-medium text-vanguard-text">Active Bounties</h3>
			<a href={resolve('/bounties')} class="text-xs text-cyan-400 hover:text-cyan-300 transition-colors">View all →</a>
		</div>
		<div class="divide-y divide-vanguard-border">
			{#each app.bounties.filter(b => b.status !== 'cancelled') as bounty}
				{@const objectives = app.getBountyObjectives(bounty.id)}
				{@const progress = app.getBountyProgress(bounty.id)}
				{@const creator = app.getSoldier(bounty.creatorId)}
				<a href={resolve(`/bounties/${bounty.id}`)} class="block px-5 py-4 card-hover group">
					<div class="flex items-start justify-between gap-4">
						<div class="flex-1 min-w-0">
							<div class="flex items-center gap-2 mb-1">
								<span class="text-sm font-medium text-vanguard-text group-hover:text-cyan-400 transition-colors truncate">
									{bounty.title}
								</span>
								<StatusBadge status={bounty.status} />
							</div>
							<p class="text-xs text-vanguard-text-muted truncate">{bounty.description}</p>
							<div class="flex items-center gap-4 mt-2">
								<span class="text-xs text-vanguard-text-muted">
									{objectives.length} objectives
								</span>
								<span class="text-xs text-vanguard-text-muted">
									{formatVgrd(bounty.totalAmount)} VGRD
								</span>
								{#if creator}
									<span class="text-xs text-vanguard-text-muted">
										by {creator.callsign}
									</span>
								{/if}
								<div class="flex gap-1">
									{#each bounty.skillTags.slice(0, 3) as tag}
										<span class="tag bg-vanguard-surface-3 text-vanguard-text-muted">{tag}</span>
									{/each}
								</div>
							</div>
						</div>
						<div class="flex-shrink-0 w-24">
							<ProgressBar value={progress} showLabel color="cyan" />
						</div>
					</div>
				</a>
			{/each}
		</div>
	</div>

	<!-- Online Team Members -->
	<div class="rounded-xl border border-vanguard-border bg-vanguard-surface">
		<div class="flex items-center justify-between px-5 py-3 border-b border-vanguard-border">
			<h3 class="text-sm font-medium text-vanguard-text">Team Online</h3>
			<a href={resolve('/team')} class="text-xs text-cyan-400 hover:text-cyan-300 transition-colors">View all →</a>
		</div>
		<div class="px-5 py-4 flex flex-wrap gap-3">
			{#each app.soldiers.filter(s => s.isOnline) as soldier}
				{@const meta = RANK_META[soldier.rank]}
				<a href={resolve(`/team/${soldier.id}`)} class="flex items-center gap-2 px-3 py-2 rounded-lg bg-vanguard-surface-2 border border-vanguard-border hover:border-vanguard-border-bright transition-all group">
					<SoldierAvatar callsign={soldier.callsign} rank={soldier.rank} isOnline={true} size="sm" />
					<div>
						<span class="text-xs font-medium text-vanguard-text group-hover:text-cyan-400 transition-colors">{soldier.callsign}</span>
						<span class="text-[10px] text-vanguard-text-muted block">{soldier.specialty}</span>
					</div>
				</a>
			{/each}
		</div>
	</div>
</div>
