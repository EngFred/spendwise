import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';

class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 70, endIndent: AppSizes.md);
  }
}
