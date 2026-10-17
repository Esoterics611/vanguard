// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title BaseRegistry
 * @notice Abstract registry of soldiers and units shared across Vanguard verticals.
 *
 * Concrete verticals (e.g. ArmyRegistry) inherit this and supply their own typed
 * Rank enum + initial unit name. Storage uses uint8 ranks so the engine remains
 * agnostic to a specific rank schema; verticals expose typed wrappers.
 */
abstract contract BaseRegistry is AccessControl, Pausable, ReentrancyGuard {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant RANK_MANAGER_ROLE = keccak256("RANK_MANAGER_ROLE");

    enum UnitType {
        SQUAD,
        SECTION,
        PLATOON,
        COMPANY
    }

    struct Soldier {
        bytes32 callsign;
        uint8 rank;
        uint256 unitId;
        uint256 tasksCompleted;
        uint256 totalEarned;
        uint256 enlistedAt;
        address invitedBy;
    }

    struct Unit {
        UnitType unitType;
        bytes32 name;
        address leader;
        address secondInCommand;
        uint256 parentUnitId;
        uint256 memberCount;
        uint256 createdAt;
        bool active;
    }

    mapping(address => Soldier) public soldiers;
    mapping(uint256 => Unit) public units;
    mapping(uint256 => address[]) public unitMembers;

    uint256 public nextUnitId = 1;
    uint256 public totalSoldiers;
    uint256 public totalUnits;

    bytes32[] public prefixes;
    bytes32[] public suffixes;

    event SoldierEnlisted(address indexed wallet, bytes32 callsign, uint256 squadId);
    event UnitCreated(uint256 indexed unitId, UnitType unitType, bytes32 name);
    event UnitSplit(uint256 indexed parentId, uint256 newUnitId, address newLeader);
    event MemberTransferred(address indexed soldier, uint256 fromUnit, uint256 toUnit);
    event RankUpdated(address indexed soldier, uint8 fromRank, uint8 toRank);
    event TaskCompleted(address indexed soldier, uint256 taskId, uint256 reward);

    constructor(address admin) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
    }

    /// @dev Concrete registries override to set rank assigned on first enlist.
    function _defaultEnlistRank() internal view virtual returns (uint8);

    /// @dev Highest valid rank index (inclusive). Used for bounds checks.
    function _maxRank() internal view virtual returns (uint8);

    /**
     * @dev Create the founding squad. Concrete contracts must call this in
     *      their constructor with a vertical-specific name.
     */
    function _createInitialSquad(bytes32 name, address leader) internal returns (uint256) {
        uint256 unitId = nextUnitId++;
        units[unitId] = Unit({
            unitType: UnitType.SQUAD,
            name: name,
            leader: leader,
            secondInCommand: address(0),
            parentUnitId: 0,
            memberCount: 0,
            createdAt: block.timestamp,
            active: true
        });
        totalUnits++;
        emit UnitCreated(unitId, UnitType.SQUAD, name);
        return unitId;
    }

    function enlist(uint256 squadId) external whenNotPaused nonReentrant {
        _enlist(msg.sender, squadId, address(0));
    }

    function enlistWithInvite(uint256 squadId, address inviter) external whenNotPaused nonReentrant {
        require(soldiers[inviter].enlistedAt != 0, "Inviter not enlisted");
        _enlist(msg.sender, squadId, inviter);
    }

    function _enlist(address wallet, uint256 squadId, address inviter) internal {
        require(soldiers[wallet].enlistedAt == 0, "Already enlisted");
        require(units[squadId].active, "Unit not active");
        require(units[squadId].unitType == UnitType.SQUAD, "Can only join squads");

        bytes32 callsign = _generateCallsign(wallet);

        soldiers[wallet] = Soldier({
            callsign: callsign,
            rank: _defaultEnlistRank(),
            unitId: squadId,
            tasksCompleted: 0,
            totalEarned: 0,
            enlistedAt: block.timestamp,
            invitedBy: inviter
        });

        unitMembers[squadId].push(wallet);
        units[squadId].memberCount++;
        totalSoldiers++;

        emit SoldierEnlisted(wallet, callsign, squadId);
    }

    function isEnlisted(address wallet) external view returns (bool) {
        return soldiers[wallet].enlistedAt != 0;
    }

    function getSoldier(address wallet) external view returns (Soldier memory) {
        return soldiers[wallet];
    }

    function getUnit(uint256 unitId) external view returns (Unit memory) {
        return units[unitId];
    }

    function getUnitMembers(uint256 unitId) external view returns (address[] memory) {
        return unitMembers[unitId];
    }

    /// @notice Engine-level rank getter — returns raw uint8.
    function getRankIndex(address soldier) external view returns (uint8) {
        return soldiers[soldier].rank;
    }

    function createUnit(
        UnitType uType,
        bytes32 name,
        uint256 parentId
    ) external whenNotPaused returns (uint256) {
        require(
            hasRole(ADMIN_ROLE, msg.sender) ||
            (parentId != 0 && units[parentId].leader == msg.sender),
            "Not authorized"
        );

        uint256 unitId = nextUnitId++;
        units[unitId] = Unit({
            unitType: uType,
            name: name,
            leader: msg.sender,
            secondInCommand: address(0),
            parentUnitId: parentId,
            memberCount: 0,
            createdAt: block.timestamp,
            active: true
        });
        totalUnits++;

        emit UnitCreated(unitId, uType, name);
        return unitId;
    }

    function splitSquad(
        uint256 squadId,
        address newLeader,
        address[] calldata newSquadMembers
    ) external whenNotPaused nonReentrant {
        Unit storage squad = units[squadId];
        require(squad.active, "Squad not active");
        require(squad.memberCount > 10, "Not enough members to split");
        require(squad.leader == msg.sender, "Not squad leader");
        require(newSquadMembers.length >= 5, "New squad needs 5+ members");
        require(soldiers[newLeader].unitId == squadId, "New leader must be in squad");

        uint256 sectionId = squad.parentUnitId;
        if (sectionId == 0 || units[sectionId].unitType != UnitType.SECTION) {
            sectionId = nextUnitId++;
            units[sectionId] = Unit({
                unitType: UnitType.SECTION,
                name: squad.name,
                leader: msg.sender,
                secondInCommand: address(0),
                parentUnitId: squad.parentUnitId,
                memberCount: 2,
                createdAt: block.timestamp,
                active: true
            });
            totalUnits++;
            emit UnitCreated(sectionId, UnitType.SECTION, squad.name);

            squad.parentUnitId = sectionId;
        }

        uint256 newSquadId = nextUnitId++;
        units[newSquadId] = Unit({
            unitType: UnitType.SQUAD,
            name: keccak256(abi.encodePacked("Squad-", newSquadId)),
            leader: newLeader,
            secondInCommand: address(0),
            parentUnitId: sectionId,
            memberCount: 0,
            createdAt: block.timestamp,
            active: true
        });
        totalUnits++;
        emit UnitCreated(newSquadId, UnitType.SQUAD, keccak256(abi.encodePacked("Squad-", newSquadId)));

        for (uint i = 0; i < newSquadMembers.length; i++) {
            address member = newSquadMembers[i];
            require(soldiers[member].unitId == squadId, "Member not in original squad");
            _transferMember(member, squadId, newSquadId);
        }

        emit UnitSplit(squadId, newSquadId, newLeader);
    }

    /// @notice Engine-level rank setter — accepts uint8.
    function updateRankIndex(address soldier, uint8 newRank) external onlyRole(RANK_MANAGER_ROLE) {
        require(soldiers[soldier].enlistedAt != 0, "Not enlisted");
        require(newRank <= _maxRank(), "Rank out of range");
        uint8 oldRank = soldiers[soldier].rank;
        soldiers[soldier].rank = newRank;
        emit RankUpdated(soldier, oldRank, newRank);
    }

    function recordTaskCompletion(address soldier, uint256 taskId, uint256 reward) external onlyRole(ADMIN_ROLE) {
        require(soldiers[soldier].enlistedAt != 0, "Not enlisted");
        soldiers[soldier].tasksCompleted++;
        soldiers[soldier].totalEarned += reward;
        emit TaskCompleted(soldier, taskId, reward);
    }

    function setUnitLeader(uint256 unitId, address newLeader) external onlyRole(ADMIN_ROLE) {
        require(units[unitId].active, "Unit not active");
        units[unitId].leader = newLeader;
    }

    function setUnit2IC(uint256 unitId, address new2IC) external onlyRole(ADMIN_ROLE) {
        require(units[unitId].active, "Unit not active");
        units[unitId].secondInCommand = new2IC;
    }

    function seedCallsignWords(bytes32[] calldata _prefixes, bytes32[] calldata _suffixes) external onlyRole(ADMIN_ROLE) {
        for (uint i = 0; i < _prefixes.length; i++) {
            prefixes.push(_prefixes[i]);
        }
        for (uint i = 0; i < _suffixes.length; i++) {
            suffixes.push(_suffixes[i]);
        }
    }

    function _generateCallsign(address wallet) internal view returns (bytes32) {
        if (prefixes.length == 0 || suffixes.length == 0) {
            return keccak256(abi.encodePacked(wallet, block.timestamp));
        }
        uint256 prefixIdx = uint256(keccak256(abi.encodePacked(wallet, block.timestamp))) % prefixes.length;
        uint256 suffixIdx = uint256(keccak256(abi.encodePacked(block.timestamp, wallet))) % suffixes.length;
        return keccak256(abi.encodePacked(prefixes[prefixIdx], suffixes[suffixIdx]));
    }

    function _transferMember(address member, uint256 fromUnit, uint256 toUnit) internal {
        address[] storage members = unitMembers[fromUnit];
        for (uint i = 0; i < members.length; i++) {
            if (members[i] == member) {
                members[i] = members[members.length - 1];
                members.pop();
                break;
            }
        }
        units[fromUnit].memberCount--;

        unitMembers[toUnit].push(member);
        units[toUnit].memberCount++;
        soldiers[member].unitId = toUnit;

        emit MemberTransferred(member, fromUnit, toUnit);
    }

    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }
}
