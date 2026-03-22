import 'package:drift/drift.dart';
import '../../database/app_database.dart';

/// Processes all due recurring transaction templates.
///
/// This function is deliberately framework-free — no Riverpod, no Flutter
/// widgets. It takes a raw [AppDatabase] instance so it can be called from:
///   • The main isolate (on app resume via AppLifecycleObserver)
///   • The WorkManager background isolate (via callbackDispatcher in main.dart)
///
/// Returns the number of new transaction instances created.
Future<int> processRecurringTransactions(AppDatabase db) async {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final templates = await db.transactionsDao.getRecurringTemplates();
  int created = 0;

  for (final template in templates) {
    if (template.recurringInterval == null) continue;

    final dueDates = _computeDueDates(template: template, today: today);
    if (dueDates.isEmpty) continue;

    for (final dueDate in dueDates) {
      // Create a non-recurring instance for this occurrence.
      // isRecurring = false so it appears as a normal transaction in the list
      // and does not get picked up by the processor again.
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          amount: template.amount,
          type: template.type,
          note: Value(_buildNote(template.note, template.recurringInterval!)),
          date: dueDate,
          accountId: template.accountId,
          categoryId: template.categoryId,
          isRecurring: const Value(false),
          recurringInterval: const Value(null),
          lastProcessedDate: const Value(null),
        ),
      );

      // Apply the balance delta on the linked account.
      final account = await db.accountsDao.getAccountById(template.accountId);
      if (account != null) {
        final newBalance = template.type == 'income'
            ? account.balance + template.amount
            : account.balance - template.amount;
        await db.accountsDao.updateBalance(template.accountId, newBalance);
      }

      created++;
    }

    // Mark the template as processed up to today so it is not re-triggered
    // until the next due date.
    await db.transactionsDao.updateLastProcessedDate(template.id, today);
  }

  return created;
}

// ── Due-date computation ──────────────────────────────────────────────────────
//
// Returns a list of dates on which the template should fire, starting from
// the day after it was last processed up to and including today.
//
// Design decisions:
//   • We backfill missed occurrences (up to a safety cap of 366 for daily,
//     53 for weekly, 24 for monthly) so a user who didn't open the app for
//     a week still gets their salary recorded correctly.
//   • The cap prevents runaway loops if lastProcessedDate is very old or null.
List<DateTime> _computeDueDates({
  required Transaction template,
  required DateTime today,
}) {
  final last = template.lastProcessedDate;
  final interval = template.recurringInterval!;

  // If never processed, use the transaction's own date as the baseline.
  // Strip time component so arithmetic is day-clean.
  DateTime baseline = last != null
      ? DateTime(last.year, last.month, last.day)
      : DateTime(
          template.date.year,
          template.date.month,
          template.date.day,
        ).subtract(
          // Subtract one period so the baseline date itself counts as due.
          _intervalDuration(interval, template.date),
        );

  final List<DateTime> due = [];
  const int cap = 366; // absolute safety ceiling per run

  while (due.length < cap) {
    final next = _nextOccurrence(baseline, interval, template.date);

    // Stop if we've gone past today.
    if (next.isAfter(today)) break;

    // Skip if this date is the same as the template's own creation date
    // (the template transaction itself already represents that occurrence).
    final templateDay = DateTime(
      template.date.year,
      template.date.month,
      template.date.day,
    );
    if (!next.isAtSameMomentAs(templateDay)) {
      due.add(next);
    }

    baseline = next;
  }

  return due;
}

DateTime _nextOccurrence(
  DateTime after,
  String interval,
  DateTime originalDate,
) {
  switch (interval) {
    case 'daily':
      return after.add(const Duration(days: 1));
    case 'weekly':
      return after.add(const Duration(days: 7));
    case 'monthly':
      // Preserve the original day-of-month (e.g. salary on the 25th).
      // If the target month is shorter (e.g. Feb), clamp to last day.
      final targetMonth = after.month == 12 ? 1 : after.month + 1;
      final targetYear = after.month == 12 ? after.year + 1 : after.year;
      final lastDayOfTarget = DateTime(targetYear, targetMonth + 1, 0).day;
      final targetDay = originalDate.day.clamp(1, lastDayOfTarget);
      return DateTime(targetYear, targetMonth, targetDay);
    default:
      // Unknown interval — return a date far in the future to skip.
      return after.add(const Duration(days: 36500));
  }
}

Duration _intervalDuration(String interval, DateTime originalDate) {
  switch (interval) {
    case 'daily':
      return const Duration(days: 1);
    case 'weekly':
      return const Duration(days: 7);
    case 'monthly':
      // Approximate: subtract enough to land in previous month.
      return const Duration(days: 31);
    default:
      return const Duration(days: 1);
  }
}

String _buildNote(String? originalNote, String interval) {
  final label = switch (interval) {
    'daily' => 'Daily',
    'weekly' => 'Weekly',
    'monthly' => 'Monthly',
    _ => 'Recurring',
  };
  if (originalNote == null || originalNote.trim().isEmpty) {
    return '[$label] Auto-generated';
  }
  return '[$label] $originalNote';
}
