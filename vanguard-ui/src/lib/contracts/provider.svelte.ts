// ═══════════════════════════════════════════════════════════════
// WalletStore — Svelte 5 runes class wrapping a browser wallet
// (window.ethereum / MetaMask) and ethers v6 BrowserProvider.
//
// Use:
//   import { wallet } from '$lib/contracts/provider.svelte';
//   await wallet.connect();
//   wallet.account; wallet.chainId; wallet.isConnected;
// ═══════════════════════════════════════════════════════════════

import { BrowserProvider, type JsonRpcSigner } from 'ethers';
import {
	BASE_SEPOLIA_CHAIN_ID,
	BASE_SEPOLIA_CHAIN_ID_HEX,
	BASE_SEPOLIA_EXPLORER_URL,
	BASE_SEPOLIA_NAME,
	BASE_SEPOLIA_RPC_URL,
} from './addresses';
import type { Eip1193Provider } from './eip1193';

class WalletStore {
	account = $state<string | null>(null);
	chainId = $state<number | null>(null);
	provider = $state<BrowserProvider | null>(null);
	signer = $state<JsonRpcSigner | null>(null);
	error = $state<string | null>(null);
	connecting = $state<boolean>(false);

	isConnected = $derived(this.account !== null && this.provider !== null);
	isCorrectNetwork = $derived(this.chainId === BASE_SEPOLIA_CHAIN_ID);

	#listenersBound = false;
	#onAccountsChanged = (...args: unknown[]) => {
		const accounts = (args[0] as string[]) ?? [];
		if (accounts.length === 0) {
			this.disconnect();
		} else {
			this.account = accounts[0];
			void this.#refreshSigner();
		}
	};
	#onChainChanged = (...args: unknown[]) => {
		const hex = args[0] as string;
		const parsed = parseInt(hex, 16);
		this.chainId = Number.isFinite(parsed) ? parsed : null;
		void this.#refreshSigner();
	};

	#getEthereum(): Eip1193Provider | null {
		if (typeof window === 'undefined') return null;
		return window.ethereum ?? null;
	}

	#bindListeners(eth: Eip1193Provider) {
		if (this.#listenersBound) return;
		eth.on('accountsChanged', this.#onAccountsChanged);
		eth.on('chainChanged', this.#onChainChanged);
		this.#listenersBound = true;
	}

	#unbindListeners() {
		const eth = this.#getEthereum();
		if (!eth || !this.#listenersBound) return;
		eth.removeListener('accountsChanged', this.#onAccountsChanged);
		eth.removeListener('chainChanged', this.#onChainChanged);
		this.#listenersBound = false;
	}

	async #refreshSigner() {
		if (!this.provider || !this.account) {
			this.signer = null;
			return;
		}
		try {
			this.signer = await this.provider.getSigner();
		} catch {
			this.signer = null;
		}
	}

	async connect(): Promise<void> {
		this.error = null;
		const eth = this.#getEthereum();
		if (!eth) {
			this.error = 'No browser wallet detected. Install MetaMask.';
			return;
		}
		this.connecting = true;
		try {
			const accounts = await eth.request<string[]>({ method: 'eth_requestAccounts' });
			if (!accounts || accounts.length === 0) {
				this.error = 'No accounts returned by wallet.';
				return;
			}
			const provider = new BrowserProvider(eth);
			const network = await provider.getNetwork();
			this.provider = provider;
			this.account = accounts[0];
			this.chainId = Number(network.chainId);
			await this.#refreshSigner();
			this.#bindListeners(eth);
		} catch (e) {
			this.error = e instanceof Error ? e.message : 'Failed to connect wallet.';
		} finally {
			this.connecting = false;
		}
	}

	disconnect(): void {
		this.#unbindListeners();
		this.account = null;
		this.chainId = null;
		this.provider = null;
		this.signer = null;
		this.error = null;
	}

	async switchToBaseSepolia(): Promise<void> {
		const eth = this.#getEthereum();
		if (!eth) return;
		try {
			await eth.request({
				method: 'wallet_switchEthereumChain',
				params: [{ chainId: BASE_SEPOLIA_CHAIN_ID_HEX }],
			});
		} catch (err) {
			// 4902: chain not added — try to add it
			const code = (err as { code?: number }).code;
			if (code === 4902) {
				await eth.request({
					method: 'wallet_addEthereumChain',
					params: [
						{
							chainId: BASE_SEPOLIA_CHAIN_ID_HEX,
							chainName: BASE_SEPOLIA_NAME,
							nativeCurrency: { name: 'Sepolia ETH', symbol: 'ETH', decimals: 18 },
							rpcUrls: [BASE_SEPOLIA_RPC_URL],
							blockExplorerUrls: [BASE_SEPOLIA_EXPLORER_URL],
						},
					],
				});
			} else {
				this.error = err instanceof Error ? err.message : 'Failed to switch network.';
			}
		}
	}
}

export const wallet = new WalletStore();

/** Format an address as 0x1234...abcd. */
export function shortAddress(addr: string | null | undefined): string {
	if (!addr) return '';
	if (addr.length < 10) return addr;
	return `${addr.slice(0, 6)}...${addr.slice(-4)}`;
}
