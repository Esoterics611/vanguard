// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @notice Engine-level registry interface — verticals satisfy this via BaseRegistry.
interface IBaseRegistry {
    function isEnlisted(address wallet) external view returns (bool);
    function getRankIndex(address soldier) external view returns (uint8);
}

/**
 * @title BaseGovernance
 * @notice Abstract DAO governance shared across Vanguard verticals.
 *
 * Vote weight = `tokenBalance(voter) × rankMultiplierBps / 100`, where the
 * voter's rank is delivered via an EIP-712 RankAttestation signed by the
 * backend `attestationSigner`. This is the C1 hardening pattern lifted from
 * ChayoleiGovernance: the caller cannot self-declare a rank.
 *
 * Concrete verticals override `_rankMultiplierBps` and `_rankCount` to define
 * their rank schema.
 */
abstract contract BaseGovernance is AccessControl, Pausable, ReentrancyGuard, EIP712 {
    using ECDSA for bytes32;

    // ─── Roles ───────────────────────────────────────────────────────────
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");

    // ─── EIP-712 typehash ────────────────────────────────────────────────
    bytes32 private constant RANK_ATTESTATION_TYPEHASH = keccak256(
        "RankAttestation(address voter,uint8 rankIndex,uint256 proposalId,uint256 nonce,uint256 expiry)"
    );

    // ─── External dependencies ───────────────────────────────────────────
    IERC20 public immutable vgrdToken;
    IBaseRegistry public immutable registry;
    address public attestationSigner;
    mapping(uint256 => bool) public usedNonces;

    // ─── Proposal model ──────────────────────────────────────────────────
    enum ProposalState { Pending, Active, Succeeded, Defeated, Executed, Cancelled }
    enum VoteType { Against, For, Abstain }

    struct Proposal {
        uint256 id;
        address proposer;
        address[] targets;
        uint256[] values;
        bytes[] calldatas;
        string description;
        uint256 startBlock;
        uint256 endBlock;
        uint256 forVotes;
        uint256 againstVotes;
        uint256 abstainVotes;
        bool executed;
        bool cancelled;
    }

    struct Receipt {
        bool hasVoted;
        VoteType support;
        uint256 votes;
        uint8 rankIndex;
    }

    struct RankAttestation {
        address voter;
        uint8 rankIndex;
        uint256 proposalId;
        uint256 nonce;
        uint256 expiry;
        bytes signature;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => Receipt)) public receipts;

    uint256 public nextProposalId = 1;
    uint256 public votingDelay = 1;
    uint256 public votingPeriod = 45818; // ~1 week on Base
    uint256 public proposalThreshold = 100_000 * 10**18;
    uint256 public quorumPercentage = 4; // 4% of total supply
    uint8 public proposerMinRank;        // set by concrete; rank index threshold for proposing without token threshold

    // ─── Events ──────────────────────────────────────────────────────────
    event ProposalCreated(
        uint256 indexed proposalId,
        address proposer,
        address[] targets,
        uint256[] values,
        bytes[] calldatas,
        string description,
        uint256 startBlock,
        uint256 endBlock
    );
    event VoteCast(
        uint256 indexed proposalId,
        address indexed voter,
        VoteType support,
        uint8 rankIndex,
        uint256 weight,
        uint256 nonce
    );
    event ProposalExecuted(uint256 indexed proposalId);
    event ProposalCancelled(uint256 indexed proposalId);
    event AttestationSignerUpdated(address indexed oldSigner, address indexed newSigner);

    // ─── Constructor ─────────────────────────────────────────────────────
    constructor(
        address admin,
        address _vgrdToken,
        address _registry,
        address _attestationSigner,
        string memory eip712Name,
        uint8 _proposerMinRank
    ) EIP712(eip712Name, "1") {
        require(admin != address(0), "admin zero");
        require(_vgrdToken != address(0), "token zero");
        require(_registry != address(0), "registry zero");
        require(_attestationSigner != address(0), "signer zero");

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(EXECUTOR_ROLE, admin);

        vgrdToken = IERC20(_vgrdToken);
        registry = IBaseRegistry(_registry);
        attestationSigner = _attestationSigner;
        proposerMinRank = _proposerMinRank;

        emit AttestationSignerUpdated(address(0), _attestationSigner);
    }

    // ─── Hooks for concrete verticals ────────────────────────────────────

    /// @dev Rank multiplier in basis points (100 = 1.0x). Index 0 is reserved for non-members.
    function _rankMultiplierBps(uint8 rankIndex) internal view virtual returns (uint256);

    /// @dev Number of valid rank indices (exclusive upper bound on rankIndex).
    function _rankCount() internal pure virtual returns (uint8);

    // ─── Views ───────────────────────────────────────────────────────────

    /// @notice Compute vote weight for a voter at a given rank.
    function getVotingPower(address voter, uint8 rankIndex) public view returns (uint256) {
        require(rankIndex < _rankCount(), "Invalid rank index");
        uint256 balance = vgrdToken.balanceOf(voter);
        if (balance == 0) return 0;
        return (balance * _rankMultiplierBps(rankIndex)) / 100;
    }

    function getProposal(uint256 proposalId) external view returns (Proposal memory) {
        return proposals[proposalId];
    }

    function getReceipt(uint256 proposalId, address voter) external view returns (Receipt memory) {
        return receipts[proposalId][voter];
    }

    /// @notice EIP-712 domain separator — useful for off-chain signers.
    function domainSeparator() external view returns (bytes32) {
        return _domainSeparatorV4();
    }

    function rankAttestationTypehash() external pure returns (bytes32) {
        return RANK_ATTESTATION_TYPEHASH;
    }

    // ─── Propose ─────────────────────────────────────────────────────────
    function propose(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata calldatas,
        string calldata description
    ) external whenNotPaused returns (uint256) {
        require(targets.length == values.length && targets.length == calldatas.length, "Invalid proposal");
        require(targets.length > 0, "Empty proposal");

        uint8 proposerRank = registry.getRankIndex(msg.sender);
        require(
            proposerRank >= proposerMinRank || vgrdToken.balanceOf(msg.sender) >= proposalThreshold,
            "Not eligible to propose"
        );

        uint256 proposalId = nextProposalId++;
        Proposal storage p = proposals[proposalId];
        p.id = proposalId;
        p.proposer = msg.sender;
        p.targets = targets;
        p.values = values;
        p.calldatas = calldatas;
        p.description = description;
        p.startBlock = block.number + votingDelay;
        p.endBlock = p.startBlock + votingPeriod;

        emit ProposalCreated(proposalId, msg.sender, targets, values, calldatas, description, p.startBlock, p.endBlock);
        return proposalId;
    }

    // ─── Vote (EIP-712 rank-attested) ────────────────────────────────────

    /**
     * @notice Cast a vote, authenticating the voter's rank via an EIP-712
     *         RankAttestation signed by the backend attestation signer.
     */
    function castVote(
        uint256 proposalId,
        VoteType support,
        RankAttestation calldata att
    ) external whenNotPaused nonReentrant returns (uint256) {
        require(att.rankIndex < _rankCount(), "Invalid rank index");
        require(att.voter == msg.sender, "Attestation not for caller");
        require(att.proposalId == proposalId, "Attestation proposal mismatch");
        require(block.timestamp < att.expiry, "Attestation expired");
        require(!usedNonces[att.nonce], "Nonce already used");

        bytes32 structHash = keccak256(abi.encode(
            RANK_ATTESTATION_TYPEHASH,
            att.voter,
            att.rankIndex,
            att.proposalId,
            att.nonce,
            att.expiry
        ));
        bytes32 digest = _hashTypedDataV4(structHash);
        address recovered = ECDSA.recover(digest, att.signature);
        require(recovered != address(0) && recovered == attestationSigner, "Invalid attestation");

        require(state(proposalId) == ProposalState.Active, "Voting not active");
        require(!receipts[proposalId][msg.sender].hasVoted, "Already voted");

        uint256 weight = getVotingPower(msg.sender, att.rankIndex);
        require(weight > 0, "No voting power");

        usedNonces[att.nonce] = true;
        receipts[proposalId][msg.sender] = Receipt({
            hasVoted: true,
            support: support,
            votes: weight,
            rankIndex: att.rankIndex
        });

        Proposal storage proposal = proposals[proposalId];
        if (support == VoteType.For) {
            proposal.forVotes += weight;
        } else if (support == VoteType.Against) {
            proposal.againstVotes += weight;
        } else {
            proposal.abstainVotes += weight;
        }

        emit VoteCast(proposalId, msg.sender, support, att.rankIndex, weight, att.nonce);
        return weight;
    }

    // ─── State ───────────────────────────────────────────────────────────
    function state(uint256 proposalId) public view returns (ProposalState) {
        Proposal storage proposal = proposals[proposalId];
        require(proposal.id != 0, "Proposal does not exist");

        if (proposal.cancelled) return ProposalState.Cancelled;
        if (proposal.executed) return ProposalState.Executed;
        if (block.number < proposal.startBlock) return ProposalState.Pending;
        if (block.number <= proposal.endBlock) return ProposalState.Active;

        uint256 quorum = (vgrdToken.totalSupply() * quorumPercentage) / 100;
        uint256 totalVotes = proposal.forVotes + proposal.againstVotes + proposal.abstainVotes;
        if (totalVotes >= quorum && proposal.forVotes > proposal.againstVotes) {
            return ProposalState.Succeeded;
        }
        return ProposalState.Defeated;
    }

    // ─── Execute ─────────────────────────────────────────────────────────
    function execute(uint256 proposalId) external whenNotPaused nonReentrant onlyRole(EXECUTOR_ROLE) {
        require(state(proposalId) == ProposalState.Succeeded, "Proposal not successful");
        Proposal storage proposal = proposals[proposalId];
        proposal.executed = true;

        for (uint i = 0; i < proposal.targets.length; i++) {
            (bool success,) = proposal.targets[i].call{value: proposal.values[i]}(proposal.calldatas[i]);
            require(success, "Execution failed");
        }

        emit ProposalExecuted(proposalId);
    }

    function cancel(uint256 proposalId) external {
        Proposal storage proposal = proposals[proposalId];
        require(
            proposal.proposer == msg.sender || hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Not authorized"
        );
        ProposalState s = state(proposalId);
        require(s == ProposalState.Pending || s == ProposalState.Active, "Cannot cancel");
        proposal.cancelled = true;
        emit ProposalCancelled(proposalId);
    }

    // ─── Admin ───────────────────────────────────────────────────────────
    function setAttestationSigner(address newSigner) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(newSigner != address(0), "signer zero");
        address old = attestationSigner;
        attestationSigner = newSigner;
        emit AttestationSignerUpdated(old, newSigner);
    }

    function setVotingDelay(uint256 _votingDelay) external onlyRole(DEFAULT_ADMIN_ROLE) {
        votingDelay = _votingDelay;
    }

    function setVotingPeriod(uint256 _votingPeriod) external onlyRole(DEFAULT_ADMIN_ROLE) {
        votingPeriod = _votingPeriod;
    }

    function setProposalThreshold(uint256 _proposalThreshold) external onlyRole(DEFAULT_ADMIN_ROLE) {
        proposalThreshold = _proposalThreshold;
    }

    function setQuorumPercentage(uint256 _quorumPercentage) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_quorumPercentage <= 100, "Invalid quorum");
        quorumPercentage = _quorumPercentage;
    }

    function setProposerMinRank(uint8 _proposerMinRank) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_proposerMinRank < _rankCount(), "Invalid rank index");
        proposerMinRank = _proposerMinRank;
    }

    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    receive() external payable {}
}
