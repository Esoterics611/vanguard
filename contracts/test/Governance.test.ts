import { expect } from "chai";
import { ethers, network } from "hardhat";
import { mine } from "@nomicfoundation/hardhat-network-helpers";
import type { HDNodeWallet, Signer } from "ethers";

/**
 * Build & sign an EIP-712 RankAttestation for VanguardDAO.
 */
async function signAttestation(
  signer: Signer | HDNodeWallet,
  domain: { name: string; version: string; chainId: number; verifyingContract: string },
  fields: { voter: string; rankIndex: number; proposalId: bigint; nonce: bigint; expiry: bigint }
) {
  const types = {
    RankAttestation: [
      { name: "voter", type: "address" },
      { name: "rankIndex", type: "uint8" },
      { name: "proposalId", type: "uint256" },
      { name: "nonce", type: "uint256" },
      { name: "expiry", type: "uint256" },
    ],
  } as const;
  return await (signer as any).signTypedData(domain, types, fields);
}

describe("Engine: VanguardDAO + ArmyRegistry", function () {
  let token: any;
  let registry: any;
  let dao: any;
  let admin: Signer;
  let proposer: Signer;
  let voter: Signer;
  let other: Signer;
  let attestationSigner: HDNodeWallet;
  let domain: { name: string; version: string; chainId: number; verifyingContract: string };

  // Use small voting params so tests run fast.
  const VOTING_DELAY = 1;
  const VOTING_PERIOD = 10;

  beforeEach(async () => {
    [admin, proposer, voter, other] = await ethers.getSigners();

    // Backend attestation key — separate from any test signer so signature
    // recovery is unambiguous.
    attestationSigner = ethers.Wallet.createRandom().connect(ethers.provider);

    const Token = await ethers.getContractFactory("VGRDToken");
    token = await Token.deploy(await admin.getAddress());
    await token.waitForDeployment();

    const Registry = await ethers.getContractFactory("ArmyRegistry");
    registry = await Registry.deploy(await admin.getAddress());
    await registry.waitForDeployment();

    const DAO = await ethers.getContractFactory("VanguardDAO");
    dao = await DAO.deploy(
      await admin.getAddress(),
      await token.getAddress(),
      await registry.getAddress(),
      attestationSigner.address
    );
    await dao.waitForDeployment();

    // Tighten voting params
    await dao.connect(admin).setVotingDelay(VOTING_DELAY);
    await dao.connect(admin).setVotingPeriod(VOTING_PERIOD);

    // Fund proposer above proposalThreshold (100k) and voter with enough to clear quorum (4% of 1B = 40M).
    await token.connect(admin).transfer(await proposer.getAddress(), ethers.parseEther("200000"));
    await token.connect(admin).transfer(await voter.getAddress(), ethers.parseEther("100000000")); // 100M

    const net = await ethers.provider.getNetwork();
    domain = {
      name: "VanguardDAO",
      version: "1",
      chainId: Number(net.chainId),
      verifyingContract: await dao.getAddress(),
    };
  });

  // ─── Helpers ───────────────────────────────────────────────────────────
  async function createProposal() {
    const tx = await dao.connect(proposer).propose(
      [await admin.getAddress()],
      [0],
      ["0x"],
      "Test proposal: noop call to admin EOA"
    );
    const rc = await tx.wait();
    // Read proposal id from event
    const evt = rc!.logs
      .map((l: any) => {
        try {
          return dao.interface.parseLog(l);
        } catch {
          return null;
        }
      })
      .find((p: any) => p && p.name === "ProposalCreated");
    return BigInt(evt!.args.proposalId);
  }

  // ─── Sanity ────────────────────────────────────────────────────────────
  it("deploys with the expected config", async () => {
    expect(await dao.attestationSigner()).to.equal(attestationSigner.address);
    expect(await dao.proposerMinRank()).to.equal(11); // CPT
    expect(await dao.rankMultipliersBps(1)).to.equal(100n); // PVT 1.0x
    expect(await dao.rankMultipliersBps(11)).to.equal(1200n); // CPT 12.0x
  });

  // ─── Rank attestation: valid signature passes ──────────────────────────
  it("accepts a valid attestation and records vote weight = balance × multiplier", async () => {
    const proposalId = await createProposal();
    await mine(VOTING_DELAY + 1);

    const expiry = BigInt(Math.floor(Date.now() / 1000) + 3600);
    const nonce = 1n;
    const rankIndex = 5; // SGT (3.0x)
    const sig = await signAttestation(attestationSigner, domain, {
      voter: await voter.getAddress(),
      rankIndex,
      proposalId,
      nonce,
      expiry,
    });

    await dao.connect(voter).castVote(
      proposalId,
      1, // VoteType.For
      { voter: await voter.getAddress(), rankIndex, proposalId, nonce, expiry, signature: sig }
    );

    const balance = await token.balanceOf(await voter.getAddress());
    const expectedWeight = (balance * 300n) / 100n; // SGT = 300 bps
    const proposal = await dao.getProposal(proposalId);
    expect(proposal.forVotes).to.equal(expectedWeight);

    const receipt = await dao.getReceipt(proposalId, await voter.getAddress());
    expect(receipt.hasVoted).to.equal(true);
    expect(receipt.votes).to.equal(expectedWeight);
    expect(receipt.rankIndex).to.equal(rankIndex);
  });

  // ─── Rank attestation: tampered signature reverts ──────────────────────
  it("rejects a tampered signature with 'Invalid attestation'", async () => {
    const proposalId = await createProposal();
    await mine(VOTING_DELAY + 1);

    const expiry = BigInt(Math.floor(Date.now() / 1000) + 3600);
    const nonce = 2n;
    const rankIndex = 5;
    let sig = await signAttestation(attestationSigner, domain, {
      voter: await voter.getAddress(),
      rankIndex,
      proposalId,
      nonce,
      expiry,
    });

    // Flip a byte in the signature
    const bytes = ethers.getBytes(sig);
    bytes[10] = bytes[10] ^ 0xff;
    const tamperedSig = ethers.hexlify(bytes);

    await expect(
      dao.connect(voter).castVote(proposalId, 1, {
        voter: await voter.getAddress(),
        rankIndex,
        proposalId,
        nonce,
        expiry,
        signature: tamperedSig,
      })
    // A flipped byte either recovers the wrong signer ("Invalid attestation") or makes the
    // signature malformed, which OpenZeppelin's ECDSA rejects with its own custom error.
    ).to.be.reverted;
  });

  // ─── Rank attestation: expired reverts ─────────────────────────────────
  it("rejects an expired attestation", async () => {
    const proposalId = await createProposal();
    await mine(VOTING_DELAY + 1);

    const expiry = BigInt(Math.floor(Date.now() / 1000) - 60); // 60s in the past
    const nonce = 3n;
    const rankIndex = 5;
    const sig = await signAttestation(attestationSigner, domain, {
      voter: await voter.getAddress(),
      rankIndex,
      proposalId,
      nonce,
      expiry,
    });

    await expect(
      dao.connect(voter).castVote(proposalId, 1, {
        voter: await voter.getAddress(),
        rankIndex,
        proposalId,
        nonce,
        expiry,
        signature: sig,
      })
    ).to.be.revertedWith("Attestation expired");
  });

  // ─── Rank attestation: wrong voter reverts ─────────────────────────────
  it("rejects an attestation whose voter != msg.sender", async () => {
    const proposalId = await createProposal();
    await mine(VOTING_DELAY + 1);

    const expiry = BigInt(Math.floor(Date.now() / 1000) + 3600);
    const nonce = 4n;
    const rankIndex = 5;
    // Sign for `other`, but submit from `voter`.
    const sig = await signAttestation(attestationSigner, domain, {
      voter: await other.getAddress(),
      rankIndex,
      proposalId,
      nonce,
      expiry,
    });

    await expect(
      dao.connect(voter).castVote(proposalId, 1, {
        voter: await other.getAddress(),
        rankIndex,
        proposalId,
        nonce,
        expiry,
        signature: sig,
      })
    ).to.be.revertedWith("Attestation not for caller");
  });

  // ─── Nonce replay ──────────────────────────────────────────────────────
  it("rejects a reused nonce", async () => {
    const proposalId = await createProposal();
    await mine(VOTING_DELAY + 1);

    const expiry = BigInt(Math.floor(Date.now() / 1000) + 3600);
    const nonce = 5n;
    const rankIndex = 5;
    const sig = await signAttestation(attestationSigner, domain, {
      voter: await voter.getAddress(),
      rankIndex,
      proposalId,
      nonce,
      expiry,
    });
    await dao.connect(voter).castVote(proposalId, 1, {
      voter: await voter.getAddress(),
      rankIndex,
      proposalId,
      nonce,
      expiry,
      signature: sig,
    });

    // Second call with same nonce — voter has hasVoted, but the nonce check fires first.
    // Use a different proposal so hasVoted doesn't trip.
    const proposalId2 = await createProposal();
    await mine(VOTING_DELAY + 1);
    const sig2 = await signAttestation(attestationSigner, domain, {
      voter: await voter.getAddress(),
      rankIndex,
      proposalId: proposalId2,
      nonce, // reused
      expiry,
    });
    await expect(
      dao.connect(voter).castVote(proposalId2, 1, {
        voter: await voter.getAddress(),
        rankIndex,
        proposalId: proposalId2,
        nonce,
        expiry,
        signature: sig2,
      })
    ).to.be.revertedWith("Nonce already used");
  });

  // ─── Lifecycle: propose ────────────────────────────────────────────────
  it("allows proposing when proposer holds tokens above threshold", async () => {
    const proposalId = await createProposal();
    expect(proposalId).to.equal(1n);
    const p = await dao.getProposal(proposalId);
    expect(p.proposer).to.equal(await proposer.getAddress());
  });

  it("blocks proposing when proposer is below rank and below token threshold", async () => {
    await expect(
      dao.connect(other).propose(
        [await admin.getAddress()],
        [0],
        ["0x"],
        "should fail"
      )
    ).to.be.revertedWith("Not eligible to propose");
  });

  // ─── Lifecycle: vote → succeed → execute ───────────────────────────────
  it("transitions to Succeeded and allows execution by EXECUTOR_ROLE", async () => {
    const proposalId = await createProposal();
    await mine(VOTING_DELAY + 1);

    // Cast a passing vote with enough weight to clear 4% quorum.
    const expiry = BigInt(Math.floor(Date.now() / 1000) + 3600);
    const sig = await signAttestation(attestationSigner, domain, {
      voter: await voter.getAddress(),
      rankIndex: 1, // PVT 1.0x → weight = balance × 1
      proposalId,
      nonce: 100n,
      expiry,
    });
    await dao.connect(voter).castVote(proposalId, 1, {
      voter: await voter.getAddress(),
      rankIndex: 1,
      proposalId,
      nonce: 100n,
      expiry,
      signature: sig,
    });

    // Mine through end of voting period
    await mine(VOTING_PERIOD + 1);
    expect(await dao.state(proposalId)).to.equal(2); // Succeeded

    // Admin holds EXECUTOR_ROLE
    await expect(dao.connect(admin).execute(proposalId)).to.emit(dao, "ProposalExecuted");
    expect(await dao.state(proposalId)).to.equal(4); // Executed
  });

  // ─── Lifecycle: cancel ─────────────────────────────────────────────────
  it("lets the proposer cancel a pending proposal", async () => {
    const proposalId = await createProposal();
    await dao.connect(proposer).cancel(proposalId);
    expect(await dao.state(proposalId)).to.equal(5); // Cancelled
  });
});
