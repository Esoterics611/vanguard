import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/army_provider.dart';
import '../../core/models/army/army_models.dart';
import '../../app/theme/cyber_colors.dart';
import '../../app/theme/cyber_text_styles.dart';
import 'widgets/army_widgets.dart';
import 'widgets/army_graph_widget.dart';
import 'pages/unit_detail_page.dart';

/// Army - Network Visualization screen
class ArmyPage extends ConsumerStatefulWidget {
  const ArmyPage({super.key});

  @override
  ConsumerState<ArmyPage> createState() => _ArmyPageState();
}

class _ArmyPageState extends ConsumerState<ArmyPage> {
  bool _isGraphView = true;

  void _onNodeTap(BuildContext context, GraphNode node) {
    node.map(
      soldier: (s) {
        // Show soldier details (could be a dialog or new page)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${s.rank.displayName} ${s.callsign}'),
            backgroundColor: CyberColors.cardBackground,
          ),
        );
      },
      unit: (u) async {
        final service = ref.read(armyServiceProvider);
        final fullUnit = await service.getUnit(u.id);
        if (fullUnit != null && context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UnitDetailPage(unit: fullUnit)),
          );
        }
      },
      bounty: (b) {
        // Navigate to bounty details
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bounty: ${b.title}'),
            backgroundColor: CyberColors.militaryAmber,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final graphAsync = ref.watch(armyGraphProvider);
    final statsAsync = ref.watch(armyStatsProvider);
    final unitsAsync = ref.watch(unitsProvider(null));

    return Scaffold(
      backgroundColor: CyberColors.spaceBlack,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'ARMY',
                    style: CyberTextStyles.headlineLarge,
                  ),
                  const Spacer(),
                  // View toggle
                  Container(
                    decoration: BoxDecoration(
                      color: CyberColors.cardBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        _ViewToggleButton(
                          icon: Icons.account_tree,
                          isSelected: _isGraphView,
                          onTap: () => setState(() => _isGraphView = true),
                        ),
                        _ViewToggleButton(
                          icon: Icons.list,
                          isSelected: !_isGraphView,
                          onTap: () => setState(() => _isGraphView = false),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      // TODO: Search units
                    },
                    icon: const Icon(
                      Icons.search,
                      color: CyberColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isGraphView
                  ? graphAsync.when(
                      data: (graph) => Stack(
                        children: [
                          ArmyGraphWidget(
                            nodes: graph.nodes,
                            edges: graph.edges,
                            onNodeTap: (node) => _onNodeTap(context, node),
                          ),
                          // Legend overlay
                          const Positioned(
                            left: 16,
                            bottom: 16,
                            child: ArmyGraphLegend(),
                          ),
                        ],
                      ),
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                          color: CyberColors.electricCyan,
                        ),
                      ),
                      error: (e, _) => Center(
                        child: Text(
                          'Error: $e',
                          style: CyberTextStyles.bodyMedium.copyWith(
                            color: CyberColors.combatRed,
                          ),
                        ),
                      ),
                    )
                  : unitsAsync.when(
                      data: (units) => _ListView(units: units),
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                          color: CyberColors.electricCyan,
                        ),
                      ),
                      error: (e, _) => Center(
                        child: Text(
                          'Error: $e',
                          style: CyberTextStyles.bodyMedium.copyWith(
                            color: CyberColors.combatRed,
                          ),
                        ),
                      ),
                    ),
            ),

            // Stats footer
            statsAsync.when(
              data: (stats) => _StatsFooter(stats: stats),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // Apply button (for guests)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Apply to squad
                      },
                      icon: const Icon(Icons.person_add),
                      label: const Text('Apply to Squad'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ViewToggleButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? CyberColors.electricCyan.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? CyberColors.electricCyan : CyberColors.textMuted,
        ),
      ),
    );
  }
}

class _GraphView extends StatelessWidget {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;

