import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/customer.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import '../widgets/field_map.dart';

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

  LatLng get _defaultCenter {
    final customer =
        widget.focusedCustomer ??
        (widget.customers.isEmpty ? null : widget.customers.first);
    if (customer == null) {
      return const LatLng(-6.2088, 106.8456);
    }
    return LatLng(customer.latitude, customer.longitude);
  }

  @override
  void initState() {
    super.initState();
    _selected = widget.focusedCustomer;
  }

  @override
  void didUpdateWidget(covariant CustomerMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusRequest != oldWidget.focusRequest) {
      final focused = widget.focusedCustomer;
      if (focused != null) {
        setState(() => _selected = focused);
        final target = LatLng(focused.latitude, focused.longitude);
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: target, zoom: 16.5),
          ),
        );
      }
    }
  }

  void _selectCustomer(Customer customer) {
    setState(() => _selected = customer);
    final target = LatLng(customer.latitude, customer.longitude);
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 16.5),
      ),
    );
  }

  Future<void> _goToOfficer() async {
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
      if (!mounted) return;
      _showMessage(error.message);
    } catch (_) {
      if (!mounted) return;
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
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maps'),
        actions: [
          IconButton(
            tooltip: 'Lokasi saya',
            onPressed: _isLocating ? null : _goToOfficer,
            icon: _isLocating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  )
                : const Icon(Icons.my_location),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: isNativeMapSupported ? _buildNativeMap() : _buildMapFallback(),
    );
  }

  Widget _buildNativeMap() {
    final selected = _selected;
    return Stack(
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
          child: _MapInfoPill(
            icon: Icons.people_outline,
            text: '${widget.customers.length} pelanggan',
          ),
        ),
        Positioned(
          right: 14,
          bottom: selected == null ? 18 : 140,
          child: FloatingActionButton.small(
            heroTag: 'my-location-map',
            tooltip: 'Lokasi saya',
            onPressed: _isLocating ? null : _goToOfficer,
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.toskaDark,
            child: _isLocating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location, size: 21),
          ),
        ),
        if (selected != null)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: _SelectedCustomerCard(
              customer: selected,
              onClose: () => setState(() => _selected = null),
              onEdit: () => widget.onEdit(selected),
            ),
          ),
      ],
    );
  }

  Widget _buildMapFallback() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        MapFallback(
          pins: [
            for (final customer in widget.customers)
              MapPin(
                id: customer.idpel,
                position: LatLng(customer.latitude, customer.longitude),
                title: customer.nama,
                snippet: customer.alamat,
              ),
          ],
          height: 230,
          center: _defaultCenter,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.toskaTint,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Peta interaktif Google Maps tersedia pada perangkat Android dan iOS. '
            'Daftar pelanggan tetap dapat dibuka di bawah ini.',
            style: TextStyle(
              color: AppColors.toskaDark,
              fontSize: 11.5,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Pelanggan di peta',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        for (final customer in widget.customers)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 3,
              ),
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.toskaTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
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
                customer.alamat,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5),
              ),
              trailing: IconButton(
                tooltip: 'Buka formulir',
                onPressed: () => widget.onEdit(customer),
                icon: const Icon(Icons.edit, size: 19),
              ),
            ),
          ),
      ],
    );
  }
}

class _MapInfoPill extends StatelessWidget {
  const _MapInfoPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.toskaDark),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedCustomerCard extends StatelessWidget {
  const _SelectedCustomerCard({
    required this.customer,
    required this.onClose,
    required this.onEdit,
  });

  final Customer customer;
  final VoidCallback onClose;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: AppColors.ink.withValues(alpha: 0.16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 10),
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
                        customer.nama.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'IDPEL ${customer.idpel}',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Tutup',
                  onPressed: onClose,
                  icon: const Icon(Icons.close, size: 18),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              customer.alamat,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 11.5,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Isi Inspeksi'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 38),
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  textStyle: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
