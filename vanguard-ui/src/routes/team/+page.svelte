<script lang="ts">
	import { onMount } from 'svelte';
	import { app } from '$stores/app.svelte';
	import { RANK_META } from '$lib/types';
	import { formatVgrd, tierColor } from '$lib/utils/format';
	import SoldierAvatar from '$components/SoldierAvatar.svelte';
	import RankBadge from '$components/RankBadge.svelte';
	import ProgressBar from '$components/ProgressBar.svelte';

	let viewMode = $state<'roster' | 'hierarchy'>('roster');

	onMount(() => app.loadSoldiersFromChain());

	// Group soldiers by tier — live from ArmyRegistry
	let officers = $derived(app.chainSoldiers.filter(s => RANK_META[s.rank].tier === 'officer'));
	let ncos = $derived(app.chainSoldiers.filter(s => RANK_META[s.rank].tier === 'nco'));
	let enlisted = $derived(app.chainSoldiers.filter(s => RANK_META[s.rank].tier === 'enlisted'));

	// Hierarchy: company -> platoons -> sections -> squads
	let company = $derived(app.units.find(u => u.type === 'company'));

	function getUnitMembers(unitId: string) {
		const unit = app.getUnit(unitId);
		if (!unit) return [];
		return unit.memberIds.map(id => app.getSoldier(id)).filter(Boolean);
	}

	function getUnitChildren(unitId: string) {
		const unit = app.getUnit(unitId);
		if (!unit) return [];
		return unit.childUnitIds.map(id => app.getUnit(id)).filter(Boolean);
	}
</script>

