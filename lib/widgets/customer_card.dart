import 'package:flutter/material.dart';

import '../models/customer.dart';
import '../theme/app_theme.dart';
import 'status_badge.dart';

class CustomerCard extends StatelessWidget {
  const CustomerCard({
    super.key,
    required this.customer,
    required this.onEdit,
    required this.onViewMap,
  });

  final Customer customer;
  final VoidCallback onEdit;
  final VoidCallback onViewMap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  customer.nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headlineSm.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              StatusBadge(status: customer.status),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Text(
                'ID:',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  customer.idpel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.codeData.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${customer.tarif} / ${customer.daya} VA',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.place_outlined,
                  size: 16,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    customer.alamat,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Text(
                'No. Seri Meter:',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  customer.nomorMeter,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.codeData.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onEdit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.onSecondary,
                  ),
                  icon: const Icon(Icons.assignment_outlined, size: 18),
                  label: const Text('Buka Form Inspeksi'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: 48,
                height: 48,
                child: IconButton(
                  tooltip: 'Lihat peta',
                  onPressed: onViewMap,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.onSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  icon: const Icon(Icons.location_on_outlined, size: 22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
