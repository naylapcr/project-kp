import 'package:flutter/material.dart';

import '../models/customer.dart';
import '../theme/app_theme.dart';
import '../widgets/customer_card.dart';
import 'customer_search_delegate.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({
    super.key,
    required this.customers,
    required this.onEdit,
    required this.onViewMap,
    required this.onAdd,
  });

  final List<Customer> customers;
  final ValueChanged<Customer> onEdit;
  final ValueChanged<Customer> onViewMap;
  final VoidCallback onAdd;

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  bool _isRefreshing = false;

  Future<void> _search() async {
    final selected = await showSearch<Customer?>(
      context: context,
      delegate: CustomerSearchDelegate(customers: widget.customers),
    );
    if (selected != null && mounted) {
      widget.onEdit(selected);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring'),
        actions: [
          IconButton(
            tooltip: 'Cari pelanggan',
            onPressed: _search,
            icon: const Icon(Icons.search),
          ),
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: _isRefreshing ? null : _refresh,
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  )
                : const Icon(Icons.refresh),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.toska,
        child: widget.customers.isEmpty
            ? _EmptyMonitoring(onRefresh: _refresh)
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                itemCount: widget.customers.length,
                itemBuilder: (context, index) {
                  final customer = widget.customers[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CustomerCard(
                      key: ValueKey('customer-${customer.idpel}'),
                      customer: customer,
                      onEdit: () => widget.onEdit(customer),
                      onViewMap: () => widget.onViewMap(customer),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Buat inspeksi baru',
        onPressed: widget.onAdd,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyMonitoring extends StatelessWidget {
  const _EmptyMonitoring({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 90),
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.toskaTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.people_outline,
              color: AppColors.toskaDark,
              size: 34,
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Belum ada pelanggan',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Tarik ke bawah atau muat ulang untuk mengambil data terbaru.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted, fontSize: 12.5),
        ),
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Muat ulang'),
            style: OutlinedButton.styleFrom(minimumSize: const Size(160, 46)),
          ),
        ),
      ],
    );
  }
}
