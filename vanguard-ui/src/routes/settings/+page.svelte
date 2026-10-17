<script lang="ts">
	import { app } from '$stores/app.svelte';
	import { RANK_META } from '$lib/types';
	import RankInsignia from '$components/RankInsignia.svelte';
	import SoldierAvatar from '$components/SoldierAvatar.svelte';
	import { formatVgrd } from '$lib/utils/format';
	import { wallet, shortAddress } from '$lib/contracts/provider.svelte';
	import { BASE_SEPOLIA_NAME } from '$lib/contracts/addresses';

	let selectedId = $derived(app.currentUserId);
</script>

<div class="max-w-3xl mx-auto space-y-6">
	<div>
		<h2 class="text-lg font-semibold text-vanguard-text">Settings</h2>
		<p class="text-xs text-vanguard-text-muted mt-0.5">Switch active user to test different role perspectives</p>
	</div>

	{#if wallet.isConnected}
		<!-- Wallet-locked: real connected user -->
		<div class="rounded-xl border border-cyan-500/40 bg-cyan-500/5 px-5 py-4">
			<div class="flex items-start justify-between gap-4">
				<div>
					<h3 class="text-sm font-medium text-vanguard-text">Active User (wallet-locked)</h3>
					<p class="text-[10px] text-vanguard-text-muted mt-0.5">
						Identity is bound to the connected wallet. The mock-data switcher is hidden while a wallet is connected.
					</p>
					<div class="mt-3 flex items-center gap-3">
						<span class="w-2 h-2 rounded-full bg-cyan-400 shadow-[0_0_6px_rgba(34,211,238,0.8)]"></span>
						<span class="font-mono text-cyan-300 text-sm" title={wallet.account ?? ''}>
							{shortAddress(wallet.account)}
						</span>
						<span class="text-[10px] uppercase tracking-wider text-vanguard-text-muted">
							{wallet.isCorrectNetwork ? BASE_SEPOLIA_NAME : `chain ${wallet.chainId ?? '?'}`}
						</span>
					</div>
				</div>
				<button
					onclick={() => wallet.disconnect()}
					class="px-3 py-1.5 rounded-lg border border-vanguard-border bg-vanguard-surface-2 text-vanguard-text-muted text-xs hover:text-vanguard-text hover:border-vanguard-border-bright transition-all"
				>
					Disconnect
				</button>
			</div>
		</div>
	{:else}
	<!-- User Switcher -->
	<div class="rounded-xl border border-vanguard-border bg-vanguard-surface">
		<div class="px-5 py-3 border-b border-vanguard-border">
			<h3 class="text-sm font-medium text-vanguard-text">Active User</h3>
			<p class="text-[10px] text-vanguard-text-muted mt-0.5">
				Select a soldier to view the UI from their perspective. Officers can create bounties and review work. NCOs lead units. Enlisted soldiers execute tasks.
			</p>
		</div>
		<div class="divide-y divide-vanguard-border">
			{#each app.soldiers as soldier}
				{@const meta = RANK_META[soldier.rank]}
				{@const isActive = soldier.id === selectedId}
				{@const tasks = app.getSoldierTasks(soldier.id)}
				<button
					onclick={() => app.currentUserId = soldier.id}
					class="w-full text-left flex items-center gap-4 px-5 py-4 transition-all
						{isActive
							? 'bg-cyan-500/5 border-l-2 border-l-cyan-400'
							: 'hover:bg-vanguard-surface-2 border-l-2 border-l-transparent'}"
				>
					<SoldierAvatar callsign={soldier.callsign} rank={soldier.rank} isOnline={soldier.isOnline} size="md" />
					<div class="flex-1 min-w-0">
						<div class="flex items-center gap-2">
							<span class="text-sm font-medium text-vanguard-text">{soldier.callsign}</span>
							{#if isActive}
								<span class="tag bg-cyan-500/20 text-cyan-400">Active</span>
							{/if}
						</div>
						<div class="flex items-center gap-3 mt-0.5">
							<RankInsignia rank={soldier.rank} size="sm" showLabel />
							<span class="text-xs text-vanguard-text-muted">{soldier.specialty}</span>
						</div>
					</div>
					<div class="flex items-center gap-4 text-xs text-vanguard-text-muted flex-shrink-0">
						<div class="text-center">
							<span class="font-mono text-vanguard-text block">{tasks.length}</span>
							<span class="text-[10px]">Tasks</span>
						</div>
						<div class="text-center">
							<span class="font-mono text-amber-400 block">{formatVgrd(soldier.vgrdEarned)}</span>
							<span class="text-[10px]">VGRD</span>
						</div>
						<div class="text-center">
							<span class="font-mono text-vanguard-text block">{meta.votingPower}</span>
							<span class="text-[10px]">Votes</span>
						</div>
					</div>
					<div class="flex-shrink-0 w-20 text-right">
						<span class="text-[10px] uppercase tracking-wider px-2 py-0.5 rounded"
							style="color: {meta.color}; background: color-mix(in srgb, {meta.color} 10%, transparent)">
							{meta.tier}
						</span>
					</div>
				</button>
			{/each}
		</div>
	</div>
	{/if}

	<!-- Role Capabilities -->
	<div class="rounded-xl border border-vanguard-border bg-vanguard-surface p-5">
		<h3 class="text-sm font-medium text-vanguard-text mb-3">Role Capabilities</h3>
		<div class="grid grid-cols-3 gap-4">
			<div class="rounded-lg border border-yellow-500/20 bg-yellow-500/5 p-4">
				<span class="text-xs font-bold text-yellow-400 uppercase tracking-wider">Officers (2LT+)</span>
				<ul class="mt-2 space-y-1 text-xs text-vanguard-text-muted">
					<li>Create & fund bounties</li>
					<li>Define objectives</li>
					<li>Review & merge work</li>
					<li>Promote soldiers</li>
					<li>Manage unit hierarchy</li>
				</ul>
			</div>
			<div class="rounded-lg border border-slate-400/20 bg-slate-400/5 p-4">
				<span class="text-xs font-bold text-slate-300 uppercase tracking-wider">NCOs (SGT-1SG)</span>
				<ul class="mt-2 space-y-1 text-xs text-vanguard-text-muted">
					<li>Lead squads/sections</li>
					<li>Checkout objectives</li>
					<li>Break into tasks</li>
					<li>Assign tasks to soldiers</li>
					<li>Submit for review</li>
				</ul>
			</div>
			<div class="rounded-lg border border-amber-700/20 bg-amber-700/5 p-4">
				<span class="text-xs font-bold text-amber-700 uppercase tracking-wider">Enlisted (PVT-CPL)</span>
				<ul class="mt-2 space-y-1 text-xs text-vanguard-text-muted">
					<li>View assigned tasks</li>
					<li>Execute work</li>
					<li>Submit deliverables</li>
					<li>Earn XP & VGRD</li>
					<li>Progress through ranks</li>
				</ul>
			</div>
		</div>
	</div>
</div>