  const _GraphView({
    required this.nodes,
    required this.edges,
  });

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 3.0,
      boundaryMargin: const EdgeInsets.all(100),
      child: Center(
        child: CustomPaint(
          size: const Size(600, 500),
          painter: _HierarchyPainter(nodes: nodes, edges: edges),
          child: SizedBox(
            width: 600,
            height: 500,
            child: Stack(
              children: nodes.map((node) {
                final position = _getNodePosition(node, nodes.length);
                return Positioned(
                  left: position.dx - 40,
                  top: position.dy - 25,
                  child: _GraphNodeWidget(node: node),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Offset _getNodePosition(GraphNode node, int totalNodes) {
    // Simple hierarchical layout
    return node.map(
      soldier: (s) => const Offset(300, 400),
      unit: (u) {
        switch (u.type) {
          case UnitType.company:
            return const Offset(300, 50);
          case UnitType.platoon:
            if (u.name.contains('1st')) return const Offset(150, 150);
            if (u.name.contains('2nd')) return const Offset(300, 150);
            return const Offset(450, 150);
          case UnitType.section:
            if (u.isUserUnit) return const Offset(200, 250);
            return const Offset(400, 250);
          case UnitType.squad:
            if (u.isUserUnit) return const Offset(150, 350);
            return const Offset(250, 350);
        }
      },
      bounty: (b) => const Offset(500, 400),
    );
  }
}

class _HierarchyPainter extends CustomPainter {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;

  _HierarchyPainter({required this.nodes, required this.edges});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CyberColors.borderSubtle
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw connections
    // Company to platoons
    canvas.drawLine(const Offset(300, 75), const Offset(150, 125), paint);
    canvas.drawLine(const Offset(300, 75), const Offset(300, 125), paint);
    canvas.drawLine(const Offset(300, 75), const Offset(450, 125), paint);

    // Platoon to sections
    canvas.drawLine(const Offset(300, 175), const Offset(200, 225), paint);
    canvas.drawLine(const Offset(300, 175), const Offset(400, 225), paint);

    // Section to squads (user's section highlighted)
    final userPaint = Paint()
      ..color = CyberColors.electricCyan.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(const Offset(200, 275), const Offset(150, 325), userPaint);
    canvas.drawLine(const Offset(200, 275), const Offset(250, 325), userPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GraphNodeWidget extends StatelessWidget {
  final GraphNode node;

  const _GraphNodeWidget({required this.node});

  @override
  Widget build(BuildContext context) {
    return node.map(
      soldier: (s) => _SoldierNodeWidget(soldier: s),
      unit: (u) => _UnitNodeWidget(unit: u),
      bounty: (b) => const SizedBox.shrink(),
    );
  }
}

class _UnitNodeWidget extends ConsumerWidget {
  final UnitNode unit;

  const _UnitNodeWidget({required this.unit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        final service = ref.read(armyServiceProvider);
        final fullUnit = await service.getUnit(unit.id);
        if (fullUnit != null && context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UnitDetailPage(unit: fullUnit)),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: unit.isUserUnit
              ? CyberColors.electricCyan.withValues(alpha: 0.2)
              : CyberColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: unit.isUserUnit
                ? CyberColors.electricCyan
                : _getUnitColor(unit.type),
            width: unit.isUserUnit ? 2 : 1,
          ),
          boxShadow: unit.isUserUnit
              ? [
                  BoxShadow(
                    color: CyberColors.electricCyan.withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              unit.type.icon,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 2),
            Text(
              unit.name,
              style: CyberTextStyles.labelSmall.copyWith(
                color: unit.isUserUnit
                    ? CyberColors.electricCyan
                    : CyberColors.textPrimary,
              ),
            ),
            Text(
              '(${unit.memberCount})',
              style: CyberTextStyles.labelSmall.copyWith(
                fontSize: 9,
              ),
            ),
          ],
        ),
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
}

class _SoldierNodeWidget extends StatelessWidget {
  final SoldierNode soldier;

  const _SoldierNodeWidget({required this.soldier});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: CyberColors.cardBackground,
        shape: BoxShape.circle,
        border: Border.all(
          color: soldier.isCurrentUser
              ? CyberColors.electricCyan
              : CyberColors.borderSubtle,
          width: soldier.isCurrentUser ? 2 : 1,
        ),
      ),
      child: const Icon(
        Icons.person,
        size: 20,
        color: CyberColors.textMuted,
      ),
    );
  }
}

class _ListView extends StatelessWidget {
  final List<Unit> units;

  const _ListView({required this.units});

  @override
  Widget build(BuildContext context) {
    // Group units by type
    final companies =
        units.where((u) => u.type == UnitType.company).toList();
    final platoons =
        units.where((u) => u.type == UnitType.platoon).toList();
    final sections =
        units.where((u) => u.type == UnitType.section).toList();
    final squads = units.where((u) => u.type == UnitType.squad).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        if (companies.isNotEmpty) ...[
          _UnitSection(title: 'Companies', units: companies),
        ],
        if (platoons.isNotEmpty) ...[
          _UnitSection(title: 'Platoons', units: platoons),
        ],
        if (sections.isNotEmpty) ...[
          _UnitSection(title: 'Sections', units: sections),
        ],
        if (squads.isNotEmpty) ...[
          _UnitSection(title: 'Squads', units: squads),
        ],
      ],
    );
  }
}

class _UnitSection extends StatelessWidget {
  final String title;
  final List<Unit> units;

  const _UnitSection({
    required this.title,
    required this.units,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            title.toUpperCase(),
            style: CyberTextStyles.labelSmall.copyWith(
              letterSpacing: 1,
            ),
          ),
        ),
        ...units.map(
          (unit) => GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UnitDetailPage(unit: unit)),
              );
            },
            child: UnitCard(
              unit: unit,
              isUserUnit: unit.id == 'squad_1', // Mock - would check actual user
            ),
          ),
        ),
      ],
    );
  }
}

class _StatsFooter extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _StatsFooter({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: CyberColors.cardBackground,
        border: Border(
          top: BorderSide(color: CyberColors.borderSubtle),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _FooterStat(
            value: '${stats['totalSoldiers']}',
            label: 'Soldiers',
          ),
          _FooterStat(
            value: '${stats['totalCompanies']}',
            label: 'Companies',
          ),
          _FooterStat(
            value: '${stats['totalPlatoons']}',
            label: 'Platoons',
          ),
          _FooterStat(
            value: '${stats['totalSquads']}',
            label: 'Squads',
          ),
        ],
      ),
    );
  }
}

class _FooterStat extends StatelessWidget {
  final String value;
  final String label;

  const _FooterStat({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: CyberTextStyles.statNumber.copyWith(
            fontSize: 18,
            color: CyberColors.electricCyan,
          ),
        ),
        Text(
          label,
          style: CyberTextStyles.labelSmall,
        ),
      ],
    );
  }
}
