import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import '../../../app/theme/cyber_colors.dart';
import '../../../app/theme/cyber_text_styles.dart';
import '../../../core/models/army/army_models.dart';

/// Interactive network graph visualization for the Army hierarchy
/// Uses force-directed layout with custom styling
class ArmyGraphWidget extends StatefulWidget {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final String? highlightNodeId;
  final void Function(GraphNode node)? onNodeTap;

  const ArmyGraphWidget({
    super.key,
    required this.nodes,
    required this.edges,
    this.highlightNodeId,
    this.onNodeTap,
  });

  @override
  State<ArmyGraphWidget> createState() => _ArmyGraphWidgetState();
}

class _ArmyGraphWidgetState extends State<ArmyGraphWidget> {
  late Graph _graph;
  late Algorithm _algorithm;
  final TransformationController _transformController = TransformationController();

  @override
  void initState() {
    super.initState();
    _buildGraph();
  }

  @override
  void didUpdateWidget(ArmyGraphWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.nodes != widget.nodes || oldWidget.edges != widget.edges) {
      _buildGraph();
    }
  }

  void _buildGraph() {
    _graph = Graph();

    // Create nodes map for edge lookup
    final nodeMap = <String, Node>{};

    // Add nodes
    for (final graphNode in widget.nodes) {
      final id = _getNodeId(graphNode);
      final node = Node.Id(id);
      nodeMap[id] = node;
      _graph.addNode(node);
    }

    // Add edges
    for (final edge in widget.edges) {
      final fromNode = nodeMap[edge.fromId];
      final toNode = nodeMap[edge.toId];
      if (fromNode != null && toNode != null) {
        _graph.addEdge(fromNode, toNode);
      }
    }

    // Use tree layout for hierarchical data
    final configuration = BuchheimWalkerConfiguration()
      ..siblingSeparation = 60
      ..levelSeparation = 80
      ..subtreeSeparation = 80
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;
    _algorithm = BuchheimWalkerAlgorithm(configuration, TreeEdgeRenderer(configuration));
  }

  String _getNodeId(GraphNode node) {
    return node.map(
      soldier: (s) => s.id,
      unit: (u) => u.id,
      bounty: (b) => b.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.nodes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_tree_outlined,
              size: 64,
              color: CyberColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'No units to display',
              style: CyberTextStyles.bodyMedium.copyWith(
                color: CyberColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return InteractiveViewer(
      constrained: false,
      boundaryMargin: const EdgeInsets.all(100),
      minScale: 0.3,
      maxScale: 3.0,
      transformationController: _transformController,
      child: GraphView(
        graph: _graph,
        algorithm: _algorithm,
        paint: Paint()
          ..color = CyberColors.borderSubtle
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
        builder: (Node node) {
          // Find the corresponding GraphNode
          final nodeId = node.key?.value as String?;
          final graphNode = widget.nodes.firstWhere(
            (n) => _getNodeId(n) == nodeId,
            orElse: () => widget.nodes.first,
          );
          return _buildNodeWidget(graphNode);
        },
      ),
    );
  }

  Widget _buildNodeWidget(GraphNode node) {
    final isHighlighted = _getNodeId(node) == widget.highlightNodeId;

    return GestureDetector(
      onTap: () => widget.onNodeTap?.call(node),
      child: node.map(
        soldier: (s) => _SoldierNodeWidget(
          soldier: s,
          isHighlighted: isHighlighted || s.isCurrentUser,
        ),
        unit: (u) => _UnitNodeWidget(
          unit: u,
          isHighlighted: isHighlighted || u.isUserUnit,
        ),
        bounty: (b) => _BountyNodeWidget(
          bounty: b,
          isHighlighted: isHighlighted,
        ),
      ),
    );
  }
}

class _UnitNodeWidget extends StatelessWidget {
  final UnitNode unit;
  final bool isHighlighted;

  const _UnitNodeWidget({
    required this.unit,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getUnitColor(unit.type);
    final fillPercentage = unit.memberCount / _getMaxSize(unit.type);
    final isNearSplit = fillPercentage >= 0.9;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isHighlighted
            ? CyberColors.electricCyan.withValues(alpha: 0.2)
            : CyberColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isHighlighted ? CyberColors.electricCyan : color,
          width: isHighlighted ? 2.5 : 1.5,
        ),
        boxShadow: [
          if (isHighlighted)
            BoxShadow(
              color: CyberColors.electricCyan.withValues(alpha: 0.4),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          if (isNearSplit)
            BoxShadow(
              color: CyberColors.militaryAmber.withValues(alpha: 0.5),
              blurRadius: 8,
              spreadRadius: 0,
            ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                unit.type.icon,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 6),
              Text(
                unit.name,
                style: CyberTextStyles.labelMedium.copyWith(
                  color: isHighlighted
                      ? CyberColors.electricCyan
                      : CyberColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Member count with capacity bar
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: CyberColors.darkPanel,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: fillPercentage.clamp(0, 1),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isNearSplit
                          ? CyberColors.militaryAmber
                          : CyberColors.tacticalGreen,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${unit.memberCount}',
                style: CyberTextStyles.labelSmall.copyWith(
                  color: isNearSplit
                      ? CyberColors.militaryAmber
                      : CyberColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getUnitColor(UnitType type) {
    switch (type) {
      case UnitType.company:
        return CyberColors.officerGold;
      case UnitType.platoon:
        return CyberColors.militaryAmber;
      case UnitType.section:
        return CyberColors.ncoSilver;
      case UnitType.squad:
        return CyberColors.enlistedBronze;
    }
  }

  int _getMaxSize(UnitType type) {
    switch (type) {
      case UnitType.company:
        return 100;
      case UnitType.platoon:
        return 50;
      case UnitType.section:
        return 25;
      case UnitType.squad:
        return 10;
    }
  }
}

class _SoldierNodeWidget extends StatelessWidget {
  final SoldierNode soldier;
  final bool isHighlighted;

  const _SoldierNodeWidget({
    required this.soldier,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    final rankColor = _getRankColor(soldier.rank);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isHighlighted
            ? CyberColors.electricCyan.withValues(alpha: 0.2)
            : CyberColors.cardBackground,
        shape: BoxShape.circle,
        border: Border.all(
          color: isHighlighted ? CyberColors.electricCyan : rankColor,
          width: isHighlighted ? 2.5 : 1.5,
        ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: CyberColors.electricCyan.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person,
            size: 24,
            color: isHighlighted ? CyberColors.electricCyan : rankColor,
          ),
          const SizedBox(height: 2),
          Text(
            soldier.rank.abbreviation,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: rankColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(Rank rank) {
    if (rank.isOfficer) return CyberColors.officerGold;
    if (rank.isNCO) return CyberColors.ncoSilver;
    return CyberColors.enlistedBronze;
  }
}

class _BountyNodeWidget extends StatelessWidget {
  final BountyNode bounty;
  final bool isHighlighted;

  const _BountyNodeWidget({
    required this.bounty,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: CyberColors.militaryAmber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: CyberColors.militaryAmber,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.workspace_premium,
            size: 20,
            color: CyberColors.militaryAmber,
          ),
          const SizedBox(height: 2),
          Text(
            bounty.title,
            style: CyberTextStyles.labelSmall.copyWith(
              color: CyberColors.militaryAmber,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${bounty.reward} VGRD',
            style: TextStyle(
              fontSize: 10,
              color: CyberColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Legend widget showing node types
class ArmyGraphLegend extends StatelessWidget {
  const ArmyGraphLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CyberColors.cardBackground.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CyberColors.borderSubtle),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LEGEND',
            style: CyberTextStyles.labelSmall.copyWith(
              letterSpacing: 1,
              color: CyberColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          _LegendItem(
            icon: '🏛️',
            label: 'Company',
            color: CyberColors.officerGold,
          ),
          _LegendItem(
            icon: '⭐',
            label: 'Platoon',
            color: CyberColors.militaryAmber,
          ),
          _LegendItem(
            icon: '🔷',
            label: 'Section',
            color: CyberColors.ncoSilver,
          ),
          _LegendItem(
            icon: '◆',
            label: 'Squad',
            color: CyberColors.enlistedBronze,
          ),
          const Divider(height: 16),
          _LegendItem(
            icon: '★',
            label: 'Your unit',
            color: CyberColors.electricCyan,
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;

  const _LegendItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
