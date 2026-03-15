import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:spendwise/features/accounts/domain/entities/account_entity.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';

class BalanceCard extends StatefulWidget {
  final List<AccountEntity> accounts;
  const BalanceCard({super.key, required this.accounts});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _balanceVisible = true;

  @override
  Widget build(BuildContext context) {
    final totalBalance = widget.accounts.fold(0.0, (sum, a) => sum + a.balance);

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Balance',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              IconButton(
                onPressed: () =>
                    setState(() => _balanceVisible = !_balanceVisible),
                icon: Icon(
                  _balanceVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.white70,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            _balanceVisible
                ? '${AppStrings.currencySymbol}${NumberFormat('#,###').format(totalBalance)}'
                : '••••••••',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          // Account chips
          if (widget.accounts.isNotEmpty)
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.accounts.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSizes.sm),
                itemBuilder: (context, i) {
                  final account = widget.accounts[i];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusCircle,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          account.name,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: AppSizes.xs),
                        Text(
                          _balanceVisible
                              ? '${AppStrings.currencySymbol}${NumberFormat('#,###').format(account.balance)}'
                              : '•••',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          else
            Text(
              'No accounts yet — add one!',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
            ),
        ],
      ),
    );
  }
}
