import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/army_provider.dart';
import '../../core/models/army/army_models.dart';
import '../../app/theme/cyber_colors.dart';
import '../../app/theme/cyber_text_styles.dart';
import 'widgets/army_widgets.dart';

/// Intel - Analytics Dashboard screen
class IntelPage extends ConsumerStatefulWidget {
  const IntelPage({super.key});

  @override
  ConsumerState<IntelPage> createState() => _IntelPageState();
}

class _IntelPageState extends ConsumerState<IntelPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final soldierAsync = ref.watch(currentSoldierProvider);
    final leaderboardAsync = ref.watch(leaderboardProvider);

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
                    'INTEL',
                    style: CyberTextStyles.headlineLarge,
                  ),
                ],
              ),
            ),

            // Scope tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _ScopeTab(
                      label: 'Personal',
                      isSelected: _tabController.index == 0,
                      onTap: () => _tabController.animateTo(0),
                    ),
                    _ScopeTab(
                      label: 'Squad',
                      isSelected: _tabController.index == 1,
                      onTap: () => _tabController.animateTo(1),
                    ),
                    _ScopeTab(
                      label: 'Section',
                      isSelected: _tabController.index == 2,
                      onTap: () => _tabController.animateTo(2),
                    ),
                    _ScopeTab(
                      label: 'Platoon',
                      isSelected: _tabController.index == 3,
                      onTap: () => _tabController.animateTo(3),
                    ),
                    _ScopeTab(
                      label: 'Company',
                      isSelected: _tabController.index == 4,
                      onTap: () => _tabController.animateTo(4),
                    ),
                    _ScopeTab(
                      label: 'Army',
                      isSelected: _tabController.index == 5,
                      onTap: () => _tabController.animateTo(5),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 100),
                children: [
                  // Stats cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'TASK COMPLETION',
                            value: '47',
                            subtitle: '92% success rate',
                            trend: '+15%',
                            trendPositive: true,
                            icon: Icons.check_circle_outline,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            title: 'EARNINGS (30d)',
                            value: '3,450',
                            subtitle: 'VGRD earned',
                            icon: Icons.toll,
                            color: CyberColors.tacticalGreen,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Leaderboard
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'LEADERBOARD - 2nd Platoon',
                          style: CyberTextStyles.headlineSmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  leaderboardAsync.when(
                    data: (soldiers) => _Leaderboard(
                      entries: soldiers
                          .asMap()
                          .entries
                          .map((e) => {
                                'rank': e.key + 1,
                                'callsign': e.value.callsign,
                                'tasks': e.value.tasksCompleted,
                                'vgrd': e.value.vgrdEarned,
                                'streak': 0,
                              })
                          .toList(),
                    ),
                    loading: () => const CyberCard(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: CyberColors.electricCyan,
                        ),
                      ),
                    ),
                    error: (e, _) => CyberCard(
                      child: Text(
                        'Error: $e',
                        style: CyberTextStyles.bodySmall.copyWith(
                          color: CyberColors.combatRed,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Promotion progress
                  soldierAsync.when(
                    data: (soldier) => soldier != null
                        ? _PromotionProgress(soldier: soldier)
                        : const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
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

class _ScopeTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ScopeTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? CyberColors.electricCyan.withValues(alpha: 0.2)
              : CyberColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? CyberColors.electricCyan
                : CyberColors.borderSubtle,
          ),
        ),
        child: Text(
          label,
          style: CyberTextStyles.labelMedium.copyWith(
            color: isSelected
                ? CyberColors.electricCyan
                : CyberColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final String? trend;
  final bool? trendPositive;
  final IconData icon;
  final Color? color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    this.trend,
    this.trendPositive,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? CyberColors.electricCyan;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CyberColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CyberColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: cardColor),
              const SizedBox(width: 6),
              Text(
                title,
                style: CyberTextStyles.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: CyberTextStyles.statNumber.copyWith(color: cardColor),
              ),
              if (trend != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: (trendPositive ?? true)
                        ? CyberColors.tacticalGreen.withValues(alpha: 0.2)
                        : CyberColors.combatRed.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        (trendPositive ?? true)
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 12,
                        color: (trendPositive ?? true)
                            ? CyberColors.tacticalGreen
                            : CyberColors.combatRed,
                      ),
                      Text(
                        trend!,
                        style: CyberTextStyles.labelSmall.copyWith(
                          color: (trendPositive ?? true)
                              ? CyberColors.tacticalGreen
                              : CyberColors.combatRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: CyberTextStyles.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _Leaderboard extends StatelessWidget {
  final List<Map<String, dynamic>> entries;

  const _Leaderboard({required this.entries});

  @override
  Widget build(BuildContext context) {
    return CyberCard(
      child: Column(
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    'Rank',
                    style: CyberTextStyles.labelSmall,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Callsign',
                    style: CyberTextStyles.labelSmall,
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    'Tasks',
                    style: CyberTextStyles.labelSmall,
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: Text(
                    'VGRD',
                    style: CyberTextStyles.labelSmall,
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    'Streak',
                    style: CyberTextStyles.labelSmall,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...entries.map((entry) => _LeaderboardRow(entry: entry)),
        ],
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final Map<String, dynamic> entry;

  const _LeaderboardRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final rank = entry['rank'] as int;
    final isUser = entry['callsign'] == 'CIPHER-7X4';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isUser
            ? CyberColors.electricCyan.withValues(alpha: 0.1)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(color: CyberColors.borderSubtle),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: _RankMedal(rank: rank),
          ),
          Expanded(
            child: CallsignText(
              callsign: entry['callsign'] as String,
              showGlow: isUser,
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              '${entry['tasks']}',
              style: CyberTextStyles.bodyMedium,
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(
            width: 70,
            child: Text(
              '${entry['vgrd']}',
              style: CyberTextStyles.bodyMedium.copyWith(
                color: CyberColors.tacticalGreen,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(
            width: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${entry['streak']}',
                  style: CyberTextStyles.bodyMedium,
                ),
                if ((entry['streak'] as int) > 5)
                  const Text(' \ud83d\udd25', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RankMedal extends StatelessWidget {
  final int rank;

  const _RankMedal({required this.rank});

  @override
  Widget build(BuildContext context) {
    if (rank == 1) {
      return const Text('\ud83e\udd47', style: TextStyle(fontSize: 18));
    } else if (rank == 2) {
      return const Text('\ud83e\udd48', style: TextStyle(fontSize: 18));
    } else if (rank == 3) {
      return const Text('\ud83e\udd49', style: TextStyle(fontSize: 18));
    }
    return Text(
      '$rank',
      style: CyberTextStyles.bodyMedium.copyWith(
        color: CyberColors.textMuted,
      ),
    );
  }
}

class _PromotionProgress extends StatelessWidget {
  final Soldier soldier;

  const _PromotionProgress({required this.soldier});

  @override
  Widget build(BuildContext context) {
    final nextRank = soldier.rank.nextRank;
    if (nextRank == null) return const SizedBox.shrink();

    return CyberCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PROMOTION PROGRESS',
            style: CyberTextStyles.headlineSmall,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              RankBadge(rank: soldier.rank, size: 40),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      CyberProgressBar(
                        progress: soldier.xpProgressToNextRank,
                        height: 8,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(soldier.xpProgressToNextRank * 100).toInt()}%',
                        style: CyberTextStyles.labelSmall,
                      ),
                    ],
                  ),
                ),
              ),
              RankBadge(rank: nextRank, size: 40, showGlow: false),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Requirements:',
            style: CyberTextStyles.labelLarge,
          ),
          const SizedBox(height: 12),
          _RequirementItem(
            text: 'Lead squad with 8+ members (8/8)',
            isComplete: true,
          ),
          _RequirementItem(
            text: 'Complete 40+ tasks (${soldier.tasksCompleted}/40)',
            isComplete: soldier.tasksCompleted >= 40,
          ),
          _RequirementItem(
            text: 'Squad reaches 10 members for split (8/10)',
            isComplete: false,
          ),
          _RequirementItem(
            text: 'Appointed by Platoon Leader',
            isComplete: false,
          ),
        ],
      ),
    );
  }
}

class _RequirementItem extends StatelessWidget {
  final String text;
  final bool isComplete;

  const _RequirementItem({
    required this.text,
    required this.isComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            isComplete ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: isComplete
                ? CyberColors.tacticalGreen
                : CyberColors.textMuted,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: CyberTextStyles.bodySmall.copyWith(
                color: isComplete
                    ? CyberColors.textPrimary
                    : CyberColors.textMuted,
                decoration: isComplete ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
