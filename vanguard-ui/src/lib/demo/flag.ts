// ═══════════════════════════════════════════════════════════════
// Demo mode switch. /join?demo=1 turns it on for the browser tab;
// ?demo=0 or "Leave demo" turns it off. While on, the app talks to the
// simulated wallet and chain in mock-chain.ts instead of Base Sepolia.
// ═══════════════════════════════════════════════════════════════

const KEY = 'vanguard.demo';

/** Unit id of the cohort squad in the simulated chain. */
export const DEMO_SQUAD_ID = 2;

let active: boolean | null = null;

export function isDemo(): boolean {
	if (active !== null) return active;
	if (typeof window === 'undefined') return false;
	const param = new URLSearchParams(window.location.search).get('demo');
	try {
		if (param === '0') sessionStorage.removeItem(KEY);
		else if (param !== null) sessionStorage.setItem(KEY, '1');
		active = sessionStorage.getItem(KEY) === '1';
	} catch {
		active = param !== null && param !== '0';
	}
	return active;
}

export function leaveDemo(): void {
	try {
		sessionStorage.removeItem(KEY);
	} catch {
		// storage blocked; the reload without ?demo still leaves demo mode
	}
	active = false;
}
