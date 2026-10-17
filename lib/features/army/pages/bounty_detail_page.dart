import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/cyber_colors.dart';
import '../../../app/theme/cyber_text_styles.dart';
import '../../../core/models/army/army_models.dart';
import '../../../core/providers/army_provider.dart';
import '../widgets/army_widgets.dart';

/// Detail page for viewing a bounty/mission
class BountyDetailPage extends ConsumerWidget {
  final Bounty bounty;

  const BountyDetailPage({super.key, required this.bounty});

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
              title: Text('MISSION DETAILS', style: CyberTextStyles.headlineSmall),
              actions: [
                if (bounty.status == BountyStatus.active)
                  soldierAsync.whenOrNull(
                    data: (soldier) {
                      if (soldier?.rank.isCaptain == true) {
                        return IconButton(
                          icon: const Icon(Icons.edit, color: CyberColors.officerGold),
                          onPressed: () {
                            // Edit bounty
                          },
                        );
                      }
                      return null;
                    },
                  ) ?? const SizedBox.shrink(),
              ],
            ),

            // Header Card
            SliverToBoxAdapter(
              child: GlowingCard(
                glowColor: _getStatusColor(bounty.status),
                margin: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(bounty.status).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _getStatusColor(bounty.status)),
                          ),
                          child: Text(
                            bounty.status.name.toUpperCase(),
                            style: CyberTextStyles.labelSmall.copyWith(
                              color: _getStatusColor(bounty.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.schedule, size: 16, color: CyberColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          '${bounty.daysRemaining} days left',
                          style: CyberTextStyles.labelSmall.copyWith(
                            color: bounty.daysRemaining < 7
                                ? CyberColors.militaryAmber
                                : CyberColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(bounty.title, style: CyberTextStyles.headlineMedium),
                    const SizedBox(height: 8),

                    // Description
                    Text(
                      bounty.description,
                      style: CyberTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 16),

                    // Skill tags
                    if (bounty.skillTags.isNotEmpty) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: bounty.skillTags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: CyberColors.darkPanel,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: CyberColors.electricCyan.withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              tag,
                              style: CyberTextStyles.labelSmall.copyWith(
                                color: CyberColors.electricCyan,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Progress
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Progress', style: CyberTextStyles.labelMedium),
                            Text(
                              '${(bounty.completionPercentage * 100).toInt()}%',
                              style: CyberTextStyles.labelMedium.copyWith(
                                color: CyberColors.electricCyan,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        CyberProgressBar(
                          progress: bounty.completionPercentage,
                          height: 8,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Stats Row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: StatRow(
                  stats: [
                    StatBox(
                      value: '${bounty.totalAmount}',
                      label: 'Total VGRD',
                      icon: Icons.toll,
                      valueColor: CyberColors.tacticalGreen,
                    ),
                    StatBox(
                      value: '${bounty.remainingAmount}',
                      label: 'Remaining',
                      icon: Icons.account_balance_wallet,
                    ),
                    StatBox(
                      value: '${bounty.objectiveCount}',
                      label: 'Objectives',
                      icon: Icons.flag,
                    ),
                  ],
                ),
              ),
            ),

            // Objectives Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text('OBJECTIVES', style: CyberTextStyles.headlineSmall),
              ),
            ),

            // Placeholder for objectives
            SliverToBoxAdapter(
              child: CyberCard(
                child: Column(
                  children: [
                    Icon(Icons.assignment_outlined, size: 48, color: CyberColors.textMuted),
                    const SizedBox(height: 12),
                    Text(
                      'No objectives created yet',
                      style: CyberTextStyles.bodyMedium.copyWith(color: CyberColors.textMuted),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Objectives will appear here once assigned to units',
                      style: CyberTextStyles.bodySmall.copyWith(color: CyberColors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // Action Buttons
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: soldierAsync.when(
                  data: (soldier) {
                    if (soldier == null) return const SizedBox.shrink();

                    // Captains can manage bounty
                    if (soldier.rank.isCaptain && bounty.status == BountyStatus.active) {
                      return Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              // Add objective
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Objective'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              backgroundColor: CyberColors.officerGold,
                              foregroundColor: CyberColors.spaceBlack,
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () {
                              // Cancel bounty
                            },
                            icon: const Icon(Icons.cancel),
                            label: const Text('Cancel Bounty'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              side: const BorderSide(color: CyberColors.combatRed),
                              foregroundColor: CyberColors.combatRed,
                            ),
                          ),
                        ],
                      );
                    }

                    // Regular soldiers can apply to work on objectives
                    if (bounty.status == BountyStatus.active || bounty.status == BountyStatus.inProgress) {
                      return ElevatedButton.icon(
                        onPressed: () {
                          // Apply to work on bounty
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text('Apply to Work'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
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

  Color _getStatusColor(BountyStatus status) {
    switch (status) {
      case BountyStatus.draft:
        return CyberColors.textMuted;
      case BountyStatus.active:
        return CyberColors.tacticalGreen;
      case BountyStatus.inProgress:
        return CyberColors.electricCyan;
      case BountyStatus.completed:
        return CyberColors.officerGold;
      case BountyStatus.cancelled:
        return CyberColors.combatRed;
    }
  }
}
