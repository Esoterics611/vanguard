import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/cyber_colors.dart';
import '../../core/services/army_service.dart';
import '../../core/models/army/army_models.dart';
import '../army/widgets/cyber_card.dart';

/// Multi-step wizard for creating a bounty with objectives and tasks
/// Flow: Bounty Details -> Add Objectives -> Add Tasks -> Review & Create
class CreateBountyFlow extends ConsumerStatefulWidget {
  const CreateBountyFlow({super.key});

  @override
  ConsumerState<CreateBountyFlow> createState() => _CreateBountyFlowState();
}

class _CreateBountyFlowState extends ConsumerState<CreateBountyFlow> {
  int _currentStep = 0;
  bool _isCreating = false;

  // Bounty details
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rewardController = TextEditingController(text: '10000');
  int _deadlineDays = 30;
  List<String> _selectedTags = [];

  // Objectives
  final List<_ObjectiveData> _objectives = [];

  // Created IDs for navigation
  String? _createdBountyId;

  final _availableTags = [
    'Solidity',
    'Flutter',
    'Backend',
    'Frontend',
    'Security',
    'Documentation',
    'Testing',
    'DevOps',
    'Design',
    'Research',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _rewardController.dispose();
    super.dispose();
  }

  int get _totalReward => int.tryParse(_rewardController.text) ?? 0;
  int get _allocatedReward =>
      _objectives.fold(0, (sum, obj) => sum + obj.allocatedVgrd);
  int get _remainingReward => _totalReward - _allocatedReward;

  bool get _canProceedFromStep0 =>
      _titleController.text.trim().isNotEmpty && _totalReward > 0;

  bool get _canProceedFromStep1 => _objectives.isNotEmpty;

  bool get _canProceedFromStep2 =>
      _objectives.every((obj) => obj.tasks.isNotEmpty);

