import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Small pill used for section metadata such as "Terkunci Sistem".
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.icon,
    this.background = AppColors.surfaceContainer,
    this.foreground = AppColors.onSurfaceVariant,
    this.maxLines = 1,
  });

  final String label;
  final IconData? icon;
  final Color background;
  final Color foreground;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final text = Text(
            label,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelSm.copyWith(color: foreground),
          );

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 12, color: foreground),
                const SizedBox(width: 4),
              ],
              // Shrink and ellipsize only when the parent bounds the badge.
              if (constraints.hasBoundedWidth) Flexible(child: text) else text,
            ],
          );
        },
      ),
    );
  }
}
