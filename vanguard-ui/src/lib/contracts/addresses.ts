// ═══════════════════════════════════════════════════════════════
// Where the contracts are. Read from the deployment record,
// contracts/deployed/base-sepolia.json, so a redeploy only updates
// that file. The record also carries each cohort's squad, written by
// contracts/scripts/academy-setup.js.
//
// For rehearsals on a local chain, a build can point elsewhere:
// VITE_DEPLOYMENT (a deployment record as JSON) and VITE_RPC_URL.
// ═══════════════════════════════════════════════════════════════

import baseSepolia from '../../../../contracts/deployed/base-sepolia.json';

/** Base Sepolia testnet chain id (decimal). */
export const BASE_SEPOLIA_CHAIN_ID = 84532;

/** Base Sepolia testnet chain id (hex, for wallet RPC calls). */
export const BASE_SEPOLIA_CHAIN_ID_HEX = '0x14a34';

/** Human-readable network name. */
export const BASE_SEPOLIA_NAME = 'Base Sepolia';

/** Default RPC endpoint for adding the chain to a wallet. */
export const BASE_SEPOLIA_RPC_URL = 'https://sepolia.base.org';

/** Block explorer URL. */
export const BASE_SEPOLIA_EXPLORER_URL = 'https://sepolia.basescan.org';

/** RPC endpoint for reads, when a build overrides the public ones. */
export const RPC_URL_OVERRIDE: string | null = import.meta.env.VITE_RPC_URL || null;

export interface ContractAddresses {
	VGRDToken: `0x${string}`;
	Treasury: `0x${string}`;
	ArmyRegistry: `0x${string}`;
	RankManager: `0x${string}`;
	RewardPool: `0x${string}`;
	TaskRegistry: `0x${string}`;
	BountyEscrow: `0x${string}`;
	VanguardDAO: `0x${string}`;
}

/** A cohort as set up on chain by the setup script. */
export interface CohortRecord {
	squadId: number;
	instructor?: string;
}

export interface Deployment {
	network: string;
	chainId: number;
	addresses: ContractAddresses;
	academy?: Record<string, CohortRecord>;
}

export const deployment: Deployment = import.meta.env.VITE_DEPLOYMENT
	? JSON.parse(import.meta.env.VITE_DEPLOYMENT)
	: (baseSepolia as Deployment);

export const addresses: ContractAddresses = deployment.addresses;
