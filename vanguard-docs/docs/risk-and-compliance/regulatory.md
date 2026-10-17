# Regulatory Considerations

!!! note "Not Legal Advice"
    This section provides general information about regulatory considerations relevant to the Vanguard protocol. It is not legal advice. The protocol's creators, contributors, and participants should consult qualified legal counsel in their respective jurisdictions for guidance specific to their circumstances.

## Token Classification

The regulatory treatment of VGRD depends on how it is classified under applicable securities law. Key frameworks:

### United States — Howey Test

The SEC applies the Howey Test to determine whether a digital asset is a security:

1. **Investment of money** — Purchasing VGRD on a secondary market involves investment of money
2. **Common enterprise** — The DAO constitutes a common enterprise
3. **Expectation of profits** — Whether holders expect price appreciation
4. **From the efforts of others** — Whether value derives primarily from the efforts of identifiable third parties

**VGRD's characteristics that may reduce securities risk:**

- VGRD is primarily earned through work (task completion), not purchased
- The protocol is designed for utility (governance, compensation), not speculation
- Value is created by the collective, not by identifiable promoters
- There is no investment marketing or promises of returns

**VGRD's characteristics that may increase securities risk:**

- The deployer holds 35% of supply (concentration)
- Token value could appreciate based on protocol adoption
- Early participants have an informational advantage

### International Frameworks

Regulatory approaches vary significantly by jurisdiction:

| Jurisdiction | Key Framework | VGRD Likely Classification |
|-------------|---------------|--------------------------|
| United States | Howey Test (SEC) | Requires analysis |
| European Union | MiCA Regulation | Utility token provisions may apply |
| United Kingdom | FCA Crypto Asset taxonomy | Likely unregulated utility token |
| Singapore | MAS Payment Services Act | Likely digital payment token |
| Japan | FSA Virtual Currency regulations | May require registration |

## DAO Legal Structure

DAOs face a fundamental legal question: what legal entity, if any, do they constitute?

**Options under consideration for Vanguard:**

1. **No formal entity** — The DAO operates purely as a smart contract protocol with no legal wrapper. Risk: members may be treated as a general partnership with unlimited personal liability.

2. **Foundation** — A non-profit foundation (e.g., in Switzerland, Cayman Islands, or Singapore) that serves as the legal wrapper for the DAO. Common in crypto protocols.

3. **LLC (Wyoming DAO LLC)** — Wyoming allows DAOs to register as LLCs, providing limited liability to members while preserving decentralized governance.

!!! warning "Future Feature"
    No legal entity has been established for Vanguard DAO. This is a priority item for the protocol's transition to production and mainnet deployment.

## Tax Implications

Participants earning VGRD through task completion may have tax obligations:

- **VGRD earned as compensation** is likely taxable as income at the fair market value at the time of receipt (in most jurisdictions)
- **VGRD sold or exchanged** may trigger capital gains/losses
- **VGRD used in governance** generally does not create a taxable event

On testnet, VGRD has no monetary value and therefore has no tax implications. Tax obligations arise only when VGRD has real economic value (i.e., after mainnet deployment and market pricing).

## Anti-Money Laundering (AML)

The protocol is currently permissionless — anyone with a wallet can enlist and participate. There is no KYC (Know Your Customer) or AML verification.

**Considerations for mainnet:**

- Permissionless participation is a core design principle of the protocol
- Implementing KYC would require a legal entity and identity verification provider
- Some jurisdictions may require AML compliance for token issuers or service providers
- The invite system could be extended with optional identity verification tiers

## Compliance Roadmap

!!! warning "Future Feature"
    The following compliance milestones are planned but not yet executed:

    - [ ] Legal opinion on VGRD token classification
    - [ ] Establishment of legal entity (foundation or DAO LLC)
    - [ ] Terms of service for protocol participants
    - [ ] Privacy policy for any off-chain data collection
    - [ ] Tax guidance documentation for participants
    - [ ] Evaluation of AML/KYC requirements by jurisdiction
    - [ ] Regulatory engagement strategy
