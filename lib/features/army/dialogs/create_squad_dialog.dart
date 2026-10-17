import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/cyber_colors.dart';
import '../../../app/theme/cyber_text_styles.dart';
import '../../../core/providers/army_provider.dart';

/// Dialog for creating a new squad (for unit splitting)
class CreateSquadDialog extends ConsumerStatefulWidget {
  final String? parentUnitId;

  const CreateSquadDialog({super.key, this.parentUnitId});

  @override
  ConsumerState<CreateSquadDialog> createState() => _CreateSquadDialogState();
}

class _CreateSquadDialogState extends ConsumerState<CreateSquadDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createSquad() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = ref.read(armyServiceProvider);
      await service.createSquad(
        name: _nameController.text.trim(),
        parentUnitId: widget.parentUnitId ?? 'section_1',
      );

      // Refresh units
      ref.invalidate(unitsProvider);
      ref.invalidate(armyGraphProvider);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Squad created successfully')),
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
        side: const BorderSide(color: CyberColors.ncoSilver),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Text('\u25c6', style: TextStyle(fontSize: 24, color: CyberColors.enlistedBronze)),
                  const SizedBox(width: 12),
                  Text('Create New Squad', style: CyberTextStyles.headlineSmall),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Create a new squad under your section',
                style: CyberTextStyles.bodySmall,
              ),
              const SizedBox(height: 24),

              // Squad name
              TextFormField(
                controller: _nameController,
                style: CyberTextStyles.bodyMedium.copyWith(
                  color: CyberColors.textPrimary,
                ),
                decoration: InputDecoration(
                  labelText: 'Squad Name',
                  labelStyle: CyberTextStyles.labelMedium,
                  hintText: 'e.g., Bravo Squad',
                  hintStyle: CyberTextStyles.bodySmall.copyWith(
                    color: CyberColors.textMuted,
                  ),
                  filled: true,
                  fillColor: CyberColors.darkPanel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: CyberColors.borderSubtle),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: CyberColors.borderSubtle),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: CyberColors.electricCyan),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Squad name is required';
                  }
                  if (value.length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Info card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CyberColors.electricCyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: CyberColors.electricCyan.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: CyberColors.electricCyan, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You will be assigned as the Squad Leader (SGT)',
                        style: CyberTextStyles.bodySmall.copyWith(
                          color: CyberColors.electricCyan,
                        ),
                      ),
                    ),
                  ],
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
                      onPressed: _isLoading ? null : _createSquad,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        backgroundColor: CyberColors.ncoSilver,
                        foregroundColor: CyberColors.spaceBlack,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create Squad'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
