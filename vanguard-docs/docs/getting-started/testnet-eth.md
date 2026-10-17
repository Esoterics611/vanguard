# Acquiring Testnet ETH

You need a small amount of test ETH on Base Sepolia to pay for gas fees (transaction costs). Test ETH has no monetary value — it exists solely for testing.

## How Much Do You Need?

Vanguard transactions are inexpensive. Here are typical gas costs on Base Sepolia:

| Transaction | Approximate Gas Cost |
|-------------|---------------------|
| Enlist in a squad | ~0.0001 ETH |
| Create an objective | ~0.0002 ETH |
| Create a task | ~0.0002 ETH |
| Self-assign a task | ~0.0001 ETH |
| Submit task | ~0.0001 ETH |
| Approve task | ~0.0003 ETH |
| Claim rewards | ~0.0002 ETH |
| Cast a governance vote | ~0.0002 ETH |

**Recommendation:** 0.01 test ETH is sufficient for hundreds of transactions.

## Faucets (Free Test ETH)

Faucets are websites that distribute free test ETH. Here are the most reliable options for Base Sepolia:

### Option 1: Alchemy Faucet
1. Go to [faucet.alchemy.com](https://faucet.alchemy.com)
2. Select "Base Sepolia"
3. Enter your wallet address
4. Click "Send me ETH"
5. Wait ~30 seconds for the transaction to confirm

### Option 2: Coinbase Faucet
1. Go to the Base faucet at [faucet.base.org](https://faucet.base.org)
2. Connect your wallet or enter your address
3. Request test ETH

### Option 3: QuickNode Faucet
1. Go to [faucet.quicknode.com/base/sepolia](https://faucet.quicknode.com/base/sepolia)
2. Enter your wallet address
3. Complete any verification
4. Receive test ETH

!!! tip "Faucet Limits"
    Most faucets limit requests to once per day per address. If one faucet is empty or rate-limited, try another.

## Verifying Your Balance

After requesting test ETH:

1. Open MetaMask (make sure you're on Base Sepolia network)
2. Your ETH balance should update within 30 seconds
3. You can also check on the block explorer: `https://base-sepolia.blockscout.com/address/YOUR_ADDRESS`

## Troubleshooting

**"Transaction failed: insufficient funds for gas"**
:   You need more test ETH. Visit a faucet.

**"Faucet says I already requested today"**
:   Most faucets have a 24-hour cooldown. Try a different faucet or wait until tomorrow.

**"Balance shows 0 even after faucet confirmed"**
:   Make sure MetaMask is set to the Base Sepolia network (Chain ID 84532), not Ethereum Mainnet or another network.
