// ═══════════════════════════════════════════════════════════════
// BatchRunner — sends a list of contract calls, such as one assignment
// per student. Wallets that support EIP-5792 (wallet_sendCalls) get a
// single confirmation for the whole list; others confirm each call in
// turn, with progress shown. A run that stops part-way says how far
// it got; the calls already recorded stay recorded.
// ═══════════════════════════════════════════════════════════════

import { toQuantity } from 'ethers';
import { BASE_SEPOLIA_CHAIN_ID } from './addresses';
import { wallet } from './provider.svelte';
import { describeError, requireSigner, type TxPhase } from './tx.svelte';

export interface Call {
	to: string;
	data: string;
}

const CHAIN_HEX = toQuantity(BASE_SEPOLIA_CHAIN_ID);
const STATUS_POLL_MS = 1500;
const STATUS_TIMEOUT_MS = 3 * 60 * 1000;
const sleep = (ms: number) => new Promise((r) => setTimeout(r, ms));

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type Capabilities = Record<string, any>;

async function supportsBatch(account: string): Promise<boolean> {
	try {
		const caps = await wallet.request<Capabilities>('wallet_getCapabilities', [account, [CHAIN_HEX]]);
		const chain = caps?.[CHAIN_HEX] ?? caps?.[String(BASE_SEPOLIA_CHAIN_ID)];
		// EIP-5792 v2 reports atomic.status; earlier wallets reported atomicBatch.supported.
		const status = chain?.atomic?.status ?? (chain?.atomicBatch?.supported ? 'supported' : undefined);
		return status === 'supported' || status === 'ready';
	} catch {
		return false;
	}
}

export class BatchRunner {
	phase = $state<TxPhase>('idle');
	label = $state('');
	done = $state(0);
	total = $state(0);
	/** 'batch': one confirmation for everything; 'sequential': one per call. */
	mode = $state<'batch' | 'sequential' | null>(null);
	error = $state<string | null>(null);

	busy = $derived(this.phase === 'signing' || this.phase === 'pending');

	async run(label: string, calls: Call[]): Promise<boolean> {
		this.label = label;
		this.done = 0;
		this.total = calls.length;
		this.error = null;
		this.mode = null;
		if (calls.length === 0) {
			this.phase = 'done';
			return true;
		}
		this.phase = 'signing';
		try {
			const signer = requireSigner();
			const account = await signer.getAddress();
			if (calls.length > 1 && (await supportsBatch(account))) {
				this.mode = 'batch';
				await this.#sendBatch(account, calls);
			} else {
				this.mode = 'sequential';
				for (const call of calls) {
					this.phase = 'signing';
					const tx = await signer.sendTransaction({ to: call.to, data: call.data });
					this.phase = 'pending';
					const receipt = await tx.wait();
					if (receipt?.status !== 1) throw new Error('A transaction failed on chain.');
					this.done++;
				}
			}
			this.phase = 'done';
			return true;
		} catch (e) {
			const reason = describeError(e);
			this.error = this.done > 0 ? `Stopped after ${this.done} of ${this.total}: ${reason}` : reason;
			this.phase = 'failed';
			return false;
		}
	}

	async #sendBatch(account: string, calls: Call[]) {
		const sent = await wallet.request<string | { id: string }>('wallet_sendCalls', [
			{
				version: '2.0.0',
				chainId: CHAIN_HEX,
				from: account,
				atomicRequired: true,
				calls: calls.map((c) => ({ to: c.to, data: c.data, value: '0x0' })),
			},
		]);
		const id = typeof sent === 'string' ? sent : sent.id;
		this.phase = 'pending';
		const deadline = Date.now() + STATUS_TIMEOUT_MS;
		while (Date.now() < deadline) {
			await sleep(STATUS_POLL_MS);
			// eslint-disable-next-line @typescript-eslint/no-explicit-any
			const result = await wallet.request<any>('wallet_getCallsStatus', [id]);
			const status = result?.status;
			if (status === 100 || status === 'PENDING') continue;
			if (status === 200 || status === 'CONFIRMED') {
				// eslint-disable-next-line @typescript-eslint/no-explicit-any
				const failed = (result.receipts ?? []).some((r: any) => r.status !== '0x1' && r.status !== 1);
				if (failed) throw new Error('The batch was reverted on chain; nothing was recorded.');
				this.done = calls.length;
				return;
			}
			throw new Error('The wallet reports the batch failed; nothing was recorded.');
		}
		throw new Error('The wallet hasn’t confirmed the batch yet. Check your wallet, then refresh this page.');
	}

	reset(): void {
		this.phase = 'idle';
		this.label = '';
		this.done = 0;
		this.total = 0;
		this.mode = null;
		this.error = null;
	}
}
