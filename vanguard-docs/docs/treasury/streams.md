# Payment Streams

Payment streams are the Treasury's mechanism for **time-based vesting** — releasing tokens to a recipient gradually over a defined period. This is the primary tool for ongoing contributor compensation, advisor fees, and long-term partnership payments.

## How Streams Work

A payment stream is defined by:

| Field | Type | Description |
|-------|------|-------------|
| `recipient` | address | Who receives the tokens |
| `token` | address | Which token (usually VGRD) |
| `totalAmount` | uint256 | Total tokens to be released over the stream's lifetime |
| `startTime` | uint256 | When vesting begins (block timestamp) |
| `endTime` | uint256 | When vesting completes |
| `claimed` | uint256 | Tokens already claimed by the recipient |

### Vesting Formula

At any point in time, the claimable amount is:

```
elapsed = current_time - start_time
duration = end_time - start_time
vested = total_amount × elapsed ÷ duration
claimable = vested - already_claimed
```

This produces **linear vesting** — tokens accumulate at a constant rate from start to end.

### Example

A 12-month stream of 120,000 VGRD:

| Month | Vested | Previously Claimed | Claimable |
|-------|--------|-------------------|-----------|
| 1 | 10,000 | 0 | 10,000 |
| 3 | 30,000 | 10,000 | 20,000 |
| 6 | 60,000 | 30,000 | 30,000 |
| 12 | 120,000 | 60,000 | 60,000 |

The recipient can claim at any time — they don't have to claim monthly. Vested tokens accumulate until claimed.

## Creating a Stream

```javascript
const treasury = await ethers.getContractAt("Treasury", addresses.Treasury);

// Create a 6-month stream of 60,000 VGRD
const now = Math.floor(Date.now() / 1000);
const sixMonths = 180 * 24 * 60 * 60;

await treasury.createStream(
  recipientAddress,
  addresses.VGRDToken,
  ethers.parseEther("60000"),
  now,              // startTime
  now + sixMonths   // endTime
);
```

## Claiming from a Stream

Recipients claim their vested tokens:

```javascript
await treasury.claimStream(streamId);
// Transfers all currently vested (unclaimed) tokens to the recipient
```

## Use Cases

### Contributor Compensation

Long-term contributors (core developers, community managers, content creators) can receive ongoing compensation through payment streams rather than lump-sum payments. This:

- Ensures sustained engagement (leaving the project means forfeiting unvested tokens)
- Reduces treasury depletion risk (tokens are released gradually)
- Provides predictable income for contributors

### Advisor Agreements

Advisors and strategic partners can receive VGRD compensation through streams with defined vesting periods, mirroring traditional advisor equity vesting arrangements.

### Founding Team Vesting

!!! warning "Future Feature"
    The team's 350M VGRD allocation (currently held by the deployer wallet) is not currently subject to on-chain vesting. Implementing Treasury streams for team tokens — with appropriate cliff and vesting periods — is a planned governance milestone that would significantly improve the protocol's credibility with institutional stakeholders.

## Stream Management

Streams, once created, follow their vesting schedule automatically. The current contract does not support:

- Cancelling a stream (no clawback)
- Modifying a stream's terms (amount, duration)
- Pausing a stream

These limitations are conservative by design — they protect recipients from having their compensation altered unilaterally. Any changes would need to be implemented through contract upgrades approved by governance.
