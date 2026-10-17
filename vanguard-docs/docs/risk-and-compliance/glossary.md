# Glossary

A comprehensive glossary of terms used throughout this guide. Terms are organized alphabetically.

---

**ABI (Application Binary Interface)**
:   A JSON specification that defines how to interact with a smart contract — its functions, parameters, and return types. Required by any application that calls contract functions.

**AccessControl**
:   An OpenZeppelin smart contract pattern that restricts function access based on roles. Each role is a bytes32 hash, and addresses can be granted or revoked from roles.

**Alpha Squad**
:   The first squad in the ArmyRegistry, created automatically at deployment (Unit ID 1). The default squad for new enlistees.

**ArmyRegistry**
:   The Vanguard smart contract that manages membership. Tracks soldiers, ranks, units, and organizational hierarchy.

**Base**
:   An Ethereum Layer 2 (L2) network built on the OP Stack. Provides low transaction costs and fast confirmation times. Vanguard's target deployment network.

**Base Sepolia**
:   The test network for Base (Chain ID 84532). All current Vanguard contracts are deployed here.

**Block Explorer**
:   A web application that allows users to view blockchain data — transactions, addresses, contracts, and token transfers. BaseScan is the block explorer for Base.

**Bounty**
:   A funded project in the Vanguard protocol. Created by Captains, funded with VGRD, and containing one or more objectives. Managed by the BountyEscrow contract.

**BountyEscrow**
:   The Vanguard smart contract that holds bounty funds in escrow and releases them as objectives are completed.

**Callsign**
:   An optional display name for a soldier (e.g., "IRONFORGE"). Stored on-chain in the ArmyRegistry.

**Chain ID**
:   A unique identifier for a blockchain network. Base Sepolia is 84532; Base Mainnet is 8453.

**Circulating Supply**
:   The amount of VGRD tokens held by individuals (not locked in contracts). Calculated as Total Supply minus contract-held balances.

**Company**
:   The largest organizational unit in the Vanguard hierarchy. Contains platoons.

**CPT (Captain)**
:   The highest rank (11) in the Vanguard system. Can create bounties, submit governance proposals, and promote all lower ranks. Reward multiplier: 15.0x.

**DAO (Decentralized Autonomous Organization)**
:   An organization governed by smart contracts and token holder votes rather than centralized management. Vanguard DAO is the collective entity.

**DEFAULT_ADMIN_ROLE**
:   The master administrative role in OpenZeppelin's AccessControl. Can grant and revoke all other roles.

**Deployer**
:   The wallet address (`0x41521c37...`) that deployed the Vanguard contracts. Currently holds most administrative roles.

**DISTRIBUTOR_ROLE**
:   The role that allows triggering reward distribution in the RewardPool. Held by the TaskRegistry contract.

**EIP-2612**
:   An Ethereum standard for gasless token approvals (permits). Allows users to sign a message instead of sending a transaction.

**Enlisted**
:   The lowest tier of ranks (PVT, PV2, PFC, CPL). Individual contributors who complete tasks.

**Enlistment**
:   The act of joining the DAO by calling ArmyRegistry.enlist(). Creates a soldier record at PVT rank.

**ERC-20**
:   The standard interface for fungible tokens on Ethereum. VGRD follows this standard.

**Escrow**
:   A contract that holds tokens on behalf of parties until predefined conditions are met. BountyEscrow holds bounty funds until objectives complete.

**ethers.js**
:   A JavaScript library for interacting with the Ethereum blockchain. Used in the Vanguard contracts project (v6).

**Faucet**
:   A web service that distributes free testnet ETH for development and testing.

**Gas**
:   The fee paid to process a blockchain transaction. Paid in ETH on Base.

**Governance**
:   The process by which the DAO makes collective decisions. Implemented via the VanguardDAO contract (proposals, voting, execution).

**Guest**
:   Rank 0 — a wallet that has not enlisted. Has no multiplier, no voting power, and cannot participate in the protocol.

**Hardhat**
:   A development framework for Ethereum smart contracts. Used by Vanguard for compilation, testing, deployment, and verification.

**IPFS (InterPlanetary File System)**
:   A distributed file storage system. Task submissions reference IPFS hashes pointing to deliverables.

**Leader Bonus**
:   An additional VGRD reward distributed to unit leaders when an objective is fully completed.

