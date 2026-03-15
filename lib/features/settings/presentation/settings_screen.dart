import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../domain/entities/app_settings.dart';
import '../providers/settings_provider.dart';
import 'widgets/settings_card.dart';
import 'widgets/settings_divider.dart';
import 'widgets/settings_section_header.dart';
import 'widgets/settings_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value ?? const AppSettings();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsSectionHeader(title: 'Profile'),
            SettingsCard(
              children: [
                SettingsTile(
                  icon: Icons.person_outline,
                  title: 'Name',
                  subtitle: settings.userName.isEmpty
                      ? 'Tap to set your name'
                      : settings.userName,
                  onTap: () => _editName(context, ref, settings.userName),
                ),
                const SettingsDivider(),
                SettingsTile(
                  icon: Icons.currency_exchange_outlined,
                  title: 'Currency',
                  subtitle: settings.currency,
                  onTap: () => _editCurrency(context, ref),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.lg),

            const SettingsSectionHeader(title: 'Appearance'),
            SettingsCard(
              children: [
                SettingsTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  subtitle: 'Currently ${isDark ? 'on' : 'off'}',
                  trailing: Switch(
                    value: settings.isDarkMode,
                    onChanged: (v) =>
                        ref.read(settingsProvider.notifier).setDarkMode(v),
                    activeColor: AppColors.primary,
                  ),
                ),
                const SettingsDivider(),
                SettingsTile(
                  icon: Icons.category_outlined,
                  title: 'Categories',
                  subtitle: 'Manage your spending categories',
                  onTap: () => context.push('/categories'),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.lg),

            const SettingsSectionHeader(title: 'Notifications'),
            SettingsCard(
              children: [
                SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Daily Reminder',
                  subtitle: 'Remind me to log my expenses',
                  trailing: Switch(
                    value: settings.dailyReminder,
                    onChanged: (v) => _setDailyReminder(context, ref, v),
                    activeColor: AppColors.primary,
                  ),
                ),
                const SettingsDivider(),
                SettingsTile(
                  icon: Icons.warning_amber_outlined,
                  title: 'Budget Alerts',
                  subtitle: 'Notify when approaching budget limit',
                  trailing: Switch(
                    value: settings.budgetAlerts,
                    onChanged: (v) =>
                        ref.read(settingsProvider.notifier).setBudgetAlerts(v),
                    activeColor: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.lg),

            const SettingsSectionHeader(title: 'Security'),
            SettingsCard(
              children: [
                SettingsTile(
                  icon: Icons.fingerprint_outlined,
                  title: 'Biometric Lock',
                  subtitle: 'Lock app with fingerprint or face ID',
                  trailing: Switch(
                    value: settings.biometricLock,
                    onChanged: (v) =>
                        ref.read(settingsProvider.notifier).setBiometricLock(v),
                    activeColor: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.lg),

            const SettingsSectionHeader(title: 'Data'),
            SettingsCard(
              children: [
                SettingsTile(
                  icon: Icons.download_outlined,
                  title: 'Export to CSV',
                  subtitle: 'Share all transactions as a spreadsheet',
                  onTap: () => _exportCsv(context, ref),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.primary,
                  ),
                ),
                const SettingsDivider(),
                SettingsTile(
                  icon: Icons.backup_outlined,
                  title: 'Backup Data',
                  subtitle: 'Save a local backup of your data',
                  onTap: () => _showComingSoon(context, 'Backup'),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.primary,
                  ),
                ),
                const SettingsDivider(),
                SettingsTile(
                  icon: Icons.restore_outlined,
                  title: 'Restore Data',
                  subtitle: 'Restore from a local backup',
                  onTap: () => _showComingSoon(context, 'Restore'),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.lg),

            const SettingsSectionHeader(title: 'Danger Zone'),
            SettingsCard(
              children: [
                SettingsTile(
                  icon: Icons.delete_forever_outlined,
                  title: 'Clear All Data',
                  subtitle: 'Permanently delete all data',
                  iconColor: AppColors.expense,
                  titleColor: AppColors.expense,
                  onTap: () => _confirmClearData(context, ref),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.expense,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.lg),

            Center(
              child: Column(
                children: [
                  Text(
                    AppStrings.appName,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'Version 1.0.0',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                  Text(
                    'Built with ❤️ using Flutter',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.xxl),
          ],
        ),
      ),
    );
  }

  // ── Handlers ───────────────────────────────────────────────────────────────

  Future<void> _setDailyReminder(
    BuildContext context,
    WidgetRef ref,
    bool value,
  ) async {
    try {
      await ref.read(settingsProvider.notifier).setDailyReminder(value);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not schedule reminder. Please allow exact alarms in '
              'System Settings → Apps → SpendWise → Alarms & reminders.',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            backgroundColor: AppColors.expense,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
          ),
        );
      }
    }
  }

  void _editName(BuildContext context, WidgetRef ref, String current) {
    final controller = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Your Name',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: GoogleFonts.poppins(),
          ),
          style: GoogleFonts.poppins(),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(settingsProvider.notifier)
                  .setUserName(controller.text.trim());
              Navigator.pop(context);
            },
            child: Text(
              'Save',
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editCurrency(BuildContext context, WidgetRef ref) {
    final currencies = ['UGX', 'USD', 'KES', 'TZS', 'EUR', 'GBP'];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Currency',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: currencies
              .map(
                (c) => ListTile(
                  title: Text(c, style: GoogleFonts.poppins()),
                  onTap: () {
                    ref.read(settingsProvider.notifier).setCurrency(c);
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — coming soon!', style: GoogleFonts.poppins()),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
      ),
    );
  }

  void _confirmClearData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Clear All Data',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.expense,
          ),
        ),
        content: Text(
          'This will permanently delete ALL your transactions, accounts, '
          'budgets and goals. This cannot be undone!',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearAllData(context, ref);
            },
            child: Text(
              'Delete Everything',
              style: GoogleFonts.poppins(
                color: AppColors.expense,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllData(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(settingsProvider.notifier).clearAllData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'All data cleared successfully',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppColors.income,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
          ),
        );
        context.go('/dashboard');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear data', style: GoogleFonts.poppins()),
            backgroundColor: AppColors.expense,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(width: AppSizes.md),
            Text('Preparing export…', style: GoogleFonts.poppins()),
          ],
        ),
      ),
    );

    try {
      final filePath = await ref.read(settingsProvider.notifier).exportCsv();

      if (!context.mounted) return;
      Navigator.pop(context); // Dismiss loading dialog

      // Share_plus ^12.x API — ShareParams replaces shareXFiles
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath, mimeType: 'text/csv')],
          subject: 'SpendWise Transactions Export',
          text:
              'My SpendWise transactions exported on '
              '${DateFormat('MMM d, y').format(DateTime.now())}',
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Dismiss loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Export failed. Please try again.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.expense,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
        ),
      );
    }
  }
}
