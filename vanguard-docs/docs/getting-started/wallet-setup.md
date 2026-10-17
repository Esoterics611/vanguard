# Wallet Setup

This page walks you through installing MetaMask, creating a wallet, and adding the Base Sepolia network.

## Step 1: Install MetaMask

1. Go to [metamask.io](https://metamask.io/download/)
2. Click "Install MetaMask for Chrome" (or your browser of choice)
3. Follow the installation prompts
4. When prompted, choose "Create a new wallet"

### Secure Your Recovery Phrase

During wallet creation, MetaMask will show you a **12-word recovery phrase** (also called a seed phrase). This is the master key to your wallet.

!!! danger "Critical Security"
    - **Write down your recovery phrase on paper.** Do not store it digitally.
    - **Never share your recovery phrase with anyone.** No legitimate service will ever ask for it.
    - **If someone gains your recovery phrase, they control your wallet and all assets in it.**

For testnet participation, the risk is lower (test tokens have no value), but practicing good security habits now prepares you for mainnet.

## Step 2: Add Base Sepolia Network

MetaMask comes pre-configured with Ethereum Mainnet. You need to add the Base Sepolia testnet.

### Option A: Manual Configuration

1. Open MetaMask
2. Click the network selector (top of the extension)
3. Click "Add network" then "Add a network manually"
4. Enter these values:

| Field | Value |
|-------|-------|
| Network Name | Base Sepolia |
| New RPC URL | `https://sepolia.base.org` |
| Chain ID | `84532` |
| Currency Symbol | `ETH` |
| Block Explorer URL | `https://sepolia.basescan.org` |

5. Click "Save"

### Option B: Automatic (via Chainlist)

1. Go to [chainlist.org](https://chainlist.org)
2. Search for "Base Sepolia"
3. Click "Add to MetaMask"
4. Confirm in MetaMask

## Step 3: Switch to Base Sepolia

1. Open MetaMask
2. Click the network selector at the top
3. Select "Base Sepolia"
4. Your address remains the same — only the network changes

You should now see "Base Sepolia" in the network selector and a balance of 0 ETH. The next step is acquiring test ETH.

## Understanding Your Wallet Address

Your wallet address looks like this: `0x41521c37dB02956185437C4e2461261A321073E1`

This address is:

- **Public** — anyone can see your transaction history and token balances on the block explorer
- **Permanent** — it does not change and cannot be reassigned
- **Your identity** in Vanguard — it is the key that links you to your soldier record, rank, tasks, and rewards
- **The same on all networks** — your address on Base Sepolia is the same as on Base Mainnet and Ethereum Mainnet

## Multiple Wallets

You may use multiple wallet addresses with Vanguard, but each address is a separate soldier with its own rank, task history, and token balance. There is no way to merge two soldier records.

For testing purposes, it can be useful to have two wallets — one acting as a leader and one as a contributor — to test the full task workflow (create task, assign, submit, approve).
