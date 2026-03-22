import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../accounts/domain/entities/account_entity.dart';
import '../../accounts/providers/accounts_provider.dart';
import '../providers/transactions_provider.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  AccountEntity? _fromAccount;
  AccountEntity? _toAccount;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
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

  // Validates that the source account has sufficient balance.
  // Cash and mobile money: hard block.
  // Bank and savings: soft warning dialog.
  Future<bool> _passesBalanceCheck(double amount) async {
    final account = _fromAccount!;
    if (amount <= account.balance) return true;

    final formattedBalance =
        'UGX ${NumberFormat('#,###').format(account.balance)}';
    final formattedAmount = 'UGX ${NumberFormat('#,###').format(amount)}';
    final isHardBlock =
        account.type == 'cash' || account.type == 'mobile_money';

    if (isHardBlock) {
      _showError(
        'Insufficient balance. ${account.name} has $formattedBalance '
        'but you are trying to transfer $formattedAmount.',
      );
      return false;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Low balance warning',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          '${account.name} only has $formattedBalance, but you are '
          'transferring $formattedAmount. This will put the account in '
          'negative balance. Continue anyway?',
          style: GoogleFonts.poppins(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
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

    if (_fromAccount == null || _toAccount == null) {
      _showError('Please select both accounts');
      return;
    }

    if (_fromAccount!.id == _toAccount!.id) {
      _showError('Source and destination accounts must be different');
      return;
    }

    final amount = double.parse(_amountController.text.replaceAll(',', ''));
    final canProceed = await _passesBalanceCheck(amount);
    if (!canProceed) return;

    setState(() => _isLoading = true);

    try {
      await ref
          .read(transactionsNotifierProvider.notifier)
          .createTransfer(
            fromAccount: _fromAccount!,
            toAccount: _toAccount!,
            amount: amount,
            date: _selectedDate,
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
          );

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transfer complete!', style: GoogleFonts.poppins()),
            backgroundColor: AppColors.income,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
          ),
        );
      }
    } catch (e) {
      _showError('Transfer failed. Please try again.');
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transfer',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close),
        ),
      ),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (accounts) {
          if (accounts.length < 2) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 64,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: AppSizes.md),
                    Text(
                      'You need at least two accounts to make a transfer.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── From / To account selectors ───────────────────────
                  Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkCard
                          : AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkDivider
                            : AppColors.lightDivider,
                      ),
                    ),
                    child: Column(
                      children: [
                        // From
                        _AccountDropdown(
                          label: 'From',
                          icon: Icons.arrow_upward_rounded,
                          iconColor: AppColors.expense,
                          accounts: accounts,
                          selected: _fromAccount,
                          excluded: _toAccount,
                          onSelected: (a) => setState(() => _fromAccount = a),
                        ),

                        // Swap button
                        Center(
                          child: InkWell(
                            onTap: () => setState(() {
                              final temp = _fromAccount;
                              _fromAccount = _toAccount;
                              _toAccount = temp;
                            }),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: AppSizes.sm,
                              ),
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.swap_vert_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                          ),
                        ),

                        // To
                        _AccountDropdown(
                          label: 'To',
                          icon: Icons.arrow_downward_rounded,
                          iconColor: AppColors.income,
                          accounts: accounts,
                          selected: _toAccount,
                          excluded: _fromAccount,
                          onSelected: (a) => setState(() => _toAccount = a),
                        ),
                      ],
                    ),
                  ),

                  // Balance hint for source account
                  if (_fromAccount != null) ...[
                    const SizedBox(height: AppSizes.xs),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'Available in ${_fromAccount!.name}: '
                        'UGX ${NumberFormat('#,###').format(_fromAccount!.balance)}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: _fromAccount!.balance <= 0
                              ? AppColors.expense
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSizes.lg),

                  // ── Amount ────────────────────────────────────────────
                  AppTextField(
                    label: 'Amount',
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
                      if (v == null || v.isEmpty) return 'Enter amount';
                      if (double.tryParse(v) == null) {
                        return 'Invalid amount';
                      }
                      if (double.parse(v) <= 0) return 'Amount must be > 0';
                      return null;
                    },
                  ),

                  const SizedBox(height: AppSizes.lg),

                  // ── Date ──────────────────────────────────────────────
                  _SectionLabel(label: 'Date'),
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
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
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
                            DateFormat('EEEE, MMMM d, y').format(_selectedDate),
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.lg),

                  // ── Note ──────────────────────────────────────────────
                  _SectionLabel(label: 'Note (optional)'),
                  const SizedBox(height: AppSizes.sm),
                  AppTextField(
                    label: 'Add a note',
                    controller: _noteController,
                    maxLines: 2,
                    prefixIcon: const Icon(Icons.notes_outlined),
                  ),

                  const SizedBox(height: AppSizes.xl),

                  AppButton(
                    label: 'Transfer',
                    onPressed: _submit,
                    isLoading: _isLoading,
                  ),

                  const SizedBox(height: AppSizes.lg),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Account dropdown ──────────────────────────────────────────────────────────

class _AccountDropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final List<AccountEntity> accounts;
  final AccountEntity? selected;
  final AccountEntity? excluded;
  final void Function(AccountEntity) onSelected;

  const _AccountDropdown({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.accounts,
    required this.selected,
    required this.excluded,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Filter out the excluded account (the other side of the transfer).
    final available = accounts.where((a) => a.id != excluded?.id).toList();

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<AccountEntity>(
              isExpanded: true,
              hint: Text(
                'Select $label account',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              value: selected,
              items: available.map((account) {
                return DropdownMenuItem(
                  value: account,
                  child: Text(
                    account.name,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (a) {
                if (a != null) onSelected(a);
              },
            ),
          ),
        ),
      ],
    );
  }
}

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
