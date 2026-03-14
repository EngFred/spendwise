import 'package:intl/intl.dart';
import '../constants/app_strings.dart';

extension DoubleExtensions on double {
  String toUGX() =>
      '${AppStrings.currencySymbol}${NumberFormat('#,###').format(this)}';

  String toFormattedCurrency([String symbol = AppStrings.currencySymbol]) =>
      '$symbol${NumberFormat('#,###').format(this)}';

  bool get isPositive => this > 0;
}
