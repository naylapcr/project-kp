import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class FormSectionCard extends StatelessWidget {
  const FormSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryFixed,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(icon, color: AppColors.secondary, size: 21),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.headlineSm.copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                if (badge != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  badge!,
                ],
              ],
            ),
          ),
          Divider(
            height: 1,
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var index = 0; index < children.length; index++) ...[
                  if (index > 0) const SizedBox(height: 14),
                  children[index],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RequiredFieldLabel extends StatelessWidget {
  const RequiredFieldLabel({
    super.key,
    required this.label,
    this.required = false,
    this.helper,
  });

  final String label;
  final bool required;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: label,
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              if (required)
                TextSpan(
                  text: ' *',
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.error,
                  ),
                ),
            ],
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 3),
          Text(
            helper!,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }
}

/// A read-only system value row used inside the locked customer card.
class ReadOnlyValueRow extends StatelessWidget {
  const ReadOnlyValueRow({
    super.key,
    required this.label,
    required this.value,
    this.code = false,
  });

  final String label;
  final String value;
  final bool code;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSm.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: code
              ? AppTypography.codeData.copyWith(color: AppColors.onSurface)
              : AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                  fontVariations: const [FontVariation('wght', 600)],
                ),
        ),
      ],
    );
  }
}
