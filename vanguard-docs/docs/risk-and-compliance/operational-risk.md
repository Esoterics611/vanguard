# Operational Risk

Beyond smart contract vulnerabilities, the Vanguard protocol faces operational risks — risks arising from how the system is used, managed, and governed.

## 1. Key Person Risk

**Risk: HIGH (Current State)**

The deployer wallet is a single point of failure. If the private key is:

- **Lost:** Administrative functions become permanently inaccessible. The protocol continues to operate but cannot be upgraded, paused, or have parameters changed.
- **Stolen:** An attacker gains full control over all administrative functions, including Treasury withdrawals and token minting.
- **Compromised by social engineering:** Same impact as theft.

**Mitigation:** Transfer administrative roles to the VanguardDAO contract or a multisig wallet. Use a hardware wallet for the deployer key. Implement a key rotation procedure.

## 2. Governance Participation Risk

**Risk: MEDIUM**

If governance participation is too low:

- Quorum (4% of supply) may not be reached, preventing any proposals from passing
- A small group of active voters can dominate governance decisions
- Critical updates or parameter changes cannot be implemented

**Indicators to monitor:**

- Number of unique voters per proposal
- Average quorum coverage (actual participation vs. required)
- Time to reach quorum

## 3. Rank Inflation Risk

**Risk: MEDIUM**

If promotions are too easy or too frequent:

- Average multiplier across the DAO increases
- RewardPool depletes faster
- Token inflation accelerates
- Economic sustainability is threatened

**Scenario analysis:**

| Avg Multiplier | Pool Burn Rate Increase | Impact |
|---------------|------------------------|--------|
| 1.5x | 50% faster | Moderate — pool still lasts years |
| 3.0x | 200% faster | Significant — pool lasts ~1.5 years at 50 soldiers |
| 6.0x | 500% faster | Critical — pool could deplete within months |

## 3. Task Quality Risk

**Risk: MEDIUM**

The protocol's value depends on the quality of work produced. Risks include:

- **Rubber-stamping:** Leaders approve low-quality work to help friends earn rewards
- **Task padding:** Creating many small tasks to accumulate task counts for promotion
- **Self-dealing:** Leaders creating tasks and approving their own associates

**Current mitigations:**

- Task approval requires a different address than the submitter
- Rank requirements for task creation prevent junior members from padding

**Missing mitigations:**

- No quality review mechanism beyond the approving leader's judgment
- No dispute resolution for contested approvals
- No reputation system that penalizes approvers who rubber-stamp

## 4. Economic Sustainability Risk

**Risk: MEDIUM-HIGH (Long Term)**

The RewardPool is finite (400M VGRD). Without additional token inflows or controlled minting, the pool will eventually deplete.

**Break-even conditions:** The protocol needs to either:

1. Generate external revenue that purchases VGRD to replenish the pool
2. Enable controlled minting through governance (inflationary)
3. Reduce reward rates as the pool shrinks (deflationary pressure)
4. Transition to a fee-based model where bounty creators fund rewards directly

None of these mechanisms are currently implemented. This is a fundamental economic sustainability question that governance will need to address.

## 5. Network and Infrastructure Risk

| Risk | Description | Likelihood | Impact |
|------|-------------|-----------|--------|
| Base network outage | L2 sequencer goes down | Low | High (no transactions possible) |
| RPC endpoint failure | Provider unavailable | Medium | Medium (use backup RPC) |
| Block explorer downtime | BaseScan unavailable | Medium | Low (contracts still work) |
| Gas price spike | Unusual L1 congestion | Low | Low (Base fees are typically minimal) |

## 6. Transition Risk

**Risk: HIGH (Planned)**

The transition from deployer-controlled to DAO-controlled governance is a critical operational milestone with significant risk:

- Premature transfer before sufficient community maturity could lock out necessary administrative actions
- Incorrect role configuration during transfer could create permanently broken access control
- The transfer itself requires careful sequencing (grant roles to DAO before revoking from deployer)

**Recommended approach:**

1. Grant roles to VanguardDAO contract (both deployer and DAO hold roles)
2. Test governance proposals that exercise each role
3. After successful testing, renounce deployer roles one by one
4. Final step: renounce DEFAULT_ADMIN_ROLE (irreversible)
