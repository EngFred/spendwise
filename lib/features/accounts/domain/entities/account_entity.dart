/// Pure Dart entity — zero dependency on Flutter or Drift.
class AccountEntity {
  final int? id;
  final String name;
  final String type; // cash | mobile_money | bank | savings
  final double balance;
  final String currency;
  final String color; // hex e.g. '#6C63FF'
  final String icon;
  final bool isDefault;
  final DateTime createdAt;

  const AccountEntity({
    this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.currency,
    required this.color,
    required this.icon,
    required this.isDefault,
    required this.createdAt,
  });

  AccountEntity copyWith({
    int? id,
    String? name,
    String? type,
    double? balance,
    String? currency,
    String? color,
    String? icon,
    bool? isDefault,
    DateTime? createdAt,
  }) => AccountEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    balance: balance ?? this.balance,
    currency: currency ?? this.currency,
    color: color ?? this.color,
    icon: icon ?? this.icon,
    isDefault: isDefault ?? this.isDefault,
    createdAt: createdAt ?? this.createdAt,
  );

  @override
  String toString() => 'AccountEntity(id: $id, name: $name, balance: $balance)';
}
