import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/army_provider.dart';
import '../../core/models/army/army_models.dart';
import '../../app/theme/cyber_colors.dart';
import '../../app/theme/cyber_text_styles.dart';
import 'widgets/army_widgets.dart';
import 'pages/bounty_detail_page.dart';
import '../bounty/create_bounty_flow.dart';

/// Provider for search query
final bountySearchQueryProvider = StateProvider<String>((ref) => '');

/// Missions - Bounties & Objectives screen
class MissionsPage extends ConsumerStatefulWidget {
  const MissionsPage({super.key});

  @override
  ConsumerState<MissionsPage> createState() => _MissionsPageState();
}

class _MissionsPageState extends ConsumerState<MissionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        ref.read(bountySearchQueryProvider.notifier).state = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bountiesAsync = ref.watch(bountiesProvider);
    final searchQuery = ref.watch(bountySearchQueryProvider);
    final soldierAsync = ref.watch(currentSoldierProvider);

    return Scaffold(
      backgroundColor: CyberColors.spaceBlack,
      floatingActionButton: soldierAsync.whenOrNull(
        data: (soldier) {
          // Allow bounty creation for demo purposes (SGT+ in production)
          if (soldier != null) {
            return FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateBountyFlow()),
                );
              },
              backgroundColor: CyberColors.tacticalGreen,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Create Bounty'),
            );
          }
          return null;
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (!_isSearching)
                    Text(
                      'MISSIONS',
                      style: CyberTextStyles.headlineLarge,
                    )
                  else
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: CyberTextStyles.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'Search missions...',
                          hintStyle: CyberTextStyles.bodyMedium.copyWith(
                            color: CyberColors.textMuted,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (value) {
                          ref.read(bountySearchQueryProvider.notifier).state = value;
                        },
                      ),
                    ),
                  if (!_isSearching) const Spacer(),
                  IconButton(
                    onPressed: _toggleSearch,
                    icon: Icon(
                      _isSearching ? Icons.close : Icons.search,
                      color: CyberColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: CyberColors.cardBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: CyberColors.electricCyan.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: CyberColors.electricCyan,
                unselectedLabelColor: CyberColors.textMuted,
                labelStyle: CyberTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Available'),
                  Tab(text: 'Active'),
                  Tab(text: 'Done'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Content
            Expanded(
              child: bountiesAsync.when(
                data: (bounties) {
                  // Filter by search query
                  final filtered = searchQuery.isEmpty
                      ? bounties
                      : bounties.where((b) {
                          final query = searchQuery.toLowerCase();
                          return b.title.toLowerCase().contains(query) ||
                              b.description.toLowerCase().contains(query) ||
                              b.skillTags.any((t) => t.toLowerCase().contains(query));
                        }).toList();

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _BountyList(bounties: filtered),
                      _BountyList(
                        bounties: filtered
                            .where((b) => b.status == BountyStatus.active)
                            .toList(),
                      ),
                      _BountyList(
                        bounties: filtered
                            .where((b) => b.status == BountyStatus.inProgress)
                            .toList(),
                      ),
                      _BountyList(
                        bounties: filtered
                            .where((b) => b.status == BountyStatus.completed)
                            .toList(),
                      ),
                    ],
                  );
                },
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
          ],
        ),
      ),
    );
  }
}

class _BountyList extends StatelessWidget {
  final List<Bounty> bounties;

  const _BountyList({required this.bounties});

  @override
  Widget build(BuildContext context) {
    if (bounties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.track_changes_outlined,
              size: 64,
              color: CyberColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'No missions found',
              style: CyberTextStyles.bodyMedium.copyWith(
                color: CyberColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: bounties.length + 1, // +1 for featured
      itemBuilder: (context, index) {
        if (index == 0) {
          // Featured bounty
          final featured = bounties.first;
          return _FeaturedBountyCard(bounty: featured);
        }
        return _BountyCard(bounty: bounties[index - 1]);
      },
    );
  }
}

class _FeaturedBountyCard extends StatelessWidget {
  final Bounty bounty;

  const _FeaturedBountyCard({required this.bounty});

  @override
  Widget build(BuildContext context) {
    return GlowingCard(
      glowColor: CyberColors.officerGold,
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: CyberColors.officerGold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'FEATURED BOUNTY',
                style: CyberTextStyles.labelMedium.copyWith(
                  color: CyberColors.officerGold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CyberColors.officerGold.withValues(alpha: 0.2),
                  CyberColors.cardBackground,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: CyberColors.officerGold.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bounty.title,
                  style: CyberTextStyles.headlineMedium.copyWith(
                    color: CyberColors.officerGold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bounty.description,
                  style: CyberTextStyles.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _InfoChip(
                icon: Icons.toll,
                label: '${bounty.totalAmount} VGRD',
                color: CyberColors.tacticalGreen,
              ),
              const SizedBox(width: 12),
              _InfoChip(
                icon: Icons.schedule,
                label: '${bounty.daysRemaining} days left',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _InfoChip(
                icon: Icons.groups,
                label: '${bounty.objectiveCount} objectives',
              ),
              const SizedBox(width: 12),
              _InfoChip(
                icon: Icons.pie_chart,
                label: '${(bounty.completionPercentage * 100).toInt()}% complete',
                color: CyberColors.electricCyan,
              ),
            ],
          ),
          const SizedBox(height: 16),
          CyberProgressBar(
            progress: bounty.completionPercentage,
            height: 6,
            progressColor: CyberColors.officerGold,
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BountyDetailPage(bounty: bounty)),
              );
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              side: const BorderSide(color: CyberColors.officerGold),
              foregroundColor: CyberColors.officerGold,
            ),
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }
}

class _BountyCard extends StatelessWidget {
  final Bounty bounty;

  const _BountyCard({required this.bounty});

  @override
  Widget build(BuildContext context) {
    return CyberCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BountyDetailPage(bounty: bounty)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  bounty.title,
                  style: CyberTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (bounty.status == BountyStatus.active)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: CyberColors.tacticalGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'NEW',
                    style: CyberTextStyles.labelSmall.copyWith(
                      color: CyberColors.tacticalGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Skill tags
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: bounty.skillTags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: CyberColors.darkPanel,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: CyberColors.borderSubtle),
                    ),
                    child: Text(
                      tag,
                      style: CyberTextStyles.labelSmall,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${bounty.totalAmount} VGRD',
                style: CyberTextStyles.tokenAmount,
              ),
              const Spacer(),
              Text(
                '${bounty.objectiveCount} objectives',
                style: CyberTextStyles.labelSmall,
              ),
              const SizedBox(width: 12),
              Text(
                '${bounty.daysRemaining}d',
                style: CyberTextStyles.labelSmall.copyWith(
                  color: bounty.daysRemaining < 7
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
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? CyberColors.textMuted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: chipColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: CyberTextStyles.labelSmall.copyWith(color: chipColor),
        ),
      ],
    );
  }
}