<div class="space-y-5">
	<div class="flex items-center justify-between">
		<div>
			<h2 class="text-lg font-semibold text-vanguard-text">Team</h2>
			<p class="text-xs text-vanguard-text-muted mt-0.5">{app.chainSoldiers.length} soldiers · {app.chainSoldiers.filter(s => s.isOnline).length} online</p>
		</div>
		<div class="flex rounded-lg border border-vanguard-border bg-vanguard-surface overflow-hidden">
			<button
				onclick={() => viewMode = 'roster'}
				class="px-3 py-1.5 text-xs transition-all {viewMode === 'roster' ? 'bg-vanguard-surface-3 text-cyan-400 font-medium' : 'text-vanguard-text-muted hover:text-vanguard-text'}"
			>Roster</button>
			<button
				onclick={() => viewMode = 'hierarchy'}
				class="px-3 py-1.5 text-xs transition-all {viewMode === 'hierarchy' ? 'bg-vanguard-surface-3 text-cyan-400 font-medium' : 'text-vanguard-text-muted hover:text-vanguard-text'}"
			>Hierarchy</button>
		</div>
	</div>

	{#if viewMode === 'roster'}
		{#if app.chainSoldiersLoading}
			<div class="py-8 text-center text-sm text-vanguard-text-muted">Loading roster from chain…</div>
		{:else if app.chainSoldiers.length === 0}
			<div class="py-8 text-center text-sm text-vanguard-text-muted">No soldiers enlisted on-chain yet.</div>
		{:else}
		<!-- Roster View: grouped by tier -->
		{#each [
			{ label: 'Officers', tier: 'officer', soldiers: officers, color: 'text-yellow-400', borderColor: 'border-yellow-500/30' },
			{ label: 'NCOs', tier: 'nco', soldiers: ncos, color: 'text-slate-300', borderColor: 'border-slate-400/30' },
			{ label: 'Enlisted', tier: 'enlisted', soldiers: enlisted, color: 'text-amber-700', borderColor: 'border-amber-700/30' },
		] as group}
			{#if group.soldiers.length > 0}
				<div>
					<div class="flex items-center gap-2 mb-3">
						<span class="text-xs font-semibold uppercase tracking-wider {group.color}">{group.label}</span>
						<span class="text-xs text-vanguard-text-muted">({group.soldiers.length})</span>
						<div class="flex-1 border-t border-vanguard-border"></div>
					</div>
					<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
						{#each group.soldiers as soldier}
							{@const meta = RANK_META[soldier.rank]}
							{@const tasks = app.getSoldierTasks(soldier.id)}
							{@const completedTasks = tasks.filter(t => t.status === 'approved').length}
							<a href="/team/{soldier.id}" class="rounded-xl border {group.borderColor} bg-vanguard-surface p-4 card-hover group">
								<div class="flex items-center gap-3 mb-3">
									<SoldierAvatar callsign={soldier.callsign} rank={soldier.rank} isOnline={soldier.isOnline} size="md" />
									<div class="flex-1 min-w-0">
										<div class="flex items-center gap-2">
											<span class="text-sm font-medium text-vanguard-text group-hover:text-cyan-400 transition-colors truncate">{soldier.callsign}</span>
											{#if soldier.isOnline}
												<span class="w-1.5 h-1.5 rounded-full bg-emerald-400 pulse-online"></span>
											{/if}
										</div>
										<div class="flex items-center gap-2 mt-0.5">
											<RankBadge rank={soldier.rank} size="sm" />
											<span class="text-xs text-vanguard-text-muted">{soldier.specialty}</span>
										</div>
									</div>
								</div>
								<div class="grid grid-cols-3 gap-2 text-center">
									<div>
										<span class="text-sm font-bold text-vanguard-text font-mono block">{soldier.tasksCompleted}</span>
										<span class="text-[10px] text-vanguard-text-muted">Tasks</span>
									</div>
									<div>
										<span class="text-sm font-bold text-amber-400 font-mono block">{formatVgrd(soldier.vgrdEarned)}</span>
										<span class="text-[10px] text-vanguard-text-muted">VGRD</span>
									</div>
									<div>
										<span class="text-sm font-bold text-vanguard-text font-mono block">{soldier.xp.toLocaleString()}</span>
										<span class="text-[10px] text-vanguard-text-muted">XP</span>
									</div>
								</div>
							</a>
						{/each}
					</div>
				</div>
			{/if}
		{/each}
		{/if}

	{:else}
		<!-- Hierarchy View -->
		{#if company}
			{@const companyLeader = app.getSoldier(company.leaderId)}
			<div class="rounded-xl border border-yellow-500/30 bg-vanguard-surface p-5">
				<div class="flex items-center gap-3 mb-4">
					<span class="text-lg text-yellow-400">⬡</span>
					<div>
						<h3 class="text-sm font-semibold text-vanguard-text">{company.name}</h3>
						<span class="text-xs text-vanguard-text-muted">{company.memberIds.length} members · Company</span>
					</div>
					{#if companyLeader}
						<div class="ml-auto flex items-center gap-2">
							<SoldierAvatar callsign={companyLeader.callsign} rank={companyLeader.rank} isOnline={companyLeader.isOnline} size="sm" />
							<span class="text-xs text-vanguard-text">{companyLeader.callsign}</span>
							<span class="text-[10px] text-yellow-400">CO</span>
						</div>
					{/if}
				</div>

				<!-- Platoons -->
				{#each getUnitChildren(company.id) as platoon}
					{#if platoon}
						{@const platoonLeader = app.getSoldier(platoon.leaderId)}
						<div class="ml-6 mb-4 rounded-lg border border-vanguard-border bg-vanguard-surface-2 p-4">
							<div class="flex items-center gap-3 mb-3">
								<span class="text-sm text-cyan-400">⬡</span>
								<div>
									<h4 class="text-sm font-medium text-vanguard-text">{platoon.name}</h4>
									<span class="text-xs text-vanguard-text-muted">{platoon.memberIds.length} members · Platoon</span>
								</div>
								{#if platoonLeader}
									<div class="ml-auto flex items-center gap-2">
										<SoldierAvatar callsign={platoonLeader.callsign} rank={platoonLeader.rank} isOnline={platoonLeader.isOnline} size="sm" />
										<span class="text-xs text-vanguard-text">{platoonLeader.callsign}</span>
										<span class="text-[10px] text-cyan-400">PL</span>
									</div>
								{/if}
							</div>

							<!-- Sections -->
							{#each getUnitChildren(platoon.id) as section}
								{#if section}
									{@const sectionLeader = app.getSoldier(section.leaderId)}
									<div class="ml-6 mb-3 rounded-lg border border-vanguard-border bg-vanguard-surface-3 p-3">
										<div class="flex items-center gap-3 mb-2">
											<span class="text-sm text-slate-400">⬡</span>
											<div>
												<h5 class="text-xs font-medium text-vanguard-text">{section.name}</h5>
												<span class="text-[10px] text-vanguard-text-muted">{section.memberIds.length} members · Section</span>
											</div>
											{#if sectionLeader}
												<div class="ml-auto flex items-center gap-1.5">
													<SoldierAvatar callsign={sectionLeader.callsign} rank={sectionLeader.rank} isOnline={sectionLeader.isOnline} size="sm" />
													<span class="text-[11px] text-vanguard-text-muted">{sectionLeader.callsign}</span>
												</div>
											{/if}
										</div>

										<!-- Squads -->
										<div class="ml-6 flex flex-wrap gap-2">
											{#each getUnitChildren(section.id) as squad}
												{#if squad}
													{@const squadLeader = app.getSoldier(squad.leaderId)}
													<div class="rounded-md border border-vanguard-border bg-vanguard-bg p-2.5 min-w-36">
														<div class="flex items-center gap-2 mb-1.5">
															<span class="text-xs text-amber-600">⬡</span>
															<span class="text-[11px] font-medium text-vanguard-text">{squad.name}</span>
														</div>
														<div class="flex flex-wrap gap-1">
															{#each getUnitMembers(squad.id) as member}
																{#if member}
																	<div class="flex items-center gap-1 px-1.5 py-0.5 rounded bg-vanguard-surface-2" title="{member.callsign} ({member.rank})">
																		<div class="w-1.5 h-1.5 rounded-full"
																			class:bg-emerald-400={member.isOnline}
																			class:bg-zinc-600={!member.isOnline}></div>
																		<span class="text-[10px] text-vanguard-text-muted">{member.callsign}</span>
																	</div>
																{/if}
															{/each}
														</div>
													</div>
												{/if}
											{/each}
										</div>
									</div>
								{/if}
							{/each}
						</div>
					{/if}
				{/each}
			</div>
		{/if}
	{/if}
</div>
