import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { FieldValue } from "firebase-admin/firestore";

const getDb = () => admin.firestore();

interface EnlistRequest {
  walletAddress: string;
  squadId: string;
}

/**
 * Enlist a new soldier (create soldier record with generated callsign)
 */
export const enlistSoldier = functions.https.onCall(
  async (data: EnlistRequest, context) => {
    // Verify authenticated
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Must be authenticated to enlist"
      );
    }

    const { walletAddress, squadId } = data;

    // Check if already enlisted
    const existingDoc = await getDb()
      .collection("soldiers")
      .where("walletAddress", "==", walletAddress)
      .get();

    if (!existingDoc.empty) {
      throw new functions.https.HttpsError(
        "already-exists",
        "Wallet already enlisted"
      );
    }

    // Verify squad exists and has room
    const squadDoc = await getDb().collection("units").doc(squadId).get();
    if (!squadDoc.exists) {
      throw new functions.https.HttpsError("not-found", "Squad not found");
    }

    const squad = squadDoc.data()!;
    if (squad.memberIds && squad.memberIds.length >= squad.maxSize) {
      throw new functions.https.HttpsError(
        "resource-exhausted",
        "Squad is at capacity"
      );
    }

    // Generate unique callsign
    const callsign = await generateUniqueCallsign();

    // Create soldier
    const soldierId = context.auth.uid;
    const now = FieldValue.serverTimestamp();

    const soldierData = {
      id: soldierId,
      walletAddress,
      callsign,
      rank: "pvt",
      squadId,
      tasksCompleted: 0,
      xp: 0,
      vgrdEarned: 0,
      votingPower: 1,
      enlistedAt: now,
      hasCompletedPLDC: false,
      hasCompletedOBC: false,
      createdAt: now,
      updatedAt: now,
    };

    await getDb().collection("soldiers").doc(soldierId).set(soldierData);

    // Add to squad members
    await getDb()
      .collection("units")
      .doc(squadId)
      .update({
        memberIds: FieldValue.arrayUnion(soldierId),
        updatedAt: now,
      });

    return { soldierId, callsign };
  }
);

/**
 * Generate a unique callsign
 */
export const generateCallsign = functions.https.onCall(async () => {
  return { callsign: await generateUniqueCallsign() };
});

/**
 * Quick start - sign in anonymously + create soldier + join default squad
 */
export const quickStart = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Must be authenticated");
  }

  const uid = context.auth.uid;
  const db = getDb();

  // Check if already has soldier
  const existing = await db.collection("soldiers").doc(uid).get();
  if (existing.exists) {
    return { soldierId: uid, callsign: existing.data()!.callsign, isNew: false };
  }

  // Generate callsign
  const callsign = await generateUniqueCallsign();
  const now = FieldValue.serverTimestamp();

  // Create soldier in default squad
  await db.collection("soldiers").doc(uid).set({
    id: uid,
    walletAddress: null,
    callsign,
    rank: "pvt",
    squadId: "squad_alpha",
    tasksCompleted: 0,
    xp: 0,
    vgrdEarned: 0,
    votingPower: 1,
    enlistedAt: now,
    hasCompletedPLDC: false,
    hasCompletedOBC: false,
    createdAt: now,
    updatedAt: now,
  });

  // Add to squad
  await db.collection("units").doc("squad_alpha").update({
    memberIds: FieldValue.arrayUnion(uid),
    updatedAt: now,
  });

  return { soldierId: uid, callsign, isNew: true };
});

/**
 * Connect wallet - create soldier with wallet address
 */
export const connectWallet = functions.https.onCall(async (data: { walletAddress: string }, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Must be authenticated");
  }

  const uid = context.auth.uid;
  const db = getDb();
  const { walletAddress } = data;

  if (!walletAddress || typeof walletAddress !== "string") {
    throw new functions.https.HttpsError("invalid-argument", "Wallet address required");
  }

  // Check if already has soldier
  const existing = await db.collection("soldiers").doc(uid).get();
  if (existing.exists) {
    // Update wallet address if not set
    const soldierData = existing.data()!;
    if (!soldierData.walletAddress) {
      await db.collection("soldiers").doc(uid).update({
        walletAddress,
        updatedAt: FieldValue.serverTimestamp(),
      });
    }
    return { soldierId: uid, callsign: soldierData.callsign, isNew: false };
  }

  // Check if wallet already used by another soldier
  const walletCheck = await db
    .collection("soldiers")
    .where("walletAddress", "==", walletAddress)
    .get();

  if (!walletCheck.empty) {
    throw new functions.https.HttpsError(
      "already-exists",
      "Wallet already linked to another soldier"
    );
  }

  // Generate callsign
  const callsign = await generateUniqueCallsign();
  const now = FieldValue.serverTimestamp();

  // Create soldier in default squad
  await db.collection("soldiers").doc(uid).set({
    id: uid,
    walletAddress,
    callsign,
    rank: "pvt",
    squadId: "squad_alpha",
    tasksCompleted: 0,
    xp: 0,
    vgrdEarned: 0,
    votingPower: 1,
    enlistedAt: now,
    hasCompletedPLDC: false,
    hasCompletedOBC: false,
    createdAt: now,
    updatedAt: now,
  });

  // Add to squad
  await db.collection("units").doc("squad_alpha").update({
    memberIds: FieldValue.arrayUnion(uid),
    updatedAt: now,
  });

  return { soldierId: uid, callsign, isNew: true };
});

/**
 * Internal: Generate unique callsign from word lists
 */
async function generateUniqueCallsign(): Promise<string> {
  const prefixesSnap = await getDb()
    .collection("callsignWords")
    .where("type", "==", "prefix")
    .get();

  const suffixesSnap = await getDb()
    .collection("callsignWords")
    .where("type", "==", "suffix")
    .get();

  const prefixes = prefixesSnap.docs.map((d) => d.data().word);
  const suffixes = suffixesSnap.docs.map((d) => d.data().word);

  // Try up to 100 times to find unique callsign
  for (let i = 0; i < 100; i++) {
    const prefix = prefixes[Math.floor(Math.random() * prefixes.length)];
    const suffix = suffixes[Math.floor(Math.random() * suffixes.length)];
    const callsign = `${prefix}-${suffix}`;

    const existing = await getDb()
      .collection("soldiers")
      .where("callsign", "==", callsign)
      .get();

    if (existing.empty) {
      return callsign;
    }
  }

  // Fallback with random numbers
  const prefix = prefixes[Math.floor(Math.random() * prefixes.length)];
  const random = Math.floor(Math.random() * 10000)
    .toString()
    .padStart(4, "0");
  return `${prefix}-${random}`;
}
