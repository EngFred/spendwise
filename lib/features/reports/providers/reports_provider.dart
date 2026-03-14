import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';

class MonthlySummary {
  final int year;
  final int month;
  final double totalIncome;
  final double totalExpense;
  final double netSavings;
  final Map<int, double> expenseByCategory;
  final Map<int, double> incomeByCategory;
  final List<double> dailyExpenses;

  const MonthlySummary({
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
    required this.netSavings,
    required this.expenseByCategory,
    required this.incomeByCategory,
    required this.dailyExpenses,
  });
}

class YearlySummary {
  final int year;
  final List<double> monthlyIncome;
  final List<double> monthlyExpense;

  const YearlySummary({
    required this.year,
    required this.monthlyIncome,
    required this.monthlyExpense,
  });
}

// Selected month for reports
class ReportsMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void setMonth(DateTime month) => state = month;
}

final reportsMonthProvider = NotifierProvider<ReportsMonthNotifier, DateTime>(
  ReportsMonthNotifier.new,
);

// Monthly summary
final monthlySummaryProvider = FutureProvider<MonthlySummary>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final selected = ref.watch(reportsMonthProvider);

  final transactions = await db.transactionsDao.getTransactionsByMonth(
    selected.year,
    selected.month,
  );

  double totalIncome = 0;
  double totalExpense = 0;
  final Map<int, double> expenseByCategory = {};
  final Map<int, double> incomeByCategory = {};

  // Days in selected month
  final daysInMonth = DateTime(selected.year, selected.month + 1, 0).day;
  final dailyExpenses = List<double>.filled(daysInMonth, 0);

  for (final t in transactions) {
    if (t.type == 'income') {
      totalIncome += t.amount;
      incomeByCategory[t.categoryId] =
          (incomeByCategory[t.categoryId] ?? 0) + t.amount;
    } else {
      totalExpense += t.amount;
      expenseByCategory[t.categoryId] =
          (expenseByCategory[t.categoryId] ?? 0) + t.amount;
      final dayIndex = t.date.day - 1;
      if (dayIndex >= 0 && dayIndex < daysInMonth) {
        dailyExpenses[dayIndex] += t.amount;
      }
    }
  }

  return MonthlySummary(
    year: selected.year,
    month: selected.month,
    totalIncome: totalIncome,
    totalExpense: totalExpense,
    netSavings: totalIncome - totalExpense,
    expenseByCategory: expenseByCategory,
    incomeByCategory: incomeByCategory,
    dailyExpenses: dailyExpenses,
  );
});

// Yearly summary
final yearlySummaryProvider = FutureProvider<YearlySummary>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final selected = ref.watch(reportsMonthProvider);

  final monthlyIncome = <double>[];
  final monthlyExpense = <double>[];

  for (int m = 1; m <= 12; m++) {
    final transactions = await db.transactionsDao.getTransactionsByMonth(
      selected.year,
      m,
    );
    double income = 0;
    double expense = 0;
    for (final t in transactions) {
      if (t.type == 'income') {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }
    monthlyIncome.add(income);
    monthlyExpense.add(expense);
  }

  return YearlySummary(
    year: selected.year,
    monthlyIncome: monthlyIncome,
    monthlyExpense: monthlyExpense,
  );
});
