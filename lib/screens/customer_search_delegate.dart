import 'package:flutter/material.dart';

import '../models/customer.dart';
import '../theme/app_theme.dart';

class CustomerSearchDelegate extends SearchDelegate<Customer?> {
  CustomerSearchDelegate({required this.customers, this.onViewMap})
    : super(searchFieldLabel: 'Cari nama, IDPEL, atau alamat');

  final List<Customer> customers;
  final ValueChanged<Customer>? onViewMap;

  List<Customer> _filter(String value) {
    final query = value.trim().toLowerCase();
    if (query.isEmpty) return customers;
    return customers.where((customer) {
      return customer.nama.toLowerCase().contains(query) ||
          customer.idpel.contains(query) ||
          customer.alamat.toLowerCase().contains(query) ||
          customer.nomorMeter.toLowerCase().contains(query);
    }).toList();
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.toska,
        selectionColor: AppColors.toska.withValues(alpha: 0.2),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          tooltip: 'Hapus pencarian',
          onPressed: () => query = '',
          icon: const Icon(Icons.clear),
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Kembali',
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildResults(context);

  Widget _buildResults(BuildContext context) {
    final results = _filter(query);
    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.toskaTint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search_off,
                  color: AppColors.toskaDark,
                  size: 30,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Pelanggan tidak ditemukan',
                style: TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Coba gunakan nama, IDPEL, alamat, atau nomor meter lain.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, fontSize: 12.5),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: results.length,
      separatorBuilder: (_, _) => const Divider(indent: 72, endIndent: 16),
      itemBuilder: (context, index) {
        final customer = results[index];
        return ListTile(
          contentPadding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.toskaTint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_outline,
              color: AppColors.toskaDark,
              size: 21,
            ),
          ),
          title: Text(
            customer.nama,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          subtitle: Text(
            '${customer.idpel}\n${customer.alamat}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11.5, height: 1.35),
          ),
          isThreeLine: true,
          trailing: onViewMap == null
              ? const Icon(Icons.chevron_right)
              : IconButton(
                  tooltip: 'Lihat peta',
                  onPressed: () {
                    close(context, null);
                    onViewMap!(customer);
                  },
                  icon: const Icon(Icons.location_on_outlined),
                ),
          onTap: () => close(context, customer),
        );
      },
    );
  }
}
