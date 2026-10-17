# Prerequisites

Before you can participate in the Vanguard protocol, you need three things:

1. An Ethereum-compatible wallet
2. Test ETH for gas fees
3. A basic understanding of blockchain transactions

This chapter covers each prerequisite in detail.

## 1. An Ethereum-Compatible Wallet

A wallet is your identity on the blockchain. It holds your tokens, signs transactions, and serves as your login credential for all Vanguard interactions. Unlike traditional accounts, there is no username, password, or email — your wallet address *is* your identity.

### Recommended: MetaMask

MetaMask is the most widely supported Ethereum wallet. It runs as a browser extension (Chrome, Firefox, Brave, Edge) and as a mobile app (iOS, Android).

**What MetaMask provides:**

- A unique Ethereum address (e.g., `0x41521c37dB02956185437C4e2461261A321073E1`)
- A secure keystore for your private key
- A transaction signing interface (confirms what you're approving before you send it)
- Network switching (so you can connect to Base Sepolia)

### Alternative Wallets

Any wallet that supports the EIP-1193 standard (the standard interface for Ethereum wallets in browsers) will work with Vanguard. Common alternatives include:

| Wallet | Type | Notes |
|--------|------|-------|
| MetaMask | Browser extension + Mobile | Most widely supported |
| Coinbase Wallet | Browser extension + Mobile | Tight Base integration |
| Rainbow | Mobile | Clean UX, good for beginners |
| Rabby | Browser extension | Advanced features, chain detection |

## 2. Understanding of Blockchain Transactions

Every action you take in Vanguard (enlisting, creating tasks, voting) is a **blockchain transaction**. Here is what you need to know:

### Transactions Cost Gas

Every transaction requires a small fee ("gas") paid in ETH. On Base Sepolia (testnet), you pay with test ETH that has no real value. On Base Mainnet, you would pay with real ETH — but Base fees are very low (typically under $0.01 per transaction).

### Transactions Are Irreversible

Once a transaction is confirmed on the blockchain, it cannot be undone. There is no "undo" button. If you enlist in the wrong squad, you cannot un-enlist. If you approve a task, the reward distribution is triggered immediately and permanently.

### Transactions Require Confirmation

Your wallet will ask you to confirm every transaction before it is sent. Read the confirmation screen carefully — it shows you what contract you're interacting with, what function you're calling, and how much gas you'll pay.

### Transactions Take a Few Seconds

On Base, transactions are typically confirmed within 2 seconds. Your wallet will show a "pending" state during this time, then switch to "confirmed."

## 3. What You Will NOT Need

- **No email address.** Your wallet is your identity.
- **No KYC or ID verification.** Vanguard is permissionless — anyone with a wallet can enlist.
- **No minimum token balance.** You do not need to hold VGRD to enlist. You earn VGRD by completing tasks.
- **No approval from existing members.** Enlistment is open (though invite-based enlistment offers benefits).

## Technical Requirements

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| Browser | Chrome 90+ / Firefox 90+ | Latest version |
| Wallet | MetaMask 10+ | MetaMask 11+ |
| Network | Internet connection | Stable broadband |
| ETH Balance | ~0.001 test ETH | ~0.01 test ETH |
