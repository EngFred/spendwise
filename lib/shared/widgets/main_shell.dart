import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/transactions')) return 1;
    if (location.startsWith('/accounts')) return 2;
    if (location.startsWith('/budgets')) return 3;
    if (location.startsWith('/goals') || location.startsWith('/reports')) {
      return 4;
    }
    return 0;
  }

  void _handleTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
      case 1:
        context.go('/transactions');
      case 2:
        context.go('/accounts');
      case 3:
        context.go('/budgets');
      case 4:
        _showMoreSheet(context);
    }
  }

  void _showMoreSheet(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _MoreSheet(currentLocation: location),
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _locationToIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: _SpendWiseNavBar(
        currentIndex: currentIndex,
        onTap: (index) => _handleTap(context, index),
      ),
    );
  }
}

// ── Custom Nav Bar ────────────────────────────────────────────────────────────

class _SpendWiseNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _SpendWiseNavBar({required this.currentIndex, required this.onTap});

  static const _items = [
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavItem(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      label: 'Transactions',
    ),
    _NavItem(
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet_rounded,
      label: 'Accounts',
    ),
    _NavItem(
      icon: Icons.donut_large_outlined,
      activeIcon: Icons.donut_large_rounded,
      label: 'Budgets',
    ),
    _NavItem(
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
      label: 'More',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            width: 0.5,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: AppSizes.sm,
          bottom: bottomPadding > 0 ? bottomPadding : AppSizes.sm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            _items.length,
            (i) => _NavItemWidget(
              item: _items[i],
              isActive: currentIndex == i,
              onTap: () => onTap(i),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Single Nav Item ───────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _NavItemWidget extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItemWidget({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sm,
          vertical: AppSizes.xs,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? item.activeIcon : item.icon,
                key: ValueKey(isActive),
                size: 22,
                color: isActive
                    ? AppColors.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? AppColors.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── More Bottom Sheet ─────────────────────────────────────────────────────────

class _MoreSheet extends StatelessWidget {
  final String currentLocation;
  const _MoreSheet({required this.currentLocation});

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
        top: AppSizes.md,
        left: AppSizes.md,
        right: AppSizes.md,
        bottom: MediaQuery.of(context).padding.bottom + AppSizes.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
              ),
            ),
          ),

          const SizedBox(height: AppSizes.lg),

          Text(
            'More',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: AppSizes.md),

          _MoreTile(
            icon: Icons.savings_outlined,
            activeIcon: Icons.savings_rounded,
            label: 'Savings Goals',
            subtitle: 'Track your savings targets',
            isActive: currentLocation.startsWith('/goals'),
            color: const Color(0xFF6BCB77),
            onTap: () {
              Navigator.pop(context);
              context.go('/goals');
            },
          ),

          const SizedBox(height: AppSizes.sm),

          _MoreTile(
            icon: Icons.bar_chart_outlined,
            activeIcon: Icons.bar_chart_rounded,
            label: 'Reports',
            subtitle: 'Spending insights & analytics',
            isActive: currentLocation.startsWith('/reports'),
            color: const Color(0xFF45B7D1),
            onTap: () {
              Navigator.pop(context);
              context.go('/reports');
            },
          ),

          const SizedBox(height: AppSizes.md),

          Divider(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            height: 1,
          ),

          const SizedBox(height: AppSizes.md),

          _MoreTile(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings_rounded,
            label: 'Settings',
            subtitle: 'Preferences, data & security',
            isActive: false,
            color: AppColors.primary,
            onTap: () {
              Navigator.pop(context);
              context.push('/settings');
            },
          ),

          const SizedBox(height: AppSizes.sm),
        ],
      ),
    );
  }
}

// ── More Tile ─────────────────────────────────────────────────────────────────

class _MoreTile extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String subtitle;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _MoreTile({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.subtitle,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: isActive
              ? color.withOpacity(0.1)
              : isDark
              ? AppColors.darkCard
              : AppColors.lightBackground,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: isActive ? Border.all(color: color.withOpacity(0.3)) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Icon(isActive ? activeIcon : icon, color: color, size: 22),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isActive ? color : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isActive
                  ? color
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