**Mainnet**
:   The production blockchain network where tokens have real economic value. Vanguard targets Base Mainnet.

**MetaMask**
:   A popular Ethereum wallet browser extension and mobile app.

**MINTER_ROLE**
:   The role that allows minting new VGRD tokens. Held by the RewardPool contract.

**Multiplier**
:   See Reward Multiplier.

**NCO (Non-Commissioned Officer)**
:   The middle tier of ranks (SGT, SSG, SFC, 1SG). Team leaders who create tasks and review submissions.

**Objective**
:   A workstream within a bounty. Contains one or more tasks. Managed by the TaskRegistry.

**OBC (Officer Basic Course)**
:   A training qualification required for promotion to 2LT and 1LT.

**Officer**
:   The highest tier of ranks (2LT, 1LT, CPT). Strategic leaders who create bounties and governance proposals.

**PAUSER_ROLE**
:   The role that allows pausing and unpausing the VGRDToken.

**Payment Stream**
:   A time-based vesting schedule in the Treasury that releases tokens to a recipient over a defined period.

**Pending Rewards**
:   VGRD rewards accrued but not yet claimed by a soldier. Stored in the RewardPool contract.

**PLDC (Primary Leadership Development Course)**
:   A training qualification required for promotion from CPL to SGT.

**Platoon**
:   An organizational unit containing sections.

**Proposal**
:   A formal governance request containing contract calls to execute if the vote passes.

**Proposal Threshold**
:   The minimum VGRD balance (100,000) required to submit a proposal (waived for CPT+ rank).

**Provider**
:   A connection to the blockchain network for reading data. Does not require a wallet.

**PVT (Private)**
:   The starting rank (1) for newly enlisted soldiers. Reward multiplier: 1.0x, voting power: 1.

**Quorum**
:   The minimum total voting power that must participate for a governance vote to be valid. Set at 4% of total VGRD supply.

**Rank**
:   A soldier's position in the hierarchy (0-11). Determines reward multiplier, voting power, and access to protocol functions.

**RankManager**
:   The Vanguard smart contract that manages promotions, multipliers, and training requirements.

**Reentrancy**
:   A class of smart contract vulnerability where a malicious contract calls back into the victim during a token transfer. Protected by ReentrancyGuard.

**Reward Multiplier**
:   A rank-based factor applied to task base rewards. Stored as an integer where 100 = 1.0x.

**RewardPool**
:   The Vanguard smart contract that calculates and distributes rank-adjusted VGRD rewards.

**RPC (Remote Procedure Call)**
:   The protocol used to communicate with blockchain nodes. Base Sepolia RPC: `https://sepolia.base.org`.

**Section**
:   An organizational unit containing two or more squads.

**Signer**
:   A wallet connected to a provider that can sign and send transactions.

**Snapshot**
:   A record of all token balances at a specific block number. Used for fair governance voting.

**Soldier**
:   Any wallet address that has enlisted in the ArmyRegistry. Has a rank, unit assignment, and work history.

**Squad**
:   The smallest organizational unit (4-10 soldiers). The basic working team.

**Squad Split**
:   The automatic division of a squad exceeding 10 members into two squads under a new section.

**Task**
:   The atomic unit of work. Has a title, description, VGRD reward, and lifecycle (OPEN → ASSIGNED → SUBMITTED → APPROVED).

**TaskRegistry**
:   The Vanguard smart contract that manages objectives and tasks.

**Testnet**
:   A practice blockchain network where tokens have no real value. Used for development and testing.

**Treasury**
:   The Vanguard smart contract that holds the DAO's reserve fund (250M VGRD) and manages payment streams.

**VGRD**
:   The native ERC-20 token of the Vanguard protocol. Total supply: 1 billion.

**VanguardDAO**
:   The governance smart contract. Handles proposals, weighted voting, and on-chain execution.

**Vesting**
:   The gradual release of tokens over time. Implemented via Treasury payment streams.

**Voting Period**
:   The window during which governance votes can be cast (~1 week / 45,818 blocks on Base).

**Voting Power**
:   A voter's influence, calculated as `token_balance × rank_voting_weight`.

**Wallet**
:   A cryptographic key pair (public address + private key) used to interact with the blockchain. Your identity in Vanguard.
