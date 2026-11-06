import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Dark navy app header used by all three field screens.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.leading,
    this.onRefresh,
    this.isRefreshing = false,
    this.refreshTooltip = 'Muat ulang',
    this.syncLabel = 'Sync OK',
  });

  final String title;
  final String subtitle;
  final Widget? leading;
  final VoidCallback? onRefresh;
  final bool isRefreshing;
  final String refreshTooltip;
  final String syncLabel;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Material(
      color: AppColors.primary,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.margin,
          topPadding + 10,
          12,
          12,
        ),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 4)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.headlineMd.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.secondaryContainer,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _SyncPill(label: syncLabel),
            if (onRefresh != null) ...[
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: 44,
                height: 44,
                child: IconButton(
                  tooltip: refreshTooltip,
                  onPressed: isRefreshing ? null : onRefresh,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    foregroundColor: AppColors.onPrimary,
                    disabledForegroundColor: AppColors.onPrimary.withValues(
                      alpha: 0.55,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  icon: isRefreshing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : const Icon(Icons.refresh, size: 20),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SyncPill extends StatelessWidget {
  const _SyncPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified_outlined,
            size: 13,
            color: AppColors.secondaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: AppColors.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
