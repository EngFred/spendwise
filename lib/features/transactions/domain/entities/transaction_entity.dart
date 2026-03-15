class TransactionEntity {
  final int? id;
  final double amount;
  final String type; // 'income' | 'expense'
  final String? note;
  final DateTime date;
  final int accountId;
  final int categoryId;
  final bool isRecurring;
  final String? recurringInterval; // 'daily' | 'weekly' | 'monthly'
  final DateTime createdAt;

  const TransactionEntity({
    this.id,
    required this.amount,
    required this.type,
    this.note,
    required this.date,
    required this.accountId,
    required this.categoryId,
    required this.isRecurring,
    this.recurringInterval,
    required this.createdAt,
  });

  TransactionEntity copyWith({
    int? id,
    double? amount,
    String? type,
    String? note,
    DateTime? date,
    int? accountId,
    int? categoryId,
    bool? isRecurring,
    String? recurringInterval,
    DateTime? createdAt,
  }) => TransactionEntity(
    id: id ?? this.id,
    amount: amount ?? this.amount,
    type: type ?? this.type,
    note: note ?? this.note,
    date: date ?? this.date,
    accountId: accountId ?? this.accountId,
    categoryId: categoryId ?? this.categoryId,
    isRecurring: isRecurring ?? this.isRecurring,
    recurringInterval: recurringInterval ?? this.recurringInterval,
    createdAt: createdAt ?? this.createdAt,
  );

  @override
  String toString() =>
      'TransactionEntity(id: $id, amount: $amount, type: $type)';
}
