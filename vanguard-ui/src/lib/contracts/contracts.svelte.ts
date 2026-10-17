// ═══════════════════════════════════════════════════════════════
// Typed contract factory functions.
//
// Each `getX(signerOrProvider)` returns an ethers.Contract bound to
// the deployed address and the compiled ABI for contract X.
//
// ABI source: contracts/artifacts/contracts/<X>.sol/<X>.json
// (we keep the full Hardhat artifact and read .abi at construction time)
// ═══════════════════════════════════════════════════════════════

import { Contract, type ContractRunner, type InterfaceAbi } from 'ethers';
import { addresses } from './addresses';

import VGRDTokenArtifact from './abis/VGRDToken.json';
import TreasuryArtifact from './abis/Treasury.json';
import ArmyRegistryArtifact from './abis/ArmyRegistry.json';
import RankManagerArtifact from './abis/RankManager.json';
import RewardPoolArtifact from './abis/RewardPool.json';
import TaskRegistryArtifact from './abis/TaskRegistry.json';
import BountyEscrowArtifact from './abis/BountyEscrow.json';
import VanguardDAOArtifact from './abis/VanguardDAO.json';

interface HardhatArtifact {
	abi: InterfaceAbi;
}

const abis = {
	VGRDToken: (VGRDTokenArtifact as HardhatArtifact).abi,
	Treasury: (TreasuryArtifact as HardhatArtifact).abi,
	ArmyRegistry: (ArmyRegistryArtifact as HardhatArtifact).abi,
	RankManager: (RankManagerArtifact as HardhatArtifact).abi,
	RewardPool: (RewardPoolArtifact as HardhatArtifact).abi,
	TaskRegistry: (TaskRegistryArtifact as HardhatArtifact).abi,
	BountyEscrow: (BountyEscrowArtifact as HardhatArtifact).abi,
	VanguardDAO: (VanguardDAOArtifact as HardhatArtifact).abi,
} as const;

export function getVGRDToken(runner: ContractRunner): Contract {
	return new Contract(addresses.VGRDToken, abis.VGRDToken, runner);
}

export function getTreasury(runner: ContractRunner): Contract {
	return new Contract(addresses.Treasury, abis.Treasury, runner);
}

export function getArmyRegistry(runner: ContractRunner): Contract {
	return new Contract(addresses.ArmyRegistry, abis.ArmyRegistry, runner);
}

export function getRankManager(runner: ContractRunner): Contract {
	return new Contract(addresses.RankManager, abis.RankManager, runner);
}

export function getRewardPool(runner: ContractRunner): Contract {
	return new Contract(addresses.RewardPool, abis.RewardPool, runner);
}

export function getTaskRegistry(runner: ContractRunner): Contract {
	return new Contract(addresses.TaskRegistry, abis.TaskRegistry, runner);
}

export function getBountyEscrow(runner: ContractRunner): Contract {
	return new Contract(addresses.BountyEscrow, abis.BountyEscrow, runner);
}

export function getVanguardDAO(runner: ContractRunner): Contract {
	return new Contract(addresses.VanguardDAO, abis.VanguardDAO, runner);
}
