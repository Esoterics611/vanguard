import '../models/army/army_models.dart';
import 'army_service.dart';

/// Service for graph-based queries on the Army hierarchy
/// Handles visibility rules, promotion authority, and network traversal
class GraphService {
  final ArmyService _armyService;

  // In-memory cache for fast lookups
  final Map<String, Soldier> _soldierCache = {};
  final Map<String, Unit> _unitCache = {};
  final Map<String, List<String>> _unitMembershipCache = {};

  // Singleton
  static final GraphService _instance = GraphService._internal(ArmyService());
  factory GraphService() => _instance;
  GraphService._internal(this._armyService);

  /// Clear all caches
  void clearCache() {
    _soldierCache.clear();
    _unitCache.clear();
    _unitMembershipCache.clear();
  }

  // ============ VISIBILITY QUERIES ============

  /// Get all chat channels a soldier can access based on their unit hierarchy
  Future<List<String>> getAccessibleChannels(String soldierId) async {
    final soldier = await _getSoldier(soldierId);
    if (soldier == null) return [];

    final channels = <String>[];

    // Squad channel (always accessible if in squad)
    if (soldier.squadId != null) {
      final squad = await _getUnit(soldier.squadId!);
      if (squad?.chatChannelId != null) {
        channels.add(squad!.chatChannelId!);
      }

      // Section announcement channel
      if (squad?.parentUnitId != null) {
        final section = await _getUnit(squad!.parentUnitId!);
        if (section?.chatChannelId != null) {
          channels.add(section!.chatChannelId!);
        }

        // Platoon announcement channel
        if (section?.parentUnitId != null) {
          final platoon = await _getUnit(section!.parentUnitId!);
          if (platoon?.chatChannelId != null) {
            channels.add(platoon!.chatChannelId!);
          }

          // Company broadcast channel
          if (platoon?.parentUnitId != null) {
            final company = await _getUnit(platoon!.parentUnitId!);
            if (company?.chatChannelId != null) {
              channels.add(company!.chatChannelId!);
            }
          }
        }
      }
    }

    return channels;
  }

  /// Get all soldiers visible to a given soldier
  /// Leaders can see subordinates, soldiers can see squad members
  Future<List<Soldier>> getVisibleSoldiers(String viewerId) async {
    final viewer = await _getSoldier(viewerId);
    if (viewer == null) return [];

    final visible = <Soldier>[];

    // Always see squad members
    if (viewer.squadId != null) {
      final squadMembers = await _armyService.getSquadMembers(viewer.squadId!);
      visible.addAll(squadMembers);
    }

    // Leaders see subordinate units
    if (viewer.rank.isNCO || viewer.rank.isOfficer) {
      final subordinates = await _getSubordinateSoldiers(viewer);
      visible.addAll(subordinates);
    }

    // Remove duplicates
    final unique = <String, Soldier>{};
    for (final s in visible) {
      unique[s.id] = s;
    }

    return unique.values.toList();
  }

  /// Check if soldier can view a specific target
  Future<bool> canView({
    required String viewerId,
    required String targetId,
  }) async {
    final viewer = await _getSoldier(viewerId);
    final target = await _getSoldier(targetId);

    if (viewer == null || target == null) return false;

    // Same soldier
    if (viewerId == targetId) return true;

    // Same squad
    if (viewer.squadId == target.squadId && viewer.squadId != null) {
      return true;
    }

    // Leader relationship
    return await _isInChainOfCommand(leaderId: viewerId, subordinateId: targetId);
  }

  // ============ PROMOTION AUTHORITY ============

