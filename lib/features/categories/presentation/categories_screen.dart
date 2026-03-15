import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spendwise/features/categories/domain/entities/category_entity.dart';
import 'package:spendwise/features/categories/domain/usecases/create_category_usecase.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../providers/categories_provider.dart';
import 'widgets/categories_list.dart';
import 'widgets/add_category_sheet.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Categories',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
          actions: [
            IconButton(
              onPressed: () => _showAddSheet(context, ref),
              icon: const Icon(Icons.add),
            ),
          ],
          bottom: TabBar(
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            unselectedLabelStyle: GoogleFonts.poppins(),
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Expense'),
              Tab(text: 'Income'),
            ],
          ),
        ),
        body: categoriesAsync.when(
          data: (categories) {
            final expense = categories
                .where((c) => c.type == 'expense')
                .toList();
            final income = categories.where((c) => c.type == 'income').toList();

            return TabBarView(
              children: [
                CategoriesList(
                  categories: expense,
                  type: 'expense',
                  onAdd: () =>
                      _showAddSheet(context, ref, preselectedType: 'expense'),
                  onDelete: (cat) => _confirmDelete(context, ref, cat),
                ),
                CategoriesList(
                  categories: income,
                  type: 'income',
                  onAdd: () =>
                      _showAddSheet(context, ref, preselectedType: 'income'),
                  onDelete: (cat) => _confirmDelete(context, ref, cat),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  void _showAddSheet(
    BuildContext context,
    WidgetRef ref, {
    String preselectedType = 'expense',
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddCategorySheet(
        preselectedType: preselectedType,
        onSave: (name, icon, color, type) async {
          await ref
              .read(categoriesNotifierProvider.notifier)
              .createCategory(
                CreateCategoryParams(
                  name: name,
                  icon: icon,
                  color: color,
                  type: type,
                ),
              );
        },
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CategoryEntity category,
  ) {
    if (category.isDefault) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Default categories cannot be deleted',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Delete Category',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Delete "${category.name}"? Transactions using this category will not be deleted.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref
                  .read(categoriesNotifierProvider.notifier)
                  .deleteCategory(category.id!);
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: AppColors.expense),
            ),
          ),
        ],
      ),
    );
  }
}
