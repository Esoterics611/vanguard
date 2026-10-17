import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/cyber_colors.dart';
import '../../../app/theme/cyber_text_styles.dart';
import '../../../core/providers/army_provider.dart';

/// Dialog for creating a new bounty/mission (Captains only)
class CreateBountyDialog extends ConsumerStatefulWidget {
  const CreateBountyDialog({super.key});

  @override
  ConsumerState<CreateBountyDialog> createState() => _CreateBountyDialogState();
}

class _CreateBountyDialogState extends ConsumerState<CreateBountyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _deadlineDaysController = TextEditingController(text: '14');
  final _skillTagsController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _deadlineDaysController.dispose();
    _skillTagsController.dispose();
    super.dispose();
  }

  Future<void> _createBounty() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = ref.read(armyServiceProvider);
      await service.createBounty(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        totalAmount: int.parse(_amountController.text.trim()),
        deadlineDays: int.parse(_deadlineDaysController.text.trim()),
        skillTags: _skillTagsController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
      );

      // Refresh bounties
      ref.invalidate(bountiesProvider);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bounty created successfully')),
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
        side: const BorderSide(color: CyberColors.officerGold, width: 2),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
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
                    Icon(Icons.add_task, color: CyberColors.officerGold),
                    const SizedBox(width: 12),
                    Text('Create New Bounty', style: CyberTextStyles.headlineSmall),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Fund a new mission for the Army',
                  style: CyberTextStyles.bodySmall,
                ),
                const SizedBox(height: 24),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Title
                        _buildTextField(
                          controller: _titleController,
                          label: 'Bounty Title',
                          hint: 'e.g., Smart Contract Audit',
                          validator: (v) => v == null || v.isEmpty ? 'Title required' : null,
                        ),
                        const SizedBox(height: 16),

                        // Description
                        _buildTextField(
                          controller: _descriptionController,
                          label: 'Description',
                          hint: 'Describe the deliverables and success criteria...',
                          maxLines: 4,
                          validator: (v) => v == null || v.isEmpty ? 'Description required' : null,
                        ),
                        const SizedBox(height: 16),

                        // Amount and Deadline row
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _amountController,
                                label: 'Total VGRD',
                                hint: '10000',
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Amount required';
                                  final amount = int.tryParse(v);
                                  if (amount == null || amount < 100) return 'Min 100 VGRD';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _deadlineDaysController,
                                label: 'Days to Complete',
                                hint: '14',
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Required';
                                  final days = int.tryParse(v);
                                  if (days == null || days < 1) return 'Min 1 day';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Skill Tags
                        _buildTextField(
                          controller: _skillTagsController,
                          label: 'Skill Tags (comma separated)',
                          hint: 'Solidity, Security, DeFi',
                        ),
                      ],
                    ),
                  ),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: CyberTextStyles.bodySmall.copyWith(color: CyberColors.combatRed),
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
                        onPressed: _isLoading ? null : _createBounty,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          backgroundColor: CyberColors.officerGold,
                          foregroundColor: CyberColors.spaceBlack,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Create Bounty'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: CyberTextStyles.bodyMedium.copyWith(color: CyberColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: CyberTextStyles.labelMedium,
        hintText: hint,
        hintStyle: CyberTextStyles.bodySmall.copyWith(color: CyberColors.textMuted),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: CyberColors.combatRed),
        ),
      ),
    );
  }
}
