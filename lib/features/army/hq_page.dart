import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/army_provider.dart';
import '../../core/models/army/army_models.dart';
import '../../app/theme/cyber_colors.dart';
import '../../app/theme/cyber_text_styles.dart';
import 'widgets/army_widgets.dart';
import 'dialogs/connect_wallet_dialog.dart';
import 'dialogs/recruit_dialog.dart';
import 'pages/task_detail_page.dart';
import 'pages/notifications_page.dart';

/// Headquarters - Personal Dashboard
class HQPage extends ConsumerWidget {
  const HQPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soldierAsync = ref.watch(currentSoldierProvider);
    final tasksAsync = ref.watch(myTasksProvider);
    final unitAsync = ref.watch(myUnitProvider);

    return Scaffold(
      backgroundColor: CyberColors.spaceBlack,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      'HEADQUARTERS',
                      style: CyberTextStyles.headlineLarge,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NotificationsPage()),
                        );
                      },
                      icon: Stack(
                        children: [
                          const Icon(
                            Icons.notifications_outlined,
                            color: CyberColors.textPrimary,
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: CyberColors.combatRed,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Profile Card
            SliverToBoxAdapter(
              child: soldierAsync.when(
                data: (soldier) => soldier != null
                    ? _ProfileCard(soldier: soldier)
                    : const _GuestCard(),
                loading: () => const _LoadingCard(),
                error: (e, _) => _ErrorCard(error: e.toString()),
              ),
            ),

            // Stats Row
            SliverToBoxAdapter(
              child: soldierAsync.when(
                data: (soldier) =>
                    soldier != null ? _StatsSection(soldier: soldier) : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            // Active Tasks Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ACTIVE TASKS',
                      style: CyberTextStyles.headlineSmall,
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Navigate to all tasks
                      },
                      child: Text(
                        'View All',
                        style: CyberTextStyles.labelMedium.copyWith(
                          color: CyberColors.electricCyan,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tasks List
            tasksAsync.when(
              data: (tasks) => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= tasks.length || index >= 3) return null;
                    return CompactTaskCard(
                      task: tasks[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TaskDetailPage(task: tasks[index]),
                          ),
                        );
                      },
                    );
                  },
                  childCount: tasks.length > 3 ? 3 : tasks.length,
                ),
              ),
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: _ErrorCard(error: e.toString()),
              ),
            ),

            // Squad Status Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'SQUAD STATUS',
                  style: CyberTextStyles.headlineSmall,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: unitAsync.when(
                data: (unit) =>
                    unit != null ? _SquadStatusCard(unit: unit) : const SizedBox.shrink(),
                loading: () => const _LoadingCard(),
                error: (e, _) => _ErrorCard(error: e.toString()),
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final Soldier soldier;

  const _ProfileCard({required this.soldier});

  @override
  Widget build(BuildContext context) {
    return CyberCard(
      showScanLines: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar with rank
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CyberColors.darkPanel,
                      border: Border.all(
                        color: _getRankColor(soldier.rank),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getRankColor(soldier.rank).withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person,
                        size: 36,
                        color: _getRankColor(soldier.rank),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: CyberColors.cardBackground,
                      shape: BoxShape.circle,
                      border: Border.all(color: _getRankColor(soldier.rank)),
                    ),
                    child: Text(
                      soldier.rank.abbreviation,
                      style: CyberTextStyles.labelSmall.copyWith(
                        color: _getRankColor(soldier.rank),
                        fontWeight: FontWeight.bold,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CallsignDisplay(callsign: soldier.callsign),
                    const SizedBox(height: 4),
                    Text(
                      '${soldier.rank.displayName} • Alpha Squad Leader',
                      style: CyberTextStyles.bodySmall,
                    ),
                    Text(
                      '1st Section, 2nd Platoon',
                      style: CyberTextStyles.labelSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // XP Progress
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress to ${soldier.rank.nextRank?.abbreviation ?? "MAX"}',
                    style: CyberTextStyles.labelSmall,
                  ),
                  Text(
                    '${(soldier.xpProgressToNextRank * 100).toInt()}%',
                    style: CyberTextStyles.labelSmall.copyWith(
                      color: CyberColors.electricCyan,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              CyberProgressBar(
                progress: soldier.xpProgressToNextRank,
                height: 8,
              ),
              const SizedBox(height: 4),
              Text(
                '${soldier.xpToNextRank} XP to next rank',
                style: CyberTextStyles.labelSmall,
              ),
            ],
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

class _StatsSection extends StatelessWidget {
  final Soldier soldier;

  const _StatsSection({required this.soldier});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: StatRow(
        stats: [
          StatBox(
            value: '${soldier.tasksCompleted}',
            label: 'Tasks',
            icon: Icons.check_circle_outline,
          ),
          StatBox(
            value: '12',
            label: 'Recruits',
            icon: Icons.person_add_outlined,
          ),
          StatBox(
            value: '${soldier.vgrdEarned}',
            label: 'VGRD',
            icon: Icons.toll_outlined,
            valueColor: CyberColors.tacticalGreen,
          ),
          StatBox(
            value: '${soldier.effectiveVotingPower}',
            label: 'Voting',
            icon: Icons.how_to_vote_outlined,
          ),
        ],
      ),
    );
  }
}

class _SquadStatusCard extends StatelessWidget {
  final Unit unit;

  const _SquadStatusCard({required this.unit});

  @override
  Widget build(BuildContext context) {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    unit.type.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    unit.name,
                    style: CyberTextStyles.headlineSmall,
                  ),
                ],
              ),
              Text(
                '${unit.memberCount}/${unit.maxSize} members',
                style: CyberTextStyles.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${unit.objectiveIds.length} active objectives',
            style: CyberTextStyles.bodySmall,
          ),
          const SizedBox(height: 16),
          // Member icons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              unit.memberCount > 8 ? 8 : unit.memberCount,
              (index) => _MemberIcon(
                isOnline: index % 3 != 2,
                isLeader: index == 0,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => const RecruitDialog(),
              );
            },
            icon: const Icon(Icons.person_add, size: 18),
            label: const Text('Recruit'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberIcon extends StatelessWidget {
  final bool isOnline;
  final bool isLeader;

  const _MemberIcon({
    required this.isOnline,
    this.isLeader = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: CyberColors.darkPanel,
            border: Border.all(
              color: isLeader
                  ? CyberColors.ncoSilver
                  : CyberColors.borderSubtle,
              width: isLeader ? 2 : 1,
            ),
          ),
          child: Icon(
            Icons.person,
            size: 20,
            color: isLeader
                ? CyberColors.ncoSilver
                : CyberColors.textMuted,
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline
                  ? CyberColors.tacticalGreen
                  : CyberColors.textMuted,
              border: Border.all(
                color: CyberColors.cardBackground,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GuestCard extends StatelessWidget {
  const _GuestCard();

  @override
  Widget build(BuildContext context) {
    return CyberCard(
      child: Column(
        children: [
          Icon(
            Icons.military_tech,
            size: 64,
            color: CyberColors.electricCyan,
          ),
          const SizedBox(height: 16),
          Text(
            'Join the Army',
            style: CyberTextStyles.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Connect your wallet and apply to a squad to begin your journey.',
            style: CyberTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => const ConnectWalletDialog(),
              );
            },
            icon: const Icon(Icons.account_balance_wallet),
            label: const Text('Connect Wallet'),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const CyberCard(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(
            color: CyberColors.electricCyan,
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String error;

  const _ErrorCard({required this.error});

  @override
  Widget build(BuildContext context) {
    return CyberCard(
      borderColor: CyberColors.combatRed,
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: CyberColors.combatRed,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: CyberTextStyles.bodySmall.copyWith(
                color: CyberColors.combatRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
