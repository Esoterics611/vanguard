// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./VGRDToken.sol";
import "./ArmyRegistry.sol";
import "./RankManager.sol";

/**
 * @title RewardPool
 * @dev Manages reward distribution with rank multipliers
 */
contract RewardPool is AccessControl, Pausable, ReentrancyGuard {
    bytes32 public constant DISTRIBUTOR_ROLE = keccak256("DISTRIBUTOR_ROLE");
    bytes32 public constant DAO_ROLE = keccak256("DAO_ROLE");

    VGRDToken public immutable token;
    ArmyRegistry public immutable registry;
    RankManager public immutable rankManager;

    // Pending rewards per soldier
    mapping(address => uint256) public pendingRewards;

    // Stats
    uint256 public totalDistributed;
    uint256 public totalClaimed;

    // Events
    event RewardDistributed(address indexed soldier, uint256 baseAmount, uint256 finalAmount, uint256 taskId);
    event LeaderBonusDistributed(address indexed leader, uint256 objectiveId, uint256 amount);
    event RewardsClaimed(address indexed soldier, uint256 amount);

    constructor(
        address admin,
        address _token,
        address _registry,
        address _rankManager
    ) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(DAO_ROLE, admin);
        token = VGRDToken(_token);
        registry = ArmyRegistry(_registry);
        rankManager = RankManager(_rankManager);
    }

    /**
     * @dev Distribute task reward with rank multiplier
     */
    function distributeTaskReward(
        address soldier,
        uint256 baseAmount,
        uint256 taskId
    ) external onlyRole(DISTRIBUTOR_ROLE) whenNotPaused {
        require(registry.isEnlisted(soldier), "Not enlisted");

        ArmyRegistry.Rank rank = registry.getRank(soldier);
        uint256 multiplier = rankManager.getTokenMultiplier(rank);

        // Calculate final reward: baseAmount * multiplier / 100
        uint256 finalAmount = (baseAmount * multiplier) / 100;

        pendingRewards[soldier] += finalAmount;
        totalDistributed += finalAmount;

        // Update soldier stats
        registry.recordTaskCompletion(soldier, taskId, finalAmount);

        emit RewardDistributed(soldier, baseAmount, finalAmount, taskId);
    }

    /**
     * @dev Distribute leader bonus for objective completion
     */
    function distributeLeaderBonus(
        address leader,
        uint256 objectiveId,
        uint256 bonusAmount
    ) external onlyRole(DISTRIBUTOR_ROLE) whenNotPaused {
        require(registry.isEnlisted(leader), "Not enlisted");

        pendingRewards[leader] += bonusAmount;
        totalDistributed += bonusAmount;

        emit LeaderBonusDistributed(leader, objectiveId, bonusAmount);
    }

    /**
     * @dev Claim accumulated rewards
     */
    function claimRewards() external whenNotPaused nonReentrant {
        uint256 amount = pendingRewards[msg.sender];
        require(amount > 0, "No rewards to claim");

        pendingRewards[msg.sender] = 0;
        totalClaimed += amount;

        // Transfer tokens
        require(token.transfer(msg.sender, amount), "Transfer failed");

        emit RewardsClaimed(msg.sender, amount);
    }

    /**
     * @dev Get pending rewards for a soldier
     */
    function getPendingRewards(address soldier) external view returns (uint256) {
        return pendingRewards[soldier];
    }

    /**
     * @dev Calculate expected reward for a base amount and soldier
     */
    function calculateReward(address soldier, uint256 baseAmount) external view returns (uint256) {
        ArmyRegistry.Rank rank = registry.getRank(soldier);
        uint256 multiplier = rankManager.getTokenMultiplier(rank);
        return (baseAmount * multiplier) / 100;
    }

    /**
     * @dev Withdraw tokens to treasury (DAO only)
     */
    function withdrawToTreasury(address treasury, uint256 amount) external onlyRole(DAO_ROLE) {
        require(token.transfer(treasury, amount), "Transfer failed");
    }

    /**
     * @dev Get pool balance
     */
    function getPoolBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }
}
