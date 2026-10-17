<script lang="ts">
	import { goto } from '$app/navigation';
	import { app } from '$stores/app.svelte';
	import { RANK_META } from '$lib/types';
	import type { BountyStatus } from '$lib/types';

	let title = $state('');
	let description = $state('');
	let totalAmount = $state(10000);
	let deadline = $state('2025-12-31');
	let skillTagsInput = $state('');
	let status = $state<BountyStatus>('draft');

	let user = $derived(app.currentUser);
	let canCreate = $derived(user && RANK_META[user.rank].tier === 'officer');
	let isValid = $derived(title.trim().length > 0 && description.trim().length > 0 && totalAmount > 0);

	function createBounty() {
		if (!isValid || !user) return;
		const id = `bounty-${Date.now()}`;
		const tags = skillTagsInput.split(',').map(t => t.trim()).filter(Boolean);
		const now = new Date().toISOString();
		app.bounties = [...app.bounties, {
			id,
			title: title.trim(),
			description: description.trim(),
			creatorId: user.id,
			totalAmount,
			remainingAmount: totalAmount,
			status,
			objectiveIds: [],
			skillTags: tags,
			deadline: new Date(deadline).toISOString(),
			createdAt: now,
			updatedAt: now,
		}];
		// Add activity
		app.activities = [{
			id: `act-${Date.now()}`,
			type: 'bounty_created',
			actorId: user.id,
			actorCallsign: user.callsign,
			targetId: id,
			targetTitle: title.trim(),
			description: 'created bounty',
			timestamp: now,
			metadata: { amount: totalAmount },
		}, ...app.activities];
		goto(`/bounties/${id}`);
	}
</script>

<div class="max-w-2xl mx-auto space-y-6">
	<div>
		<a href="/bounties" class="text-xs text-vanguard-text-muted hover:text-cyan-400 transition-colors">← Back to Bounties</a>
		<h2 class="text-lg font-semibold text-vanguard-text mt-2">Create New Bounty</h2>
		<p class="text-xs text-vanguard-text-muted mt-0.5">Define a new deal or engagement for the team</p>
	</div>

	{#if !canCreate}
		<div class="rounded-xl border border-amber-500/20 bg-amber-500/5 p-5">
			<p class="text-sm text-amber-400">Only officers (2LT+) can create bounties. Switch to an officer account in Settings to test this flow.</p>
		</div>
	{/if}

	<div class="rounded-xl border border-vanguard-border bg-vanguard-surface p-6 space-y-5">
		<!-- Title -->
		<div>
			<label for="title" class="block text-xs text-vanguard-text-muted mb-1.5 uppercase tracking-wider">Title</label>
			<input
				id="title"
				type="text"
				bind:value={title}
				placeholder="e.g., Series B Due Diligence — TargetCo Acquisition"
				class="w-full px-4 py-2.5 rounded-lg border border-vanguard-border bg-vanguard-surface-2 text-sm text-vanguard-text placeholder:text-vanguard-text-muted/50 focus:outline-none focus:border-cyan-500/50 transition-colors"
			/>
		</div>

		<!-- Description -->
		<div>
			<label for="desc" class="block text-xs text-vanguard-text-muted mb-1.5 uppercase tracking-wider">Description</label>
			<textarea
				id="desc"
				bind:value={description}
				placeholder="Describe the scope of work, deliverables, and success criteria..."
				rows="4"
				class="w-full px-4 py-2.5 rounded-lg border border-vanguard-border bg-vanguard-surface-2 text-sm text-vanguard-text placeholder:text-vanguard-text-muted/50 focus:outline-none focus:border-cyan-500/50 transition-colors resize-none"
			></textarea>
		</div>

		<!-- Amount + Deadline Row -->
		<div class="grid grid-cols-2 gap-4">
			<div>
				<label for="amount" class="block text-xs text-vanguard-text-muted mb-1.5 uppercase tracking-wider">VGRD Budget</label>
				<div class="relative">
					<input
						id="amount"
						type="number"
						bind:value={totalAmount}
						min="100"
						step="1000"
						class="w-full px-4 py-2.5 rounded-lg border border-vanguard-border bg-vanguard-surface-2 text-sm text-vanguard-text focus:outline-none focus:border-cyan-500/50 transition-colors pr-16"
					/>
					<span class="absolute right-3 top-1/2 -translate-y-1/2 text-xs text-amber-400 font-mono">VGRD</span>
				</div>
			</div>
			<div>
				<label for="deadline" class="block text-xs text-vanguard-text-muted mb-1.5 uppercase tracking-wider">Deadline</label>
				<input
					id="deadline"
					type="date"
					bind:value={deadline}
					class="w-full px-4 py-2.5 rounded-lg border border-vanguard-border bg-vanguard-surface-2 text-sm text-vanguard-text focus:outline-none focus:border-cyan-500/50 transition-colors"
				/>
			</div>
		</div>

		<!-- Skill Tags -->
		<div>
			<label for="tags" class="block text-xs text-vanguard-text-muted mb-1.5 uppercase tracking-wider">Skill Tags (comma-separated)</label>
			<input
				id="tags"
				type="text"
				bind:value={skillTagsInput}
				placeholder="e.g., M&A, Financial Modeling, Due Diligence"
				class="w-full px-4 py-2.5 rounded-lg border border-vanguard-border bg-vanguard-surface-2 text-sm text-vanguard-text placeholder:text-vanguard-text-muted/50 focus:outline-none focus:border-cyan-500/50 transition-colors"
			/>
		</div>

		<!-- Status -->
		<div>
			<label class="block text-xs text-vanguard-text-muted mb-1.5 uppercase tracking-wider">Initial Status</label>
			<div class="flex gap-2">
				<button
					onclick={() => status = 'draft'}
					class="px-3 py-1.5 rounded-lg text-xs border transition-all {status === 'draft' ? 'bg-zinc-400/10 text-zinc-300 border-zinc-400/30' : 'border-vanguard-border text-vanguard-text-muted hover:text-vanguard-text'}"
				>Draft</button>
				<button
					onclick={() => status = 'active'}
					class="px-3 py-1.5 rounded-lg text-xs border transition-all {status === 'active' ? 'bg-cyan-400/10 text-cyan-400 border-cyan-400/30' : 'border-vanguard-border text-vanguard-text-muted hover:text-vanguard-text'}"
				>Active</button>
			</div>
		</div>

		<!-- Submit -->
		<div class="flex items-center gap-3 pt-2">
			<button
				onclick={createBounty}
				disabled={!isValid || !canCreate}
				class="px-6 py-2.5 rounded-lg text-sm font-medium transition-all
					{isValid && canCreate
						? 'bg-cyan-500/15 text-cyan-400 border border-cyan-500/30 hover:bg-cyan-500/25 cursor-pointer'
						: 'bg-vanguard-surface-3 text-vanguard-text-muted border border-vanguard-border cursor-not-allowed'}"
			>
				Create Bounty
			</button>
			<a href="/bounties" class="text-xs text-vanguard-text-muted hover:text-vanguard-text transition-colors">Cancel</a>
		</div>
	</div>
</div>
