import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../database/app_database.dart';
import '../../../../shared/widgets/empty_state.dart';
import 'category_tile.dart';

class CategoriesList extends StatelessWidget {
  final List<Category> categories;
  final String type;
  final VoidCallback onAdd;
  final void Function(Category) onDelete;

  const CategoriesList({
    super.key,
    required this.categories,
    required this.type,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return EmptyState(
        icon: Icons.category_outlined,
        title: 'No $type categories',
        subtitle: 'Add a custom category to organise your transactions',
        actionLabel: 'Add Category',
        onAction: onAdd,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSizes.md),
      itemCount: categories.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
      itemBuilder: (context, i) => CategoryTile(
        category: categories[i],
        onDelete: () => onDelete(categories[i]),
      ),
    );
  }
}
