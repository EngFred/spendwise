import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/accounts_table.dart';
import 'tables/categories_table.dart';
import 'tables/transactions_table.dart';
import 'tables/budgets_table.dart';
import 'tables/goals_table.dart';
import 'daos/accounts_dao.dart';
import 'daos/categories_dao.dart';
import 'daos/transactions_dao.dart';
import 'daos/budgets_dao.dart';
import 'daos/goals_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Accounts, Categories, Transactions, Budgets, Goals],
  daos: [AccountsDao, CategoriesDao, TransactionsDao, BudgetsDao, GoalsDao],
)
class AppDatabase extends _$AppDatabase {
  // Normal constructor — used by the main isolate via Riverpod.
  AppDatabase() : super(_openConnection());

  // Direct-file constructor — used by the WorkManager background isolate.
  // The isolate cannot use Riverpod or LazyDatabase, so it opens the file
  // synchronously. NativeDatabase (not createInBackground) is correct here
  // because we are already in a background isolate.
  AppDatabase.fromFile(File file) : super(NativeDatabase(file));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _insertDefaultCategories();
    },
    onUpgrade: (m, from, to) async {
      // v1 → v2: add lastProcessedDate to transactions table.
      // This column tracks when a recurring template was last auto-processed.
      if (from < 2) {
        await m.addColumn(transactions, transactions.lastProcessedDate);
      }
    },
  );

  Future<void> _insertDefaultCategories() async {
    final defaults = [
      CategoriesCompanion.insert(
        name: 'Food & Drinks',
        icon: 'restaurant',
        color: '#FF6B6B',
        type: 'expense',
      ),
      CategoriesCompanion.insert(
        name: 'Transport',
        icon: 'directions_car',
        color: '#4ECDC4',
        type: 'expense',
      ),
      CategoriesCompanion.insert(
        name: 'Shopping',
        icon: 'shopping_bag',
        color: '#45B7D1',
        type: 'expense',
      ),
      CategoriesCompanion.insert(
        name: 'Entertainment',
        icon: 'movie',
        color: '#96CEB4',
        type: 'expense',
      ),
      CategoriesCompanion.insert(
        name: 'Health',
        icon: 'favorite',
        color: '#FF8B94',
        type: 'expense',
      ),
      CategoriesCompanion.insert(
        name: 'Rent & Bills',
        icon: 'home',
        color: '#A8E6CF',
        type: 'expense',
      ),
      CategoriesCompanion.insert(
        name: 'Airtime & Data',
        icon: 'phone_android',
        color: '#FFD93D',
        type: 'expense',
      ),
      CategoriesCompanion.insert(
        name: 'Education',
        icon: 'school',
        color: '#6BCB77',
        type: 'expense',
      ),
      CategoriesCompanion.insert(
        name: 'Salary',
        icon: 'work',
        color: '#4D96FF',
        type: 'income',
      ),
      CategoriesCompanion.insert(
        name: 'Freelance',
        icon: 'laptop',
        color: '#FF6B6B',
        type: 'income',
      ),
      CategoriesCompanion.insert(
        name: 'Gift',
        icon: 'card_giftcard',
        color: '#C77DFF',
        type: 'income',
      ),
      CategoriesCompanion.insert(
        name: 'Other',
        icon: 'more_horiz',
        color: '#ADB5BD',
        type: 'expense',
      ),
    ];
    for (final cat in defaults) {
      await into(categories).insert(cat);
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'spendwise.db'));
    return NativeDatabase.createInBackground(file);
  });
}

// Returns the same File used by _openConnection.
// Called from the WorkManager callback to open the same database.
Future<File> getDatabaseFile() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  return File(p.join(dbFolder.path, 'spendwise.db'));
}
