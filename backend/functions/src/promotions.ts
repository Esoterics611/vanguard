import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { FieldValue } from "firebase-admin/firestore";

const getDb = () => admin.firestore();

// Rank hierarchy (index = authority level)
const RANKS = [
  "guest",
  "pvt",
  "pv2",
  "pfc",
  "cpl",
  "sgt",
  "ssg",
  "sfc",
  "firstSgt",
  "secondLt",
  "firstLt",
  "cpt",
];

const RANK_CONFIG: Record<
  string,
  { votingPower: number; tokenMultiplier: number }
> = {
  pvt: { votingPower: 1, tokenMultiplier: 1.0 },
  pv2: { votingPower: 2, tokenMultiplier: 1.2 },
  pfc: { votingPower: 3, tokenMultiplier: 1.5 },
  cpl: { votingPower: 5, tokenMultiplier: 2.0 },
  sgt: { votingPower: 10, tokenMultiplier: 3.0 },
  ssg: { votingPower: 15, tokenMultiplier: 4.0 },
  sfc: { votingPower: 20, tokenMultiplier: 5.0 },
  firstSgt: { votingPower: 25, tokenMultiplier: 6.0 },
  secondLt: { votingPower: 30, tokenMultiplier: 8.0 },
  firstLt: { votingPower: 35, tokenMultiplier: 10.0 },
  cpt: { votingPower: 50, tokenMultiplier: 15.0 },
};

interface PromoteRequest {
  targetSoldierId: string;
  newRank: string;
  reason?: string;
}

interface CanPromoteRequest {
  targetSoldierId: string;
  newRank: string;
}

/**
 * Check if a promotion is allowed
 */
export const canPromote = functions.https.onCall(
  async (data: CanPromoteRequest, context) => {
    if (!context.auth) {
      return { allowed: false, reason: "Not authenticated" };
    }

    const { targetSoldierId, newRank } = data;
    const promoterId = context.auth.uid;

    return await checkPromotionAuthority(promoterId, targetSoldierId, newRank);
  }
);

/**
 * Execute a promotion
 */
export const promoteSoldier = functions.https.onCall(
  async (data: PromoteRequest, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Must be authenticated"
      );
    }

    const { targetSoldierId, newRank, reason } = data;
    const promoterId = context.auth.uid;

    // Check authority
    const check = await checkPromotionAuthority(
      promoterId,
      targetSoldierId,
      newRank
    );
    if (!check.allowed) {
      throw new functions.https.HttpsError(
        "permission-denied",
        check.reason || "Promotion not allowed"
      );
    }

    // Get current soldier data
    const targetDoc = await getDb().collection("soldiers").doc(targetSoldierId).get();
    const targetData = targetDoc.data()!;
    const fromRank = targetData.rank;

    const now = FieldValue.serverTimestamp();
    const rankConfig = RANK_CONFIG[newRank];

    // Update soldier rank
    await getDb()
      .collection("soldiers")
      .doc(targetSoldierId)
      .update({
        rank: newRank,
        votingPower: rankConfig.votingPower,
        updatedAt: now,
      });

    // Record promotion in audit log
    await getDb().collection("promotions").add({
      soldierId: targetSoldierId,
      fromRank,
      toRank: newRank,
      promotedById: promoterId,
      reason: reason || null,
      createdAt: now,
    });

    return { success: true, fromRank, toRank: newRank };
  }
);

/**
 * Internal: Check promotion authority matrix
 */
async function checkPromotionAuthority(
  promoterId: string,
  targetSoldierId: string,
  newRank: string
): Promise<{ allowed: boolean; reason?: string }> {
  // Get promoter
  const promoterDoc = await getDb().collection("soldiers").doc(promoterId).get();
  if (!promoterDoc.exists) {
    return { allowed: false, reason: "Promoter not found" };
  }
  const promoter = promoterDoc.data()!;
  const promoterRankIndex = RANKS.indexOf(promoter.rank);

  // Get target
  const targetDoc = await getDb().collection("soldiers").doc(targetSoldierId).get();
  if (!targetDoc.exists) {
    return { allowed: false, reason: "Target soldier not found" };
  }
  const target = targetDoc.data()!;
  const currentRankIndex = RANKS.indexOf(target.rank);
  const newRankIndex = RANKS.indexOf(newRank);

  // Can't demote
  if (newRankIndex <= currentRankIndex) {
    return { allowed: false, reason: "Cannot demote or promote to same rank" };
  }

  // Check one rank at a time (except special cases)
  if (newRankIndex > currentRankIndex + 1) {
    const isUnitSplitPromotion =
      (target.rank === "sgt" && newRank === "ssg") ||
      (target.rank === "ssg" && newRank === "secondLt");
    if (!isUnitSplitPromotion) {
      return { allowed: false, reason: "Can only promote one rank at a time" };
    }
  }

  // Promotion authority matrix
  switch (newRank) {
    case "pv2":
      // SSG+ can promote PVT → PV2
      if (promoterRankIndex >= RANKS.indexOf("ssg")) {
        return { allowed: true };
      }
      return { allowed: false, reason: "Must be SSG or higher to promote to PV2" };

    case "pfc":
    case "cpl":
      // 2LT+ can promote to PFC/CPL
      if (promoterRankIndex >= RANKS.indexOf("secondLt")) {
        return { allowed: true };
      }
      return { allowed: false, reason: "Must be 2LT or higher" };

    case "sgt":
      // Requires PLDC + CPT approval
      if (!target.hasCompletedPLDC) {
        return { allowed: false, reason: "Target must complete PLDC training" };
      }
      if (promoterRankIndex >= RANKS.indexOf("cpt")) {
        return { allowed: true };
      }
      return { allowed: false, reason: "Must be CPT to promote to SGT" };

    case "ssg":
    case "secondLt":
      // Unit split promotions - CPT only
      if (promoterRankIndex >= RANKS.indexOf("cpt")) {
        return { allowed: true };
      }
      return { allowed: false, reason: "Must be CPT" };

    case "sfc":
      // Appointed as Platoon 2IC
      if (promoterRankIndex >= RANKS.indexOf("secondLt")) {
        return { allowed: true };
      }
      return { allowed: false, reason: "Must be Platoon Leader" };

    case "firstSgt":
      // Appointed as Company 2IC
      if (promoter.rank === "cpt") {
        return { allowed: true };
      }
      return { allowed: false, reason: "Must be CPT" };

    case "firstLt":
      // Requires OBC + CPT approval
      if (!target.hasCompletedOBC) {
        return { allowed: false, reason: "Target must complete OBC training" };
      }
      if (promoter.rank === "cpt") {
        return { allowed: true };
      }
      return { allowed: false, reason: "Must be CPT" };

    case "cpt":
      return { allowed: false, reason: "CPT promotion requires company formation" };

    default:
      return { allowed: false, reason: "Invalid rank" };
  }
}
