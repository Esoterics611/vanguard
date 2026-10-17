import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/cyber_colors.dart';
import '../../../app/theme/cyber_text_styles.dart';
import '../../../core/providers/army_provider.dart';

/// Dialog for recruiting a new soldier to the squad
class RecruitDialog extends ConsumerStatefulWidget {
  const RecruitDialog({super.key});

  @override
  ConsumerState<RecruitDialog> createState() => _RecruitDialogState();
}

class _RecruitDialogState extends ConsumerState<RecruitDialog> {
  final _linkController = TextEditingController();
  String? _inviteLink;

  @override
  void initState() {
    super.initState();
    _generateInviteLink();
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  void _generateInviteLink() {
    // Generate a unique invite link
    final soldierAsync = ref.read(currentSoldierProvider);
    soldierAsync.whenData((soldier) {
      if (soldier != null) {
        setState(() {
          _inviteLink = 'https://vanguard.army/join/${soldier.squadId}?ref=${soldier.id.substring(0, 8)}';
        });
      }
    });
  }

  void _copyLink() {
    if (_inviteLink != null) {
      Clipboard.setData(ClipboardData(text: _inviteLink!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invite link copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final unitAsync = ref.watch(myUnitProvider);

    return Dialog(
      backgroundColor: CyberColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: CyberColors.electricCyan),
      ),
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
                Text('Recruit Soldier', style: CyberTextStyles.headlineSmall),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Share this link to invite soldiers to your squad',
              style: CyberTextStyles.bodySmall,
            ),
            const SizedBox(height: 24),

            // Squad info
            unitAsync.when(
              data: (unit) {
                if (unit == null) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CyberColors.darkPanel,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(unit.type.icon, style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(unit.name, style: CyberTextStyles.bodyLarge),
                            Text(
                              '${unit.memberCount}/${unit.maxSize} members',
                              style: CyberTextStyles.labelSmall,
                            ),
                          ],
                        ),
                      ),
                      if (unit.memberCount < unit.maxSize)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: CyberColors.tacticalGreen.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${unit.maxSize - unit.memberCount} slots',
                            style: CyberTextStyles.labelSmall.copyWith(
                              color: CyberColors.tacticalGreen,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: CyberColors.combatRed.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Full',
                            style: CyberTextStyles.labelSmall.copyWith(
                              color: CyberColors.combatRed,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 24),

            // Invite link
            Text('Invite Link', style: CyberTextStyles.labelMedium),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CyberColors.darkPanel,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: CyberColors.borderSubtle),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      _inviteLink ?? 'Generating...',
                      style: CyberTextStyles.bodySmall.copyWith(
                        fontFamily: 'monospace',
                        color: CyberColors.electricCyan,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: CyberColors.electricCyan),
                    onPressed: _copyLink,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // QR Code placeholder
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: CyberColors.darkPanel,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: CyberColors.borderSubtle),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_2, size: 64, color: CyberColors.textMuted),
                    const SizedBox(height: 8),
                    Text(
                      'QR Code',
                      style: CyberTextStyles.labelSmall.copyWith(
                        color: CyberColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Close button
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
