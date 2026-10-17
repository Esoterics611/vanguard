import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/cyber_colors.dart';
import '../../../app/theme/cyber_text_styles.dart';
import '../../../core/models/army/army_models.dart';
import '../../../core/providers/army_provider.dart';
import '../widgets/army_widgets.dart';
import '../dialogs/apply_squad_dialog.dart';

/// Detail page for viewing a unit
class UnitDetailPage extends ConsumerWidget {
  final Unit unit;

  const UnitDetailPage({super.key, required this.unit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soldierAsync = ref.watch(currentSoldierProvider);

    return Scaffold(
      backgroundColor: CyberColors.spaceBlack,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              backgroundColor: CyberColors.spaceBlack,
              floating: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: CyberColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text('UNIT DETAILS', style: CyberTextStyles.headlineSmall),
            ),

            // Header Card
            SliverToBoxAdapter(
              child: GlowingCard(
                glowColor: _getUnitColor(unit.type),
                margin: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type and Icon
                    Row(
                      children: [
                        Text(
                          unit.type.icon,
                          style: const TextStyle(fontSize: 48),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                unit.type.name.toUpperCase(),
                                style: CyberTextStyles.labelMedium.copyWith(
                                  color: _getUnitColor(unit.type),
                                  letterSpacing: 2,
                                ),
                              ),
                              Text(unit.name, style: CyberTextStyles.headlineMedium),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Stats Row
                    Row(
                      children: [
                        _StatChip(
                          icon: Icons.people,
                          label: '${unit.memberCount}/${unit.maxSize}',
                          sublabel: 'Members',
                        ),
                        const SizedBox(width: 16),
                        _StatChip(
                          icon: Icons.flag,
                          label: '${unit.objectiveIds.length}',
                          sublabel: 'Objectives',
                        ),
                        const SizedBox(width: 16),
                        _StatChip(
                          icon: Icons.account_tree,
                          label: '${unit.childUnitIds.length}',
                          sublabel: 'Sub-units',
                        ),
                      ],
                    ),

                    // Capacity bar
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Capacity', style: CyberTextStyles.labelSmall),
                            Text(
                              '${(unit.memberCount / unit.maxSize * 100).toInt()}%',
                              style: CyberTextStyles.labelSmall.copyWith(
                                color: CyberColors.electricCyan,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        CyberProgressBar(
                          progress: unit.memberCount / unit.maxSize,
                          height: 6,
                          progressColor: unit.memberCount >= unit.maxSize
                              ? CyberColors.combatRed
                              : _getUnitColor(unit.type),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Leadership Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text('LEADERSHIP', style: CyberTextStyles.headlineSmall),
              ),
            ),

            SliverToBoxAdapter(
              child: CyberCard(
                child: Column(
                  children: [
                    if (unit.leaderId != null)
                      _LeaderRow(
                        title: 'Commander',
                        soldierId: unit.leaderId!,
                      )
                    else
                      Text(
                        'No commander assigned',
                        style: CyberTextStyles.bodySmall.copyWith(
                          color: CyberColors.textMuted,
                        ),
                      ),
                    if (unit.secondInCommandId != null) ...[
                      const SizedBox(height: 12),
                      _LeaderRow(
                        title: 'Second in Command',
                        soldierId: unit.secondInCommandId!,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Members Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('MEMBERS', style: CyberTextStyles.headlineSmall),
                    Text(
                      '${unit.memberCount} soldiers',
                      style: CyberTextStyles.labelSmall,
                    ),
                  ],
                ),
              ),
            ),

            // Member list placeholder
            SliverToBoxAdapter(
              child: CyberCard(
                child: unit.memberIds.isEmpty
                    ? Center(
                        child: Text(
                          'No members yet',
                          style: CyberTextStyles.bodySmall.copyWith(
                            color: CyberColors.textMuted,
                          ),
                        ),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: unit.memberIds.map((memberId) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: CyberColors.darkPanel,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: CyberColors.borderSubtle),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 16,
                                  color: CyberColors.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  memberId.substring(0, 8),
                                  style: CyberTextStyles.labelSmall,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ),

            // Action buttons
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: soldierAsync.when(
                  data: (soldier) {
                    if (soldier == null) return const SizedBox.shrink();

                    // Check if user is already in this unit
                    if (soldier.squadId == unit.id) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: CyberColors.electricCyan.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: CyberColors.electricCyan),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, color: CyberColors.electricCyan),
                            const SizedBox(width: 8),
                            Text(
                              'You are a member of this unit',
                              style: CyberTextStyles.bodyMedium.copyWith(
                                color: CyberColors.electricCyan,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Can apply to squad
                    if (unit.type == UnitType.squad && unit.memberCount < unit.maxSize) {
                      return ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => ApplySquadDialog(squad: unit),
                          );
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text('Apply to Join'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      );
                    }

                    if (unit.memberCount >= unit.maxSize) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: CyberColors.combatRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: CyberColors.combatRed),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.block, color: CyberColors.combatRed),
                            const SizedBox(width: 8),
                            Text(
                              'Unit is at capacity',
                              style: CyberTextStyles.bodyMedium.copyWith(
                                color: CyberColors.combatRed,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
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

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CyberColors.darkPanel,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: CyberColors.electricCyan, size: 20),
            const SizedBox(height: 4),
            Text(label, style: CyberTextStyles.headlineSmall),
            Text(
              sublabel,
              style: CyberTextStyles.labelSmall.copyWith(
                color: CyberColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderRow extends ConsumerWidget {
  final String title;
  final String soldierId;

  const _LeaderRow({required this.title, required this.soldierId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: CyberColors.darkPanel,
            border: Border.all(color: CyberColors.officerGold),
          ),
          child: Icon(Icons.military_tech, color: CyberColors.officerGold, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: CyberTextStyles.labelSmall),
              Text(
                soldierId.substring(0, 12),
                style: CyberTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
