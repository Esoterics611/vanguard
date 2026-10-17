const hre = require("hardhat");
const addresses = require("../deployed-addresses.json");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Checking soldier status for:", deployer.address);

  const registry = await hre.ethers.getContractAt("ArmyRegistry", addresses.ArmyRegistry);

  const isEnlisted = await registry.isEnlisted(deployer.address);
  console.log("Is enlisted:", isEnlisted);

  if (isEnlisted) {
    const soldier = await registry.getSoldier(deployer.address);
    console.log("Soldier details:");
    console.log("  - Callsign:", soldier.callsign);
    console.log("  - Rank:", soldier.rank.toString(), "(1=PVT)");
    console.log("  - Unit ID:", soldier.unitId.toString());
    console.log("  - Tasks completed:", soldier.tasksCompleted.toString());
    console.log("  - Total earned:", hre.ethers.formatEther(soldier.totalEarned), "VGRD");
    console.log("  - Enlisted at:", new Date(Number(soldier.enlistedAt) * 1000).toISOString());
  }

  const unit = await registry.getUnit(1);
  console.log("\nSquad 1 details:");
  console.log("  - Member count:", unit.memberCount.toString());
  console.log("  - Leader:", unit.leader);
  console.log("  - Active:", unit.active);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
