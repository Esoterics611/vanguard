// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "./ArmyRegistry.sol";

/**
 * @title RankManager
 * @dev Handles rank promotions and authority matrix
 */
contract RankManager is AccessControl, Pausable {
    bytes32 public constant DAO_ROLE = keccak256("DAO_ROLE");

    ArmyRegistry public immutable registry;

    // Rank multipliers in basis points (100 = 1.0x)
    uint256[12] public MULTIPLIERS = [
        0,      // GUEST
        100,    // PVT (1.0x)
        120,    // PV2 (1.2x)
        150,    // PFC (1.5x)
        200,    // CPL (2.0x)
        300,    // SGT (3.0x)
        400,    // SSG (4.0x)
        500,    // SFC (5.0x)
        600,    // 1SG (6.0x)
        800,    // 2LT (8.0x)
        1000,   // 1LT (10.0x)
        1500    // CPT (15.0x)
    ];

    // Voting power per rank
    uint256[12] public VOTING_POWER = [
        0,      // GUEST
        1,      // PVT
        2,      // PV2
        3,      // PFC
        5,      // CPL
        10,     // SGT
        15,     // SSG
        20,     // SFC
        25,     // 1SG
        30,     // 2LT
        35,     // 1LT
        50      // CPT
    ];

    // Training completion tracking
    mapping(address => bool) public hasCompletedPLDC; // CPL → SGT qualification
    mapping(address => bool) public hasCompletedOBC;  // 2LT → 1LT qualification

    // Promotion cooldown
    mapping(address => uint256) public lastPromotionTime;
    uint256 public promotionCooldown = 7 days;

    // Events
    event Promoted(address indexed soldier, ArmyRegistry.Rank fromRank, ArmyRegistry.Rank toRank, address indexed promotedBy);
    event TrainingCompleted(address indexed soldier, bytes32 courseId);

    constructor(address admin, address _registry) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(DAO_ROLE, admin);
        registry = ArmyRegistry(_registry);
    }

    /**
     * @dev Get token multiplier for a rank
     */
    function getTokenMultiplier(ArmyRegistry.Rank rank) external view returns (uint256) {
        return MULTIPLIERS[uint8(rank)];
    }

    /**
     * @dev Get voting power for a rank
     */
    function getVotingPower(ArmyRegistry.Rank rank) external view returns (uint256) {
        return VOTING_POWER[uint8(rank)];
    }

    /**
     * @dev Get rank of a soldier
     */
    function getRank(address soldier) public view returns (ArmyRegistry.Rank) {
        return registry.getRank(soldier);
    }

    /**
     * @dev Check if promoter can promote target to newRank
     */
    function canPromote(
        address promoter,
        address target,
        ArmyRegistry.Rank newRank
    ) public view returns (bool) {
        ArmyRegistry.Rank promoterRank = getRank(promoter);
        ArmyRegistry.Rank targetRank = getRank(target);

        // Must be promoting to adjacent rank
        if (uint8(newRank) != uint8(targetRank) + 1) return false;

        // Check cooldown
        if (block.timestamp < lastPromotionTime[target] + promotionCooldown) return false;

        // Authority matrix
        if (newRank == ArmyRegistry.Rank.PV2) {
            return promoterRank >= ArmyRegistry.Rank.SSG;
        }
        if (newRank == ArmyRegistry.Rank.PFC || newRank == ArmyRegistry.Rank.CPL) {
            return promoterRank >= ArmyRegistry.Rank.SECOND_LT;
        }
        if (newRank == ArmyRegistry.Rank.SGT) {
            return promoterRank >= ArmyRegistry.Rank.CPT && hasCompletedPLDC[target];
        }
        if (uint8(newRank) >= uint8(ArmyRegistry.Rank.SSG)) {
            return promoterRank == ArmyRegistry.Rank.CPT;
        }

        return false;
    }

    /**
     * @dev Promote a soldier
     */
    function promote(address target, ArmyRegistry.Rank newRank) external whenNotPaused {
        require(canPromote(msg.sender, target, newRank), "Not authorized to promote");

        ArmyRegistry.Rank oldRank = getRank(target);
        registry.updateRank(target, newRank);
        lastPromotionTime[target] = block.timestamp;

        emit Promoted(target, oldRank, newRank, msg.sender);
    }

    /**
     * @dev DAO can promote anyone to any rank
     */
    function daoPromote(address target, ArmyRegistry.Rank newRank) external onlyRole(DAO_ROLE) {
        ArmyRegistry.Rank oldRank = getRank(target);
        registry.updateRank(target, newRank);
        lastPromotionTime[target] = block.timestamp;

        emit Promoted(target, oldRank, newRank, msg.sender);
    }

    /**
     * @dev Complete PLDC training (CPL → SGT qualification)
     */
    function completePLDC(address soldier) external onlyRole(DAO_ROLE) {
        require(getRank(soldier) >= ArmyRegistry.Rank.CPL, "Must be CPL or higher");
        hasCompletedPLDC[soldier] = true;
        emit TrainingCompleted(soldier, keccak256("PLDC"));
    }

    /**
     * @dev Complete OBC training (2LT → 1LT qualification)
     */
    function completeOBC(address soldier) external onlyRole(DAO_ROLE) {
        require(getRank(soldier) >= ArmyRegistry.Rank.SECOND_LT, "Must be 2LT or higher");
        hasCompletedOBC[soldier] = true;
        emit TrainingCompleted(soldier, keccak256("OBC"));
    }

    /**
     * @dev Update promotion cooldown
     */
    function setPromotionCooldown(uint256 _cooldown) external onlyRole(DAO_ROLE) {
        promotionCooldown = _cooldown;
    }

    /**
     * @dev Update multipliers (DAO only)
     */
    function setMultipliers(uint256[12] calldata _multipliers) external onlyRole(DAO_ROLE) {
        MULTIPLIERS = _multipliers;
    }

    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }
}
