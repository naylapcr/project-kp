import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Three-tab field navigation. The third item starts a new inspection.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.onInspection,
  });

  /// Only Monitoring (0) and Peta (1) are persistent destinations.
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onInspection;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        height: 80,
        child: Row(
          children: [
            _NavItem(
              icon: Icons.contacts_outlined,
              selectedIcon: Icons.contacts,
              label: 'Monitoring',
              selected: selectedIndex == 0,
              onTap: () => onSelected(0),
            ),
            _NavItem(
              icon: Icons.map_outlined,
              selectedIcon: Icons.map,
              label: 'Peta',
              selected: selectedIndex == 1,
              onTap: () => onSelected(1),
            ),
            _NavItem(
              icon: Icons.assignment_outlined,
              selectedIcon: Icons.assignment,
              label: 'Inspeksi',
              selected: false,
              onTap: onInspection,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppColors.secondary
        : AppColors.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 56,
              height: 28,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.secondaryFixed
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                selected ? selectedIcon : icon,
                size: 21,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelSm.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
