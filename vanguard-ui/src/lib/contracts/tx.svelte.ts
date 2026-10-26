// ═══════════════════════════════════════════════════════════════
// TxRunner — one write at a time: waits for the wallet, then for the
// block, and turns wallet and contract errors into plain sentences.
//
// Use:
//   const tx = new TxRunner();
//   const ok = await tx.run('Enlist', () => getArmyRegistry(requireSigner()).enlist(id));
// ═══════════════════════════════════════════════════════════════

import type { ContractTransactionResponse, JsonRpcSigner } from 'ethers';
import { wallet } from './provider.svelte';

export type TxPhase = 'idle' | 'signing' | 'pending' | 'done' | 'failed';

// Revert strings from the contracts, in the words a student would use.
const REVERT_MESSAGES: Record<string, string> = {
	'Already enlisted': 'This wallet is already enlisted.',
	'Unit not active': 'This squad is closed to new members.',
	'Can only join squads': 'This unit is not a squad, so nobody can enlist in it directly.',
	'Inviter not enlisted': 'The invite link points to a wallet that isn’t enlisted. Ask for a new link.',
	'Deadline passed': 'The deadline for this assignment has passed. Ask your instructor to reopen it.',
	'Not assignee': 'This assignment belongs to someone else.',
	'Task not assigned': 'This assignment isn’t waiting for a submission.',
	'Task not rejected': 'This assignment wasn’t sent back, so there is nothing to resubmit.',
	'Task not open': 'Someone else took this assignment first.',
	'No rewards to claim': 'There is nothing to claim yet.',
	'Not enlisted': 'Enlist first.',
};

export function describeError(e: unknown): string {
	const err = (e ?? {}) as { code?: string; reason?: string | null; shortMessage?: string; message?: string };
	if (err.code === 'ACTION_REJECTED') return 'You cancelled it in your wallet. Nothing was sent.';
	const text = `${err.shortMessage ?? ''} ${err.message ?? ''}`;
	if (err.code === 'INSUFFICIENT_FUNDS' || /insufficient funds/i.test(text)) {
		return 'Your wallet needs a little Base Sepolia ETH to pay the fee.';
	}
	if (err.reason) return REVERT_MESSAGES[err.reason] ?? `The contract refused: ${err.reason}.`;
	return err.shortMessage ?? err.message ?? 'Something went wrong. Try again.';
}

/** The connected wallet's signer, if it is ready to write on Base Sepolia. */
export function requireSigner(): JsonRpcSigner {
	if (!wallet.signer) throw new Error('Connect your wallet first.');
	if (!wallet.isCorrectNetwork) throw new Error('Switch your wallet to Base Sepolia first.');
	return wallet.signer;
}

export class TxRunner {
	phase = $state<TxPhase>('idle');
	label = $state('');
	hash = $state<string | null>(null);
	error = $state<string | null>(null);

	busy = $derived(this.phase === 'signing' || this.phase === 'pending');

	async run(label: string, send: () => Promise<ContractTransactionResponse>): Promise<boolean> {
		this.label = label;
		this.phase = 'signing';
		this.hash = null;
		this.error = null;
		try {
			const tx = await send();
			this.hash = tx.hash;
			this.phase = 'pending';
			const receipt = await tx.wait();
			if (receipt?.status !== 1) throw new Error('The transaction failed on chain.');
			this.phase = 'done';
			return true;
		} catch (e) {
			this.error = describeError(e);
			this.phase = 'failed';
			return false;
		}
	}

	reset(): void {
		this.phase = 'idle';
		this.label = '';
		this.hash = null;
		this.error = null;
	}
}
