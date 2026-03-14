import 'package:drift/drift.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get icon => text()();
  TextColumn get color => text()(); // hex color string
  TextColumn get type => text()(); // income or expense
  BoolColumn get isDefault => boolean().withDefault(const Constant(true))();
}
