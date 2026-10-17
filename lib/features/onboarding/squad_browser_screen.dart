import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/cyber_colors.dart';
import '../../app/app_shell.dart';
import '../../core/services/army_service.dart';
import '../../core/models/army/army_models.dart';
import '../army/widgets/cyber_card.dart';

/// Screen for browsing squads and choosing to join or create one
/// Default flow: Create a new squad (if you have tokens/permission)
/// Alternative: Apply to existing squad
class SquadBrowserScreen extends ConsumerStatefulWidget {
  final String? walletAddress;

  const SquadBrowserScreen({super.key, this.walletAddress});

  @override
  ConsumerState<SquadBrowserScreen> createState() => _SquadBrowserScreenState();
}

class _SquadBrowserScreenState extends ConsumerState<SquadBrowserScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Unit> _squads = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSquads();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSquads() async {
    try {
      final army = ArmyService();
      final squads = await army.getUnits(type: UnitType.squad);
      setState(() {
        _squads = squads;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = widget.walletAddress == null;

    return Scaffold(
      backgroundColor: CyberColors.spaceBlack,
      appBar: AppBar(
        backgroundColor: CyberColors.deepSpace,
        title: Text(
          'CHOOSE YOUR PATH',
          style: TextStyle(
            color: CyberColors.textPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        bottom: isGuest
            ? null
            : TabBar(
                controller: _tabController,
                indicatorColor: CyberColors.electricCyan,
                labelColor: CyberColors.electricCyan,
                unselectedLabelColor: CyberColors.textMuted,
                tabs: const [
                  Tab(text: 'CREATE SQUAD'),
                  Tab(text: 'JOIN SQUAD'),
                ],
              ),
      ),
      body: isGuest
          ? _buildGuestView()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCreateSquadTab(),
                _buildJoinSquadTab(),
              ],
            ),
    );
  }

  Widget _buildGuestView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.visibility_outlined,
              size: 64,
              color: CyberColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'Guest Mode',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: CyberColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Connect a wallet to create or join a squad',
              style: TextStyle(
                fontSize: 14,
                color: CyberColors.textMuted,
              ),
            ),
            const SizedBox(height: 32),
            _buildSquadList(canApply: false),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateSquadTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  CyberColors.tacticalGreen.withValues(alpha: 0.2),
                  CyberColors.electricCyan.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CyberColors.tacticalGreen.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.flag,
                  size: 48,
                  color: CyberColors.tacticalGreen,
                ),
                const SizedBox(height: 16),
                Text(
                  'START YOUR OWN SQUAD',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CyberColors.textPrimary,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Lead from day one. Build your team. Complete bounties together.',
                  style: TextStyle(
                    fontSize: 14,
                    color: CyberColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Create squad form
          _CreateSquadForm(
            walletAddress: widget.walletAddress!,
            onSquadCreated: _onSquadCreated,
          ),
        ],
      ),
    );
  }

  Widget _buildJoinSquadTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Squads',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CyberColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Apply to join an existing squad',
            style: TextStyle(
              fontSize: 13,
              color: CyberColors.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          _buildSquadList(canApply: true),
        ],
      ),
    );
  }

  Widget _buildSquadList({required bool canApply}) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          'Error: $_error',
          style: TextStyle(color: CyberColors.combatRed),
        ),
      );
    }

    if (_squads.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.groups_outlined,
              size: 48,
              color: CyberColors.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              'No squads yet',
              style: TextStyle(
                fontSize: 16,
                color: CyberColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to create one!',
              style: TextStyle(
                fontSize: 13,
                color: CyberColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _squads.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final squad = _squads[index];
        return _SquadCard(
          squad: squad,
          canApply: canApply && widget.walletAddress != null,
          onApply: () => _showApplicationDialog(squad),
        );
      },
    );
  }

  void _showApplicationDialog(Unit squad) {
    showDialog(
      context: context,
      builder: (context) => _SquadApplicationDialog(
        squad: squad,
        walletAddress: widget.walletAddress!,
        onSubmitted: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Application submitted to ${squad.name}'),
              backgroundColor: CyberColors.tacticalGreen,
            ),
          );
        },
      ),
    );
  }

  void _onSquadCreated(String squadId) {
    // Navigate to main app
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AppShell()),
      (route) => false,
    );
  }
}

/// Form for creating a new squad
class _CreateSquadForm extends StatefulWidget {
  final String walletAddress;
  final Function(String squadId) onSquadCreated;

  const _CreateSquadForm({
    required this.walletAddress,
    required this.onSquadCreated,
  });

  @override
  State<_CreateSquadForm> createState() => _CreateSquadFormState();
}

