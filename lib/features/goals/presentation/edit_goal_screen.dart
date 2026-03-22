import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../domain/entities/goal_entity.dart';
import '../providers/goals_provider.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class EditGoalScreen extends ConsumerStatefulWidget {
  final GoalEntity goal;

  const EditGoalScreen({super.key, required this.goal});

  @override
  ConsumerState<EditGoalScreen> createState() => _EditGoalScreenState();
}

class _EditGoalScreenState extends ConsumerState<EditGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _targetController;

  late String _selectedColor;
  late String _selectedIcon;

  // Nullable — user can clear an existing deadline.
  // We track it separately so that setting to null is intentional,
  // not a copyWith fallback ambiguity.
  DateTime? _deadline;
  bool _deadlineCleared = false;

  bool _isLoading = false;

  final List<String> _icons = [
    '🎯',
    '💻',
    '✈️',
    '🏠',
    '🚗',
    '📱',
    '🎓',
    '💍',
    '🏋️',
    '📚',
    '🎮',
    '💰',
  ];

  final List<String> _colors = [
    '#6C63FF',
    '#FF6B6B',
    '#4ECDC4',
    '#45B7D1',
    '#96CEB4',
    '#FFD93D',
    '#6BCB77',
    '#C77DFF',
    '#FF9A3C',
    '#4D96FF',
    '#FF6584',
    '#03DAC6',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goal.name);
    _targetController = TextEditingController(
      text: widget.goal.targetAmount.toStringAsFixed(0),
    );
    _selectedColor = widget.goal.color;
    _selectedIcon = widget.goal.icon;
    _deadline = widget.goal.deadline;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _deadline = picked;
        _deadlineCleared = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // Build the updated entity manually rather than using copyWith so that
      // clearing the deadline (setting to null) works correctly — copyWith
      // cannot distinguish "pass null to clear" from "pass null to keep".
      final updated = GoalEntity(
        id: widget.goal.id,
        name: _nameController.text.trim(),
        icon: _selectedIcon,
        color: _selectedColor,
        targetAmount:
            double.tryParse(_targetController.text.replaceAll(',', '')) ??
            widget.goal.targetAmount,
        // savedAmount and isCompleted are not editable here — they are
        // managed by addToSavings and the completion logic in the notifier.
        savedAmount: widget.goal.savedAmount,
        isCompleted: widget.goal.isCompleted,
        deadline: _deadlineCleared ? null : _deadline,
        createdAt: widget.goal.createdAt,
      );

      await ref.read(goalsNotifierProvider.notifier).updateGoal(updated);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Goal updated!', style: GoogleFonts.poppins()),
            backgroundColor: AppColors.income,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update goal',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppColors.expense,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Goal',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Icon picker ─────────────────────────────────────────
              Text(
                'Icon',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _icons.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppSizes.sm),
                  itemBuilder: (context, i) {
                    final isSelected = _selectedIcon == _icons[i];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = _icons[i]),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : isDark
                              ? AppColors.darkCard
                              : AppColors.lightBackground,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMd,
                          ),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _icons[i],
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSizes.lg),

              // ── Name ────────────────────────────────────────────────
              AppTextField(
                label: 'Goal Name',
                hint: 'e.g. New Laptop, Trip to Mombasa',
                controller: _nameController,
                prefixIcon: const Icon(Icons.flag_outlined),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter goal name' : null,
              ),

              const SizedBox(height: AppSizes.lg),

              // ── Target amount ───────────────────────────────────────
              AppTextField(
                label: 'Target Amount',
                controller: _targetController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Text(
                    'UGX',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter target';
                  if (double.tryParse(v) == null) return 'Invalid amount';
                  if (double.parse(v) <= 0) return 'Must be greater than 0';
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.xs),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Already saved: UGX ${NumberFormat('#,###').format(widget.goal.savedAmount)} — '
                  'this is not editable here. Use "Add savings" on the goal card.',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.lg),

              // ── Deadline ────────────────────────────────────────────
              Text(
                'Deadline (optional)',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              InkWell(
                onTap: _pickDeadline,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkCard
                        : AppColors.lightBackground,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkDivider
                          : AppColors.lightDivider,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        child: Text(
                          (_deadlineCleared || _deadline == null)
                              ? 'No deadline'
                              : DateFormat(
                                  'EEEE, MMMM d, y',
                                ).format(_deadline!),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: (_deadlineCleared || _deadline == null)
                                ? Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.4)
                                : null,
                          ),
                        ),
                      ),
                      // Show clear button only when there is an active deadline
                      if (!_deadlineCleared && _deadline != null)
                        GestureDetector(
                          onTap: () => setState(() {
                            _deadline = null;
                            _deadlineCleared = true;
                          }),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.expense,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.lg),

              // ── Color ───────────────────────────────────────────────
              Text(
                'Color',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              Wrap(
                spacing: AppSizes.sm,
                runSpacing: AppSizes.sm,
                children: _colors.map((hex) {
                  final color = Color(int.parse(hex.replaceFirst('#', '0xFF')));
                  final isSelected = _selectedColor == hex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = hex),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppSizes.xl),

              AppButton(
                label: 'Save Changes',
                onPressed: _submit,
                isLoading: _isLoading,
              ),

              const SizedBox(height: AppSizes.lg),
            ],
          ),
        ),
      ),
    );
  }
}
