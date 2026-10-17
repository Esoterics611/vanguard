// ═══════════════════════════════════════════════════════════════
// Minimal EIP-1193 provider typing for window.ethereum
// (avoids pulling a heavy wallet-types dep)
// ═══════════════════════════════════════════════════════════════

export interface Eip1193RequestArguments {
	method: string;
	params?: readonly unknown[] | object;
}

export type Eip1193EventName =
	| 'accountsChanged'
	| 'chainChanged'
	| 'connect'
	| 'disconnect'
	| 'message';

export interface Eip1193Provider {
	request<T = unknown>(args: Eip1193RequestArguments): Promise<T>;
	on(event: Eip1193EventName, listener: (...args: unknown[]) => void): void;
	removeListener(event: Eip1193EventName, listener: (...args: unknown[]) => void): void;
	isMetaMask?: boolean;
}

declare global {
	interface Window {
		ethereum?: Eip1193Provider;
	}
}
