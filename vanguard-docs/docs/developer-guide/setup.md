# Environment Setup

This page walks developers through setting up a local development environment for working with the Vanguard smart contracts and web UI.

## Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| Node.js | 18+ | Runtime for Hardhat, scripts, and web UI |
| npm | 9+ | Package management |
| Git | 2.30+ | Source control |
| MetaMask | Latest | Wallet for testnet interaction |
| Code editor | VS Code recommended | Solidity and TypeScript development |

## Repository Structure

```
vanguard/
  contracts/           # Smart contracts (Hardhat + Solidity)
    contracts/         # .sol source files
    scripts/           # Deploy, test, verify scripts
    artifacts/         # Compiled ABIs (generated)
    deployed-addresses.json  # Live contract addresses
    hardhat.config.js  # Network and compiler config
    .env               # Private key, API keys

  vanguard-ui/         # Web frontend (SvelteKit + Svelte 5)
    src/
      lib/             # Components, stores, types
      routes/          # SvelteKit pages
    package.json

  vanguard-docs/       # This documentation (MkDocs)

  backend/             # Firebase Cloud Functions
  lib/                 # Flutter mobile app
  docs/                # Design specs and guides
```

## Setting Up the Contracts Environment

```bash
# Clone the repository
git clone <repo-url>
cd vanguard/contracts

# Install dependencies
npm install

# Create environment file
cp .env.example .env  # or create manually
```

### Environment Variables

Create `contracts/.env` with:

```env
# Required: Your wallet's private key (for deploying and testing)
PRIVATE_KEY=0xYOUR_PRIVATE_KEY_HERE

# Optional: For contract verification on BaseScan
BASESCAN_API_KEY=your_basescan_api_key

# Optional: For enhanced RPC (faster, more reliable)
ALCHEMY_API_KEY=your_alchemy_key
```

!!! danger "Private Key Security"
    Never commit your `.env` file to version control. The `.gitignore` already excludes it. For testnet, use a dedicated development wallet — not a wallet that holds real assets.

### Compile Contracts

```bash
npx hardhat compile
```

This generates the ABI files in `artifacts/contracts/*/` which are needed for frontend integration.

### Run Local Tests

```bash
npm test
```

### Test Against Deployed Contracts

```bash
npm run test:deployed
```

This runs `scripts/test-deployed.js` against the live Base Sepolia contracts. Requires `PRIVATE_KEY` in `.env` and test ETH on Base Sepolia.

## Setting Up the Web UI

```bash
cd vanguard/vanguard-ui

# Install dependencies
npm install

# Start development server
npm run dev
```

The dev server runs at `http://localhost:5173`. The UI currently uses mock data — see [Contract Integration](integration.md) for connecting it to live contracts.

## Setting Up This Documentation

```bash
cd vanguard/vanguard-docs

# Install MkDocs (Python required)
pip install -r requirements.txt

# Serve locally
mkdocs serve
```

The docs server runs at `http://localhost:8000`.

## Useful Commands Reference

### Contracts

| Command | What It Does |
|---------|-------------|
| `npx hardhat compile` | Compile all Solidity contracts |
| `npm test` | Run local Hardhat tests |
| `npm run test:deployed` | Test against live Base Sepolia contracts |
| `npm run deploy:sepolia` | Deploy all contracts to Base Sepolia |
| `npm run verify` | Run enlistment verification script |
| `npx hardhat console --network baseSepolia` | Interactive console connected to testnet |
| `npx hardhat verify --network baseSepolia <address> <args>` | Verify a contract on BaseScan |

### Web UI

| Command | What It Does |
|---------|-------------|
| `npm run dev` | Start dev server with hot reload |
| `npm run build` | Production build |
| `npm run preview` | Preview production build locally |
| `npm run check` | TypeScript type checking |

## IDE Configuration

### VS Code Extensions (Recommended)

- **Solidity** (Juan Blanco) — Syntax highlighting and linting for .sol files
- **Svelte for VS Code** — Svelte component support
- **Tailwind CSS IntelliSense** — Class name autocomplete
- **ESLint** — JavaScript/TypeScript linting
