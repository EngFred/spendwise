import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/app_database.dart';

/// All feature repositories live in their own feature providers files:
/// - accounts  → features/accounts/accounts_providers.dart
/// - categories → features/categories/categories_providers.dart
/// - transactions → features/transactions/transactions_providers.dart
/// - budgets   → features/budgets/budgets_providers.dart
/// - goals     → features/goals/goals_providers.dart

// Database
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
