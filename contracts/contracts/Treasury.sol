// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./base/BaseTreasury.sol";

/**
 * @title Treasury
 * @notice Vanguard concrete treasury. All streaming/withdraw logic lives in BaseTreasury;
 *         the engine token (VGRD) is injected at construction time.
 */
contract Treasury is BaseTreasury {
    constructor(address admin, address _vgrdToken) BaseTreasury(admin, _vgrdToken) {}
}
