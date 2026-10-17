// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./VGRDToken.sol";
import "./ArmyRegistry.sol";
import "./TaskRegistry.sol";
import "./RewardPool.sol";

/**
 * @title BountyEscrow
 * @dev Holds funds for bounties, releases on completion
 */
contract BountyEscrow is AccessControl, Pausable, ReentrancyGuard {
    bytes32 public constant DAO_ROLE = keccak256("DAO_ROLE");

    VGRDToken public immutable token;
    ArmyRegistry public immutable registry;
    TaskRegistry public taskRegistry;
    RewardPool public rewardPool;

    enum BountyStatus { ACTIVE, COMPLETED, CANCELLED }

    struct Bounty {
        bytes32 titleHash;
        address creator;
        uint256 totalAmount;
        uint256 remainingAmount;
        uint256 deadline;
        BountyStatus status;
        uint256[] objectiveIds;
    }

    // State
    mapping(uint256 => Bounty) public bounties;
    uint256 public nextBountyId = 1;

    // Stats
    uint256 public totalBountiesCreated;
    uint256 public totalBountiesCompleted;
    uint256 public totalFundsDistributed;

    // Events
    event BountyCreated(uint256 indexed bountyId, address creator, uint256 amount);
    event BountyFunded(uint256 indexed bountyId, uint256 amount);
    event BountyCompleted(uint256 indexed bountyId);
    event BountyCancelled(uint256 indexed bountyId, uint256 refundAmount);
    event ObjectiveRewardReleased(uint256 indexed bountyId, uint256 objectiveId, uint256 amount);

    constructor(
        address admin,
        address _token,
        address _registry
    ) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(DAO_ROLE, admin);
        token = VGRDToken(_token);
        registry = ArmyRegistry(_registry);
    }

    /**
     * @dev Set task registry (can only be set once)
     */
    function setTaskRegistry(address _taskRegistry) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(address(taskRegistry) == address(0), "Already set");
        taskRegistry = TaskRegistry(_taskRegistry);
    }

    /**
     * @dev Set reward pool (can only be set once)
     */
    function setRewardPool(address _rewardPool) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(address(rewardPool) == address(0), "Already set");
        rewardPool = RewardPool(_rewardPool);
    }

    /**
     * @dev Create a bounty (CPT+ or admin)
     */
    function createBounty(
        bytes32 titleHash,
        uint256 amount,
        uint256 deadline,
        uint256[] calldata objectiveAllocations
    ) external whenNotPaused nonReentrant returns (uint256) {
        ArmyRegistry.Rank creatorRank = registry.getRank(msg.sender);
        require(
            creatorRank >= ArmyRegistry.Rank.CPT ||
            hasRole(DAO_ROLE, msg.sender),
            "Must be CPT+ to create bounties"
        );

        // Verify allocations sum to amount
        uint256 totalAllocation;
        for (uint i = 0; i < objectiveAllocations.length; i++) {
            totalAllocation += objectiveAllocations[i];
        }
        require(totalAllocation == amount, "Allocations must sum to amount");

        // Transfer tokens to escrow
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        uint256 bountyId = nextBountyId++;
        bounties[bountyId] = Bounty({
            titleHash: titleHash,
            creator: msg.sender,
            totalAmount: amount,
            remainingAmount: amount,
            deadline: deadline,
            status: BountyStatus.ACTIVE,
            objectiveIds: new uint256[](0)
        });

        totalBountiesCreated++;

        emit BountyCreated(bountyId, msg.sender, amount);
        return bountyId;
    }

    /**
     * @dev Add more funds to a bounty
     */
    function fundBounty(uint256 bountyId, uint256 amount) external whenNotPaused nonReentrant {
        Bounty storage bounty = bounties[bountyId];
        require(bounty.status == BountyStatus.ACTIVE, "Bounty not active");

        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        bounty.totalAmount += amount;
        bounty.remainingAmount += amount;

        emit BountyFunded(bountyId, amount);
    }

    /**
     * @dev Cancel a bounty (creator only, refunds remaining)
     */
    function cancelBounty(uint256 bountyId) external whenNotPaused nonReentrant {
        Bounty storage bounty = bounties[bountyId];
        require(bounty.creator == msg.sender || hasRole(DAO_ROLE, msg.sender), "Not authorized");
        require(bounty.status == BountyStatus.ACTIVE, "Bounty not active");

        // Check if any objectives have started
        bool hasProgress = false;
        for (uint i = 0; i < bounty.objectiveIds.length; i++) {
            (uint256 completed,) = taskRegistry.getObjectiveProgress(bounty.objectiveIds[i]);
            if (completed > 0) {
                hasProgress = true;
                break;
            }
        }
        require(!hasProgress, "Cannot cancel bounty with progress");

        bounty.status = BountyStatus.CANCELLED;
        uint256 refund = bounty.remainingAmount;
        bounty.remainingAmount = 0;

        require(token.transfer(bounty.creator, refund), "Refund failed");

        emit BountyCancelled(bountyId, refund);
    }

    /**
     * @dev Link an objective to a bounty
     */
    function linkObjective(uint256 bountyId, uint256 objectiveId) external onlyRole(DAO_ROLE) {
        Bounty storage bounty = bounties[bountyId];
        require(bounty.status == BountyStatus.ACTIVE, "Bounty not active");
        bounty.objectiveIds.push(objectiveId);
    }

    /**
     * @dev Release funds for a completed objective
     */
    function releaseObjectiveReward(
        uint256 bountyId,
        uint256 objectiveId,
        uint256 amount
    ) external whenNotPaused nonReentrant {
        require(
            hasRole(DAO_ROLE, msg.sender) ||
            msg.sender == address(taskRegistry),
            "Not authorized"
        );

        Bounty storage bounty = bounties[bountyId];
        require(bounty.status == BountyStatus.ACTIVE, "Bounty not active");
        require(bounty.remainingAmount >= amount, "Insufficient funds");

        bounty.remainingAmount -= amount;
        totalFundsDistributed += amount;

        // Transfer to reward pool
        if (address(rewardPool) != address(0)) {
            require(token.transfer(address(rewardPool), amount), "Transfer failed");
        }

        emit ObjectiveRewardReleased(bountyId, objectiveId, amount);

        // Check if bounty is complete
        if (bounty.remainingAmount == 0) {
            bounty.status = BountyStatus.COMPLETED;
            totalBountiesCompleted++;
            emit BountyCompleted(bountyId);
        }
    }

    /**
     * @dev Complete a bounty manually
     */
    function completeBounty(uint256 bountyId) external whenNotPaused {
        Bounty storage bounty = bounties[bountyId];
        require(bounty.creator == msg.sender || hasRole(DAO_ROLE, msg.sender), "Not authorized");
        require(bounty.status == BountyStatus.ACTIVE, "Bounty not active");

        bounty.status = BountyStatus.COMPLETED;
        totalBountiesCompleted++;

        // Refund any remaining amount to creator
        if (bounty.remainingAmount > 0) {
            uint256 refund = bounty.remainingAmount;
            bounty.remainingAmount = 0;
            require(token.transfer(bounty.creator, refund), "Refund failed");
        }

        emit BountyCompleted(bountyId);
    }

    /**
     * @dev Get bounty details
     */
    function getBounty(uint256 bountyId) external view returns (Bounty memory) {
        return bounties[bountyId];
    }

    /**
     * @dev Get bounty objective IDs
     */
    function getBountyObjectives(uint256 bountyId) external view returns (uint256[] memory) {
        return bounties[bountyId].objectiveIds;
    }

    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }
}
