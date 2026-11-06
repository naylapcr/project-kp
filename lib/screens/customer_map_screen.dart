import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/customer.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_badge.dart';
import '../widgets/app_header.dart';
import '../widgets/field_map.dart';
import '../widgets/status_badge.dart';

class CustomerMapScreen extends StatefulWidget {
  const CustomerMapScreen({
    super.key,
    required this.customers,
    required this.onEdit,
    this.focusedCustomer,
    this.focusRequest = 0,
  });

  final List<Customer> customers;
  final ValueChanged<Customer> onEdit;
  final Customer? focusedCustomer;
  final int focusRequest;

  @override
  State<CustomerMapScreen> createState() => _CustomerMapScreenState();
}

class _CustomerMapScreenState extends State<CustomerMapScreen> {
  final _locationService = LocationService();

  GoogleMapController? _mapController;
  Customer? _selected;
  Position? _officerPosition;
  bool _isLocating = false;

  Customer? get _fallbackCustomer =>
      widget.customers.isEmpty ? null : widget.customers.first;

  LatLng get _defaultCenter {
    final customer = _selected ?? widget.focusedCustomer ?? _fallbackCustomer;
    if (customer == null) {
      return const LatLng(-6.2088, 106.8456);
    }
    return LatLng(customer.latitude, customer.longitude);
  }

