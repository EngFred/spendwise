import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../categories/providers/categories_provider.dart';
import '../domain/entities/budget_entity.dart';
import '../providers/budgets_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class EditBudgetScreen extends ConsumerStatefulWidget {
  final BudgetEntity budget;

  const EditBudgetScreen({super.key, required this.budget});

  @override
  ConsumerState<EditBudgetScreen> createState() => _EditBudgetScreenState();
}

class _EditBudgetScreenState extends ConsumerState<EditBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;

  late int _selectedCategoryId;
  late String _selectedPeriod;
  bool _isLoading = false;

  final List<Map<String, String>> _periods = [
    {'value': 'monthly', 'label': 'Monthly'},
    {'value': 'weekly', 'label': 'Weekly'},
  ];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.budget.amount.toStringAsFixed(0),
    );
    _selectedCategoryId = widget.budget.categoryId;
    _selectedPeriod = widget.budget.period;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final updated = widget.budget.copyWith(
        categoryId: _selectedCategoryId,
        amount:
            double.tryParse(_amountController.text.replaceAll(',', '')) ??
            widget.budget.amount,
        period: _selectedPeriod,
      );

      await ref.read(budgetsNotifierProvider.notifier).updateBudget(updated);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Budget updated!', style: GoogleFonts.poppins()),
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
              'Failed to update budget',
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
    final categoriesAsync = ref.watch(expenseCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Budget',
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
              Text(
                'Category',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              categoriesAsync.when(
                data: (categories) => Wrap(
                  spacing: AppSizes.sm,
                  runSpacing: AppSizes.sm,
                  children: categories.map((cat) {
                    final isSelected = _selectedCategoryId == cat.id;
                    final color = _hexToColor(cat.color);
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedCategoryId = cat.id!),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.md,
                          vertical: AppSizes.sm,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? color : color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusCircle,
                          ),
                        ),
                        child: Text(
                          cat.name,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : color,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => const SizedBox.shrink(),
              ),

              const SizedBox(height: AppSizes.lg),

              AppTextField(
                label: 'Budget Amount',
                controller: _amountController,
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
                  if (v == null || v.isEmpty) return 'Enter amount';
                  if (double.tryParse(v) == null) return 'Invalid amount';
                  if (double.parse(v) <= 0) return 'Amount must be > 0';
                  return null;
                },
              ),

              const SizedBox(height: AppSizes.lg),

              Text(
                'Period',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              Row(
                children: _periods.map((p) {
                  final isSelected = _selectedPeriod == p['value'];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedPeriod = p['value']!),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(
                          right: p['value'] == 'monthly' ? AppSizes.sm : 0,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSizes.md,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMd,
                          ),
                        ),
                        child: Text(
                          p['label']!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppColors.primary,
                          ),
                        ),
                      ),
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

  Color _hexToColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primary;
    }
  }
}
