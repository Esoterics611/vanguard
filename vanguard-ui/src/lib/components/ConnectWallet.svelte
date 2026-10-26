<script lang="ts">
	import { wallet, shortAddress } from '$lib/contracts/provider.svelte';

	async function handleClick() {
		if (wallet.isConnected) {
			wallet.disconnect();
		} else {
			await wallet.connect();
		}
	}
</script>

{#if wallet.isConnected}
	<button
		onclick={handleClick}
		title={wallet.account ?? ''}
		class="flex items-center gap-2 px-3 py-1.5 rounded-lg border border-cyan-500/40 bg-cyan-500/10 text-cyan-300 text-xs font-mono hover:bg-cyan-500/20 hover:border-cyan-400 transition-all"
	>
		<span class="w-2 h-2 rounded-full bg-cyan-400 shadow-[0_0_6px_rgba(34,211,238,0.8)]"></span>
		<span>{shortAddress(wallet.account)}</span>
		<span class="hidden sm:inline text-[10px] uppercase tracking-wider text-cyan-300/60">Disconnect</span>
	</button>
{:else}
	<button
		onclick={handleClick}
		disabled={wallet.connecting}
		class="flex items-center gap-2 px-3 py-1.5 rounded-lg border border-amber-400/40 bg-amber-500/10 text-amber-300 text-xs font-medium hover:bg-amber-500/20 hover:border-amber-400 transition-all disabled:opacity-60 disabled:cursor-not-allowed"
	>
		<span class="text-sm leading-none">⬢</span>
		<span>{wallet.connecting ? 'Connecting...' : 'Connect Wallet'}</span>
	</button>
{/if}

{#if wallet.error}
	<span class="text-[10px] text-red-400 ml-2 max-w-[180px] truncate" title={wallet.error}>
		{wallet.error}
	</span>
{/if}
