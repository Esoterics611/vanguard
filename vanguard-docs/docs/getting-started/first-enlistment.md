# Your First Enlistment

Enlistment is your entry point into the Vanguard protocol. This page walks you through the process step by step.

## What Happens When You Enlist

When you call `ArmyRegistry.enlist(squadId)`:

1. The contract verifies you have not already enlisted (each address can enlist once)
2. A **Soldier record** is created for your address with:
   - Rank: **PVT** (Private, rank 1)
   - Unit: The squad you specified
   - Tasks completed: 0
   - VGRD earned: 0
   - Enlistment date: Current block timestamp
3. You are added to the squad's member list
4. The squad's member count increases by 1

**This action is irreversible.** Once enlisted, your address is permanently recorded as a soldier in the ArmyRegistry.

## Choosing a Squad

Currently, **Alpha Squad** (Unit ID `1`) is the only squad available. It was created automatically when the ArmyRegistry was deployed.

To check the current state of Alpha Squad before enlisting:

=== "BaseScan"

    1. Go to [ArmyRegistry on BaseScan](https://base-sepolia.blockscout.com/address/0xBf3BEE33090fb5f9b147a72cAac6f4f44CE1F270#readContract)
    2. Find `getUnit(uint256)`
    3. Enter `1` and click "Query"
    4. You'll see: unit type (0 = Squad), name, leader, member count, active status

=== "Hardhat Console"

    ```javascript
    const registry = await ethers.getContractAt(
      "ArmyRegistry",
      "0xBf3BEE33090fb5f9b147a72cAac6f4f44CE1F270"
    );
    const unit = await registry.getUnit(1);
    console.log("Type:", unit.unitType);       // 0 = SQUAD
    console.log("Members:", unit.memberCount);
    console.log("Active:", unit.active);
    ```

## Enlisting via BaseScan

1. Go to [ArmyRegistry on BaseScan](https://base-sepolia.blockscout.com/address/0xBf3BEE33090fb5f9b147a72cAac6f4f44CE1F270#writeContract)
2. Click "Connect to Web3" and connect your MetaMask
3. Find the `enlist` function
4. Enter `1` for `_squadId` (Alpha Squad)
5. Click "Write"
6. Confirm the transaction in MetaMask
7. Wait for confirmation (~2 seconds)

## Enlisting via Hardhat Console

```javascript
const registry = await ethers.getContractAt(
  "ArmyRegistry",
  "0xBf3BEE33090fb5f9b147a72cAac6f4f44CE1F270"
);

// Enlist in Alpha Squad (Unit 1)
const tx = await registry.enlist(1);
console.log("Transaction hash:", tx.hash);
await tx.wait();
console.log("Enlisted successfully!");
```

## Enlisting with an Invite

If an existing member has given you their address as an invitation, you can enlist with a referral:

```javascript
const tx = await registry.enlistWithInvite(1, "0xINVITER_ADDRESS");
await tx.wait();
```

The invite system records who referred you, which may be relevant for future referral-based incentive programs.

!!! warning "Future Feature"
    Invite-based rewards and referral tracking are not yet implemented in the RewardPool. The `inviter` field is stored on-chain but does not currently affect compensation.

## Verifying Your Enlistment

After enlisting, verify your soldier record:

=== "BaseScan"

    1. Go to ArmyRegistry Read Contract
    2. Find `getSoldier(address)`
    3. Enter your wallet address
    4. You should see: rank = 1 (PVT), unitId = 1, tasksCompleted = 0

=== "Hardhat Console"

    ```javascript
    const soldier = await registry.getSoldier("0xYOUR_ADDRESS");
    console.log("Rank:", soldier.rank);           // 1 (PVT)
    console.log("Unit ID:", soldier.unitId);       // 1
    console.log("Tasks:", soldier.tasksCompleted);  // 0
    console.log("Earned:", ethers.formatEther(soldier.totalEarned)); // 0.0
    ```

You can also verify with:

```javascript
const isEnlisted = await registry.isEnlisted("0xYOUR_ADDRESS");
console.log("Enlisted:", isEnlisted); // true
```

## What You Can Do Now

As a newly enlisted Private (PVT), you can:

- [x] **View** bounties, objectives, and tasks
- [x] **Self-assign** open tasks in your squad's objectives
- [x] **Submit** completed work with an IPFS hash
- [x] **Claim** any VGRD rewards you earn
- [x] **Vote** on governance proposals (with your token balance x rank weight)

You cannot yet:

- [ ] Create objectives (requires SGT+ rank)
- [ ] Create tasks (requires SGT+ rank)
- [ ] Approve or reject submissions (requires SGT+ rank)
- [ ] Create bounties (requires CPT rank)
- [ ] Submit governance proposals (requires CPT rank or 100,000+ VGRD)

To unlock these capabilities, you need to complete tasks and earn promotions. See [Rank Progression](../rank-system/progression.md).

## Common Errors

**"Already enlisted"**
:   Your address has already called `enlist()`. Each address can only enlist once. Check your soldier record with `getSoldier()`.

**"Invalid squad"**
:   The squad ID you entered does not exist or is not active. Use `getUnit(id)` to verify the squad exists and `active` is true.

**"Squad is full"**
:   The squad has reached its maximum capacity (10 members). When this happens, the squad should automatically split. If not, contact the squad leader or try a different squad.

**"Insufficient funds for gas"**
:   You need test ETH. See [Acquiring Testnet ETH](testnet-eth.md).
