import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';

class DashboardSummary {
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final Map<String, double> expenseByCategory;
  final List<double> last7DaysExpenses;

  const DashboardSummary({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.expenseByCategory,
    required this.last7DaysExpenses,
  });
}

final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final now = DateTime.now();

  // Total balance across all accounts
  final accounts = await db.accountsDao.getAllAccounts();
  final totalBalance = accounts.fold(0.0, (sum, a) => sum + a.balance);

  // This month's transactions
  final transactions = await db.transactionsDao.getTransactionsByMonth(
    now.year,
    now.month,
  );

  double totalIncome = 0;
  double totalExpense = 0;
  final Map<String, double> expenseByCategory = {};

  for (final t in transactions) {
    if (t.type == 'income') {
      totalIncome += t.amount;
    } else {
      totalExpense += t.amount;
      final key = t.categoryId.toString();
      expenseByCategory[key] = (expenseByCategory[key] ?? 0) + t.amount;
    }
  }

  // Last 7 days expenses
  final last7Days = List.generate(7, (i) {
    final day = DateTime(now.year, now.month, now.day - (6 - i));
    final dayTotal = transactions
        .where(
          (t) =>
              t.type == 'expense' &&
              t.date.year == day.year &&
              t.date.month == day.month &&
              t.date.day == day.day,
        )
        .fold(0.0, (sum, t) => sum + t.amount);
    return dayTotal;
  });

  return DashboardSummary(
    totalBalance: totalBalance,
    totalIncome: totalIncome,
    totalExpense: totalExpense,
    expenseByCategory: expenseByCategory,
    last7DaysExpenses: last7Days,
  );
});
