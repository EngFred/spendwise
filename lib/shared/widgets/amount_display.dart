import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class AmountDisplay extends StatelessWidget {
  final double amount;
  final bool isIncome;
  final double fontSize;
  final bool showSign;

  const AmountDisplay({
    super.key,
    required this.amount,
    this.isIncome = true,
    this.fontSize = 14,
    this.showSign = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = isIncome ? AppColors.income : AppColors.expense;
    final sign = showSign ? (isIncome ? '+ ' : '- ') : '';

    return Text(
      '$sign${AppStrings.currencySymbol}${NumberFormat('#,###').format(amount)}',
      style: GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );
  }
}
