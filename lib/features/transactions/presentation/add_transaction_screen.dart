import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:spendwise/features/transactions/domain/usecases/create_transaction_usecase.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../accounts/domain/entities/account_entity.dart';
import '../../accounts/providers/accounts_provider.dart';
import '../../categories/domain/entities/category_entity.dart';
import '../../categories/providers/categories_provider.dart';
import '../providers/transactions_provider.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _type = AppStrings.expense;
  AccountEntity? _selectedAccount;
  CategoryEntity? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _type = _tabController.index == 0
              ? AppStrings.expense
              : AppStrings.income;
          _selectedCategory = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // ── Balance check ─────────────────────────────────────────────────────────
  //
  // Only runs for expense transactions.
  //
  // Cash / Mobile Money → hard block. You cannot physically spend money
  // you don't have from these accounts.
  //
  // Bank / Savings → soft warning. Some banks allow overdraft, and the user
  // may have forgotten to log an income transaction. We warn but let them
  // decide.
  //
  // Returns true if the transaction should proceed, false if it was blocked
  // or the user cancelled.
  Future<bool> _passesBalanceCheck(double amount) async {
    if (_type != AppStrings.expense) return true;

    final account = _selectedAccount!;
    if (amount <= account.balance) return true;

    final formattedBalance =
        'UGX ${NumberFormat('#,###').format(account.balance)}';
    final formattedAmount = 'UGX ${NumberFormat('#,###').format(amount)}';

    final isHardBlock =
        account.type == 'cash' || account.type == 'mobile_money';

    if (isHardBlock) {
      // Hard block — just show an error snackbar, no way to proceed.
      _showError(
        'Insufficient balance. ${account.name} has $formattedBalance '
        'but this expense is $formattedAmount.',
      );
      return false;
    }

    // Soft warning for bank / savings — ask the user to confirm.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Low balance warning',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          '${account.name} only has $formattedBalance, but this expense '
          'is $formattedAmount. This will put the account in negative balance. '
          'Continue anyway?',
          style: GoogleFonts.poppins(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: Text(
              'Proceed',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccount == null) {
      _showError('Please select an account');
      return;
    }
    if (_selectedCategory == null) {
      _showError('Please select a category');
      return;
    }

    final amount = double.parse(_amountController.text.replaceAll(',', ''));

    // Run the balance check before doing anything else.
    final canProceed = await _passesBalanceCheck(amount);
    if (!canProceed) return;

    setState(() => _isLoading = true);

    try {
      await ref
          .read(transactionsNotifierProvider.notifier)
          .createTransaction(
            CreateTransactionParams(
              amount: amount,
              type: _type,
              accountId: _selectedAccount!.id!,
              categoryId: _selectedCategory!.id!,
              date: _selectedDate,
              note: _noteController.text.trim().isEmpty
                  ? null
                  : _noteController.text.trim(),
            ),
          );

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction added!', style: GoogleFonts.poppins()),
            backgroundColor: AppColors.income,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
          ),
        );
      }
    } catch (e) {
      _showError('Failed to save transaction');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: AppColors.expense,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsStreamProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Transaction',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(AppSizes.md),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightBackground,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: _type == AppStrings.expense
                      ? AppColors.expense
                      : AppColors.income,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.6),
                labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                unselectedLabelStyle: GoogleFonts.poppins(),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Expense'),
                  Tab(text: 'Income'),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionLabel(label: 'Amount'),
                    const SizedBox(height: AppSizes.sm),
                    AppTextField(
                      label: 'Enter amount',
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
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
                        if (v == null || v.isEmpty) return 'Enter an amount';
                        if (double.tryParse(v) == null) {
                          return 'Invalid amount';
                        }
                        if (double.parse(v) <= 0) return 'Amount must be > 0';
                        return null;
                      },
                    ),

                    // Balance hint — shown when an account is selected and
                    // this is an expense, so the user knows what they have
                    // available before they even tap Save.
                    if (_selectedAccount != null &&
                        _type == AppStrings.expense) ...[
                      const SizedBox(height: AppSizes.xs),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          'Available: UGX ${NumberFormat('#,###').format(_selectedAccount!.balance)}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: _selectedAccount!.balance <= 0
                                ? AppColors.expense
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSizes.lg),

                    const _SectionLabel(label: 'Account'),
                    const SizedBox(height: AppSizes.sm),
                    accountsAsync.when(
                      data: (accounts) => accounts.isEmpty
                          ? _EmptyAccountPrompt()
                          : _AccountSelector(
                              accounts: accounts,
                              selected: _selectedAccount,
                              onSelected: (a) =>
                                  setState(() => _selectedAccount = a),
                            ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => const SizedBox.shrink(),
                    ),

                    const SizedBox(height: AppSizes.lg),

                    const _SectionLabel(label: 'Category'),
                    const SizedBox(height: AppSizes.sm),
                    categoriesAsync.when(
                      data: (categories) {
                        final filtered = categories
                            .where((c) => c.type == _type)
                            .toList();
                        return _CategorySelector(
                          categories: filtered,
                          selected: _selectedCategory,
                          onSelected: (c) =>
                              setState(() => _selectedCategory = c),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => const SizedBox.shrink(),
                    ),

                    const SizedBox(height: AppSizes.lg),

                    const _SectionLabel(label: 'Date'),
                    const SizedBox(height: AppSizes.sm),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      child: Container(
                        padding: const EdgeInsets.all(AppSizes.md),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkCard
                              : AppColors.lightBackground,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMd,
                          ),
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
                            Text(
                              DateFormat(
                                'EEEE, MMMM d, y',
                              ).format(_selectedDate),
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSizes.lg),

                    const _SectionLabel(label: 'Note (optional)'),
                    const SizedBox(height: AppSizes.sm),
                    AppTextField(
                      label: 'Add a note',
                      controller: _noteController,
                      maxLines: 2,
                      prefixIcon: const Icon(Icons.notes_outlined),
                    ),

                    const SizedBox(height: AppSizes.xl),

                    AppButton(
                      label: 'Save Transaction',
                      onPressed: _submit,
                      isLoading: _isLoading,
                      type: AppButtonType.primary,
                    ),

                    const SizedBox(height: AppSizes.lg),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      ),
    );
  }
}

