import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { FieldValue } from "firebase-admin/firestore";

const getDb = () => admin.firestore();

/**
 * Seed callsign words (admin only, run once)
 */
export const seedCallsignWords = functions.https.onCall(async (data, context) => {
  // In production, verify admin auth
  // if (!context.auth?.token.admin) throw error

  const prefixes = [
    "CIPHER", "GHOST", "NOVA", "VIPER", "SHADOW", "PHOENIX", "STORM", "APEX",
    "RAVEN", "FALCON", "TITAN", "SPECTRE", "REAPER", "HAVOC", "BLAZE", "FROST",
    "THUNDER", "VECTOR", "PULSE", "DELTA", "OMEGA", "ZERO", "ECHO", "BRAVO",
    "ALPHA", "SIERRA", "TANGO", "WHISKEY", "FOXTROT", "ROMEO", "KILO", "LIMA",
    "MIKE", "OSCAR", "PAPA", "QUEBEC", "UNIFORM", "VICTOR", "YANKEE", "ZULU",
    "ATLAS", "SENTINEL", "WRAITH", "PHANTOM", "STRIKER", "VENOM", "TALON",
    "RAPTOR", "NOMAD", "ZEALOT", "ONYX", "COBALT", "CRIMSON", "AZURE", "JADE",
    "IRON", "STEEL", "CHROME", "NEON", "CYBER", "NEXUS", "PRISM", "VOLT",
    "SURGE", "FLUX", "CORE", "NODE", "MATRIX", "BINARY", "QUANTUM", "PLASMA",
    "PYRO", "CRYO", "HYDRA", "MEDUSA", "ORACLE", "SPHINX", "GRIFFIN", "MANTIS",
    "COBRA", "PYTHON", "SCORPION", "WOLF", "BEAR", "HAWK", "EAGLE", "LION",
    "TIGER", "PANTHER", "JAGUAR", "LYNX", "FOX", "HOUND", "SHARK", "BARRACUDA",
  ];

  const suffixes = [
    "7X4", "9K2", "3Z7", "1A8", "5M3", "2R6", "8P1", "4W9", "6Y5", "0T2",
    "1B7", "3C4", "5D9", "7E2", "9F6", "2G8", "4H1", "6J3", "8K5", "0L7",
    "1M9", "3N2", "5P4", "7Q6", "9R8", "2S1", "4T3", "6U5", "8V7", "0W9",
    "1X2", "3Y4", "5Z6", "7A8", "9B1", "2C3", "4D5", "6E7", "8F9", "0G2",
    "11X", "22Y", "33Z", "44A", "55B", "66C", "77D", "88E", "99F", "00G",
    "A1B", "C2D", "E3F", "G4H", "I5J", "K6L", "M7N", "O8P", "Q9R", "S0T",
    "X1X", "Y2Y", "Z3Z", "A4A", "B5B", "C6C", "D7D", "E8E", "F9F", "G0G",
    "1X1", "2Y2", "3Z3", "4A4", "5B5", "6C6", "7D7", "8E8", "9F9", "0G0",
    "K1X", "L2Y", "M3Z", "N4A", "P5B", "Q6C", "R7D", "S8E", "T9F", "U0G",
    "V1H", "W2I", "X3J", "Y4K", "Z5L", "A6M", "B7N", "C8O", "D9P", "E0Q",
  ];

  const batch = getDb().batch();

  for (const word of prefixes) {
    const ref = getDb().collection("callsignWords").doc();
    batch.set(ref, { word, type: "prefix" });
  }

  for (const word of suffixes) {
    const ref = getDb().collection("callsignWords").doc();
    batch.set(ref, { word, type: "suffix" });
  }

  await batch.commit();

  return { success: true, prefixes: prefixes.length, suffixes: suffixes.length };
});

/**
 * Seed demo data (admin only)
 */
