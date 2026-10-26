// ═══════════════════════════════════════════════════════════════
// RankManager.canPromote, in words: who may promote whom, so the
// instructor page can say why a promotion isn't available yet.
// The contract stays the authority; the page only offers a promotion
// when canPromote returns true.
// ═══════════════════════════════════════════════════════════════

import { RANK_META } from '$lib/types';
import { rankCode } from '$lib/contracts/chain';

const CPT = 11;
const SGT = 5;

export function rankLabel(rankIndex: number): string {
	return RANK_META[rankCode(rankIndex)].label;
}

/** Lowest promoter rank the contract accepts for a promotion to `target`. */
export function minPromoterRank(target: number): number {
	if (target === 2) return 6; // to PV2: staff sergeant or above
	if (target === 3 || target === 4) return 9; // to PFC or CPL: second lieutenant or above
	return CPT; // to SGT and above: captain only
}

/** The highest rank a promoter at `promoterRank` can promote someone to. */
export function promotesUpTo(promoterRank: number): number | null {
	if (promoterRank >= CPT) return CPT;
	if (promoterRank >= 9) return 4;
	if (promoterRank >= 6) return 2;
	return null;
}

/** Why a promotion to the next rank isn't possible yet, or null if nothing stands in the way. */
export function promotionBlocker(opts: {
	promoterRank: number;
	memberRank: number;
	pldc: boolean;
	lastPromotion: Date | null;
	cooldownSeconds: number;
	now?: Date;
}): string | null {
	const target = opts.memberRank + 1;
	if (target > CPT) return 'Already at the top rank.';
	const needed = minPromoterRank(target);
	if (opts.promoterRank < needed) return `Promotion to ${rankLabel(target)} needs a ${rankLabel(needed)} or command.`;
	if (target === SGT && !opts.pldc) return 'Needs the leadership course (PLDC) recorded first.';
	const now = opts.now ?? new Date();
	if (opts.lastPromotion) {
		const eligible = new Date(opts.lastPromotion.getTime() + opts.cooldownSeconds * 1000);
		if (now < eligible) return `Eligible again ${eligible.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}.`;
	}
	return null;
}
