<script lang="ts">
	import { page } from '$app/stores';
	import { app } from '$stores/app.svelte';
	import { RANK_META, RANKS } from '$lib/types';
	import { formatVgrd, formatDate, priorityColor } from '$lib/utils/format';
	import SoldierAvatar from '$components/SoldierAvatar.svelte';
	import RankBadge from '$components/RankBadge.svelte';
	import StatusBadge from '$components/StatusBadge.svelte';
	import ProgressBar from '$components/ProgressBar.svelte';
	import EmptyState from '$components/EmptyState.svelte';

	let soldierId = $derived($page.params.id);
	let soldier = $derived(app.getSoldier(soldierId));
	let rankMeta = $derived(soldier ? RANK_META[soldier.rank] : null);
	let tasks = $derived(app.getSoldierTasks(soldierId));
	let unit = $derived(soldier?.squadId ? app.getUnit(soldier.squadId) : null);

	// XP to next rank
	let nextRank = $derived(() => {
		if (!soldier) return null;
		const idx = RANKS.indexOf(soldier.rank);
		if (idx >= RANKS.length - 1) return null;
		const next = RANKS[idx + 1];
		return RANK_META[next];
	});

	// Task stats
	let taskStats = $derived({
		total: tasks.length,
		approved: tasks.filter(t => t.status === 'approved').length,
		inProgress: tasks.filter(t => t.status === 'in_progress').length,
		submitted: tasks.filter(t => t.status === 'submitted').length,
	});

	// Bounties this soldier contributes to
	let contributingBounties = $derived(() => {
		const bountyIds = [...new Set(tasks.map(t => t.bountyId))];
		return bountyIds.map(id => app.getBounty(id)).filter(Boolean);
	});
</script>

