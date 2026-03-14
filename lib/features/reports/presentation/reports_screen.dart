import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../categories/providers/categories_provider.dart';
import '../providers/reports_provider.dart';
import 'widgets/monthly_summary_card.dart';
import 'widgets/category_breakdown_chart.dart';
import 'widgets/income_expense_chart.dart';
import 'widgets/top_spending_categories.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(reportsMonthProvider);
    final monthlySummaryAsync = ref.watch(monthlySummaryProvider);
    final yearlySummaryAsync = ref.watch(yearlySummaryProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reports',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppSizes.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month selector
            _MonthSelector(
              selected: selectedMonth,
              onPrevious: () {
                ref
                    .read(reportsMonthProvider.notifier)
                    .setMonth(
                      DateTime(selectedMonth.year, selectedMonth.month - 1),
                    );
              },
              onNext: () {
                final next = DateTime(
                  selectedMonth.year,
                  selectedMonth.month + 1,
                );
                if (!next.isAfter(DateTime.now())) {
                  ref.read(reportsMonthProvider.notifier).setMonth(next);
                }
              },
            ),

            // Monthly summary card
            monthlySummaryAsync.when(
              data: (summary) => MonthlySummaryCard(summary: summary),
              loading: () => _Shimmer(height: 160),
              error: (e, _) => const SizedBox.shrink(),
            ),

            const SizedBox(height: AppSizes.lg),

            // Category breakdown pie chart
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Text(
                'Where Did Your Money Go?',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            monthlySummaryAsync.when(
              data: (summary) => categoriesAsync.when(
                data: (categories) => CategoryBreakdownChart(
                  summary: summary,
                  categories: categories,
                ),
                loading: () => _Shimmer(height: 200),
                error: (e, _) => const SizedBox.shrink(),
              ),
              loading: () => _Shimmer(height: 200),
              error: (e, _) => const SizedBox.shrink(),
            ),

            const SizedBox(height: AppSizes.lg),

            // Top spending categories
            monthlySummaryAsync.when(
              data: (summary) => categoriesAsync.when(
                data: (categories) => TopSpendingCategories(
                  summary: summary,
                  categories: categories,
                ),
                loading: () => _Shimmer(height: 200),
                error: (e, _) => const SizedBox.shrink(),
              ),
              loading: () => _Shimmer(height: 200),
              error: (e, _) => const SizedBox.shrink(),
            ),

            const SizedBox(height: AppSizes.lg),

            // Yearly income vs expense chart
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Text(
                'Yearly Overview',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            yearlySummaryAsync.when(
              data: (summary) => IncomeExpenseChart(summary: summary),
              loading: () => _Shimmer(height: 220),
              error: (e, _) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Month Selector ────────────────────────────────────────────────────────────

class _MonthSelector extends StatelessWidget {
  final DateTime selected;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MonthSelector({
    required this.selected,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentMonth =
        selected.year == DateTime.now().year &&
        selected.month == DateTime.now().month;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.sm,
        AppSizes.md,
        0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            DateFormat('MMMM yyyy').format(selected),
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          IconButton(
            onPressed: isCurrentMonth ? null : onNext,
            icon: Icon(
              Icons.chevron_right,
              color: isCurrentMonth
                  ? Theme.of(context).colorScheme.onSurface.withOpacity(0.3)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shimmer placeholder ───────────────────────────────────────────────────────

class _Shimmer extends StatelessWidget {
  final double height;
  const _Shimmer({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
    );
  }
}
