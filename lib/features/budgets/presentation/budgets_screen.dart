import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../categories/domain/entities/category_entity.dart';
import '../../categories/providers/categories_provider.dart';
import '../../transactions/providers/transactions_provider.dart';
import '../domain/entities/budget_entity.dart';
import '../providers/budgets_provider.dart';
import '../../../../shared/widgets/empty_state.dart';
import 'widgets/budget_card.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetsStreamProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final transactionsAsync = ref.watch(transactionsByMonthProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Budgets',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/budgets/add'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/budgets/add'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: budgetsAsync.when(
        data: (budgets) {
          if (budgets.isEmpty) {
            return EmptyState(
              icon: Icons.pie_chart_outline,
              title: AppStrings.noBudgets,
              subtitle: 'Set spending limits per category to stay on track',
              actionLabel: 'Create Budget',
              onAction: () => context.push('/budgets/add'),
            );
          }

          return categoriesAsync.when(
            // ✅ categories is now List<CategoryEntity>
            data: (categories) => transactionsAsync.when(
              // ✅ transactions is now List<TransactionEntity>
              data: (transactions) {
                final spentByCategory = <int, double>{};
                for (final t in transactions) {
                  if (t.type == 'expense') {
                    spentByCategory[t.categoryId] =
                        (spentByCategory[t.categoryId] ?? 0) + t.amount;
                  }
                }

                final totalBudgeted = budgets.fold(
                  0.0,
                  (sum, b) => sum + b.amount,
                );
                final totalSpent = budgets.fold(0.0, (sum, b) {
                  return sum + (spentByCategory[b.categoryId] ?? 0);
                });
                final overallProgress = totalBudgeted > 0
                    ? totalSpent / totalBudgeted
                    : 0.0;

                return SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: AppSizes.xxl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _OverallBudgetCard(
                        totalBudgeted: totalBudgeted,
                        totalSpent: totalSpent,
                        progress: overallProgress.clamp(0.0, 1.0),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.md,
                        ),
                        child: Text(
                          'Category Budgets',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.md,
                        ),
                        itemCount: budgets.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSizes.sm),
                        itemBuilder: (context, i) {
                          final budget = budgets[i];
                          final CategoryEntity? category = categories
                              .where((c) => c.id == budget.categoryId)
                              .firstOrNull;
                          final spent =
                              spentByCategory[budget.categoryId] ?? 0.0;

                          return BudgetCard(
                            budget: budget,
                            category: category,
                            spent: spent,
                            onDelete: () =>
                                _confirmDelete(context, ref, budget),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    BudgetEntity budget,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Delete Budget',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete this budget?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(budgetsNotifierProvider.notifier)
                  .deleteBudget(budget.id!);
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: AppColors.expense),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Overall Budget Card (no type changes needed) ──────────────────────────────

class _OverallBudgetCard extends StatelessWidget {
  final double totalBudgeted;
  final double totalSpent;
  final double progress;

  const _OverallBudgetCard({
    required this.totalBudgeted,
    required this.totalSpent,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = totalBudgeted - totalSpent;
    final isOverBudget = remaining < 0;

    return Container(
      margin: const EdgeInsets.all(AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Budget Overview',
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'UGX ${NumberFormat('#,###').format(totalSpent)}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'of UGX ${NumberFormat('#,###').format(totalBudgeted)}',
                    style: GoogleFonts.poppins(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.sm,
                ),
                decoration: BoxDecoration(
                  color: isOverBudget
                      ? AppColors.expense.withOpacity(0.3)
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
                ),
                child: Text(
                  isOverBudget
                      ? 'Over by UGX ${NumberFormat('#,###').format(remaining.abs())}'
                      : 'UGX ${NumberFormat('#,###').format(remaining)} left',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.9
                    ? AppColors.expense
                    : progress > 0.7
                    ? AppColors.warning
                    : Colors.white,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% used',
            style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
