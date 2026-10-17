import { expect } from "chai";
import { ethers } from "hardhat";
import { time } from "@nomicfoundation/hardhat-network-helpers";
import type { Signer } from "ethers";

describe("Engine: Treasury", function () {
  let token: any;
  let treasury: any;
  let admin: Signer;
  let recipient: Signer;
  let outsider: Signer;

  beforeEach(async () => {
    [admin, recipient, outsider] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("VGRDToken");
    token = await Token.deploy(await admin.getAddress());
    await token.waitForDeployment();

    const Treasury = await ethers.getContractFactory("Treasury");
    treasury = await Treasury.deploy(await admin.getAddress(), await token.getAddress());
    await treasury.waitForDeployment();

    // Seed treasury with 10M VGRD
    await token.connect(admin).transfer(await treasury.getAddress(), ethers.parseEther("10000000"));
  });

  it("accepts ERC20 deposits via plain transfer (deposit-by-transfer)", async () => {
    const balance = await token.balanceOf(await treasury.getAddress());
    expect(balance).to.equal(ethers.parseEther("10000000"));

    // Top up another 1M
    await token.connect(admin).transfer(await treasury.getAddress(), ethers.parseEther("1000000"));
    expect(await treasury.getBalance(await token.getAddress())).to.equal(
      ethers.parseEther("11000000")
    );
  });

  it("allows DAO_ROLE to withdraw ERC20 tokens", async () => {
    const recipientAddr = await recipient.getAddress();
    const before = await token.balanceOf(recipientAddr);
    await treasury
      .connect(admin)
      .withdraw(await token.getAddress(), recipientAddr, ethers.parseEther("500000"));
    const after = await token.balanceOf(recipientAddr);
    expect(after - before).to.equal(ethers.parseEther("500000"));
  });

  it("rejects withdrawals from non-DAO callers", async () => {
    await expect(
      treasury
        .connect(outsider)
        .withdraw(
          await token.getAddress(),
          await recipient.getAddress(),
          ethers.parseEther("1")
        )
    ).to.be.reverted;
  });

  it("creates a stream and allows the recipient to claim a vested portion", async () => {
    const recipientAddr = await recipient.getAddress();
    const total = ethers.parseEther("1000000");
    const duration = 1_000_000n; // seconds

    const tx = await treasury
      .connect(admin)
      .createStream(recipientAddr, await token.getAddress(), total, duration);
    const rc = await tx.wait();
    const evt = rc!.logs
      .map((l: any) => {
        try {
          return treasury.interface.parseLog(l);
        } catch {
          return null;
        }
      })
      .find((p: any) => p && p.name === "StreamCreated");
    const streamId = BigInt(evt!.args.streamId);

    // Advance halfway through the stream
    await time.increase(Number(duration) / 2);
    const claimable = await treasury.getClaimableAmount(streamId);
    // Allow ±1 wei rounding
    const expected = total / 2n;
    expect(claimable >= expected - 100n && claimable <= expected + 100n).to.equal(true);

    const before = await token.balanceOf(recipientAddr);
    await treasury.connect(recipient).claimStream(streamId);
    const after = await token.balanceOf(recipientAddr);
    expect(after - before >= expected - 100n).to.equal(true);
  });

  it("falls back to the engine token when stream token == address(0)", async () => {
    const recipientAddr = await recipient.getAddress();
    const total = ethers.parseEther("100000");
    const duration = 100_000n;

    const tx = await treasury
      .connect(admin)
      .createStream(recipientAddr, ethers.ZeroAddress, total, duration);
    const rc = await tx.wait();
    const evt = rc!.logs
      .map((l: any) => {
        try {
          return treasury.interface.parseLog(l);
        } catch {
          return null;
        }
      })
      .find((p: any) => p && p.name === "StreamCreated");
    expect(evt!.args.token).to.equal(await token.getAddress());
  });
});