export const seedDemoData = functions.https.onCall(async (data, context) => {
  // In production, verify admin auth

  const now = FieldValue.serverTimestamp();

  // Create company
  const companyRef = getDb().collection("units").doc("company_alpha");
  const companyChannelRef = getDb().collection("chatChannels").doc("channel_company");

  await companyRef.set({
    id: "company_alpha",
    type: "company",
    name: "Alpha Company",
    leaderId: "soldier_cpt",
    memberIds: [],
    childUnitIds: ["platoon_1", "platoon_2"],
    chatChannelId: "channel_company",
    maxSize: 100,
    createdAt: now,
    updatedAt: now,
  });

  await companyChannelRef.set({
    id: "channel_company",
    unitId: "company_alpha",
    type: "company_broadcast",
    name: "alpha-company",
    createdAt: now,
  });

  // Create platoon
  const platoonRef = getDb().collection("units").doc("platoon_1");
  const platoonChannelRef = getDb().collection("chatChannels").doc("channel_platoon_1");

  await platoonRef.set({
    id: "platoon_1",
    type: "platoon",
    name: "1st Platoon",
    leaderId: "soldier_lt",
    parentUnitId: "company_alpha",
    memberIds: [],
    childUnitIds: ["section_1"],
    chatChannelId: "channel_platoon_1",
    maxSize: 50,
    createdAt: now,
    updatedAt: now,
  });

  await platoonChannelRef.set({
    id: "channel_platoon_1",
    unitId: "platoon_1",
    type: "platoon_announce",
    name: "1st-platoon",
    createdAt: now,
  });

  // Create section
  const sectionRef = getDb().collection("units").doc("section_1");
  const sectionChannelRef = getDb().collection("chatChannels").doc("channel_section_1");

  await sectionRef.set({
    id: "section_1",
    type: "section",
    name: "1st Section",
    leaderId: "soldier_ssg",
    parentUnitId: "platoon_1",
    memberIds: [],
    childUnitIds: ["squad_alpha"],
    chatChannelId: "channel_section_1",
    maxSize: 25,
    createdAt: now,
    updatedAt: now,
  });

  await sectionChannelRef.set({
    id: "channel_section_1",
    unitId: "section_1",
    type: "section_announce",
    name: "1st-section",
    createdAt: now,
  });

  // Create squad
  const squadRef = getDb().collection("units").doc("squad_alpha");
  const squadChannelRef = getDb().collection("chatChannels").doc("channel_squad_alpha");

  await squadRef.set({
    id: "squad_alpha",
    type: "squad",
    name: "Alpha Squad",
    leaderId: "soldier_1",
    parentUnitId: "section_1",
    memberIds: ["soldier_1", "soldier_2", "soldier_3", "soldier_4", "soldier_5"],
    childUnitIds: [],
    chatChannelId: "channel_squad_alpha",
    maxSize: 10,
    createdAt: now,
    updatedAt: now,
  });

  await squadChannelRef.set({
    id: "channel_squad_alpha",
    unitId: "squad_alpha",
    type: "squad",
    name: "alpha-squad",
    createdAt: now,
  });

  // Create demo soldier (CIPHER-7X4)
  await getDb().collection("soldiers").doc("soldier_1").set({
    id: "soldier_1",
    walletAddress: "0x1234567890ABCDEF",
    callsign: "CIPHER-7X4",
    rank: "sgt",
    squadId: "squad_alpha",
    tasksCompleted: 47,
    xp: 78,
    vgrdEarned: 3450,
    votingPower: 10,
    enlistedAt: now,
    hasCompletedPLDC: true,
    hasCompletedOBC: false,
    createdAt: now,
    updatedAt: now,
  });

  // Create a bounty
  await getDb().collection("bounties").doc("bounty_1").set({
    id: "bounty_1",
    title: "OPERATION: PHOENIX RISING",
    description: "Launch V2 Protocol on Mainnet",
    creatorId: "soldier_cpt",
    totalAmount: 50000,
    remainingAmount: 33000,
    deadline: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
    status: "inProgress",
    skillTags: ["Solidity", "Security", "Testing"],
    createdAt: now,
    updatedAt: now,
  });

  return { success: true };
});
