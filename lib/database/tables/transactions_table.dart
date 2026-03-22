import 'package:drift/drift.dart';
import 'accounts_table.dart';
import 'categories_table.dart';

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get type => text()(); // income or expense
  TextColumn get note => text().nullable()();
  DateTimeColumn get date => dateTime()();
  IntColumn get accountId => integer().references(Accounts, #id)();
  IntColumn get categoryId => integer().references(Categories, #id)();
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  TextColumn get recurringInterval =>
      text().nullable()(); // daily | weekly | monthly

  // Tracks the date this recurring template was last auto-processed.
  // null = never processed (will be processed on next check).
  // Only meaningful when isRecurring = true.
  DateTimeColumn get lastProcessedDate => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
