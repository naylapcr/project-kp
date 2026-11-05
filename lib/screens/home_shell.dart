import 'package:flutter/material.dart';

import '../data/mock_customers.dart';
import '../models/customer.dart';
import '../screens/customer_map_screen.dart';
import '../screens/inspection_form_screen.dart';
import '../screens/monitoring_screen.dart';
import '../theme/app_theme.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final List<Customer> _customers = List<Customer>.of(mockCustomers);

  int _selectedTab = 0;
  bool _mapsOpened = false;
  Customer? _focusedCustomer;
  int _mapFocusRequest = 0;

  Future<void> _openInspection(Customer customer) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => InspectionFormScreen(customer: customer),
      ),
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Inspeksi ${customer.nama} berhasil disimpan.'),
          ),
        );
    }
  }

  Future<void> _startNewInspection() async {
    final customer = await showModalBottomSheet<Customer>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return _CustomerPickerSheet(customers: _customers);
      },
    );

    if (customer != null && mounted) {
      await _openInspection(customer);
    }
  }

  void _showCustomerOnMap(Customer customer) {
    setState(() {
      _mapsOpened = true;
      _focusedCustomer = customer;
      _mapFocusRequest++;
      _selectedTab = 1;
    });
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedTab = index;
      if (index == 1) _mapsOpened = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedTab,
        children: [
          MonitoringScreen(
            customers: _customers,
            onEdit: _openInspection,
            onViewMap: _showCustomerOnMap,
            onAdd: _startNewInspection,
          ),
          _mapsOpened
              ? CustomerMapScreen(
                  customers: _customers,
                  onEdit: _openInspection,
                  focusedCustomer: _focusedCustomer,
                  focusRequest: _mapFocusRequest,
                )
              : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: _onTabSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.contacts_outlined),
            selectedIcon: Icon(Icons.contacts),
            label: 'Monitoring',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Maps',
          ),
        ],
      ),
    );
  }
}

class _CustomerPickerSheet extends StatelessWidget {
  const _CustomerPickerSheet({required this.customers});

  final List<Customer> customers;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.72;
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Buat inspeksi baru',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Pilih pelanggan yang akan diperiksa.',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ),
            ),
            const Divider(),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: customers.length,
                separatorBuilder: (_, _) =>
                    const Divider(indent: 68, endIndent: 20),
                itemBuilder: (context, index) {
                  final customer = customers[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 2,
                    ),
                    leading: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.toskaTint,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: AppColors.toskaDark,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      customer.nama,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      customer.idpel,
                      style: const TextStyle(fontSize: 11.5),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.muted,
                    ),
                    onTap: () => Navigator.of(context).pop(customer),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
