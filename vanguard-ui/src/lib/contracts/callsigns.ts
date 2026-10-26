// ═══════════════════════════════════════════════════════════════
// Callsigns are stored on chain as keccak256(prefix ‖ suffix) of two
// bytes32 words from the registry's word lists
// (BaseRegistry._generateCallsign), or as a hash of the wallet when no
// words are seeded. We read both lists once, rebuild every combination
// and look the stored hash up; anything unknown falls back to a stable
// name derived from the address.
// ═══════════════════════════════════════════════════════════════

import { concat, decodeBytes32String, keccak256, type Contract } from 'ethers';

export type CallsignTable = Map<string, string>;

const BATCH = 50;
const MAX_WORDS = 1000;

async function readWordList(registry: Contract, list: 'prefixes' | 'suffixes'): Promise<string[]> {
	const words: string[] = [];
	// Public array getters revert past the end, so read in batches until one does.
	for (let start = 0; start < MAX_WORDS; start += BATCH) {
		const results = await Promise.allSettled(
			Array.from({ length: BATCH }, (_, i) => registry[list](start + i) as Promise<string>)
		);
		for (const result of results) {
			if (result.status === 'rejected') return words;
			words.push(result.value);
		}
	}
	return words;
}

function decodeWord(raw: string): string {
	try {
		return decodeBytes32String(raw);
	} catch {
		return '?';
	}
}

export async function loadCallsignTable(registry: Contract): Promise<CallsignTable> {
	const [prefixes, suffixes] = await Promise.all([
		readWordList(registry, 'prefixes'),
		readWordList(registry, 'suffixes'),
	]);
	const table: CallsignTable = new Map();
	for (const prefix of prefixes) {
		const first = decodeWord(prefix);
		for (const suffix of suffixes) {
			table.set(keccak256(concat([prefix, suffix])), `${first}-${decodeWord(suffix)}`);
		}
	}
	return table;
}

export function callsignFor(table: CallsignTable, hash: string, address: string): string {
	return table.get(hash.toLowerCase()) ?? `RECRUIT-${address.slice(2, 6).toUpperCase()}`;
}
