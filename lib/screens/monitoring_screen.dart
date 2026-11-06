import 'package:flutter/material.dart';

import '../models/customer.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/customer_card.dart';

enum _CustomerFilter { all, pending, followUp, completed }

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({
    super.key,
    required this.customers,
    required this.onEdit,
    required this.onViewMap,
  });

  final List<Customer> customers;
  final ValueChanged<Customer> onEdit;
  final ValueChanged<Customer> onViewMap;

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  final _searchController = TextEditingController();

  _CustomerFilter _filter = _CustomerFilter.all;
  String _query = '';
  bool _isRefreshing = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Customer> get _visibleCustomers {
    final query = _query.trim().toLowerCase();
    return widget.customers.where((customer) {
      if (!_matchesFilter(customer)) return false;
      if (query.isEmpty) return true;
      return customer.nama.toLowerCase().contains(query) ||
          customer.idpel.contains(query) ||
          customer.alamat.toLowerCase().contains(query) ||
          customer.nomorMeter.toLowerCase().contains(query);
    }).toList();
  }

  bool _matchesFilter(Customer customer) {
    return switch (_filter) {
      _CustomerFilter.all => true,
      _CustomerFilter.pending =>
        customer.status == CustomerStatus.pending,
      _CustomerFilter.followUp =>
        customer.status == CustomerStatus.followUp,
      _CustomerFilter.completed =>
        customer.status == CustomerStatus.completed,
    };
  }

  int _countFor(_CustomerFilter filter) {
    return switch (filter) {
      _CustomerFilter.all => widget.customers.length,
      _CustomerFilter.pending => widget.customers
          .where((customer) => customer.status == CustomerStatus.pending)
          .length,
      _CustomerFilter.followUp => widget.customers
          .where((customer) => customer.status == CustomerStatus.followUp)
          .length,
      _CustomerFilter.completed => widget.customers
          .where((customer) => customer.status == CustomerStatus.completed)
          .length,
    };
  }

  Future<void> _refresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);

    // Replace this delay with the monitoring data request when the API is ready.
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;

    setState(() => _isRefreshing = false);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Data monitoring berhasil diperbarui.')),
      );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  Future<void> _openFilterSheet() async {
    final selected = await showModalBottomSheet<_CustomerFilter>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.margin,
              10,
              AppSpacing.margin,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
                const SizedBox(height: AppSpacing.margin),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Filter status',
                    style: AppTypography.headlineSm.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Tampilkan pelanggan berdasarkan status inspeksi.',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                for (final filter in _CustomerFilter.values)
                  _FilterOptionTile(
                    filter: filter,
                    count: _countFor(filter),
                    selected: _filter == filter,
                    onTap: () => Navigator.of(sheetContext).pop(filter),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null && mounted) {
      setState(() => _filter = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customers = _visibleCustomers;
    final hasCriteria = _query.trim().isNotEmpty || _filter != _CustomerFilter.all;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          AppHeader(
            title: 'Inspeksi Lapangan',
            subtitle: 'Monitoring',
            onRefresh: _refresh,
            isRefreshing: _isRefreshing,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.secondary,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.margin,
                  14,
                  AppSpacing.margin,
                  24,
                ),
                children: [
                  const _SyncBanner(),
                  const SizedBox(height: AppSpacing.md),
                  _StatsCard(customers: widget.customers),
                  const SizedBox(height: 14),
                  _SearchBar(
                    controller: _searchController,
                    query: _query,
                    onChanged: (value) => setState(() => _query = value),
                    onClear: _clearSearch,
                    onFilter: _openFilterSheet,
                  ),
                  const SizedBox(height: 10),
                  _FilterChips(
                    filter: _filter,
                    countFor: _countFor,
                    onSelected: (filter) => setState(() => _filter = filter),
                  ),
                  const SizedBox(height: 14),
                  if (customers.isEmpty)
                    _EmptyMonitoring(
                      hasCriteria: hasCriteria,
                      onReset: () {
                        _clearSearch();
                        setState(() => _filter = _CustomerFilter.all);
                      },
                    )
                  else
                    for (final customer in customers)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.md,
                        ),
                        child: CustomerCard(
                          key: ValueKey('customer-${customer.idpel}'),
                          customer: customer,
                          onEdit: () => widget.onEdit(customer),
                          onViewMap: () => widget.onViewMap(customer),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncBanner extends StatelessWidget {
  const _SyncBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.secondaryFixed,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.shield_outlined,
            size: 18,
            color: AppColors.secondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Data tersinkron otomatis',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSecondaryFixed,
                      fontWeight: FontWeight.w700,
                      fontVariations: const [FontVariation('wght', 700)],
                    ),
                  ),
                  TextSpan(
                    text: ' (Offline Ready) ',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSecondaryFixed,
                    ),
                  ),
                  TextSpan(
                    text: '100% Siap',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w700,
                      fontVariations: const [FontVariation('wght', 700)],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.customers});

  final List<Customer> customers;

  @override
  Widget build(BuildContext context) {
    final total = customers.length;
    final pending = customers
        .where((customer) => customer.status == CustomerStatus.pending)
        .length;
    final completed = customers
        .where((customer) => customer.status == CustomerStatus.completed)
        .length;
    final progress = total == 0 ? 0.0 : completed / total;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Row(
            children: [
              _StatColumn(
                label: 'TOTAL',
                value: total,
                caption: 'Pelanggan',
                valueColor: AppColors.onSurface,
              ),
              const _StatDivider(),
              _StatColumn(
                label: 'PENDING',
                value: pending,
                caption: 'Belum Cek',
                valueColor: AppColors.onTertiaryContainer,
              ),
              const _StatDivider(),
              _StatColumn(
                label: 'SELESAI',
                value: completed,
                caption: 'Terverifikasi',
                valueColor: AppColors.secondary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: AppColors.outlineVariant.withValues(alpha: 0.5),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
    required this.caption,
    required this.valueColor,
  });

  final String label;
  final int value;
  final String caption;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: AppColors.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: AppTypography.headlineXlMobile.copyWith(color: valueColor),
          ),
          const SizedBox(height: 1),
          Text(
            caption,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 48,
      color: AppColors.outlineVariant.withValues(alpha: 0.45),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
    required this.onFilter,
  });

  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(
            Icons.search,
            size: 20,
            color: AppColors.secondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => FocusScope.of(context).unfocus(),
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurface,
              ),
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                hintText: 'Cari Nama, IDPEL, atau Alamat...',
                hintStyle: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (query.isNotEmpty)
            SizedBox(
              width: 40,
              height: 44,
              child: IconButton(
                tooltip: 'Hapus pencarian',
                onPressed: onClear,
                icon: const Icon(Icons.close, size: 18),
              ),
            ),
          SizedBox(
            width: 44,
            height: 44,
            child: IconButton(
              tooltip: 'Filter status',
              onPressed: onFilter,
              icon: const Icon(Icons.tune, size: 20),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.filter,
    required this.countFor,
    required this.onSelected,
  });

  final _CustomerFilter filter;
  final int Function(_CustomerFilter filter) countFor;
  final ValueChanged<_CustomerFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final item in _CustomerFilter.values) ...[
              _FilterChip(
                label: '${_labelFor(item)} (${countFor(item)})',
                selected: filter == item,
                onTap: () => onSelected(item),
              ),
              if (item != _CustomerFilter.values.last)
                const SizedBox(width: AppSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }

  String _labelFor(_CustomerFilter filter) {
    return switch (filter) {
      _CustomerFilter.all => 'Semua',
      _CustomerFilter.pending => 'Belum Dikerjakan',
      _CustomerFilter.followUp => 'Perlu Tindak Lanjut',
      _CustomerFilter.completed => 'Selesai',
    };
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.primary : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            height: 44,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: AppTypography.labelMd.copyWith(
                color: selected
                    ? AppColors.onPrimary
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterOptionTile extends StatelessWidget {
  const _FilterOptionTile({
    required this.filter,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final _CustomerFilter filter;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = switch (filter) {
      _CustomerFilter.all => 'Semua pelanggan',
      _CustomerFilter.pending => 'Belum dikerjakan',
      _CustomerFilter.followUp => 'Perlu tindak lanjut',
      _CustomerFilter.completed => 'Selesai diperiksa',
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  fontVariations: [
                    FontVariation('wght', selected ? 600 : 400),
                  ],
                ),
              ),
            ),
            Text(
              '$count',
              style: AppTypography.labelMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              size: 20,
              color: selected
                  ? AppColors.secondary
                  : AppColors.outlineVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMonitoring extends StatelessWidget {
  const _EmptyMonitoring({
    required this.hasCriteria,
    required this.onReset,
  });

  final bool hasCriteria;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.secondaryFixed,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.people_outline,
              color: AppColors.secondary,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            hasCriteria
                ? 'Tidak ada pelanggan yang cocok'
                : 'Belum ada pelanggan',
            textAlign: TextAlign.center,
            style: AppTypography.headlineSm.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hasCriteria
                ? 'Ubah kata kunci atau filter status untuk melihat pelanggan lain.'
                : 'Tarik ke bawah untuk mengambil data terbaru.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          if (hasCriteria) ...[
            const SizedBox(height: AppSpacing.margin),
            OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.restart_alt, size: 18),
              label: const Text('Reset filter'),
            ),
          ],
        ],
      ),
    );
  }
}