  Future<void> _createBounty() async {
    setState(() => _isCreating = true);

    try {
      final army = ArmyService();

      // 1. Create the bounty
      final bountyId = await army.createBounty(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        totalAmount: _totalReward,
        deadlineDays: _deadlineDays,
        skillTags: _selectedTags,
      );

      // 2. Create objectives
      for (final objData in _objectives) {
        final objectiveId = await army.createObjective(
          title: objData.title,
          description: objData.description,
          bountyId: bountyId,
          unitId: '', // Will be assigned when claimed
          allocatedVgrd: objData.allocatedVgrd,
          deadlineDays: _deadlineDays,
        );

        // 3. Create tasks for each objective
        for (final taskData in objData.tasks) {
          await army.createTask(
            title: taskData.title,
            description: taskData.description,
            objectiveId: objectiveId,
            rewardVgrd: taskData.rewardVgrd,
            priority: taskData.priority,
            deadlineDays: _deadlineDays,
            assigneeId: taskData.assignToSelf ? army.currentUserId : null,
          );
        }
      }

      _createdBountyId = bountyId;

      if (mounted) {
        // Show success and close
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Bounty created successfully!'),
            backgroundColor: CyberColors.tacticalGreen,
          ),
        );
        Navigator.of(context).pop(bountyId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: CyberColors.combatRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.spaceBlack,
      appBar: AppBar(
        backgroundColor: CyberColors.deepSpace,
        title: Text(
          'CREATE BOUNTY',
          style: TextStyle(
            color: CyberColors.textPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildCurrentStep(),
            ),
          ),

          // Bottom actions
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      color: CyberColors.deepSpace,
      child: Row(
        children: [
          _StepIndicator(
            number: 1,
            label: 'Details',
            isActive: _currentStep == 0,
            isCompleted: _currentStep > 0,
          ),
          _StepConnector(isActive: _currentStep > 0),
          _StepIndicator(
            number: 2,
            label: 'Objectives',
            isActive: _currentStep == 1,
            isCompleted: _currentStep > 1,
          ),
          _StepConnector(isActive: _currentStep > 1),
          _StepIndicator(
            number: 3,
            label: 'Tasks',
            isActive: _currentStep == 2,
            isCompleted: _currentStep > 2,
          ),
          _StepConnector(isActive: _currentStep > 2),
          _StepIndicator(
            number: 4,
            label: 'Review',
            isActive: _currentStep == 3,
            isCompleted: false,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep0Details();
      case 1:
        return _buildStep1Objectives();
      case 2:
        return _buildStep2Tasks();
      case 3:
        return _buildStep3Review();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep0Details() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bounty Details',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: CyberColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Define what needs to be accomplished',
          style: TextStyle(
            fontSize: 14,
            color: CyberColors.textMuted,
          ),
        ),
        const SizedBox(height: 24),

        // Title
        _FormField(
          label: 'Title',
          child: TextField(
            controller: _titleController,
            onChanged: (_) => setState(() {}),
            style: TextStyle(color: CyberColors.textPrimary),
            decoration: _inputDecoration('e.g., Build Token Staking Dashboard'),
          ),
        ),
        const SizedBox(height: 20),

        // Description
        _FormField(
          label: 'Description',
          child: TextField(
            controller: _descriptionController,
            maxLines: 4,
            style: TextStyle(color: CyberColors.textPrimary),
            decoration: _inputDecoration('Describe the bounty in detail...'),
          ),
        ),
        const SizedBox(height: 20),

        // Total Reward
        _FormField(
          label: 'Total Reward (VGRD)',
          child: TextField(
            controller: _rewardController,
            onChanged: (_) => setState(() {}),
            keyboardType: TextInputType.number,
            style: TextStyle(
              color: CyberColors.militaryAmber,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            decoration: _inputDecoration('').copyWith(
              prefixIcon: Icon(Icons.token, color: CyberColors.militaryAmber),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Deadline
        _FormField(
          label: 'Deadline',
          child: Container(
            decoration: BoxDecoration(
              color: CyberColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: CyberColors.borderSubtle),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _deadlineDays,
                isExpanded: true,
                dropdownColor: CyberColors.cardBackground,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                style: TextStyle(color: CyberColors.textPrimary),
                items: [7, 14, 30, 60, 90]
                    .map((days) => DropdownMenuItem(
                          value: days,
                          child: Text('$days days'),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _deadlineDays = value);
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Skill Tags
        _FormField(
          label: 'Skill Tags',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableTags.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return FilterChip(
                label: Text(tag),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTags.add(tag);
                    } else {
                      _selectedTags.remove(tag);
                    }
                  });
                },
                selectedColor: CyberColors.electricCyan.withValues(alpha: 0.3),
                checkmarkColor: CyberColors.electricCyan,
                backgroundColor: CyberColors.cardBackground,
                labelStyle: TextStyle(
                  color: isSelected
                      ? CyberColors.electricCyan
                      : CyberColors.textMuted,
                ),
                side: BorderSide(
                  color: isSelected
                      ? CyberColors.electricCyan
                      : CyberColors.borderSubtle,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStep1Objectives() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Objectives',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: CyberColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Break the bounty into unit objectives',
                  style: TextStyle(
                    fontSize: 14,
                    color: CyberColors.textMuted,
                  ),
                ),
              ],
            ),
            _AllocationBadge(
              allocated: _allocatedReward,
              total: _totalReward,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Objectives list
        if (_objectives.isEmpty)
          _EmptyState(
            icon: Icons.flag_outlined,
            message: 'No objectives yet',
            actionLabel: 'Add Objective',
            onAction: _showAddObjectiveDialog,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _objectives.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final obj = _objectives[index];
              return _ObjectiveCard(
                objective: obj,
                index: index,
                onEdit: () => _showEditObjectiveDialog(index),
                onDelete: () => _deleteObjective(index),
              );
            },
          ),

        const SizedBox(height: 20),

        // Add button
        OutlinedButton.icon(
          onPressed: _remainingReward > 0 ? _showAddObjectiveDialog : null,
          icon: const Icon(Icons.add),
          label: const Text('ADD OBJECTIVE'),
          style: OutlinedButton.styleFrom(
            foregroundColor: CyberColors.electricCyan,
            side: BorderSide(color: CyberColors.electricCyan),
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size(double.infinity, 0),
          ),
        ),

        if (_remainingReward < 0) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CyberColors.combatRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: CyberColors.combatRed.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: CyberColors.combatRed, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Over-allocated by ${(-_remainingReward).toString()} VGRD',
                  style:
                      TextStyle(color: CyberColors.combatRed, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStep2Tasks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tasks',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: CyberColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Break objectives into individual tasks',
          style: TextStyle(
            fontSize: 14,
            color: CyberColors.textMuted,
          ),
        ),
        const SizedBox(height: 24),

        // Objectives with tasks
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _objectives.length,
          separatorBuilder: (_, __) => const SizedBox(height: 24),
          itemBuilder: (context, objIndex) {
            final obj = _objectives[objIndex];
            return _ObjectiveTasksSection(
              objective: obj,
              objectiveIndex: objIndex,
              onAddTask: () => _showAddTaskDialog(objIndex),
              onEditTask: (taskIndex) =>
                  _showEditTaskDialog(objIndex, taskIndex),
              onDeleteTask: (taskIndex) =>
                  _deleteTask(objIndex, taskIndex),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStep3Review() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review & Create',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: CyberColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Verify everything looks correct',
          style: TextStyle(
            fontSize: 14,
            color: CyberColors.textMuted,
          ),
        ),
        const SizedBox(height: 24),

        // Bounty summary card
        GlowingCard(
          glowColor: CyberColors.militaryAmber,
          padding: const EdgeInsets.all(20),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.flag, color: CyberColors.militaryAmber),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _titleController.text,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: CyberColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_descriptionController.text.isNotEmpty) ...[
                  Text(
                    _descriptionController.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: CyberColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    _SummaryChip(
                      icon: Icons.token,
                      label: '$_totalReward VGRD',
                      color: CyberColors.militaryAmber,
                    ),
                    const SizedBox(width: 12),
                    _SummaryChip(
                      icon: Icons.calendar_today,
                      label: '$_deadlineDays days',
                      color: CyberColors.textMuted,
                    ),
                    const SizedBox(width: 12),
                    _SummaryChip(
                      icon: Icons.flag_outlined,
                      label: '${_objectives.length} objectives',
                      color: CyberColors.electricCyan,
                    ),
                  ],
                ),
                if (_selectedTags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _selectedTags
                        .map((tag) => Chip(
                              label: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: CyberColors.textSecondary,
                                ),
                              ),
                              backgroundColor: CyberColors.spaceBlack,
                              padding: EdgeInsets.zero,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
        ),
        const SizedBox(height: 20),

        // Objectives breakdown
        Text(
          'OBJECTIVES',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: CyberColors.textMuted,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _objectives.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final obj = _objectives[index];
            final totalTaskReward =
                obj.tasks.fold(0, (sum, t) => sum + t.rewardVgrd);
            return CyberCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: CyberColors.electricCyan.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: CyberColors.electricCyan,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            obj.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: CyberColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          '${obj.allocatedVgrd} VGRD',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: CyberColors.militaryAmber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...obj.tasks.map((task) => Padding(
                          padding: const EdgeInsets.only(left: 36, bottom: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_box_outline_blank,
                                size: 16,
                                color: CyberColors.textMuted,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  task.title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: CyberColors.textSecondary,
                                  ),
                                ),
                              ),
                              _PriorityBadge(priority: task.priority),
                              const SizedBox(width: 8),
                              Text(
                                '${task.rewardVgrd}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: CyberColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        )),
                    if (totalTaskReward != obj.allocatedVgrd)
                      Padding(
                        padding: const EdgeInsets.only(left: 36, top: 4),
                        child: Text(
                          'Task rewards: $totalTaskReward / ${obj.allocatedVgrd} VGRD',
                          style: TextStyle(
                            fontSize: 11,
                            color: totalTaskReward > obj.allocatedVgrd
                                ? CyberColors.combatRed
                                : CyberColors.militaryAmber,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CyberColors.deepSpace,
        border: Border(
          top: BorderSide(color: CyberColors.borderSubtle),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _currentStep--),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CyberColors.textMuted,
                    side: BorderSide(color: CyberColors.borderSubtle),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('BACK'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _getNextAction(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentStep == 3
                      ? CyberColors.tacticalGreen
                      : CyberColors.electricCyan,
                  foregroundColor:
                      _currentStep == 3 ? Colors.white : CyberColors.spaceBlack,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  disabledBackgroundColor:
                      CyberColors.textMuted.withValues(alpha: 0.3),
                ),
                child: _isCreating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _currentStep == 3 ? 'CREATE BOUNTY' : 'NEXT',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  VoidCallback? _getNextAction() {
    if (_isCreating) return null;

    switch (_currentStep) {
      case 0:
        return _canProceedFromStep0
            ? () => setState(() => _currentStep++)
            : null;
      case 1:
        return _canProceedFromStep1
            ? () => setState(() => _currentStep++)
            : null;
      case 2:
        return _canProceedFromStep2
            ? () => setState(() => _currentStep++)
            : null;
      case 3:
        return _createBounty;
      default:
        return null;
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: CyberColors.textMuted),
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: CyberColors.borderSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: CyberColors.borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: CyberColors.electricCyan),
      ),
      filled: true,
      fillColor: CyberColors.cardBackground,
    );
  }

  void _showAddObjectiveDialog() {
    showDialog(
      context: context,
      builder: (context) => _ObjectiveDialog(
        maxAllocation: _remainingReward,
        onSave: (obj) {
          setState(() => _objectives.add(obj));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showEditObjectiveDialog(int index) {
    final obj = _objectives[index];
    showDialog(
      context: context,
      builder: (context) => _ObjectiveDialog(
        existing: obj,
        maxAllocation: _remainingReward + obj.allocatedVgrd,
        onSave: (updated) {
          setState(() => _objectives[index] = updated);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _deleteObjective(int index) {
    setState(() => _objectives.removeAt(index));
  }

  void _showAddTaskDialog(int objectiveIndex) {
    showDialog(
      context: context,
      builder: (context) => _TaskDialog(
        onSave: (task) {
          setState(() => _objectives[objectiveIndex].tasks.add(task));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showEditTaskDialog(int objectiveIndex, int taskIndex) {
    final task = _objectives[objectiveIndex].tasks[taskIndex];
    showDialog(
      context: context,
      builder: (context) => _TaskDialog(
        existing: task,
        onSave: (updated) {
          setState(() => _objectives[objectiveIndex].tasks[taskIndex] = updated);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _deleteTask(int objectiveIndex, int taskIndex) {
    setState(() => _objectives[objectiveIndex].tasks.removeAt(taskIndex));
  }
}

// ============ DATA CLASSES ============

class _ObjectiveData {
  String title;
  String description;
  int allocatedVgrd;
  List<_TaskData> tasks;

  _ObjectiveData({
    required this.title,
    this.description = '',
    required this.allocatedVgrd,
    List<_TaskData>? tasks,
  }) : tasks = tasks ?? [];
}

class _TaskData {
  String title;
  String description;
  int rewardVgrd;
  TaskPriority priority;
  bool assignToSelf;

  _TaskData({
    required this.title,
    this.description = '',
    required this.rewardVgrd,
    this.priority = TaskPriority.medium,
    this.assignToSelf = false,
  });
}

// ============ HELPER WIDGETS ============

class _StepIndicator extends StatelessWidget {
  final int number;
  final String label;
  final bool isActive;
  final bool isCompleted;

  const _StepIndicator({
    required this.number,
    required this.label,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCompleted
        ? CyberColors.tacticalGreen
        : isActive
            ? CyberColors.electricCyan
            : CyberColors.textMuted;

    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isCompleted || isActive ? color.withValues(alpha: 0.2) : null,
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check, size: 16, color: color)
                : Text(
                    '$number',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _StepConnector extends StatelessWidget {
  final bool isActive;

  const _StepConnector({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: isActive ? CyberColors.tacticalGreen : CyberColors.borderSubtle,
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final Widget child;

  const _FormField({required this.label, required this.child});

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
        child,
      ],
    );
  }
}

class _AllocationBadge extends StatelessWidget {
  final int allocated;
  final int total;

  const _AllocationBadge({required this.allocated, required this.total});

  @override
  Widget build(BuildContext context) {
    final remaining = total - allocated;
    final isOver = remaining < 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isOver
            ? CyberColors.combatRed.withValues(alpha: 0.2)
            : CyberColors.militaryAmber.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOver
              ? CyberColors.combatRed.withValues(alpha: 0.5)
              : CyberColors.militaryAmber.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Text(
            '${remaining.abs()}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isOver ? CyberColors.combatRed : CyberColors.militaryAmber,
            ),
          ),
          Text(
            isOver ? 'OVER' : 'remaining',
            style: TextStyle(
              fontSize: 10,
              color: isOver ? CyberColors.combatRed : CyberColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(icon, size: 48, color: CyberColors.textMuted),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: CyberColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add),
            label: Text(actionLabel),
            style: ElevatedButton.styleFrom(
              backgroundColor: CyberColors.electricCyan,
              foregroundColor: CyberColors.spaceBlack,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _ObjectiveCard extends StatelessWidget {
  final _ObjectiveData objective;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ObjectiveCard({
    required this.objective,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return CyberCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: CyberColors.electricCyan.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: CyberColors.electricCyan,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    objective.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: CyberColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${objective.allocatedVgrd} VGRD • ${objective.tasks.length} tasks',
                    style: TextStyle(
                      fontSize: 12,
                      color: CyberColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, size: 18, color: CyberColors.textMuted),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete, size: 18, color: CyberColors.combatRed),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _ObjectiveTasksSection extends StatelessWidget {
  final _ObjectiveData objective;
  final int objectiveIndex;
  final VoidCallback onAddTask;
  final Function(int) onEditTask;
  final Function(int) onDeleteTask;

  const _ObjectiveTasksSection({
    required this.objective,
    required this.objectiveIndex,
    required this.onAddTask,
    required this.onEditTask,
    required this.onDeleteTask,
  });

  @override
  Widget build(BuildContext context) {
    return CyberCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag, size: 18, color: CyberColors.electricCyan),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    objective.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: CyberColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '${objective.allocatedVgrd} VGRD',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: CyberColors.militaryAmber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (objective.tasks.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'No tasks yet',
                    style: TextStyle(
                      fontSize: 13,
                      color: CyberColors.textMuted,
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: objective.tasks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, taskIndex) {
                  final task = objective.tasks[taskIndex];
                  return _TaskCard(
                    task: task,
                    onEdit: () => onEditTask(taskIndex),
                    onDelete: () => onDeleteTask(taskIndex),
                  );
                },
              ),

            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onAddTask,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Task'),
              style: OutlinedButton.styleFrom(
                foregroundColor: CyberColors.textMuted,
                side: BorderSide(color: CyberColors.borderSubtle),
                padding: const EdgeInsets.symmetric(vertical: 10),
                minimumSize: const Size(double.infinity, 0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final _TaskData task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.task,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CyberColors.spaceBlack,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CyberColors.borderSubtle),
      ),
      child: Row(
        children: [
          _PriorityBadge(priority: task.priority),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 14,
                    color: CyberColors.textPrimary,
                  ),
                ),
                if (task.assignToSelf)
                  Text(
                    'Assigned to you',
                    style: TextStyle(
                      fontSize: 11,
                      color: CyberColors.electricCyan,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '${task.rewardVgrd}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: CyberColors.militaryAmber,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.edit, size: 16, color: CyberColors.textMuted),
            onPressed: onEdit,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.close, size: 16, color: CyberColors.combatRed),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final TaskPriority priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Color _getColor() {
    switch (priority) {
      case TaskPriority.low:
        return CyberColors.textMuted;
      case TaskPriority.medium:
        return CyberColors.militaryAmber;
      case TaskPriority.high:
        return CyberColors.combatRed;
      case TaskPriority.critical:
        return CyberColors.combatRed;
    }
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color),
        ),
      ],
    );
  }
}

// ============ DIALOGS ============

class _ObjectiveDialog extends StatefulWidget {
  final _ObjectiveData? existing;
  final int maxAllocation;
  final Function(_ObjectiveData) onSave;

  const _ObjectiveDialog({
    this.existing,
    required this.maxAllocation,
    required this.onSave,
  });

  @override
  State<_ObjectiveDialog> createState() => _ObjectiveDialogState();
}

class _ObjectiveDialogState extends State<_ObjectiveDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _allocationController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existing?.title ?? '');
    _descController =
        TextEditingController(text: widget.existing?.description ?? '');
    _allocationController = TextEditingController(
      text: widget.existing?.allocatedVgrd.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _allocationController.dispose();
    super.dispose();
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
            Text(
              widget.existing == null ? 'Add Objective' : 'Edit Objective',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CyberColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _titleController,
              style: TextStyle(color: CyberColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: CyberColors.textMuted),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: CyberColors.borderSubtle),
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _descController,
              maxLines: 2,
              style: TextStyle(color: CyberColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                labelStyle: TextStyle(color: CyberColors.textMuted),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: CyberColors.borderSubtle),
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _allocationController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: CyberColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'VGRD Allocation',
                labelStyle: TextStyle(color: CyberColors.textMuted),
                helperText: 'Max: ${widget.maxAllocation}',
                helperStyle: TextStyle(color: CyberColors.textMuted),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: CyberColors.borderSubtle),
                ),
              ),
            ),

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
                    onPressed: () {
                      final title = _titleController.text.trim();
                      final allocation =
                          int.tryParse(_allocationController.text) ?? 0;

                      if (title.isEmpty || allocation <= 0) return;

                      widget.onSave(_ObjectiveData(
                        title: title,
                        description: _descController.text.trim(),
                        allocatedVgrd: allocation,
                        tasks: widget.existing?.tasks ?? [],
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CyberColors.electricCyan,
                      foregroundColor: CyberColors.spaceBlack,
                    ),
                    child: const Text('Save'),
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

class _TaskDialog extends StatefulWidget {
  final _TaskData? existing;
  final Function(_TaskData) onSave;

  const _TaskDialog({this.existing, required this.onSave});

  @override
  State<_TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<_TaskDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _rewardController;
  late TaskPriority _priority;
  late bool _assignToSelf;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existing?.title ?? '');
    _descController =
        TextEditingController(text: widget.existing?.description ?? '');
    _rewardController = TextEditingController(
      text: widget.existing?.rewardVgrd.toString() ?? '100',
    );
    _priority = widget.existing?.priority ?? TaskPriority.medium;
    _assignToSelf = widget.existing?.assignToSelf ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _rewardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: CyberColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existing == null ? 'Add Task' : 'Edit Task',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CyberColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _titleController,
              style: TextStyle(color: CyberColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: CyberColors.textMuted),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: CyberColors.borderSubtle),
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _descController,
              maxLines: 2,
              style: TextStyle(color: CyberColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                labelStyle: TextStyle(color: CyberColors.textMuted),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: CyberColors.borderSubtle),
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _rewardController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: CyberColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Reward (VGRD)',
                labelStyle: TextStyle(color: CyberColors.textMuted),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: CyberColors.borderSubtle),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Priority
            Text(
              'Priority',
              style: TextStyle(
                fontSize: 13,
                color: CyberColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<TaskPriority>(
              segments: TaskPriority.values.map((p) {
                return ButtonSegment(
                  value: p,
                  label: Text(p.name.toUpperCase()),
                );
              }).toList(),
              selected: {_priority},
              onSelectionChanged: (selected) {
                setState(() => _priority = selected.first);
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return CyberColors.electricCyan.withValues(alpha: 0.2);
                  }
                  return CyberColors.spaceBlack;
                }),
              ),
            ),
            const SizedBox(height: 16),

            // Assign to self
            CheckboxListTile(
              value: _assignToSelf,
              onChanged: (v) => setState(() => _assignToSelf = v ?? false),
              title: Text(
                'Assign to myself',
                style: TextStyle(
                  fontSize: 14,
                  color: CyberColors.textPrimary,
                ),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: CyberColors.electricCyan,
            ),

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
                    onPressed: () {
                      final title = _titleController.text.trim();
                      final reward =
                          int.tryParse(_rewardController.text) ?? 0;

                      if (title.isEmpty) return;

                      widget.onSave(_TaskData(
                        title: title,
                        description: _descController.text.trim(),
                        rewardVgrd: reward,
                        priority: _priority,
                        assignToSelf: _assignToSelf,
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CyberColors.electricCyan,
                      foregroundColor: CyberColors.spaceBlack,
                    ),
                    child: const Text('Save'),
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
