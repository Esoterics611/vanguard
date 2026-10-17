// ═══════════════════════════════════════════════════════════════
// Deployed contract addresses (Base Sepolia testnet)
// Source: contracts/deployed/base-sepolia.json
// Last deployed: 2026-04-27 (engine + verticals refactor)
// ═══════════════════════════════════════════════════════════════

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

export const addresses: ContractAddresses = {
	VGRDToken: '0x2Ef78A107b20eb4263448e70E643bA9621657493',
	Treasury: '0x55B811D87CFBbb149ea436BD5F57671602D91d54',
	ArmyRegistry: '0xBf3BEE33090fb5f9b147a72cAac6f4f44CE1F270',
	RankManager: '0xcbB1fB5E862D7e339619B55fE2E58dA6f35bc0f2',
	RewardPool: '0x840E56bAA0774b41eec0448F81a802281799429C',
	TaskRegistry: '0xd5832E767C76FbCBbee6F071b80B7F78Ad5F7e5A',
	BountyEscrow: '0x19F1A7F9d4A3d36BEAF2e4fb5A5E42F3f080B143',
	VanguardDAO: '0x1F6FB4dB93691747420d0fb9d397E4f97443A7Af',
};
