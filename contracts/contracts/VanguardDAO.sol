// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./base/BaseGovernance.sol";

/**
 * @title VanguardDAO
 * @notice Vanguard concrete governance. 12 rank slots (GUEST..CPT) with
 *         multipliers from PVT=1.0x to CPT=12.0x in basis points.
 *         All proposal/vote/execute logic and EIP-712 rank attestation is in BaseGovernance.
 */
contract VanguardDAO is BaseGovernance {
    /// @notice Vanguard rank multipliers in basis points (100 = 1.0x).
    /// Indices match ArmyRegistry.Rank: 0=GUEST, 1=PVT, ..., 11=CPT.
    uint256[12] public rankMultipliersBps = [
        0,      // GUEST
        100,    // PVT  (1.0x)
        120,    // PV2  (1.2x)
        150,    // PFC  (1.5x)
        200,    // CPL  (2.0x)
        300,    // SGT  (3.0x)
        400,    // SSG  (4.0x)
        500,    // SFC  (5.0x)
        600,    // FIRST_SGT (6.0x)
        800,    // SECOND_LT (8.0x)
        1000,   // FIRST_LT  (10.0x)
        1200    // CPT  (12.0x)
    ];

    /// @notice Index of the CPT rank — used as the default propose threshold.
    uint8 public constant CPT_RANK = 11;

    constructor(
        address admin,
        address _vgrdToken,
        address _registry,
        address _attestationSigner
    )
        BaseGovernance(admin, _vgrdToken, _registry, _attestationSigner, "VanguardDAO", CPT_RANK)
    {}

    function _rankMultiplierBps(uint8 rankIndex) internal view override returns (uint256) {
        return rankMultipliersBps[rankIndex];
    }

    function _rankCount() internal pure override returns (uint8) {
        return 12;
    }

    /// @notice DAO can adjust multipliers by governance vote.
    function setRankMultipliers(uint256[12] calldata _multipliers) external onlyRole(DEFAULT_ADMIN_ROLE) {
        for (uint8 i = 0; i < 12; i++) {
            rankMultipliersBps[i] = _multipliers[i];
        }
    }
}
