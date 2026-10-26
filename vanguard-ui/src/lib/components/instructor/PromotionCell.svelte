<script lang="ts">
	import { ArrowUp } from 'lucide-svelte';
	import { getRankManager } from '$lib/contracts/contracts.svelte';
	import { TxRunner, requireSigner } from '$lib/contracts/tx.svelte';
	import type { Roles } from '$lib/contracts/chain';
	import { promotionBlocker, rankLabel } from '$lib/academy/promotion';
	import type { StudentRow } from '$lib/academy/instructor.svelte';
	import TxNotice from '$components/academy/TxNotice.svelte';

	let {
		row,
		promoterRank,
		roles,
		cooldownSeconds,
		canManage,
		onchange,
	}: {
		row: StudentRow;
		promoterRank: number;
		roles: Roles;
		cooldownSeconds: number;
		canManage: boolean;
		onchange?: () => void;
	} = $props();

	const CPL = 4;
	const tx = new TxRunner();

	let member = $derived(row.member);
	let next = $derived(member.rankIndex + 1);
	let blocker = $derived(
		promotionBlocker({
			promoterRank,
			memberRank: member.rankIndex,
			pldc: row.promotion.pldc,
			lastPromotion: row.promotion.lastPromotion,
			cooldownSeconds,
		})
	);
	// The contract is the authority: only offer what canPromote allows.
	let canPromote = $derived(canManage && row.promotion.canPromote);
	let needsPldc = $derived(member.rankIndex >= CPL && !row.promotion.pldc);

	async function promote(asCommand: boolean) {
		const target = member.address;
		const rank = next;
		const ok = await tx.run(`Promote ${member.callsign} to ${rankLabel(rank)}`, () => {
			const rankManager = getRankManager(requireSigner());
			return asCommand ? rankManager.daoPromote(target, rank) : rankManager.promote(target, rank);
		});
		if (ok) onchange?.();
	}

	async function recordPldc() {
		const target = member.address;
		if (await tx.run(`Record the leadership course for ${member.callsign}`, () => getRankManager(requireSigner()).completePLDC(target))) onchange?.();
	}
</script>

<div class="space-y-1.5">
	{#if next > 11}
		<span class="text-xs text-vanguard-text-muted">Top rank</span>
	{:else if canPromote}
		<button class="btn-ghost px-2.5 py-1 text-xs" onclick={() => promote(false)} disabled={tx.busy}>
			<ArrowUp size={12} /> Promote to {rankLabel(next)}
		</button>
	{:else}
		<span class="block text-xs text-vanguard-text-muted">{blocker ?? 'Not available'}</span>
		{#if roles.rankAdmin}
			<button class="text-xs text-amber-300 underline underline-offset-2 hover:text-amber-200" onclick={() => promote(true)} disabled={tx.busy}>
				Promote as command
			</button>
		{/if}
	{/if}
	{#if roles.rankAdmin && needsPldc}
		<button class="block text-xs text-cyan-300 underline underline-offset-2 hover:text-cyan-200" onclick={recordPldc} disabled={tx.busy}>
			Record leadership course
		</button>
	{/if}
	<TxNotice {tx} doneText="Recorded." />
</div>
