import 'package:drift/drift.dart';
import '../../../../database/app_database.dart';
import '../../domain/entities/budget_entity.dart';

class BudgetModel {
  BudgetModel._();

  static BudgetEntity fromDrift(Budget budget) => BudgetEntity(
    id: budget.id,
    categoryId: budget.categoryId,
    amount: budget.amount,
    period: budget.period,
    startDate: budget.startDate,
    endDate: budget.endDate,
    isActive: budget.isActive,
    createdAt: budget.createdAt,
  );

  static BudgetsCompanion toInsertCompanion(BudgetEntity entity) =>
      BudgetsCompanion.insert(
        categoryId: entity.categoryId,
        amount: entity.amount,
        period: entity.period,
        startDate: entity.startDate,
        endDate: entity.endDate,
        isActive: Value(entity.isActive),
      );

  static BudgetsCompanion toUpdateCompanion(BudgetEntity entity) =>
      BudgetsCompanion(
        id: Value(entity.id!),
        categoryId: Value(entity.categoryId),
        amount: Value(entity.amount),
        period: Value(entity.period),
        startDate: Value(entity.startDate),
        endDate: Value(entity.endDate),
        isActive: Value(entity.isActive),
        createdAt: Value(entity.createdAt),
      );
}