  /// Promotion authority matrix based on UX spec
  /// Returns (allowed, reason)
  Future<({bool allowed, String reason})> canPromote({
    required String promoterId,
    required String targetId,
    required Rank newRank,
  }) async {
    final promoter = await _getSoldier(promoterId);
    final target = await _getSoldier(targetId);

    if (promoter == null) {
      return (allowed: false, reason: 'Promoter not found');
    }
    if (target == null) {
      return (allowed: false, reason: 'Target not found');
    }

    // Cannot promote self
    if (promoterId == targetId) {
      return (allowed: false, reason: 'Cannot promote yourself');
    }

    // Check promotion is actually an upgrade
    if (newRank.index <= target.rank.index) {
      return (allowed: false, reason: 'New rank must be higher than current');
    }

    // Check rank requirements
    final currentRank = target.rank;

    // PVT → PV2: SGT (Squad Leader)
    if (currentRank == Rank.pvt && newRank == Rank.pv2) {
      if (promoter.rank.index < Rank.sgt.index) {
        return (allowed: false, reason: 'SGT or higher required');
      }
      if (!await _isSquadLeaderOf(promoterId, targetId)) {
        return (allowed: false, reason: 'Must be target\'s squad leader');
      }
      return (allowed: true, reason: 'Approved');
    }

    // PV2 → PFC: SSG (Section Leader) or higher
    if (currentRank == Rank.pv2 && newRank == Rank.pfc) {
      if (promoter.rank.index < Rank.ssg.index) {
        return (allowed: false, reason: 'SSG or higher required');
      }
      return (allowed: true, reason: 'Approved');
    }

    // PFC → CPL: 2LT (Platoon Leader) or higher
    if (currentRank == Rank.pfc && newRank == Rank.cpl) {
      if (promoter.rank.index < Rank.secondLt.index) {
        return (allowed: false, reason: '2LT or higher required');
      }
      return (allowed: true, reason: 'Approved');
    }

    // CPL → SGT: Requires PLDC completion (checked separately)
    if (currentRank == Rank.cpl && newRank == Rank.sgt) {
      if (!target.hasCompletedPLDC) {
        return (allowed: false, reason: 'Target must complete PLDC');
      }
      if (promoter.rank.index < Rank.ssg.index) {
        return (allowed: false, reason: 'SSG or higher required');
      }
      return (allowed: true, reason: 'Approved');
    }

    // SGT → SSG: Section formation (automatic when squad splits)
    if (currentRank == Rank.sgt && newRank == Rank.ssg) {
      return (allowed: false, reason: 'SSG promotion occurs during squad split');
    }

    // Officer promotions: 2LT → 1LT requires OBC
    if (currentRank == Rank.secondLt && newRank == Rank.firstLt) {
      if (!target.hasCompletedOBC) {
        return (allowed: false, reason: 'Target must complete OBC');
      }
      if (promoter.rank != Rank.cpt) {
        return (allowed: false, reason: 'CPT required');
      }
      return (allowed: true, reason: 'Approved');
    }

    return (allowed: false, reason: 'Promotion path not defined');
  }

  /// Get soldiers that a leader can promote
  Future<List<({Soldier soldier, List<Rank> eligibleRanks})>>
      getPromotableSoldiers(String leaderId) async {
    final leader = await _getSoldier(leaderId);
    if (leader == null) return [];

    final subordinates = await _getSubordinateSoldiers(leader);
    final promotable = <({Soldier soldier, List<Rank> eligibleRanks})>[];

    for (final subordinate in subordinates) {
      final eligibleRanks = <Rank>[];

      // Check each possible next rank
      for (final rank in Rank.values) {
        if (rank.index > subordinate.rank.index) {
          final result = await canPromote(
            promoterId: leaderId,
            targetId: subordinate.id,
            newRank: rank,
          );
          if (result.allowed) {
            eligibleRanks.add(rank);
          }
        }
      }

      if (eligibleRanks.isNotEmpty) {
        promotable.add((soldier: subordinate, eligibleRanks: eligibleRanks));
      }
    }

    return promotable;
  }

  // ============ HIERARCHY TRAVERSAL ============

  /// Get the full hierarchy path for a unit (from company down to this unit)
  Future<List<Unit>> getHierarchyPath(String unitId) async {
    final path = <Unit>[];
    var currentId = unitId;

    while (true) {
      final unit = await _getUnit(currentId);
      if (unit == null) break;
      path.insert(0, unit);
      if (unit.parentUnitId == null) break;
      currentId = unit.parentUnitId!;
    }

    return path;
  }

  /// Get all units in the subtree under a given unit
  Future<List<Unit>> getSubtree(String rootUnitId) async {
    final result = <Unit>[];
    final queue = [rootUnitId];

    while (queue.isNotEmpty) {
      final currentId = queue.removeAt(0);
      final unit = await _getUnit(currentId);
      if (unit != null) {
        result.add(unit);
        queue.addAll(unit.childUnitIds);
      }
    }

    return result;
  }

  /// Get units near split threshold (90%+ capacity)
  Future<List<Unit>> getUnitsNearSplit() async {
    final allUnits = await _armyService.getUnits();
    return allUnits
        .where((u) => u.type == UnitType.squad && u.fillPercentage >= 0.9)
        .toList();
  }

  // ============ GRAPH DATA FOR VISUALIZATION ============

  /// Build graph data for the Army network visualization
  /// Filters based on viewer's permissions
  Future<({List<GraphNode> nodes, List<GraphEdge> edges})> buildGraphData({
    String? viewerId,
    int depth = 3,
  }) async {
    final nodes = <GraphNode>[];
    final edges = <GraphEdge>[];
    final addedIds = <String>{};

    // Get all units
    final allUnits = await _armyService.getUnits();

    // Get viewer for highlighting
    Soldier? viewer;
    if (viewerId != null) {
      viewer = await _getSoldier(viewerId);
    }

    // Add unit nodes
    for (final unit in allUnits) {
      final isUserUnit = viewer != null &&
          (unit.id == viewer.squadId ||
           unit.memberIds.contains(viewer.id));

      nodes.add(GraphNode.unit(
        id: unit.id,
        type: unit.type,
        name: unit.name,
        memberCount: unit.memberCount,
        isUserUnit: isUserUnit,
      ));
      addedIds.add(unit.id);

      // Add hierarchy edges
      if (unit.parentUnitId != null) {
        edges.add(GraphEdge(
          fromId: unit.parentUnitId!,
          toId: unit.id,
          type: EdgeType.childUnit,
        ));
      }
    }

    return (nodes: nodes, edges: edges);
  }

