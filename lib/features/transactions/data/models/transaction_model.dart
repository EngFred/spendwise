import 'package:drift/drift.dart';
import '../../../../database/app_database.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionModel {
  TransactionModel._();

  static TransactionEntity fromDrift(Transaction t) => TransactionEntity(
    id: t.id,
    amount: t.amount,
    type: t.type,
    note: t.note,
    date: t.date,
    accountId: t.accountId,
    categoryId: t.categoryId,
    isRecurring: t.isRecurring,
    recurringInterval: t.recurringInterval,
    createdAt: t.createdAt,
  );

  static TransactionsCompanion toInsertCompanion(TransactionEntity e) =>
      TransactionsCompanion.insert(
        amount: e.amount,
        type: e.type,
        accountId: e.accountId,
        categoryId: e.categoryId,
        date: e.date,
        note: Value(e.note),
        isRecurring: Value(e.isRecurring),
        recurringInterval: Value(e.recurringInterval),
      );

  static TransactionsCompanion toUpdateCompanion(TransactionEntity e) =>
      TransactionsCompanion(
        id: Value(e.id!),
        amount: Value(e.amount),
        type: Value(e.type),
        note: Value(e.note),
        date: Value(e.date),
        accountId: Value(e.accountId),
        categoryId: Value(e.categoryId),
        isRecurring: Value(e.isRecurring),
        recurringInterval: Value(e.recurringInterval),
        createdAt: Value(e.createdAt),
      );
}
