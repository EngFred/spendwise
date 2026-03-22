import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../domain/entities/budget_entity.dart';

class BudgetCard extends StatelessWidget {
  final BudgetEntity budget;
  final CategoryEntity? category;
  final double spent;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const BudgetCard({
    super.key,
    required this.budget,
    required this.category,
    required this.spent,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = budget.amount > 0
        ? (spent / budget.amount).clamp(0.0, 1.0)
        : 0.0;
    final remaining = budget.amount - spent;
    final isOverBudget = remaining < 0;
    final categoryColor = _hexToColor(category?.color ?? '#6C63FF');

    Color progressColor;
    if (progress > 0.9) {
      progressColor = AppColors.expense;
    } else if (progress > 0.7) {
      progressColor = AppColors.warning;
    } else {
      progressColor = AppColors.income;
    }

    return Dismissible(
      key: Key('budget_${budget.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSizes.lg),
        decoration: BoxDecoration(
          color: AppColors.expense,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Icon(
                    Icons.category_outlined,
                    color: categoryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category?.name ?? 'Unknown Category',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        budget.period.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'UGX ${NumberFormat('#,###').format(spent)}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isOverBudget
                            ? AppColors.expense
                            : AppColors.lightText,
                      ),
                    ),
                    Text(
                      'of UGX ${NumberFormat('#,###').format(budget.amount)}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppSizes.xs),
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.35),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  tooltip: 'Edit budget',
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: progressColor.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: AppSizes.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress * 100).toStringAsFixed(0)}% used',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: progressColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  isOverBudget
                      ? 'Over by UGX ${NumberFormat('#,###').format(remaining.abs())}'
                      : 'UGX ${NumberFormat('#,###').format(remaining)} remaining',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: isOverBudget
                        ? AppColors.expense
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                    fontWeight: isOverBudget
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
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
