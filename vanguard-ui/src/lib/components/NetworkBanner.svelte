<script lang="ts">
	import { wallet } from '$lib/contracts/provider.svelte';
	import { BASE_SEPOLIA_NAME } from '$lib/contracts/addresses';

	let visible = $derived(wallet.isConnected && !wallet.isCorrectNetwork);

	async function handleSwitch() {
		await wallet.switchToBaseSepolia();
	}
</script>

{#if visible}
	<div
		role="alert"
		class="w-full bg-red-600/15 border-b border-red-500/40 text-red-200 px-4 py-2 flex items-center justify-between gap-4 text-xs"
	>
		<div class="flex items-center gap-2">
			<span class="text-sm">⚠</span>
			<span class="font-medium">Wrong network</span>
			<span class="text-red-200/80">— switch to {BASE_SEPOLIA_NAME} to continue.</span>
			{#if wallet.chainId !== null}
				<span class="font-mono text-red-200/60">(current chain: {wallet.chainId})</span>
			{/if}
		</div>
		<button
			onclick={handleSwitch}
			class="px-3 py-1 rounded-md border border-red-400/60 bg-red-500/20 text-red-100 hover:bg-red-500/30 transition-colors"
		>
			Switch to {BASE_SEPOLIA_NAME}
		</button>
	</div>
{/if}
