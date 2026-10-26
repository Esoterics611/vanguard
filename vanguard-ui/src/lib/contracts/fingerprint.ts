// ═══════════════════════════════════════════════════════════════
// Fingerprints: briefs and deliverables go on chain only as
// keccak256 of their bytes, the convention contracts/scripts/demo.js
// used for the live run. A text file and the same text pasted in give
// the same fingerprint.
// ═══════════════════════════════════════════════════════════════

import { keccak256, toUtf8Bytes } from 'ethers';

export function fingerprintText(text: string): string {
	return keccak256(toUtf8Bytes(text));
}

export async function fingerprintFile(file: File): Promise<string> {
	return keccak256(new Uint8Array(await file.arrayBuffer()));
}

export function shortHash(hash: string): string {
	return `${hash.slice(0, 10)}…${hash.slice(-6)}`;
}
