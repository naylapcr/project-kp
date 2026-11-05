import 'package:flutter/material.dart';

import '../models/customer.dart';
import '../theme/app_theme.dart';

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
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 10, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    customer.nama.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  customer.idpel,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.place_outlined,
                    size: 15,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    customer.alamat,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Spacer(),
                IconButton(
                  tooltip: 'Edit inspeksi',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 20),
                  color: AppColors.toskaDark,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.toskaTint,
                    minimumSize: const Size(38, 38),
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  tooltip: 'Lihat peta',
                  onPressed: onViewMap,
                  icon: const Icon(Icons.location_on_outlined, size: 21),
                  color: AppColors.toskaDark,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.canvas,
                    minimumSize: const Size(38, 38),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
