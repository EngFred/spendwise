import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:spendwise/features/categories/domain/entities/category_entity.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../providers/reports_provider.dart';

class CategoryBreakdownChart extends StatefulWidget {
  final MonthlySummary summary;
  final List<CategoryEntity> categories;

  const CategoryBreakdownChart({
    super.key,
    required this.summary,
    required this.categories,
  });

  @override
  State<CategoryBreakdownChart> createState() => _CategoryBreakdownChartState();
}

class _CategoryBreakdownChartState extends State<CategoryBreakdownChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final data = widget.summary.expenseByCategory;

    if (data.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: Center(
          child: Text(
            'No expense data this month',
            style: GoogleFonts.poppins(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ),
      );
    }

    final total = data.values.fold(0.0, (sum, v) => sum + v);
    final colors = AppColors.categoryColors;
    final entries = data.entries.toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.md),
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
          Text(
            'Expense Breakdown',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              // Pie chart
              SizedBox(
                height: 160,
                width: 160,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        setState(() {
                          _touchedIndex =
                              response?.touchedSection?.touchedSectionIndex ??
                              -1;
                        });
                      },
                    ),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: List.generate(entries.length, (i) {
                      final isTouched = i == _touchedIndex;
                      final color = colors[i % colors.length];
                      final percentage = (entries[i].value / total * 100);
                      return PieChartSectionData(
                        color: color,
                        value: entries[i].value,
                        title: '${percentage.toStringAsFixed(0)}%',
                        radius: isTouched ? 55 : 45,
                        titleStyle: GoogleFonts.poppins(
                          fontSize: isTouched ? 12 : 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.md),
              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    entries.length > 6 ? 6 : entries.length,
                    (i) {
                      final catId = entries[i].key;
                      final amount = entries[i].value;
                      final category = widget.categories
                          .where((c) => c.id == catId)
                          .firstOrNull;
                      final color = colors[i % colors.length];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSizes.xs),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: AppSizes.xs),
                            Expanded(
                              child: Text(
                                category?.name ?? 'Other',
                                style: GoogleFonts.poppins(fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              NumberFormat('#,###').format(amount),
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