  @override
  void initState() {
    super.initState();
    _selected = widget.focusedCustomer ?? _fallbackCustomer;
    if (isNativeMapSupported) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _goToOfficer(silent: true);
      });
    }
  }

  @override
  void didUpdateWidget(covariant CustomerMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusRequest != oldWidget.focusRequest) {
      final focused = widget.focusedCustomer;
      if (focused != null) {
        setState(() => _selected = focused);
        _animateTo(focused);
      }
    }
  }

  void _animateTo(Customer customer) {
    final target = LatLng(customer.latitude, customer.longitude);
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 16.5),
      ),
    );
  }

  void _selectCustomer(Customer customer) {
    setState(() => _selected = customer);
    _animateTo(customer);
  }

  Future<void> _goToOfficer({bool silent = false}) async {
    if (_isLocating) return;
    setState(() => _isLocating = true);

    try {
      final position = await _locationService.currentPosition();
      if (!mounted) return;
      setState(() => _officerPosition = position);
      final target = LatLng(position.latitude, position.longitude);
      await _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: 17),
        ),
      );
    } on LocationFailure catch (error) {
      if (!mounted || silent) return;
      _showMessage(error.message);
    } catch (_) {
      if (!mounted || silent) return;
      _showMessage('Lokasi Anda belum tersedia. Periksa izin lokasi dan GPS.');
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  double? _distanceTo(Customer customer) {
    final position = _officerPosition;
    if (position == null) return null;
    return Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      customer.latitude,
      customer.longitude,
    );
  }

  String _distanceLabel(Customer customer) {
    final distance = _distanceTo(customer);
    if (distance == null) return 'GPS belum aktif';
    if (distance < 1000) return '${distance.round()} m';
    return '${(distance / 1000).toStringAsFixed(1)} km';
  }

  String _etaLabel(Customer customer) {
    final distance = _distanceTo(customer);
    if (distance == null) return 'Aktifkan GPS';
    final minutes = math.max(1, (distance / 1.4 / 60).round());
    return '≈ $minutes mnt';
  }

  Set<Marker> _buildMarkers() {
    return {
      for (final customer in widget.customers)
        Marker(
          markerId: MarkerId('customer-${customer.idpel}'),
          position: LatLng(customer.latitude, customer.longitude),
          infoWindow: InfoWindow(
            title: customer.nama,
            snippet: customer.alamat,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _markerHue(customer.status),
          ),
          onTap: () => _selectCustomer(customer),
        ),
      if (_officerPosition != null)
        Marker(
          markerId: const MarkerId('officer'),
          position: LatLng(
            _officerPosition!.latitude,
            _officerPosition!.longitude,
          ),
          infoWindow: const InfoWindow(title: 'Posisi Anda'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
    };
  }

  double _markerHue(CustomerStatus status) {
    return switch (status) {
      CustomerStatus.pending => BitmapDescriptor.hueOrange,
      CustomerStatus.completed => BitmapDescriptor.hueAzure,
      CustomerStatus.followUp => BitmapDescriptor.hueRed,
    };
  }

  Future<void> _showDirections(Customer customer) async {
    final distance = _distanceLabel(customer);
    final eta = _etaLabel(customer);

    await showModalBottomSheet<void>(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.margin),
                Text(
                  'Petunjuk arah',
                  style: AppTypography.headlineSm.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  customer.nama,
                  style: AppTypography.labelLg.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        size: 18,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          customer.alamat,
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.onSurface,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _InfoBlock(
                        label: 'JARAK TEMPUH',
                        value: distance,
                        caption: eta,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _InfoBlock(
                        label: 'TARIF / DAYA',
                        value: '${customer.tarif} / ${customer.daya} VA',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.margin),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: const Text('Tutup'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: customer.alamat),
                          );
                          if (!sheetContext.mounted) return;
                          Navigator.of(sheetContext).pop();
                          _showMessage('Alamat pelanggan disalin.');
                        },
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text('Salin Alamat'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          AppHeader(
            title: 'Peta Pelanggan',
            subtitle: 'Peta',
            onRefresh: () => _goToOfficer(),
            isRefreshing: _isLocating,
            refreshTooltip: 'Perbarui GPS',
          ),
          Expanded(
            child: isNativeMapSupported
                ? _buildNativeMap()
                : _buildMapFallback(),
          ),
        ],
      ),
    );
  }

  Widget _buildNativeMap() {
    final selected = _selected;

    return Stack(
      fit: StackFit.expand,
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _defaultCenter,
            zoom: 14.5,
          ),
          markers: _buildMarkers(),
          onMapCreated: (controller) => _mapController = controller,
          onTap: (_) => setState(() => _selected = null),
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          compassEnabled: false,
          rotateGesturesEnabled: false,
          tiltGesturesEnabled: false,
        ),
        Positioned(
          top: 12,
          left: 12,
          right: 84,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GpsPill(accuracy: _officerPosition?.accuracy),
              const SizedBox(height: AppSpacing.sm),
              _LocationLine(
                text: selected?.alamat ?? 'Ketuk penanda untuk melihat detail.',
              ),
            ],
          ),
        ),
        Positioned(
          right: 12,
          top: 124,
          child: Column(
            children: [
              _MapControlButton(
                icon: Icons.add,
                tooltip: 'Perbesar peta',
                onTap: () => _mapController?.animateCamera(
                  CameraUpdate.zoomIn(),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _MapControlButton(
                icon: Icons.remove,
                tooltip: 'Perkecil peta',
                onTap: () => _mapController?.animateCamera(
                  CameraUpdate.zoomOut(),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 12,
          bottom: selected == null ? 20 : 244,
          child: _MapControlButton(
            icon: Icons.my_location,
            tooltip: 'Lokasi saya',
            foregroundColor: AppColors.secondary,
            isLoading: _isLocating,
            onTap: _isLocating ? null : () => _goToOfficer(),
          ),
        ),
        if (selected != null)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: _SelectedCustomerSheet(
              customer: selected,
              distanceLabel: _distanceLabel(selected),
              etaLabel: _etaLabel(selected),
              onClose: () => setState(() => _selected = null),
              onEdit: () => widget.onEdit(selected),
              onDirections: () => _showDirections(selected),
            ),
          )
        else
          const Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: _MapHint(),
          ),
      ],
    );
  }

  Widget _buildMapFallback() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.margin,
        14,
        AppSpacing.margin,
        24,
      ),
      children: [
        _GpsTelemetryCard(
          accuracy: _officerPosition?.accuracy,
          isLocating: _isLocating,
          onLocate: () => _goToOfficer(),
        ),
        const SizedBox(height: AppSpacing.md),
        MapFallback(
          pins: [
            for (final customer in widget.customers)
              MapPin(
                id: customer.idpel,
                position: LatLng(customer.latitude, customer.longitude),
                title: customer.nama,
                snippet: customer.alamat,
                color: _pinColor(customer.status),
              ),
            if (_officerPosition != null)
              MapPin(
                id: 'petugas',
                position: LatLng(
                  _officerPosition!.latitude,
                  _officerPosition!.longitude,
                ),
                title: 'Posisi petugas',
                color: AppColors.tertiary,
              ),
          ],
          height: 230,
          center: _defaultCenter,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: Text(
                'Pelanggan di peta',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.headlineSm.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            AppBadge(
              label: '${widget.customers.length} titik',
              icon: Icons.location_on_outlined,
              background: AppColors.secondaryFixed,
              foreground: AppColors.secondary,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final customer in widget.customers)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _MapCustomerTile(
              customer: customer,
              distanceLabel: _distanceLabel(customer),
              onEdit: () => widget.onEdit(customer),
            ),
          ),
      ],
    );
  }

  Color _pinColor(CustomerStatus status) {
    return switch (status) {
      CustomerStatus.pending => AppColors.tertiary,
      CustomerStatus.completed => AppColors.secondary,
      CustomerStatus.followUp => AppColors.error,
    };
  }
}

