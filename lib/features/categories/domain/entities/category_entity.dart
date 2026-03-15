class CategoryEntity {
  final int? id;
  final String name;
  final String icon;
  final String color;
  final String type; // 'income' | 'expense'
  final bool isDefault;

  const CategoryEntity({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    required this.isDefault,
  });

  CategoryEntity copyWith({
    int? id,
    String? name,
    String? icon,
    String? color,
    String? type,
    bool? isDefault,
  }) => CategoryEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    type: type ?? this.type,
    isDefault: isDefault ?? this.isDefault,
  );

  @override
  String toString() => 'CategoryEntity(id: $id, name: $name, type: $type)';
}
