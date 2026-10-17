# ArmyRegistry

**Address:** `0xBf3BEE33090fb5f9b147a72cAac6f4f44CE1F270`
**Purpose:** Membership registry — tracks soldiers, ranks, units, and the organizational hierarchy.

## Roles

| Role | Holder | Purpose |
|------|--------|---------|
| `DEFAULT_ADMIN_ROLE` | Deployer | Grant/revoke roles |
| `ADMIN_ROLE` | TaskRegistry, Deployer | Update soldier stats |
| `RANK_MANAGER_ROLE` | RankManager | Update soldier ranks |

## Data Structures

### Soldier

```solidity
struct Soldier {
    string callsign;
    uint8 rank;          // 0=GUEST, 1=PVT, ..., 11=CPT
    uint256 unitId;
    uint256 tasksCompleted;
    uint256 totalEarned;
    uint256 enlistmentDate;
    address inviter;
}
```

### Unit

```solidity
struct Unit {
    uint8 unitType;      // 0=SQUAD, 1=SECTION, 2=PLATOON, 3=COMPANY
    string name;
    address leader;
    uint256 parentUnitId;
    uint256 memberCount;
    bool active;
}
```

## Functions

### enlist

**Access:** Public | **Mutability:** nonpayable

Enlist the caller as a PVT in the specified squad.

- `_squadId` (uint256) — ID of the squad to join

Reverts if: already enlisted, squad doesn't exist, squad is full, squad is not active.

Emits: `Enlisted(soldier, squadId, rank)`

### enlistWithInvite

**Access:** Public | **Mutability:** nonpayable

Enlist with a referral from an existing member.

- `_squadId` (uint256) — squad to join
- `_inviter` (address) — address of the inviting member

Reverts if: already enlisted, inviter not enlisted, squad invalid.

### isEnlisted

**Access:** Public | **Mutability:** view

- `_address` (address) — address to check

Returns: bool — true if the address is an enlisted soldier.

### getSoldier

**Access:** Public | **Mutability:** view

- `_address` (address) — soldier's wallet address

Returns: Soldier struct (callsign, rank, unitId, tasksCompleted, totalEarned, enlistmentDate, inviter).

### getUnit

**Access:** Public | **Mutability:** view

- `_unitId` (uint256) — unit ID

Returns: Unit struct (unitType, name, leader, parentUnitId, memberCount, active).

### totalUnits

**Access:** Public | **Mutability:** view

Returns: uint256 — total number of units created.

### updateRank

**Access:** RANK_MANAGER_ROLE | **Mutability:** nonpayable

Update a soldier's rank. Only callable by the RankManager contract.

- `_soldier` (address) — soldier to update
- `_newRank` (uint8) — new rank value

### createUnit

**Access:** ADMIN_ROLE | **Mutability:** nonpayable

Create a new organizational unit.

- `_unitType` (uint8) — type (0=SQUAD, 1=SECTION, 2=PLATOON, 3=COMPANY)
- `_name` (string) — unit name
- `_leader` (address) — unit leader
- `_parentUnitId` (uint256) — parent unit (0 for top-level)

### splitSquad

**Access:** ADMIN_ROLE | **Mutability:** nonpayable

Split an oversized squad into two squads under a new section.

- `_squadId` (uint256) — squad to split

Reverts if: squad has fewer than 10 members.

## Events

| Event | Parameters |
|-------|-----------|
| `Enlisted` | `soldier` (address), `squadId` (uint256), `rank` (uint8) |
| `RankUpdated` | `soldier` (address), `oldRank` (uint8), `newRank` (uint8) |
| `UnitCreated` | `unitId` (uint256), `unitType` (uint8), `name` (string) |
| `SquadSplit` | `originalSquadId` (uint256), `newSquadId` (uint256), `sectionId` (uint256) |
