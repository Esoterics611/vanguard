# Vanguard DAO Protocol Guide

## The Definitive Reference for Participants, Developers, and Institutional Stakeholders

---

**Version:** 1.0.0 | **Network:** Base Sepolia (Testnet) | **Last Updated:** April 2026

---

## What Is This Document?

This guide is the authoritative reference for the Vanguard DAO protocol. It is written for three audiences:

1. **Participants** — individuals who want to join the DAO, complete tasks, earn VGRD tokens, and advance through the rank system.
2. **Developers** — engineers who want to integrate with, build on, or contribute to the Vanguard smart contract system.
3. **Institutional Stakeholders** — finance professionals, analysts, and advisors who need to evaluate the protocol's economic model, governance structure, and risk profile.

This document assumes no prior knowledge of Vanguard. It does assume basic familiarity with Ethereum wallets, ERC-20 tokens, and decentralized applications. If you are new to these concepts, begin with [Prerequisites](getting-started/prerequisites.md).

---

## How This Guide Is Organized

| Part | Title | Audience | Description |
|------|-------|----------|-------------|
| I | [Introduction](introduction/overview.md) | Everyone | What Vanguard is, why it exists, and how the pieces fit together |
| II | [Getting Started](getting-started/prerequisites.md) | Participants | Wallet setup, testnet ETH, connecting, and your first enlistment |
| III | [The Rank System](rank-system/overview.md) | Everyone | The 12-rank hierarchy, promotion mechanics, and authority matrix |
| IV | [VGRD Token Economics](tokenomics/overview.md) | Everyone | Token supply, distribution, reward mechanics, and valuation framework |
| V | [Core Operations](operations/overview.md) | Participants | Bounties, objectives, tasks — the day-to-day work of the DAO |
| VI | [Governance](governance/model.md) | Everyone | Proposals, voting, execution, and the legislative process |
| VII | [Treasury & Finance](treasury/overview.md) | Stakeholders | Reserve management, payment streams, and financial controls |
| VIII | [Developer Guide](developer-guide/setup.md) | Developers | Environment setup, contract integration, testing, and deployment |
| IX | [Contract Reference](contract-reference/overview.md) | Developers | Function-level documentation for all 8 smart contracts |
| X | [Risk & Compliance](risk-and-compliance/contract-risk.md) | Stakeholders | Smart contract risk, operational risk, and regulatory considerations |

---

## Conventions Used in This Guide

!!! info "Live Features"
    Content in standard formatting describes features that are **deployed and functional** on Base Sepolia today.

!!! warning "Future Feature"
    Content marked with this label describes features that are **planned but not yet implemented**. These sections are included for completeness and to give stakeholders visibility into the protocol's roadmap.

**Code examples** use Solidity for contract interactions and JavaScript/TypeScript for frontend integration:

```solidity
// Solidity — what the contract does
function enlist(uint256 _squadId) external { ... }
```

```typescript
// TypeScript — how you call it from an application
const tx = await registry.enlist(squadId);
await tx.wait();
```

**Addresses** are shown in abbreviated form (`0x2Ef7...7493`) in running text and in full form in reference tables.

---

## Quick Paths

**"I want to join the DAO and start earning."**
:   Start at [Prerequisites](getting-started/prerequisites.md), then follow through to [Your First Enlistment](getting-started/first-enlistment.md).

**"I want to understand the economics before participating."**
:   Read [Token Overview](tokenomics/overview.md) and [Valuation Framework](tokenomics/valuation.md).

**"I want to build an application on top of Vanguard."**
:   Jump to [Developer Guide: Environment Setup](developer-guide/setup.md).

**"I need to evaluate this protocol for my firm."**
:   Read [Architecture at a Glance](introduction/architecture.md), then [Risk & Compliance](risk-and-compliance/contract-risk.md).

---

## Protocol Status

| Component | Status | Notes |
|-----------|--------|-------|
| Smart Contracts (8) | :material-check-circle:{ .green } Deployed | Base Sepolia, redeployed April 2026 |
| Contract Verification | :material-alert-circle:{ .yellow } Pending | BaseScan verification not yet completed |
| Web UI | :material-check-circle:{ .green } Built | 11 pages, mock data only |
| Web3 Integration | :material-close-circle:{ .red } Not Started | UI does not yet connect to contracts |
| Mobile App | :material-check-circle:{ .green } Built | Flutter app, Firebase backend |
| Firebase Backend | :material-check-circle:{ .green } Configured | Cloud Functions, Firestore |
| Mainnet Deployment | :material-close-circle:{ .red } Not Started | Targeting Base mainnet |
