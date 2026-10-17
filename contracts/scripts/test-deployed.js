const hre = require("hardhat");
const addresses = require("../deployed-addresses.json");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Testing with account:", deployer.address);
  console.log("Network:", hre.network.name);
  console.log("\n========== VANGUARD CONTRACT TESTS ==========\n");

  let passed = 0;
  let failed = 0;

  // Helper function
  function test(name, condition) {
    if (condition) {
      console.log(`✅ PASS: ${name}`);
      passed++;
    } else {
      console.log(`❌ FAIL: ${name}`);
      failed++;
    }
  }

  try {
    // 1. Test VGRDToken
    console.log("\n--- VGRDToken Tests ---");
    const token = await hre.ethers.getContractAt("VGRDToken", addresses.VGRDToken);

    const name = await token.name();
    test("Token name is 'Vanguard Token'", name === "Vanguard Token");

    const symbol = await token.symbol();
    test("Token symbol is 'VGRD'", symbol === "VGRD");

    const totalSupply = await token.totalSupply();
    test("Total supply is 1 billion", totalSupply === hre.ethers.parseEther("1000000000"));

    const deployerBalance = await token.balanceOf(deployer.address);
    console.log(`   Deployer balance: ${hre.ethers.formatEther(deployerBalance)} VGRD`);
    test("Deployer has tokens", deployerBalance > 0n);

    // 2. Test Treasury
    console.log("\n--- Treasury Tests ---");
    const treasury = await hre.ethers.getContractAt("Treasury", addresses.Treasury);

    const treasuryBalance = await token.balanceOf(addresses.Treasury);
    console.log(`   Treasury balance: ${hre.ethers.formatEther(treasuryBalance)} VGRD`);
    test("Treasury has 250M VGRD", treasuryBalance === hre.ethers.parseEther("250000000"));

    // 3. Test RewardPool
    console.log("\n--- RewardPool Tests ---");
    const rewardPool = await hre.ethers.getContractAt("RewardPool", addresses.RewardPool);

    const poolBalance = await token.balanceOf(addresses.RewardPool);
    console.log(`   RewardPool balance: ${hre.ethers.formatEther(poolBalance)} VGRD`);
    test("RewardPool has 400M VGRD", poolBalance === hre.ethers.parseEther("400000000"));

    // 4. Test ArmyRegistry
    console.log("\n--- ArmyRegistry Tests ---");
    const registry = await hre.ethers.getContractAt("ArmyRegistry", addresses.ArmyRegistry);

    const totalUnits = await registry.totalUnits();
    console.log(`   Total units: ${totalUnits}`);
    test("Default squad exists", totalUnits >= 1n);

    const unit1 = await registry.getUnit(1);
    test("Unit 1 is a squad", unit1.unitType === 0n); // SQUAD = 0
    test("Unit 1 is active", unit1.active === true);

    // 5. Test RankManager
    console.log("\n--- RankManager Tests ---");
    const rankManager = await hre.ethers.getContractAt("RankManager", addresses.RankManager);

    // Test multipliers
    const pvtMultiplier = await rankManager.MULTIPLIERS(1); // PVT
    test("PVT multiplier is 100 (1.0x)", pvtMultiplier === 100n);

    const cptMultiplier = await rankManager.MULTIPLIERS(11); // CPT
    test("CPT multiplier is 1500 (15.0x)", cptMultiplier === 1500n);

    // Test voting power
    const sgtVotingPower = await rankManager.VOTING_POWER(5); // SGT
    test("SGT voting power is 10", sgtVotingPower === 10n);

    // 6. Test TaskRegistry
    console.log("\n--- TaskRegistry Tests ---");
    const taskRegistry = await hre.ethers.getContractAt("TaskRegistry", addresses.TaskRegistry);

    const nextObjectiveId = await taskRegistry.nextObjectiveId();
    const nextTaskId = await taskRegistry.nextTaskId();
    console.log(`   Next objective ID: ${nextObjectiveId}`);
    console.log(`   Next task ID: ${nextTaskId}`);
    test("TaskRegistry initialized", nextObjectiveId === 1n && nextTaskId === 1n);

    // 7. Test BountyEscrow
    console.log("\n--- BountyEscrow Tests ---");
    const bountyEscrow = await hre.ethers.getContractAt("BountyEscrow", addresses.BountyEscrow);

    const nextBountyId = await bountyEscrow.nextBountyId();
    console.log(`   Next bounty ID: ${nextBountyId}`);
    test("BountyEscrow initialized", nextBountyId === 1n);

    // 8. Test VanguardDAO
    console.log("\n--- VanguardDAO Tests ---");
    const dao = await hre.ethers.getContractAt("VanguardDAO", addresses.VanguardDAO);

    const votingPeriod = await dao.votingPeriod();
    console.log(`   Voting period: ${votingPeriod} blocks`);
    test("Voting period set", votingPeriod > 0n);

    const proposalThreshold = await dao.proposalThreshold();
    console.log(`   Proposal threshold: ${hre.ethers.formatEther(proposalThreshold)} VGRD`);
    test("Proposal threshold is 100k VGRD", proposalThreshold === hre.ethers.parseEther("100000"));

    // 9. Test contract connections
    console.log("\n--- Contract Integration Tests ---");

    // Check RewardPool has correct token address
    const rpToken = await rewardPool.token();
    test("RewardPool linked to VGRDToken", rpToken.toLowerCase() === addresses.VGRDToken.toLowerCase());

    // Check TaskRegistry has correct registry address
    const trRegistry = await taskRegistry.registry();
    test("TaskRegistry linked to ArmyRegistry", trRegistry.toLowerCase() === addresses.ArmyRegistry.toLowerCase());

    // Check RankManager has correct registry address
    const rmRegistry = await rankManager.registry();
    test("RankManager linked to ArmyRegistry", rmRegistry.toLowerCase() === addresses.ArmyRegistry.toLowerCase());

    // 10. Functional test - Enlist a soldier
    console.log("\n--- Functional Tests ---");

    const isEnlisted = await registry.isEnlisted(deployer.address);
    if (!isEnlisted) {
      console.log("   Enlisting deployer as soldier...");
      const tx = await registry.enlist(1); // Join squad 1
      await tx.wait();
      console.log(`   Transaction: ${tx.hash}`);

      const nowEnlisted = await registry.isEnlisted(deployer.address);
      test("Deployer successfully enlisted", nowEnlisted === true);

      const soldier = await registry.getSoldier(deployer.address);
      console.log(`   Soldier rank: ${soldier.rank} (PVT=1)`);
      test("New soldier is PVT", soldier.rank === 1n);

      // Check unit membership increased
      const updatedUnit = await registry.getUnit(1);
      console.log(`   Squad 1 member count: ${updatedUnit.memberCount}`);
      test("Squad member count increased", updatedUnit.memberCount >= 1n);
    } else {
      console.log("   Deployer already enlisted, skipping enlist test");
      const soldier = await registry.getSoldier(deployer.address);
      console.log(`   Current rank: ${soldier.rank}`);
      test("Deployer is enlisted", isEnlisted === true);
    }

    // Summary
    console.log("\n========== TEST SUMMARY ==========");
    console.log(`Total: ${passed + failed} | Passed: ${passed} | Failed: ${failed}`);
    console.log(`Success rate: ${((passed / (passed + failed)) * 100).toFixed(1)}%`);

    if (failed > 0) {
      process.exit(1);
    }

  } catch (error) {
    console.error("\n❌ Test execution error:", error.message);
    process.exit(1);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
