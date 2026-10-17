# Governance Model

Vanguard's governance is a **weighted voting system** where both token holdings and rank determine influence. This creates a meritocratic governance structure that rewards sustained contribution over pure capital deployment.

## Governance Design Principles

1. **Dual-weight voting:** Voting power = token balance x rank weight. Neither tokens alone nor rank alone is sufficient for dominant governance influence.

2. **Earned proposal rights:** Only Captains or holders of 100,000+ VGRD can submit proposals. This prevents spam while ensuring that governance participants have demonstrated commitment.

3. **On-chain execution:** Passed proposals execute automatically via contract calls. There is no manual step between a successful vote and its implementation.

4. **Time-bounded deliberation:** A fixed voting period (~1 week) ensures proposals are resolved in a reasonable timeframe.

## Governance Parameters

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| **Proposal Threshold** | 100,000 VGRD or CPT rank | Prevents spam, ensures proposer has skin-in-the-game |
| **Voting Delay** | 1 block (~2 seconds) | Minimal delay to allow snapshot creation |
| **Voting Period** | 45,818 blocks (~1 week) | Sufficient time for deliberation |
| **Quorum** | 4% of total supply | 40,000,000 VGRD worth of voting power must participate |
| **Vote Types** | For, Against, Abstain | Standard three-choice voting |

## Governance Scope

The VanguardDAO contract can execute arbitrary contract calls on any Vanguard contract where it holds the appropriate role. In practice, governance can:

| Action Category | Examples |
|----------------|---------|
| **Parameter changes** | Adjust rank multipliers, voting period, quorum, proposal threshold |
| **Treasury management** | Withdraw from Treasury, create payment streams, fund bounties |
| **Role management** | Grant or revoke roles across contracts (MINTER_ROLE, PAUSER_ROLE, etc.) |
| **Emergency actions** | Pause token, pause contracts |
| **Protocol upgrades** | Deploy new contracts, update contract links |

## Current Governance State

!!! info "Transitional Governance"
    The protocol is in a **transitional governance state**. The deployer wallet currently holds most administrative roles (DEFAULT_ADMIN_ROLE, DAO_ROLE, EXECUTOR_ROLE). The VanguardDAO contract is deployed and functional but has not yet received these roles.

    Full decentralization requires:

    1. Transferring DAO_ROLE to the VanguardDAO contract
    2. Transferring EXECUTOR_ROLE to the VanguardDAO contract
    3. Renouncing DEFAULT_ADMIN_ROLE from the deployer (irreversible)

    These transfers will be executed as governance proposals once the community is sufficiently established.
