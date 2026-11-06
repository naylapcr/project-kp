import 'package:flutter/material.dart';

import '../data/mock_customers.dart';
import '../models/customer.dart';
import '../screens/customer_map_screen.dart';
import '../screens/inspection_form_screen.dart';
import '../screens/monitoring_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';

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
      setState(() {
        final index = _customers.indexWhere(
          (item) => item.idpel == customer.idpel,
        );
        if (index != -1) {
          _customers[index] = _customers[index].copyWith(
            status: CustomerStatus.completed,
          );
        }
      });
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
      backgroundColor: AppColors.surface,
      body: IndexedStack(
        index: _selectedTab,
        children: [
          MonitoringScreen(
            customers: _customers,
            onEdit: _openInspection,
            onViewMap: _showCustomerOnMap,
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
      bottomNavigationBar: AppBottomNav(
        selectedIndex: _selectedTab,
        onSelected: _onTabSelected,
        onInspection: _startNewInspection,
      ),
    );
  }
}

class _CustomerPickerSheet extends StatelessWidget {
  const _CustomerPickerSheet({required this.customers});

  final List<Customer> customers;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.78;

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
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.margin,
                AppSpacing.margin,
                AppSpacing.margin,
                4,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Buat Inspeksi Baru',
                  style: AppTypography.headlineMd.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.margin,
                0,
                AppSpacing.margin,
                AppSpacing.md,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Pilih pelanggan yang akan diperiksa petugas.',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const Divider(),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: customers.length,
                separatorBuilder: (_, _) => const Divider(
                  indent: 72,
                  endIndent: AppSpacing.margin,
                ),
                itemBuilder: (context, index) {
                  final customer = customers[index];
                  return InkWell(
                    onTap: () => Navigator.of(context).pop(customer),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.margin,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.secondaryFixed,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: const Icon(
                              Icons.person_outline,
                              color: AppColors.secondary,
                              size: 21,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  customer.nama,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.labelLg.copyWith(
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  customer.idpel,
                                  style: AppTypography.codeData.copyWith(
                                    color: AppColors.secondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  customer.alamat,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.bodySm.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
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
