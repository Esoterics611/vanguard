import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/cyber_colors.dart';
import '../../../app/theme/cyber_text_styles.dart';
import '../../../core/models/army/army_models.dart';
import '../../../core/providers/army_provider.dart';

/// Dialog for applying to join a squad
class ApplySquadDialog extends ConsumerStatefulWidget {
  final Unit squad;

  const ApplySquadDialog({super.key, required this.squad});

  @override
  ConsumerState<ApplySquadDialog> createState() => _ApplySquadDialogState();
}

class _ApplySquadDialogState extends ConsumerState<ApplySquadDialog> {
  bool _isLoading = false;
  String? _error;

  Future<void> _apply() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = ref.read(armyServiceProvider);
      await service.applyToSquad(squadId: widget.squad.id);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application submitted successfully')),
        );
      }
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
                Text(
                  widget.squad.type.icon,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Apply to Join', style: CyberTextStyles.headlineSmall),
                      Text(
                        widget.squad.name,
                        style: CyberTextStyles.bodyMedium.copyWith(
                          color: CyberColors.electricCyan,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Squad info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CyberColors.darkPanel,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Current Members', style: CyberTextStyles.labelSmall),
                      Text(
                        '${widget.squad.memberCount}/${widget.squad.maxSize}',
                        style: CyberTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Active Objectives', style: CyberTextStyles.labelSmall),
                      Text(
                        '${widget.squad.objectiveIds.length}',
                        style: CyberTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Your application will be reviewed by the squad leader. You will be notified when a decision is made.',
              style: CyberTextStyles.bodySmall.copyWith(
                color: CyberColors.textMuted,
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: CyberTextStyles.bodySmall.copyWith(
                  color: CyberColors.combatRed,
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      side: const BorderSide(color: CyberColors.textMuted),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _apply,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Apply'),
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
