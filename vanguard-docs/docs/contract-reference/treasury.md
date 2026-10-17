# Treasury

**Address:** `0x55B811D87CFBbb149ea436BD5F57671602D91d54`
**Purpose:** DAO reserve fund with payment stream (vesting) capability.

## Roles

| Role | Holder | Purpose |
|------|--------|---------|
| `DEFAULT_ADMIN_ROLE` | Deployer | Grant/revoke roles |
| `DAO_ROLE` | Deployer | Withdrawals, stream creation |

## Data Structures

### Stream

```solidity
struct Stream {
    address recipient;
    address token;
    uint256 totalAmount;
    uint256 startTime;
    uint256 endTime;
    uint256 claimed;
}
```

## Functions

### withdraw

**Access:** DAO_ROLE | **Mutability:** nonpayable

Withdraw ERC-20 tokens from the Treasury.

- `_token` (address) — token contract address
- `_amount` (uint256) — amount to withdraw
- `_recipient` (address) — where to send

Emits: `Withdrawn(token, amount, recipient)`

### withdrawETH

**Access:** DAO_ROLE | **Mutability:** nonpayable

Withdraw ETH from the Treasury.

- `_amount` (uint256) — ETH amount in wei
- `_recipient` (address) — where to send

### createStream

**Access:** DAO_ROLE | **Mutability:** nonpayable

Create a vesting payment stream.

- `_recipient` (address) — stream recipient
- `_token` (address) — token to stream
- `_totalAmount` (uint256) — total tokens over stream duration
- `_startTime` (uint256) — vesting start timestamp
- `_endTime` (uint256) — vesting end timestamp

Reverts if: endTime <= startTime, insufficient treasury balance.

Emits: `StreamCreated(streamId, recipient, token, totalAmount, startTime, endTime)`

### claimStream

**Access:** Stream recipient | **Mutability:** nonpayable

Claim vested tokens from a stream.

- `_streamId` (uint256) — stream to claim from

**Calculation:**
```
elapsed = block.timestamp - startTime
vested = totalAmount × elapsed ÷ (endTime - startTime)
claimable = vested - claimed
```

Reverts if: caller is not the recipient, nothing to claim.

Emits: `StreamClaimed(streamId, amount)`

### getStream

**Access:** Public | **Mutability:** view

- `_streamId` (uint256)

Returns: Stream struct.

## Events

| Event | Parameters |
|-------|-----------|
| `Withdrawn` | `token` (address), `amount` (uint256), `recipient` (address) |
| `StreamCreated` | `streamId`, `recipient`, `token`, `totalAmount`, `startTime`, `endTime` |
| `StreamClaimed` | `streamId`, `amount` |

## Receive Function

The Treasury can receive ETH via direct transfers:

```solidity
receive() external payable {}
```