class _GpsPill extends StatelessWidget {
  const _GpsPill({required this.accuracy});

  final double? accuracy;

  @override
  Widget build(BuildContext context) {
    final label = accuracy == null
        ? 'GPS BELUM AKTIF'
        : 'GPS AKURAT ±${accuracy!.round()} M';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: AppShadows.floating,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.gps_fixed,
            size: 14,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: AppColors.onSecondaryFixed,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationLine extends StatelessWidget {
  const _LocationLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: math.max(0, MediaQuery.sizeOf(context).width - 120),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.floating,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.place_outlined,
            size: 15,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.onSurface,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GpsTelemetryCard extends StatelessWidget {
  const _GpsTelemetryCard({
    required this.accuracy,
    required this.isLocating,
    required this.onLocate,
  });

  final double? accuracy;
  final bool isLocating;
  final VoidCallback onLocate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.secondaryFixed,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.gps_fixed,
              color: AppColors.secondary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  accuracy == null
                      ? 'GPS BELUM AKTIF'
                      : 'GPS AKURAT ±${accuracy!.round()} M',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  accuracy == null
                      ? 'Aktifkan GPS untuk menghitung jarak ke pelanggan.'
                      : 'Posisi petugas diperbarui secara otomatis.',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (isLocating)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            IconButton(
              tooltip: 'Aktifkan GPS',
              onPressed: onLocate,
              icon: const Icon(Icons.my_location, size: 20),
            ),
        ],
      ),
    );
  }
}

class _SelectedCustomerSheet extends StatelessWidget {
  const _SelectedCustomerSheet({
    required this.customer,
    required this.distanceLabel,
    required this.etaLabel,
    required this.onClose,
    required this.onEdit,
    required this.onDirections,
  });

  final Customer customer;
  final String distanceLabel;
  final String etaLabel;
  final VoidCallback onClose;
  final VoidCallback onEdit;
  final VoidCallback onDirections;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.sheet,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headlineSm.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          'IDPEL ',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            customer.idpel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.codeData.copyWith(
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              StatusBadge(
                status: customer.status,
                compact: true,
                uppercase: true,
              ),
              IconButton(
                tooltip: 'Tutup',
                onPressed: onClose,
                icon: const Icon(Icons.close, size: 18),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _InfoBlock(
                  label: 'JARAK TEMPUH',
                  value: distanceLabel,
                  caption: etaLabel,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _InfoBlock(
                  label: 'TARIF / DAYA',
                  value: '${customer.tarif} / ${customer.daya} VA',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.place_outlined,
                size: 15,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  customer.alamat,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDirections,
                  icon: const Icon(Icons.directions_outlined, size: 18),
                  label: const Text('Petunjuk'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.assignment_outlined, size: 18),
                  label: const Text('Mulai Inspeksi'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.label,
    required this.value,
    this.caption,
  });

  final String label;
  final String value;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelLg.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: 1),
            Text(
              caption!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MapControlButton extends StatelessWidget {
  const _MapControlButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.foregroundColor = AppColors.primary,
    this.isLoading = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final Color foregroundColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Material(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        elevation: 2,
        shadowColor: AppColors.primary.withValues(alpha: 0.18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Tooltip(
            message: tooltip,
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(icon, size: 20, color: foregroundColor),
            ),
          ),
        ),
      ),
    );
  }
}

class _MapHint extends StatelessWidget {
  const _MapHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.floating,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.touch_app_outlined,
            size: 18,
            color: AppColors.secondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Ketuk penanda pelanggan untuk melihat detail dan memulai inspeksi.',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapCustomerTile extends StatelessWidget {
  const _MapCustomerTile({
    required this.customer,
    required this.distanceLabel,
    required this.onEdit,
  });

  final Customer customer;
  final String distanceLabel;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.card,
      ),
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
            child: const Icon(
              Icons.place_outlined,
              color: AppColors.secondary,
              size: 20,
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusBadge(status: customer.status, compact: true),
                    Text(
                      distanceLabel,
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            tooltip: 'Buka form inspeksi',
            onPressed: onEdit,
            icon: const Icon(Icons.assignment_outlined, size: 20),
            color: AppColors.secondary,
          ),
        ],
      ),
    );
  }
}
