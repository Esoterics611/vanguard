// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./base/BaseRegistry.sol";

/**
 * @title ArmyRegistry
 * @notice Vanguard concrete registry. 12 ranks (GUEST..CPT); founding squad
 *         is "Alpha Squad". All rank-agnostic plumbing lives in BaseRegistry.
 */
contract ArmyRegistry is BaseRegistry {
    enum Rank {
        GUEST,      // 0 - not enlisted
        PVT,        // 1
        PV2,        // 2
        PFC,        // 3
        CPL,        // 4
        SGT,        // 5
        SSG,        // 6
        SFC,        // 7
        FIRST_SGT,  // 8
        SECOND_LT,  // 9
        FIRST_LT,   // 10
        CPT         // 11
    }

    constructor(address admin) BaseRegistry(admin) {
        _createInitialSquad(keccak256("Alpha Squad"), admin);
    }

    function _defaultEnlistRank() internal pure override returns (uint8) {
        return uint8(Rank.PVT);
    }

    function _maxRank() internal pure override returns (uint8) {
        return uint8(Rank.CPT);
    }

    /// @notice Typed rank getter for callers that work with the Vanguard Rank enum.
    function getRank(address soldier) external view returns (Rank) {
        return Rank(soldiers[soldier].rank);
    }

    /// @notice Typed rank setter — gated by RANK_MANAGER_ROLE in base.
    function updateRank(address soldier, Rank newRank) external onlyRole(RANK_MANAGER_ROLE) {
        require(soldiers[soldier].enlistedAt != 0, "Not enlisted");
        uint8 oldRank = soldiers[soldier].rank;
        soldiers[soldier].rank = uint8(newRank);
        emit RankUpdated(soldier, oldRank, uint8(newRank));
    }
}
