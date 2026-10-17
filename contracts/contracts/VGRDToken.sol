// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

/**
 * @title VGRDToken
 * @dev Vanguard DAO Token - ERC20 with minting restricted to RewardPool
 */
contract VGRDToken is ERC20, ERC20Burnable, ERC20Permit, AccessControl, Pausable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant SNAPSHOT_ROLE = keccak256("SNAPSHOT_ROLE");

    uint256 public constant TOTAL_SUPPLY = 1_000_000_000 * 10**18; // 1 billion tokens

    // Simple snapshot mechanism
    uint256 private _currentSnapshotId;
    mapping(uint256 => mapping(address => uint256)) private _balanceSnapshots;
    mapping(uint256 => mapping(address => bool)) private _snapshotTaken;

    event Snapshot(uint256 id);

    constructor(address admin) ERC20("Vanguard Token", "VGRD") ERC20Permit("Vanguard Token") {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(PAUSER_ROLE, admin);
        _grantRole(SNAPSHOT_ROLE, admin);

        // Mint initial supply to admin for distribution
        _mint(admin, TOTAL_SUPPLY);
    }

    /**
     * @dev Mint new tokens - only callable by MINTER_ROLE (RewardPool)
     */
    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    /**
     * @dev Create a new snapshot - only callable by SNAPSHOT_ROLE (DAO)
     */
    function snapshot() external onlyRole(SNAPSHOT_ROLE) returns (uint256) {
        _currentSnapshotId++;
        emit Snapshot(_currentSnapshotId);
        return _currentSnapshotId;
    }

    /**
     * @dev Get balance at a specific snapshot
     */
    function balanceOfAt(address account, uint256 snapshotId) external view returns (uint256) {
        require(snapshotId > 0 && snapshotId <= _currentSnapshotId, "Invalid snapshot id");
        if (_snapshotTaken[snapshotId][account]) {
            return _balanceSnapshots[snapshotId][account];
        }
        return balanceOf(account);
    }

    /**
     * @dev Get current snapshot id
     */
    function getCurrentSnapshotId() external view returns (uint256) {
        return _currentSnapshotId;
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _update(address from, address to, uint256 value) internal override whenNotPaused {
        // Take snapshot before transfer if needed
        if (_currentSnapshotId > 0) {
            if (from != address(0) && !_snapshotTaken[_currentSnapshotId][from]) {
                _balanceSnapshots[_currentSnapshotId][from] = balanceOf(from);
                _snapshotTaken[_currentSnapshotId][from] = true;
            }
            if (to != address(0) && !_snapshotTaken[_currentSnapshotId][to]) {
                _balanceSnapshots[_currentSnapshotId][to] = balanceOf(to);
                _snapshotTaken[_currentSnapshotId][to] = true;
            }
        }
        super._update(from, to, value);
    }
}
