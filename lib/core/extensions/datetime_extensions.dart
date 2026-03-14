import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String toDisplayDate() => DateFormat('MMM d, y').format(this);

  String toDisplayDateTime() => DateFormat('MMM d, y • hh:mm a').format(this);

  String toMonthYear() => DateFormat('MMMM y').format(this);

  String toShortDay() => DateFormat('E').format(this);

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  bool isSameMonth(DateTime other) =>
      year == other.year && month == other.month;
}
