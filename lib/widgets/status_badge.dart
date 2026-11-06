import 'package:flutter/material.dart';

import '../models/customer.dart';
import '../theme/app_theme.dart';

/// Status pill for pending, completed, and follow-up customers.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
    this.uppercase = false,
    this.compact = false,
  });

  final CustomerStatus status;
  final bool uppercase;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(status);
    final baseLabel = compact ? status.shortLabel : status.label;
    final label = uppercase ? baseLabel.toUpperCase() : baseLabel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == CustomerStatus.pending)
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.tertiaryFixedDim,
                shape: BoxShape.circle,
              ),
            )
          else
            Icon(colors.icon, size: 12, color: colors.foreground),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTypography.labelSm.copyWith(color: colors.foreground),
          ),
        ],
      ),
    );
  }

  _StatusColors _colorsFor(CustomerStatus status) {
    return switch (status) {
      CustomerStatus.pending => const _StatusColors(
        background: AppColors.surfaceContainerHigh,
        foreground: AppColors.onTertiaryContainer,
        icon: Icons.schedule,
      ),
      CustomerStatus.completed => const _StatusColors(
        background: AppColors.surfaceContainer,
        foreground: AppColors.secondary,
        icon: Icons.verified_outlined,
      ),
      CustomerStatus.followUp => const _StatusColors(
        background: AppColors.errorContainer,
        foreground: AppColors.onErrorContainer,
        icon: Icons.error_outline,
      ),
    };
  }
}

class _StatusColors {
  const _StatusColors({
    required this.background,
    required this.foreground,
    required this.icon,
  });

  final Color background;
  final Color foreground;
  final IconData icon;
}
