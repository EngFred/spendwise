class BudgetEntity {
  final int? id;
  final int categoryId;
  final double amount;
  final String period; // 'monthly' | 'weekly'
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime createdAt;

  const BudgetEntity({
    this.id,
    required this.categoryId,
    required this.amount,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.createdAt,
  });

  BudgetEntity copyWith({
    int? id,
    int? categoryId,
    double? amount,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
  }) => BudgetEntity(
    id: id ?? this.id,
    categoryId: categoryId ?? this.categoryId,
    amount: amount ?? this.amount,
    period: period ?? this.period,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );

  @override
  String toString() =>
      'BudgetEntity(id: $id, categoryId: $categoryId, amount: $amount)';
}