class _CreateSquadFormState extends State<_CreateSquadForm> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createSquad() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter a squad name');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final army = ArmyService();

      // First ensure user is authenticated and has a soldier record
      final result = await army.connectWithWallet(walletAddress: widget.walletAddress);

      // Create the squad with this soldier as leader
      final squadId = await army.createSquadWithLeader(
        name: name,
        description: _descriptionController.text.trim(),
      );

      widget.onSquadCreated(squadId);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CyberCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Squad Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CyberColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // Name input
            _InputField(
              controller: _nameController,
              label: 'Squad Name',
              hint: 'e.g., Alpha Squad, Phoenix Team',
              icon: Icons.badge_outlined,
            ),
            const SizedBox(height: 16),

            // Description input
            _InputField(
              controller: _descriptionController,
              label: 'Description (optional)',
              hint: 'What does your squad focus on?',
              icon: Icons.description_outlined,
              maxLines: 3,
            ),

            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CyberColors.combatRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: CyberColors.combatRed.withValues(alpha: 0.5)),
                ),
                child: Text(
                  _error!,
                  style: TextStyle(color: CyberColors.combatRed, fontSize: 13),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Benefits list
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CyberColors.spaceBlack,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'As Squad Leader you can:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: CyberColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _BenefitItem(text: 'Recruit up to 10 soldiers'),
                  _BenefitItem(text: 'Create and assign tasks'),
                  _BenefitItem(text: 'Promote squad members'),
                  _BenefitItem(text: 'Claim bounty rewards'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Create button
            ElevatedButton(
              onPressed: _isLoading ? null : _createSquad,
              style: ElevatedButton.styleFrom(
                backgroundColor: CyberColors.tacticalGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'CREATE SQUAD',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final String text;

  const _BenefitItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check, size: 16, color: CyberColors.tacticalGreen),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: 13, color: CyberColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: CyberColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: CyberColors.spaceBlack,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: CyberColors.borderSubtle),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(color: CyberColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: CyberColors.textMuted),
              prefixIcon: Icon(icon, color: CyberColors.textMuted, size: 20),
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

/// Card displaying a squad in the list
class _SquadCard extends StatelessWidget {
  final Unit squad;
  final bool canApply;
  final VoidCallback onApply;

  const _SquadCard({
    required this.squad,
    required this.canApply,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final isFull = squad.memberCount >= squad.maxSize;

    return CyberCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Squad icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: CyberColors.electricCyan.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.shield_outlined,
                color: CyberColors.electricCyan,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Squad info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    squad.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: CyberColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 14,
                        color: CyberColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${squad.memberCount}/${squad.maxSize} members',
                        style: TextStyle(
                          fontSize: 13,
                          color: CyberColors.textMuted,
                        ),
                      ),
                      if (isFull) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: CyberColors.combatRed.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'FULL',
                            style: TextStyle(
                              fontSize: 10,
                              color: CyberColors.combatRed,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Apply button
            if (canApply && !isFull)
              ElevatedButton(
                onPressed: onApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CyberColors.electricCyan,
                  foregroundColor: CyberColors.spaceBlack,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'APPLY',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Dialog for submitting a squad application
class _SquadApplicationDialog extends StatefulWidget {
  final Unit squad;
  final String walletAddress;
  final VoidCallback onSubmitted;

  const _SquadApplicationDialog({
    required this.squad,
    required this.walletAddress,
    required this.onSubmitted,
  });

  @override
  State<_SquadApplicationDialog> createState() => _SquadApplicationDialogState();
}

class _SquadApplicationDialogState extends State<_SquadApplicationDialog> {
  final _messageController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final army = ArmyService();
      await army.applyToSquad(
        squadId: widget.squad.id,
        message: _messageController.text.trim(),
      );
      widget.onSubmitted();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: CyberColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.person_add, color: CyberColors.electricCyan),
                const SizedBox(width: 12),
                Text(
                  'Apply to ${widget.squad.name}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: CyberColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text(
              'Why do you want to join this squad?',
              style: TextStyle(
                fontSize: 14,
                color: CyberColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: CyberColors.spaceBlack,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: CyberColors.borderSubtle),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: 4,
                style: TextStyle(color: CyberColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Tell them about your skills and experience...',
                  hintStyle: TextStyle(color: CyberColors.textMuted),
                  contentPadding: const EdgeInsets.all(16),
                  border: InputBorder.none,
                ),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: CyberColors.combatRed, fontSize: 13),
              ),
            ],

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: CyberColors.textMuted),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitApplication,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CyberColors.electricCyan,
                      foregroundColor: CyberColors.spaceBlack,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('SUBMIT'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
