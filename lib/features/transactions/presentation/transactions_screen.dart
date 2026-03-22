import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../domain/entities/transaction_entity.dart';
import '../providers/transactions_provider.dart';
import '../../../../shared/widgets/empty_state.dart';
import 'widgets/transaction_tile.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final transactionsAsync = ref.watch(transactionsByMonthProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transactions',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/transactions/add'),
            icon: const Icon(Icons.add),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _MonthSelector(
            selected: selectedMonth,
            onPrevious: () {
              ref
                  .read(selectedMonthProvider.notifier)
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
                ref.read(selectedMonthProvider.notifier).setMonth(next);
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/transactions/add'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: transactionsAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long_outlined,
              title: AppStrings.noTransactions,
              subtitle: 'Tap the + button to log your first transaction',
              actionLabel: 'Add Transaction',
              onAction: () => context.push('/transactions/add'),
            );
          }

          // Group by date
          final grouped = <String, List<TransactionEntity>>{};
          for (final t in transactions) {
            final key = DateFormat('yyyy-MM-dd').format(t.date);
            grouped.putIfAbsent(key, () => []).add(t);
          }

          final sortedKeys = grouped.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: AppSizes.xxl),
            itemCount: sortedKeys.length,
            itemBuilder: (context, i) {
              final key = sortedKeys[i];
              final dayTransactions = grouped[key]!;
              final date = DateTime.parse(key);
              final dayTotal = dayTransactions.fold(0.0, (sum, t) {
                return t.type == 'income' ? sum + t.amount : sum - t.amount;
              });

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.md,
                      AppSizes.md,
                      AppSizes.md,
                      AppSizes.sm,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDateHeader(date),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        Text(
                          '${dayTotal >= 0 ? '+' : ''} UGX ${NumberFormat('#,###').format(dayTotal.abs())}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: dayTotal >= 0
                                ? AppColors.income
                                : AppColors.expense,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...dayTransactions.map(
                    (t) => TransactionTile(
                      transaction: t,
                      onDelete: () => _confirmDelete(context, ref, t),
                      onEdit: () =>
                          context.push('/transactions/edit', extra: t),
                    ),
                  ),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      return 'Yesterday';
    }
    return DateFormat('EEEE, MMM d').format(date);
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    TransactionEntity t,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Delete Transaction',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete this transaction?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref
                  .read(transactionsNotifierProvider.notifier)
                  .deleteTransaction(t);
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

// ── Month selector ────────────────────────────────────────────────────────────

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
        0,
        AppSizes.md,
        AppSizes.sm,
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
