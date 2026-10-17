import { ethers, network } from "hardhat";
import * as fs from "fs";
import * as path from "path";

const delay = (ms: number) => new Promise((r) => setTimeout(r, ms));

async function deployWithRetry<T>(name: string, args: unknown[], maxRetries = 3): Promise<{ address: string; contract: any }> {
  const factory = await ethers.getContractFactory(name);
  for (let i = 0; i < maxRetries; i++) {
    try {
      console.log(`Deploying ${name}... (attempt ${i + 1})`);
      const contract = await factory.deploy(...(args as any[]));
      await contract.waitForDeployment();
      const address = await contract.getAddress();
      console.log(`  ${name} deployed to: ${address}`);
      // Avoid hammering RPC on remote networks
      if (network.name !== "hardhat") await delay(3000);
      return { address, contract };
    } catch (err: any) {
      console.log(`  attempt ${i + 1} failed: ${err.message}`);
      if (i === maxRetries - 1) throw err;
      await delay(8000);
    }
  }
  throw new Error("unreachable");
}

async function sendTx(label: string, txFn: () => Promise<any>, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      console.log(`${label}... (attempt ${i + 1})`);
      const tx = await txFn();
      await tx.wait(1);
      if (network.name !== "hardhat") await delay(2000);
      return tx;
    } catch (err: any) {
      console.log(`  attempt ${i + 1} failed: ${err.message}`);
      if (i === maxRetries - 1) throw err;
      await delay(6000);
    }
  }
}

async function main() {
  const [deployer] = await ethers.getSigners();
  const networkName = network.name;
  const balance = await ethers.provider.getBalance(deployer.address);

  console.log(`Network:    ${networkName}`);
  console.log(`Deployer:   ${deployer.address}`);
  console.log(`Balance:    ${ethers.formatEther(balance)} ETH\n`);

  // Attestation signer defaults to deployer if not configured (for local nets / dev).
  const attestationSigner = process.env.ATTESTATION_SIGNER ?? deployer.address;
  console.log(`Attestation signer: ${attestationSigner}\n`);

  const addresses: Record<string, string> = {};

  // 1. Token (engine singleton)
  const { address: tokenAddr, contract: token } =
    await deployWithRetry("VGRDToken", [deployer.address]);
  addresses.VGRDToken = tokenAddr;

  // 2. Treasury (vertical-specific; takes engine token)
  const { address: treasuryAddr } =
    await deployWithRetry("Treasury", [deployer.address, tokenAddr]);
  addresses.Treasury = treasuryAddr;

  // 3. ArmyRegistry (vertical-specific)
  const { address: registryAddr, contract: registry } =
    await deployWithRetry("ArmyRegistry", [deployer.address]);
  addresses.ArmyRegistry = registryAddr;

  // 4. RankManager (depends on registry)
  const { address: rankManagerAddr, contract: rankManager } =
    await deployWithRetry("RankManager", [deployer.address, registryAddr]);
  addresses.RankManager = rankManagerAddr;

  // 5. RewardPool
  const { address: rewardPoolAddr, contract: rewardPool } =
    await deployWithRetry("RewardPool", [
      deployer.address,
      tokenAddr,
      registryAddr,
      rankManagerAddr,
    ]);
  addresses.RewardPool = rewardPoolAddr;

  // 6. TaskRegistry
  const { address: taskRegistryAddr, contract: taskRegistry } =
    await deployWithRetry("TaskRegistry", [
      deployer.address,
      registryAddr,
      rankManagerAddr,
    ]);
  addresses.TaskRegistry = taskRegistryAddr;

  // 7. BountyEscrow
  const { address: bountyEscrowAddr, contract: bountyEscrow } =
    await deployWithRetry("BountyEscrow", [
      deployer.address,
      tokenAddr,
      registryAddr,
    ]);
  addresses.BountyEscrow = bountyEscrowAddr;

  // 8. VanguardDAO (concrete BaseGovernance — takes attestationSigner instead of rankManager)
  await deployWithRetry("VanguardDAO", [
    deployer.address,
    tokenAddr,
    registryAddr,
    attestationSigner,
  ]).then(({ address }) => (addresses.VanguardDAO = address));

  // ── Post-deployment wiring ────────────────────────────────────────────
  console.log("\n--- Post-deployment configuration ---");

  const MINTER_ROLE = await token.MINTER_ROLE();
  await sendTx("Granting MINTER_ROLE on token to RewardPool", () =>
    token.grantRole(MINTER_ROLE, rewardPoolAddr)
  );

  const RANK_MANAGER_ROLE = await registry.RANK_MANAGER_ROLE();
  await sendTx("Granting RANK_MANAGER_ROLE on registry to RankManager", () =>
    registry.grantRole(RANK_MANAGER_ROLE, rankManagerAddr)
  );

  await sendTx("Setting RewardPool on TaskRegistry", () =>
    taskRegistry.setRewardPool(rewardPoolAddr)
  );

  const DISTRIBUTOR_ROLE = await rewardPool.DISTRIBUTOR_ROLE();
  await sendTx("Granting DISTRIBUTOR_ROLE on RewardPool to TaskRegistry", () =>
    rewardPool.grantRole(DISTRIBUTOR_ROLE, taskRegistryAddr)
  );

  await sendTx("Setting TaskRegistry on BountyEscrow", () =>
    bountyEscrow.setTaskRegistry(taskRegistryAddr)
  );
  await sendTx("Setting RewardPool on BountyEscrow", () =>
    bountyEscrow.setRewardPool(rewardPoolAddr)
  );

  const ADMIN_ROLE = await registry.ADMIN_ROLE();
  await sendTx("Granting ADMIN_ROLE on registry to TaskRegistry", () =>
    registry.grantRole(ADMIN_ROLE, taskRegistryAddr)
  );

  // ── Initial token distribution (skip on hardhat for tests' clarity) ────
  if (network.name !== "hardhat") {
    console.log("\n--- Initial token distribution ---");
    const rewardPoolAllocation = ethers.parseEther("400000000");
    await sendTx("Transferring 400M VGRD to RewardPool", () =>
      token.transfer(rewardPoolAddr, rewardPoolAllocation)
    );
    const treasuryAllocation = ethers.parseEther("250000000");
    await sendTx("Transferring 250M VGRD to Treasury", () =>
      token.transfer(treasuryAddr, treasuryAllocation)
    );
  }

  // ── Persist addresses ──────────────────────────────────────────────────
  const outDir = path.join(__dirname, "..", "deployed");
  if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true });
  // Use kebab-case file name for Base Sepolia so it matches the public chain id.
  const fileSlug = networkName === "baseSepolia" ? "base-sepolia" : networkName;
  const outPath = path.join(outDir, `${fileSlug}.json`);
  const payload = {
    network: networkName,
    chainId: Number((await ethers.provider.getNetwork()).chainId),
    deployer: deployer.address,
    attestationSigner,
    deployedAt: new Date().toISOString(),
    addresses,
  };
  fs.writeFileSync(outPath, JSON.stringify(payload, null, 2));
  console.log(`\n=== Deployment Complete ===`);
  console.log(`Addresses written to: ${outPath}`);
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
