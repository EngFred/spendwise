import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class AddCategorySheet extends ConsumerStatefulWidget {
  final String preselectedType;
  final Future<void> Function(
    String name,
    String icon,
    String color,
    String type,
  )
  onSave;

  const AddCategorySheet({
    super.key,
    required this.preselectedType,
    required this.onSave,
  });

  @override
  ConsumerState<AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends ConsumerState<AddCategorySheet> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late String _selectedType;
  String _selectedColor = '#6C63FF';
  bool _isLoading = false;

  final List<String> _colors = [
    '#6C63FF',
    '#FF6B6B',
    '#4ECDC4',
    '#45B7D1',
    '#96CEB4',
    '#FFD93D',
    '#6BCB77',
    '#C77DFF',
    '#FF9A3C',
    '#4D96FF',
    '#FF6584',
    '#03DAC6',
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.preselectedType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppSizes.md,
        right: AppSizes.md,
        top: AppSizes.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.lg,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              'New Category',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // Type toggle
            Row(
              children: ['expense', 'income'].map((type) {
                final isSelected = _selectedType == type;
                final color = type == 'expense'
                    ? AppColors.expense
                    : AppColors.income;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedType = type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(
                        right: type == 'expense' ? AppSizes.sm : 0,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSizes.sm,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? color : color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      child: Text(
                        type[0].toUpperCase() + type.substring(1),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : color,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: AppSizes.lg),

            AppTextField(
              label: 'Category Name',
              hint: 'e.g. Gym, Petrol, Side Income',
              controller: _nameController,
              prefixIcon: const Icon(Icons.label_outline),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter category name' : null,
            ),

            const SizedBox(height: AppSizes.lg),

            Text(
              'Color',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Wrap(
              spacing: AppSizes.sm,
              runSpacing: AppSizes.sm,
              children: _colors.map((hex) {
                final color = Color(int.parse(hex.replaceFirst('#', '0xFF')));
                final isSelected = _selectedColor == hex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = hex),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: AppSizes.lg),

            AppButton(
              label: 'Save Category',
              isLoading: _isLoading,
              onPressed: _isLoading
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) return;
                      setState(() => _isLoading = true);
                      await widget.onSave(
                        _nameController.text.trim(),
                        'category',
                        _selectedColor,
                        _selectedType,
                      );
                      if (mounted) Navigator.pop(context);
                    },
            ),
          ],
        ),
      ),
    );
  }
}