class _AccountSelector extends StatelessWidget {
  final List<AccountEntity> accounts;
  final AccountEntity? selected;
  final void Function(AccountEntity) onSelected;

  const _AccountSelector({
    required this.accounts,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: accounts.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSizes.sm),
        itemBuilder: (context, i) {
          final account = accounts[i];
          final isSelected = selected?.id == account.id;
          return ChoiceChip(
            label: Text(
              account.name,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : null,
              ),
            ),
            selected: isSelected,
            selectedColor: AppColors.primary,
            onSelected: (_) => onSelected(account),
            avatar: Icon(
              Icons.account_balance_wallet_outlined,
              size: 16,
              color: isSelected ? Colors.white : AppColors.primary,
            ),
          );
        },
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  final List<CategoryEntity> categories;
  final CategoryEntity? selected;
  final void Function(CategoryEntity) onSelected;

  const _CategorySelector({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.sm,
      runSpacing: AppSizes.sm,
      children: categories.map((cat) {
        final isSelected = selected?.id == cat.id;
        final color = _hexToColor(cat.color);
        return GestureDetector(
          onTap: () => onSelected(cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected ? color : color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
              border: Border.all(
                color: isSelected ? color : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  size: 8,
                  color: isSelected ? Colors.white : color,
                ),
                const SizedBox(width: AppSizes.xs),
                Text(
                  cat.name,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : color,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
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

class _EmptyAccountPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              'No accounts yet. Please add an account first.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
