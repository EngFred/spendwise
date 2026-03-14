import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../database/app_database.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onDelete;
  final VoidCallback? onAddSavings;

  const GoalCard({
    super.key,
    required this.goal,
    required this.onDelete,
    required this.onAddSavings,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = goal.targetAmount > 0
        ? (goal.savedAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final remaining = goal.targetAmount - goal.savedAmount;
    final color = _hexToColor(goal.color);

    return Dismissible(
      key: Key('goal_${goal.id}'),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Center(
                    child: Text(
                      goal.icon,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      if (goal.deadline != null)
                        Text(
                          'Deadline: ${DateFormat('MMM d, y').format(goal.deadline!)}',
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
                if (goal.isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.income.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusCircle,
                      ),
                    ),
                    child: Text(
                      '✓ Done',
                      style: GoogleFonts.poppins(
                        color: AppColors.income,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else if (onAddSavings != null)
                  IconButton(
                    onPressed: onAddSavings,
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: AppColors.primary,
                    ),
                    tooltip: 'Add savings',
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.md),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(
                  goal.isCompleted ? AppColors.income : color,
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: AppSizes.sm),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'UGX ${NumberFormat('#,###').format(goal.savedAmount)} saved',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  goal.isCompleted
                      ? '🎉 Goal reached!'
                      : 'UGX ${NumberFormat('#,###').format(remaining)} to go',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: goal.isCompleted
                        ? AppColors.income
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                    fontWeight: goal.isCompleted
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              'Target: UGX ${NumberFormat('#,###').format(goal.targetAmount)} • ${(progress * 100).toStringAsFixed(0)}% complete',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
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
