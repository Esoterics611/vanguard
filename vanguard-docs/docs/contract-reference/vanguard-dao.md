# VanguardDAO

**Address:** `0x1F6FB4dB93691747420d0fb9d397E4f97443A7Af`
**Purpose:** On-chain governance — proposal creation, weighted voting, and execution.

## Roles

| Role | Holder | Purpose |
|------|--------|---------|
| `DEFAULT_ADMIN_ROLE` | Deployer | Grant/revoke roles |
| `EXECUTOR_ROLE` | Deployer | Execute passed proposals |

## Parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| `votingDelay` | 1 block | Blocks between proposal creation and voting start |
| `votingPeriod` | 45,818 blocks | Voting window (~1 week on Base) |
| `proposalThreshold` | 100,000 VGRD | Minimum tokens to propose (bypassed by CPT rank) |
| `quorum` | 4% of total supply | Minimum participation for valid vote |

## Functions

### propose

**Access:** CPT rank or 100,000+ VGRD holders | **Mutability:** nonpayable

Create a governance proposal.

- `targets` (address[]) — contracts to call
- `values` (uint256[]) — ETH values per call
- `calldatas` (bytes[]) — encoded function calls
- `description` (string) — proposal description

Returns: proposalId (uint256).

Emits: `ProposalCreated(proposalId, proposer, targets, values, calldatas, description, startBlock, endBlock)`

Reverts if: caller doesn't meet proposal threshold, arrays length mismatch.

### castVote

**Access:** Any VGRD holder | **Mutability:** nonpayable

Cast a vote on an active proposal.

- `proposalId` (uint256) — proposal to vote on
- `support` (uint8) — 0=Against, 1=For, 2=Abstain

**Voting power calculation:**
```
weight = balanceOfAt(voter, proposalSnapshot) × VOTING_POWER[rank]
```

Reverts if: proposal not Active, already voted.

Emits: `VoteCast(voter, proposalId, support, weight, reason)`

### castVoteWithReason

**Access:** Any VGRD holder | **Mutability:** nonpayable

Cast a vote with an on-chain explanation.

- `proposalId` (uint256)
- `support` (uint8)
- `reason` (string) — explanation for the vote

### execute

**Access:** EXECUTOR_ROLE | **Mutability:** nonpayable

Execute a succeeded proposal's contract calls.

- `targets` (address[])
- `values` (uint256[])
- `calldatas` (bytes[])
- `descriptionHash` (bytes32) — keccak256 of the description string

Reverts if: proposal not in Succeeded state, call execution fails.

Emits: `ProposalExecuted(proposalId)`

### cancel

**Access:** Proposer | **Mutability:** nonpayable

Cancel a proposal before execution.

- Same parameters as execute

Emits: `ProposalCancelled(proposalId)`

### state

**Access:** Public | **Mutability:** view

- `proposalId` (uint256)

Returns: ProposalState enum (0=Pending, 1=Active, 2=Cancelled, 3=Defeated, 4=Succeeded, 5=Queued, 6=Expired, 7=Executed).

### proposalVotes

**Access:** Public | **Mutability:** view

- `proposalId` (uint256)

Returns: (againstVotes, forVotes, abstainVotes) — all uint256.

### hasVoted

**Access:** Public | **Mutability:** view

- `proposalId` (uint256)
- `account` (address)

Returns: bool — true if the account has voted on this proposal.

### votingDelay / votingPeriod / proposalThreshold

**Access:** Public | **Mutability:** view

Returns: uint256 — the current governance parameter value.

## Events

| Event | Parameters |
|-------|-----------|
| `ProposalCreated` | `proposalId`, `proposer`, `targets`, `values`, `calldatas`, `description`, `startBlock`, `endBlock` |
| `VoteCast` | `voter`, `proposalId`, `support`, `weight`, `reason` |
| `ProposalExecuted` | `proposalId` |
| `ProposalCancelled` | `proposalId` |
