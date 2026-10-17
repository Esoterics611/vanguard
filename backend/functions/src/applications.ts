import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { FieldValue } from "firebase-admin/firestore";

const getDb = () => admin.firestore();

interface ReviewApplicationRequest {
  applicationId: string;
  accepted: boolean;
}

/**
 * Review a squad application (accept/reject)
 * If accepted, calls enlistSoldier internally
 */
export const reviewApplication = functions.https.onCall(
  async (data: ReviewApplicationRequest, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Must be authenticated"
      );
    }

    const { applicationId, accepted } = data;
    const reviewerId = context.auth.uid;

    // Get application
    const appDoc = await getDb()
      .collection("squadApplications")
      .doc(applicationId)
      .get();

    if (!appDoc.exists) {
      throw new functions.https.HttpsError(
        "not-found",
        "Application not found"
      );
    }

    const application = appDoc.data()!;

    // Verify reviewer is squad leader
    const squadDoc = await getDb()
      .collection("units")
      .doc(application.squadId)
      .get();

    if (!squadDoc.exists) {
      throw new functions.https.HttpsError("not-found", "Squad not found");
    }

    const squad = squadDoc.data()!;
    if (squad.leaderId !== reviewerId && squad.secondInCommandId !== reviewerId) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Only squad leaders can review applications"
      );
    }

    // Check if already reviewed
    if (application.status !== "pending") {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Application already reviewed"
      );
    }

    const now = FieldValue.serverTimestamp();

    if (accepted) {
      // Check squad capacity
      if (squad.memberIds && squad.memberIds.length >= squad.maxSize) {
        throw new functions.https.HttpsError(
          "resource-exhausted",
          "Squad is at capacity"
        );
      }

      // Generate callsign for new soldier
      const callsign = await generateCallsign();

      // Use transaction for atomic updates
      await getDb().runTransaction(async (transaction) => {
        // Create soldier record
        // Note: applicantId would need to be stored or derived from walletAddress
        const soldierRef = getDb().collection("soldiers").doc();

        transaction.set(soldierRef, {
          id: soldierRef.id,
          walletAddress: application.walletAddress,
          callsign,
          rank: "pvt",
          squadId: application.squadId,
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
        transaction.update(getDb().collection("units").doc(application.squadId), {
          memberIds: FieldValue.arrayUnion(soldierRef.id),
          updatedAt: now,
        });

        // Update application status
        transaction.update(getDb().collection("squadApplications").doc(applicationId), {
          status: "accepted",
          reviewedById: reviewerId,
          reviewedAt: now,
          updatedAt: now,
          assignedSoldierId: soldierRef.id,
        });
      });

      return { success: true, status: "accepted" };
    } else {
      // Reject application
      await getDb().collection("squadApplications").doc(applicationId).update({
        status: "rejected",
        reviewedById: reviewerId,
        reviewedAt: now,
        updatedAt: now,
      });

      return { success: true, status: "rejected" };
    }
  }
);

/**
 * Internal: Generate unique callsign
 */
async function generateCallsign(): Promise<string> {
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

  const prefix = prefixes[Math.floor(Math.random() * prefixes.length)];
  const random = Math.floor(Math.random() * 10000).toString().padStart(4, "0");
  return `${prefix}-${random}`;
}
