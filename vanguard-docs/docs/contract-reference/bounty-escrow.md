# BountyEscrow

**Address:** `0x19F1A7F9d4A3d36BEAF2e4fb5A5E42F3f080B143`
**Purpose:** Holds bounty funds in escrow and releases them as objectives complete.

## Roles

| Role | Holder | Purpose |
|------|--------|---------|
| `DEFAULT_ADMIN_ROLE` | Deployer | Grant/revoke roles |
| `DAO_ROLE` | Deployer | Administrative operations |

## Data Structures

### Bounty

```solidity
struct Bounty {
    address creator;
    uint256 totalAmount;
    uint256 distributedAmount;
    BountyStatus status;   // ACTIVE=0, COMPLETED=1, CANCELLED=2
}
```

## Functions

### createBounty

**Access:** CPT rank | **Mutability:** nonpayable

Create a funded bounty. Transfers VGRD from caller to escrow.

- `_totalAmount` (uint256) — total VGRD to deposit
- `_objectiveIds` (uint256[]) — linked objective IDs
- `_allocations` (uint256[]) — VGRD allocation per objective

**Requires:** Prior `token.approve(bountyEscrow, amount)`.

Reverts if: caller not CPT+, insufficient VGRD balance, allocations don't sum to total.

Emits: `BountyCreated(bountyId, creator, totalAmount)`

### fundBounty

**Access:** Any | **Mutability:** nonpayable

Add additional VGRD to an existing active bounty.

- `_bountyId` (uint256) — bounty to fund
- `_amount` (uint256) — additional VGRD to deposit

**Requires:** Prior `token.approve()`.

Emits: `BountyFunded(bountyId, funder, amount)`

### releaseObjectiveReward

**Access:** DAO_ROLE | **Mutability:** nonpayable

Release a completed objective's VGRD allocation to the RewardPool.

- `_bountyId` (uint256) — bounty ID
- `_objectiveId` (uint256) — objective ID

Reverts if: bounty not ACTIVE, objective not complete, allocation already released.

Emits: `ObjectiveRewarded(bountyId, objectiveId, amount)`

### cancelBounty

**Access:** Creator or DAO_ROLE | **Mutability:** nonpayable

Cancel a bounty. Refunds undistributed VGRD to the creator.

- `_bountyId` (uint256) — bounty to cancel

Reverts if: bounty not ACTIVE.

Emits: `BountyCancelled(bountyId, refundAmount)`

### completeBounty

**Access:** DAO_ROLE | **Mutability:** nonpayable

Mark a bounty as completed after all objectives are done.

- `_bountyId` (uint256)

Emits: `BountyCompleted(bountyId)`

### getBounty

**Access:** Public | **Mutability:** view

- `_bountyId` (uint256)

Returns: Bounty struct.

### nextBountyId

**Access:** Public | **Mutability:** view

Returns: uint256 — next auto-increment ID.

## Events

| Event | Parameters |
|-------|-----------|
| `BountyCreated` | `bountyId`, `creator`, `totalAmount` |
| `BountyFunded` | `bountyId`, `funder`, `amount` |
| `ObjectiveRewarded` | `bountyId`, `objectiveId`, `amount` |
| `BountyCancelled` | `bountyId`, `refundAmount` |
| `BountyCompleted` | `bountyId` |
