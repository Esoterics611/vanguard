import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { FieldValue } from "firebase-admin/firestore";

const getDb = () => admin.firestore();

interface SplitSquadRequest {
  squadId: string;
  newSquadLeaderId: string;
  squadAMemberIds: string[];
  squadBMemberIds: string[];
}

/**
 * Split a squad when it reaches 11+ members
 * Creates a new section with two squads
 */
export const splitSquad = functions.https.onCall(
  async (data: SplitSquadRequest, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Must be authenticated"
      );
    }

    const { squadId, newSquadLeaderId, squadAMemberIds, squadBMemberIds } = data;
    const promoterId = context.auth.uid;

    // Verify promoter is CPT
    const promoterDoc = await getDb().collection("soldiers").doc(promoterId).get();
    if (!promoterDoc.exists || promoterDoc.data()!.rank !== "cpt") {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Only Captains can authorize squad splits"
      );
    }

    // Get original squad
    const squadDoc = await getDb().collection("units").doc(squadId).get();
    if (!squadDoc.exists) {
      throw new functions.https.HttpsError("not-found", "Squad not found");
    }
    const originalSquad = squadDoc.data()!;

    if (originalSquad.type !== "squad") {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Can only split squads"
      );
    }

    // Validate member distribution
    const totalMembers = squadAMemberIds.length + squadBMemberIds.length;
    if (totalMembers !== 11) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Total members must be 11 for split"
      );
    }

    if (!squadAMemberIds.includes(originalSquad.leaderId)) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Original leader must be in Squad A"
      );
    }

    if (!squadBMemberIds.includes(newSquadLeaderId)) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "New leader must be in Squad B"
      );
    }

    const now = FieldValue.serverTimestamp();
    const originalLeaderId = originalSquad.leaderId;

    // Use transaction for atomic updates
    return await getDb().runTransaction(async (transaction) => {
      // 1. Create Section
      const sectionRef = getDb().collection("units").doc();
      const sectionChannelRef = getDb().collection("chatChannels").doc();

      transaction.set(sectionRef, {
        id: sectionRef.id,
        type: "section",
        name: `${originalSquad.name.replace(/ Squad$/i, "")} Section`,
        leaderId: originalLeaderId,
        parentUnitId: originalSquad.parentUnitId,
        memberIds: [...squadAMemberIds, ...squadBMemberIds],
        childUnitIds: [squadId],
        chatChannelId: sectionChannelRef.id,
        maxSize: 25,
        createdAt: now,
        updatedAt: now,
      });

      transaction.set(sectionChannelRef, {
        id: sectionChannelRef.id,
        unitId: sectionRef.id,
        type: "section_announce",
        name: `${originalSquad.name.replace(/ Squad$/i, "").toLowerCase()}-section`,
        createdAt: now,
      });

      // 2. Create Squad B
      const squadBRef = getDb().collection("units").doc();
      const squadBChannelRef = getDb().collection("chatChannels").doc();

      transaction.set(squadBRef, {
        id: squadBRef.id,
        type: "squad",
        name: `${originalSquad.name} B`,
        leaderId: newSquadLeaderId,
        parentUnitId: sectionRef.id,
        memberIds: squadBMemberIds,
        childUnitIds: [],
        chatChannelId: squadBChannelRef.id,
        maxSize: 10,
        createdAt: now,
        updatedAt: now,
      });

      transaction.set(squadBChannelRef, {
        id: squadBChannelRef.id,
        unitId: squadBRef.id,
        type: "squad",
        name: `${originalSquad.name.toLowerCase()}-b`,
        createdAt: now,
      });

      // 3. Update original squad (becomes Squad A)
      transaction.update(getDb().collection("units").doc(squadId), {
        name: `${originalSquad.name} A`,
        parentUnitId: sectionRef.id,
        memberIds: squadAMemberIds,
        updatedAt: now,
      });

      // 4. Update section childUnitIds
      transaction.update(sectionRef, {
        childUnitIds: [squadId, squadBRef.id],
      });

      // 5. Update Squad B members' squadId
      for (const memberId of squadBMemberIds) {
        transaction.update(getDb().collection("soldiers").doc(memberId), {
          squadId: squadBRef.id,
          updatedAt: now,
        });
      }

      // 6. Promote original leader to SSG
      const originalLeaderDoc = await getDb()
        .collection("soldiers")
        .doc(originalLeaderId)
        .get();

      transaction.update(getDb().collection("soldiers").doc(originalLeaderId), {
        rank: "ssg",
        votingPower: 15,
        squadId: null, // Section leaders don't belong to a squad
        updatedAt: now,
      });

      // Record promotion
      const promotionRef = getDb().collection("promotions").doc();
      transaction.set(promotionRef, {
        soldierId: originalLeaderId,
        fromRank: originalLeaderDoc.data()!.rank,
        toRank: "ssg",
        promotedById: promoterId,
        reason: "Section formation - squad split",
        createdAt: now,
      });

      return {
        success: true,
        sectionId: sectionRef.id,
        squadAId: squadId,
        squadBId: squadBRef.id,
      };
    });
  }
);

/**
 * Firestore trigger: Check if squad should split
 */
export const checkSplitThreshold = functions.firestore
  .document("units/{unitId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Only check squads
    if (after.type !== "squad") return;

    const membersBefore = before.memberIds?.length || 0;
    const membersAfter = after.memberIds?.length || 0;

    // Check if crossed threshold
    if (membersBefore < 10 && membersAfter >= 10) {
      // Notify leaders that squad is ready for split
      const leaderDoc = await getDb()
        .collection("soldiers")
        .doc(after.leaderId)
        .get();

      if (leaderDoc.exists) {
        // Could send push notification here
        console.log(
          `Squad ${after.name} (${context.params.unitId}) is ready for split - ${membersAfter} members`
        );
      }
    }

    return null;
  });
