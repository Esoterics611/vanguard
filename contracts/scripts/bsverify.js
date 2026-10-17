// Submit standard-json verification to Blockscout v2, one contract per minute.
const hre = require("hardhat"); const { ethers } = hre; const fs = require("fs");
const dep = require("../deployed/base-sepolia.json"); const A = dep.addresses, D = dep.deployer;
const args = { ArmyRegistry:[D], RankManager:[D,A.ArmyRegistry], RewardPool:[D,A.VGRDToken,A.ArmyRegistry,A.RankManager], TaskRegistry:[D,A.ArmyRegistry,A.RankManager], BountyEscrow:[D,A.VGRDToken,A.ArmyRegistry], VanguardDAO:[D,A.VGRDToken,A.ArmyRegistry,D] };
const sleep = ms => new Promise(r => setTimeout(r, ms));
(async () => {
  for (const [name, cargs] of Object.entries(args).filter(([n]) => !process.env.ONLY || process.env.ONLY.split(",").includes(n))) {
    const fq = `contracts/${name}.sol:${name}`;
    const bi = await hre.artifacts.getBuildInfo(fq);
    const iface = new ethers.Interface((await hre.artifacts.readArtifact(name)).abi);
    const enc = iface.encodeDeploy(cargs).slice(2);
    const form = new FormData();
    form.append("compiler_version", "v" + bi.solcLongVersion);
    form.append("contract_name", name);
    form.append("license_type", "mit");
    form.append("constructor_args", enc);
    form.append("autodetect_constructor_args", "false");
    form.append("files[0]", new Blob([JSON.stringify(bi.input)], { type: "application/json" }), "input.json");
    for (let i = 1; i <= 5; i++) {
      const r = await fetch(`https://base-sepolia.blockscout.com/api/v2/smart-contracts/${A[name]}/verification/via/standard-input`, { method: "POST", body: form, headers: { "User-Agent": "vanguard-demo/1.0" } });
      const t = await r.text();
      console.log(name, r.status, t.slice(0, 160));
      if (r.status !== 429) break;
      await sleep(180000);
    }
    await sleep(150000);
  }
})();
