// ═══════════════════════════════════════════════════════════════
// Demo mode switch. ?demo=1 turns it on for the browser tab as a
// student; ?demo=instructor as the cohort's instructor. ?demo=0 or
// "Leave demo" turns it off. While on, the app talks to the simulated
// wallet and chain in mock-chain.ts instead of Base Sepolia.
// ═══════════════════════════════════════════════════════════════

const KEY = 'vanguard.demo';

/** Unit id of the cohort squad in the simulated chain. */
export const DEMO_SQUAD_ID = 2;

export type DemoRole = 'student' | 'instructor';

let active: boolean | null = null;
let role: DemoRole = 'student';

export function isDemo(): boolean {
	if (active !== null) return active;
	if (typeof window === 'undefined') return false;
	const param = new URLSearchParams(window.location.search).get('demo');
	try {
		if (param === '0') sessionStorage.removeItem(KEY);
		else if (param !== null) sessionStorage.setItem(KEY, param === 'instructor' ? 'instructor' : 'student');
		const stored = sessionStorage.getItem(KEY);
		active = stored !== null;
		role = stored === 'instructor' ? 'instructor' : 'student';
	} catch {
		active = param !== null && param !== '0';
		role = param === 'instructor' ? 'instructor' : 'student';
	}
	return active;
}

/** Who the visitor plays in demo mode. */
export function demoRole(): DemoRole {
	isDemo();
	return role;
}

export function leaveDemo(): void {
	try {
		sessionStorage.removeItem(KEY);
	} catch {
		// storage blocked; the reload without ?demo still leaves demo mode
	}
	active = false;
}
