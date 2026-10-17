# Testing

This page covers testing strategies for the Vanguard protocol — both the existing test suite and recommended expansions.

## Current Test Suite

The deployed test suite (`contracts/scripts/test-deployed.js`) runs against live Base Sepolia contracts. It verifies:

### What's Tested (22 Checks)

| Category | Tests | Type |
|----------|-------|------|
| VGRDToken | Name, symbol, supply, deployer balance | Read-only |
| Treasury | Holds 250M VGRD | Read-only |
| RewardPool | Holds 400M VGRD | Read-only |
| ArmyRegistry | Default squad exists, is active, is correct type | Read-only |
| RankManager | PVT multiplier, CPT multiplier, SGT voting power | Read-only |
| TaskRegistry | Initialized (nextObjectiveId=1, nextTaskId=1) | Read-only |
| BountyEscrow | Initialized (nextBountyId=1) | Read-only |
| VanguardDAO | Voting period, proposal threshold | Read-only |
| Integration | Contract linkages (RewardPool→Token, TaskRegistry→Registry, RankManager→Registry) | Read-only |
| Functional | Enlist soldier, verify rank, verify squad count | Write (1 tx) |

### Running the Tests

```bash
cd contracts/
npm run test:deployed
```

Expected output:

```
Testing with account: 0x41521c37dB02956185437C4e2461261A321073E1
Network: baseSepolia

========== VANGUARD CONTRACT TESTS ==========

--- VGRDToken Tests ---
 PASS: Token name is 'Vanguard Token'
 PASS: Token symbol is 'VGRD'
 PASS: Total supply is 1 billion
 PASS: Deployer has tokens

--- Treasury Tests ---
 PASS: Treasury has 250M VGRD
...

========== TEST SUMMARY ==========
Total: 22 | Passed: 22 | Failed: 0
Success rate: 100.0%
```

## What's NOT Tested

The current suite is a **deployment verification** — it confirms contracts were deployed and configured correctly. It does not test:

| Missing Test | Why It Matters |
|-------------|---------------|
| Task lifecycle (create → assign → submit → approve) | Core workflow never validated |
| Reward distribution and claiming | Payment system never validated |
| Rank promotions | Rank system never validated end-to-end |
| Bounty creation and fund release | Bounty system never validated |
| DAO proposals and voting | Governance never validated |
| Access control (unauthorized attempts) | Security never validated |
| Edge cases (double enlist, max squad, etc.) | Error handling never validated |
| Multi-wallet scenarios | Realistic usage never validated |

## Recommended Test Expansion

### Test 1: Full Task Lifecycle

```javascript
// 1. Create an objective
const tx1 = await taskRegistry.createObjective(1, "Test Obj", "Test", 0);
await tx1.wait();

// 2. Create a task
const tx2 = await taskRegistry.createTask(1, "Test Task", "Test", ethers.parseEther("1000"));
await tx2.wait();

// 3. Self-assign (with a second wallet)
const tx3 = await taskRegistry.connect(soldier).selfAssignTask(1);
await tx3.wait();

// 4. Submit
const tx4 = await taskRegistry.connect(soldier).submitTask(1, "QmTestHash");
await tx4.wait();

// 5. Approve (with the leader wallet)
const tx5 = await taskRegistry.approveTask(1);
await tx5.wait();

// 6. Verify reward accrued
const pending = await rewardPool.pendingRewards(soldierAddress);
test("Reward accrued after task approval", pending > 0n);

// 7. Claim
const balBefore = await token.balanceOf(soldierAddress);
const tx6 = await rewardPool.connect(soldier).claimRewards();
await tx6.wait();
const balAfter = await token.balanceOf(soldierAddress);
test("Balance increased after claiming", balAfter > balBefore);
```

### Test 2: Access Control

```javascript
// Attempt to create task as PVT (should fail)
try {
  await taskRegistry.connect(privateSoldier).createTask(1, "Unauthorized", "", ethers.parseEther("100"));
  test("PVT cannot create task", false);  // Should not reach here
} catch (e) {
  test("PVT cannot create task", true);  // Revert expected
}

// Attempt to approve own task (should fail)
try {
  await taskRegistry.connect(soldier).approveTask(1);
  test("Soldier cannot approve own task", false);
} catch (e) {
  test("Soldier cannot approve own task", true);
}
```

### Test 3: Multi-Wallet Scenario

Testing realistic interaction patterns requires at least 3 wallets:

1. **Deployer/Captain** — creates objectives and bounties
2. **Sergeant** — creates tasks and approves submissions
3. **Private** — completes tasks and claims rewards

```bash
# Run with multiple signers
# The deployer wallet can fund test wallets with test ETH and VGRD
```

## Local Testing with Hardhat Network

For rapid iteration, test against the local Hardhat network (no gas costs, instant confirmation):

```bash
npx hardhat node  # Start local node in one terminal

# In another terminal:
npx hardhat run scripts/deploy.js --network localhost
npx hardhat run scripts/test-deployed.js --network localhost
```

This allows you to test destructive scenarios (deliberate reverts, edge cases) without affecting the testnet deployment.

## Continuous Integration

!!! warning "Future Feature"
    A CI/CD pipeline that runs the test suite on every pull request is not yet configured. The recommended setup:

    1. Run `npx hardhat compile` to verify contracts compile
    2. Run local Hardhat network tests for unit tests
    3. Optionally run testnet tests against a dedicated CI deployment
    4. Run `svelte-check` for UI type checking