  /// Calculate positions for hierarchical layout
  Map<String, Offset> calculateHierarchicalLayout(
    List<GraphNode> nodes,
    List<GraphEdge> edges, {
    double width = 600,
    double height = 500,
  }) {
    final positions = <String, Offset>{};

    // Group nodes by type/level
    final companies = <GraphNode>[];
    final platoons = <GraphNode>[];
    final sections = <GraphNode>[];
    final squads = <GraphNode>[];
    final soldiers = <GraphNode>[];

    for (final node in nodes) {
      node.map(
        soldier: (s) => soldiers.add(node),
        unit: (u) {
          switch (u.type) {
            case UnitType.company:
              companies.add(node);
            case UnitType.platoon:
              platoons.add(node);
            case UnitType.section:
              sections.add(node);
            case UnitType.squad:
              squads.add(node);
          }
        },
        bounty: (_) {},
      );
    }

    // Position each level
    _positionLevel(companies, 50, width, positions);
    _positionLevel(platoons, 130, width, positions);
    _positionLevel(sections, 210, width, positions);
    _positionLevel(squads, 290, width, positions);
    _positionLevel(soldiers, 370, width, positions);

    return positions;
  }

  void _positionLevel(
    List<GraphNode> nodes,
    double y,
    double width,
    Map<String, Offset> positions,
  ) {
    if (nodes.isEmpty) return;

    final spacing = width / (nodes.length + 1);
    for (var i = 0; i < nodes.length; i++) {
      final x = spacing * (i + 1);
      final id = nodes[i].map(
        soldier: (s) => s.id,
        unit: (u) => u.id,
        bounty: (b) => b.id,
      );
      positions[id] = Offset(x, y);
    }
  }

  // ============ PRIVATE HELPERS ============

  Future<Soldier?> _getSoldier(String id) async {
    if (_soldierCache.containsKey(id)) {
      return _soldierCache[id];
    }
    final soldier = await _armyService.getSoldierById(id);
    if (soldier != null) {
      _soldierCache[id] = soldier;
    }
    return soldier;
  }

  Future<Unit?> _getUnit(String id) async {
    if (_unitCache.containsKey(id)) {
      return _unitCache[id];
    }
    final unit = await _armyService.getUnit(id);
    if (unit != null) {
      _unitCache[id] = unit;
    }
    return unit;
  }

  Future<bool> _isSquadLeaderOf(String leaderId, String subordinateId) async {
    final subordinate = await _getSoldier(subordinateId);
    if (subordinate?.squadId == null) return false;

    final squad = await _getUnit(subordinate!.squadId!);
    return squad?.leaderId == leaderId;
  }

  Future<bool> _isInChainOfCommand({
    required String leaderId,
    required String subordinateId,
  }) async {
    final leader = await _getSoldier(leaderId);
    final subordinate = await _getSoldier(subordinateId);

    if (leader == null || subordinate == null) return false;
    if (subordinate.squadId == null) return false;

    // Get subordinate's hierarchy
    final hierarchyPath = <String>[];
    var currentId = subordinate.squadId;

    while (currentId != null) {
      final unit = await _getUnit(currentId);
      if (unit == null) break;

      // Check if leader leads this unit
      if (unit.leaderId == leaderId || unit.secondInCommandId == leaderId) {
        return true;
      }

      currentId = unit.parentUnitId;
    }

    return false;
  }

  Future<List<Soldier>> _getSubordinateSoldiers(Soldier leader) async {
    final subordinates = <Soldier>[];

    // If squad leader, get squad members
    if (leader.squadId != null) {
      final squad = await _getUnit(leader.squadId!);
      if (squad?.leaderId == leader.id) {
        final members = await _armyService.getSquadMembers(leader.squadId!);
        subordinates.addAll(members.where((m) => m.id != leader.id));
      }
    }

    // If section/platoon/company leader, get all subordinate units' members
    // This would require knowing which unit they lead (stored in soldier or queried)
    // For now, simplified to squad only

    return subordinates;
  }
}

/// Extension for Offset (used in layout calculations)
class Offset {
  final double dx;
  final double dy;
  const Offset(this.dx, this.dy);
}
