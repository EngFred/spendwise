class GoalEntity {
  final int? id;
  final String name;
  final String icon;
  final String color;
  final double targetAmount;
  final double savedAmount;
  final DateTime? deadline;
  final bool isCompleted;
  final DateTime createdAt;

  const GoalEntity({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.targetAmount,
    required this.savedAmount,
    this.deadline,
    required this.isCompleted,
    required this.createdAt,
  });

  double get progressPercent =>
      targetAmount > 0 ? (savedAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  double get remaining => targetAmount - savedAmount;

  GoalEntity copyWith({
    int? id,
    String? name,
    String? icon,
    String? color,
    double? targetAmount,
    double? savedAmount,
    DateTime? deadline,
    bool? isCompleted,
    DateTime? createdAt,
  }) => GoalEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    targetAmount: targetAmount ?? this.targetAmount,
    savedAmount: savedAmount ?? this.savedAmount,
    deadline: deadline ?? this.deadline,
    isCompleted: isCompleted ?? this.isCompleted,
    createdAt: createdAt ?? this.createdAt,
  );

  @override
  String toString() =>
      'GoalEntity(id: $id, name: $name, saved: $savedAmount/$targetAmount)';
}
