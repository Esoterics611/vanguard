# VGRDToken

**Address:** `0x2Ef78A107b20eb4263448e70E643bA9621657493`
**Standard:** ERC-20 with Snapshot, Permit, Pausable, AccessControl
**Solidity:** 0.8.20 | OpenZeppelin v5.4

## Roles

| Role | Description | Holder |
|------|-------------|--------|
| `DEFAULT_ADMIN_ROLE` | Can grant/revoke all roles | Deployer |
| `MINTER_ROLE` | Can mint new tokens | RewardPool |
| `PAUSER_ROLE` | Can pause/unpause transfers | Deployer |
| `SNAPSHOT_ROLE` | Can create balance snapshots | Deployer |

## Constructor

```solidity
constructor(address _admin)
```

- Mints 1,000,000,000 VGRD (with 18 decimals) to `_admin`
- Grants all roles to `_admin`

## ERC-20 Standard Functions

### name

**Access:** Public | **Mutability:** view

Returns `"Vanguard Token"`.

### symbol

**Access:** Public | **Mutability:** view

Returns `"VGRD"`.

### decimals

**Access:** Public | **Mutability:** view

Returns `18`.

### totalSupply

**Access:** Public | **Mutability:** view

Returns total token supply (initially 1,000,000,000e18).

### balanceOf

**Access:** Public | **Mutability:** view

- `account` (address) — wallet to query

Returns: token balance (uint256)

### transfer

**Access:** Public | **Mutability:** nonpayable

- `to` (address) — recipient
- `amount` (uint256) — tokens to transfer

Returns: success (bool). Emits: `Transfer(from, to, amount)`.

Reverts if: paused, insufficient balance.

### approve

**Access:** Public | **Mutability:** nonpayable

- `spender` (address) — address authorized to spend
- `amount` (uint256) — maximum spending allowance

Returns: success (bool). Emits: `Approval(owner, spender, amount)`.

### transferFrom

**Access:** Public | **Mutability:** nonpayable

- `from` (address) — token owner
- `to` (address) — recipient
- `amount` (uint256) — tokens to transfer

Returns: success (bool). Requires prior `approve()` from `from` to `msg.sender`.

### allowance

**Access:** Public | **Mutability:** view

- `owner` (address) — token owner
- `spender` (address) — authorized spender

Returns: remaining allowance (uint256).

## Snapshot Functions

### snapshot

**Access:** SNAPSHOT_ROLE | **Mutability:** nonpayable

Creates a new balance snapshot. Returns: snapshotId (uint256).

### balanceOfAt

**Access:** Public | **Mutability:** view

- `account` (address) — wallet to query
- `snapshotId` (uint256) — snapshot to query

Returns: balance at that snapshot (uint256).

### totalSupplyAt

**Access:** Public | **Mutability:** view

- `snapshotId` (uint256) — snapshot to query

Returns: total supply at that snapshot (uint256).

## Permit (EIP-2612)

### permit

**Access:** Public | **Mutability:** nonpayable

Gasless approval via signed message.

- `owner` (address) — token owner
- `spender` (address) — authorized spender
- `value` (uint256) — allowance amount
- `deadline` (uint256) — signature expiration timestamp
- `v`, `r`, `s` — signature components

## Minting

### mint

**Access:** MINTER_ROLE | **Mutability:** nonpayable

- `to` (address) — recipient
- `amount` (uint256) — tokens to mint

Emits: `Transfer(address(0), to, amount)`.

## Events

| Event | Parameters |
|-------|-----------|
| `Transfer` | `from` (address), `to` (address), `value` (uint256) |
| `Approval` | `owner` (address), `spender` (address), `value` (uint256) |
| `Snapshot` | `id` (uint256) |
| `Paused` | `account` (address) |
| `Unpaused` | `account` (address) |