{#if soldier && rankMeta}
	<div class="space-y-6">
		<!-- Profile Header -->
		<div class="rounded-xl border border-vanguard-border bg-vanguard-surface p-6"
			 style="border-color: color-mix(in srgb, {rankMeta.color} 30%, var(--color-vanguard-border))">
			<div class="flex items-center gap-2 mb-4 text-xs text-vanguard-text-muted">
				<a href="/team" class="hover:text-cyan-400 transition-colors">← Team</a>
			</div>
			<div class="flex items-start gap-6">
				<SoldierAvatar callsign={soldier.callsign} rank={soldier.rank} isOnline={soldier.isOnline} size="lg" />
				<div class="flex-1">
					<div class="flex items-center gap-3 mb-1">
						<h1 class="text-xl font-bold text-vanguard-text">{soldier.callsign}</h1>
						{#if soldier.isOnline}
							<span class="flex items-center gap-1 text-xs text-emerald-400">
								<span class="w-1.5 h-1.5 rounded-full bg-emerald-400 pulse-online"></span> Online
							</span>
						{/if}
					</div>
					<div class="flex items-center gap-3 mb-3">
						<RankBadge rank={soldier.rank} showLabel size="md" />
						<span class="text-sm text-vanguard-text-muted">· {soldier.specialty}</span>
					</div>
					<div class="flex items-center gap-2 text-xs text-vanguard-text-muted">
						<span>Wallet: {soldier.walletAddress}</span>
						<span>· Enlisted {formatDate(soldier.enlistedAt)}</span>
					</div>

					<!-- XP Progress -->
					{#if nextRank()}
						<div class="mt-4 max-w-sm">
							<div class="flex items-center justify-between mb-1">
								<span class="text-[10px] text-vanguard-text-muted uppercase tracking-wider">Progress to {nextRank()!.rank}</span>
								<span class="text-xs font-mono text-vanguard-text-muted">{soldier.xp.toLocaleString()} / {nextRank()!.xpRequired.toLocaleString()} XP</span>
							</div>
							<ProgressBar value={soldier.xp} max={nextRank()!.xpRequired} color="gold" size="md" />
						</div>
					{:else}
						<div class="mt-4 text-xs text-yellow-400">★ Maximum rank achieved</div>
					{/if}
				</div>

				<!-- Stats Card -->
				<div class="flex-shrink-0 rounded-lg border border-vanguard-border bg-vanguard-surface-2 p-4 grid grid-cols-2 gap-4 min-w-48">
					<div class="text-center">
						<span class="text-lg font-bold text-vanguard-text font-mono block">{soldier.tasksCompleted}</span>
						<span class="text-[10px] text-vanguard-text-muted">Tasks Done</span>
					</div>
					<div class="text-center">
						<span class="text-lg font-bold text-amber-400 font-mono block">{formatVgrd(soldier.vgrdEarned)}</span>
						<span class="text-[10px] text-vanguard-text-muted">VGRD Earned</span>
					</div>
					<div class="text-center">
						<span class="text-lg font-bold text-cyan-400 font-mono block">{soldier.votingPower}</span>
						<span class="text-[10px] text-vanguard-text-muted">Voting Power</span>
					</div>
					<div class="text-center">
						<span class="text-lg font-bold text-vanguard-text font-mono block">{rankMeta.multiplier}x</span>
						<span class="text-[10px] text-vanguard-text-muted">Multiplier</span>
					</div>
				</div>
			</div>
		</div>

		<!-- Two Column: Tasks + Bounties -->
		<div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
			<!-- Tasks -->
			<div class="lg:col-span-2 rounded-xl border border-vanguard-border bg-vanguard-surface">
				<div class="px-5 py-3 border-b border-vanguard-border flex items-center justify-between">
					<h3 class="text-sm font-medium text-vanguard-text">Assigned Tasks</h3>
					<div class="flex items-center gap-3 text-xs text-vanguard-text-muted">
						<span class="text-emerald-400">● {taskStats.approved} done</span>
						<span class="text-amber-400">● {taskStats.inProgress} active</span>
						<span class="text-purple-400">● {taskStats.submitted} submitted</span>
					</div>
				</div>
				<div class="divide-y divide-vanguard-border">
					{#each tasks as task}
						{@const objective = app.getObjective(task.objectiveId)}
						<div class="flex items-center gap-4 px-5 py-3 card-hover">
							<div class="w-2 h-2 rounded-full flex-shrink-0 {priorityColor(task.priority)}" style="background: currentColor"></div>
							<div class="flex-1 min-w-0">
								<div class="flex items-center gap-2">
									<span class="text-sm text-vanguard-text truncate">{task.title}</span>
									<StatusBadge status={task.status} />
								</div>
								<span class="text-xs text-vanguard-text-muted">{objective?.title}</span>
							</div>
							<span class="text-xs font-mono text-amber-400">{formatVgrd(task.rewardVgrd)}</span>
						</div>
					{:else}
						<div class="px-5 py-8 text-center text-xs text-vanguard-text-muted">No assigned tasks</div>
					{/each}
				</div>
			</div>

			<!-- Contributing Bounties -->
			<div class="rounded-xl border border-vanguard-border bg-vanguard-surface">
				<div class="px-5 py-3 border-b border-vanguard-border">
					<h3 class="text-sm font-medium text-vanguard-text">Contributing To</h3>
				</div>
				<div class="divide-y divide-vanguard-border">
					{#each contributingBounties() as bounty}
						{#if bounty}
							{@const bountyTasks = tasks.filter(t => t.bountyId === bounty.id)}
							<a href="/bounties/{bounty.id}" class="block px-5 py-3 card-hover group">
								<div class="flex items-center gap-2 mb-1">
									<span class="text-xs text-cyan-500">◈</span>
									<span class="text-sm text-vanguard-text group-hover:text-cyan-400 transition-colors truncate">{bounty.title}</span>
								</div>
								<div class="flex items-center gap-2 text-xs text-vanguard-text-muted">
									<span>{bountyTasks.length} tasks</span>
									<span>·</span>
									<span>{bountyTasks.filter(t => t.status === 'approved').length} completed</span>
								</div>
							</a>
						{/if}
					{:else}
						<div class="px-5 py-8 text-center text-xs text-vanguard-text-muted">Not contributing to any bounties</div>
					{/each}
				</div>
			</div>
		</div>
	</div>
{:else}
	<EmptyState icon="⬡" title="Soldier not found" />
{/if}
