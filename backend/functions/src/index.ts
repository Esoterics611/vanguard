import * as admin from "firebase-admin";
import { enlistSoldier, generateCallsign, quickStart, connectWallet } from "./soldiers";
import { promoteSoldier, canPromote } from "./promotions";
import { splitSquad, checkSplitThreshold } from "./units";
import { reviewApplication } from "./applications";
import { seedCallsignWords, seedDemoData } from "./seed";

admin.initializeApp();

// ============ SOLDIER FUNCTIONS ============
export { enlistSoldier, generateCallsign, quickStart, connectWallet };

// ============ PROMOTION FUNCTIONS ============
export { promoteSoldier, canPromote };

// ============ UNIT FUNCTIONS ============
export { splitSquad, checkSplitThreshold };

// ============ APPLICATION FUNCTIONS ============
export { reviewApplication };

// ============ SEED FUNCTIONS (Admin only) ============
export { seedCallsignWords, seedDemoData };
