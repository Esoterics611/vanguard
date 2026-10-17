const hre = require("hardhat"); const { ethers } = hre;
const dep = require("../deployed/base-sepolia.json");
(async () => {
  const p = new ethers.JsonRpcProvider("https://sepolia.base.org");
  console.log("block", await p.getBlockNumber());
  console.log("deployer balance ETH", ethers.formatEther(await p.getBalance(dep.deployer)));
  for (const [name, addr] of Object.entries(dep.addresses)) {
    const code = await p.getCode(addr);
    const art = await hre.artifacts.readArtifact(name);
    const strip = c => c.replace(/a2646970667358.*$/, "");
    console.log(name.padEnd(13), addr, "code bytes", (code.length-2)/2, "matches source:", strip(code) === strip(art.deployedBytecode) ? "yes" : "differs (immutables/metadata)");
  }
  const reg = new ethers.Contract(dep.addresses.ArmyRegistry, (await hre.artifacts.readArtifact("ArmyRegistry")).abi, p);
  try { console.log("totalSoldiers", (await reg.totalSoldiers()).toString()); } catch(e) { console.log("totalSoldiers err", e.shortMessage); }
})();
