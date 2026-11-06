import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../models/customer.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_badge.dart';
import '../widgets/app_header.dart';
import '../widgets/field_map.dart';
import '../widgets/form_section_card.dart';
import '../widgets/photo_form_field.dart';

class InspectionFormScreen extends StatefulWidget {
  const InspectionFormScreen({super.key, required this.customer});

  final Customer customer;

  @override
  State<InspectionFormScreen> createState() => _InspectionFormScreenState();
}

class _InspectionFormScreenState extends State<InspectionFormScreen> {
  static const _dlpdOptions = ['Z', 'A', 'B', 'C'];
  static const _keteranganOptions = [
    'Selesai',
    'Perlu Tindak Lanjut',
    'Tidak Dapat Diakses',
    'Pelanggan Menolak',
  ];

  final _formKey = GlobalKey<FormState>();
  final _locationService = LocationService();
  final _controllers = <String, TextEditingController>{};

  StreamSubscription<Position>? _positionSubscription;
  Position? _officerPosition;
  String? _locationMessage;
  bool _isLocating = false;
  bool _isSaving = false;
  bool _showSystemDetails = false;

  String? _dlpd;
  String? _hasilPeriksa;
  String? _tindakLanjut;
  String? _keterangan;
  DateTime? _installationDate;
  XFile? _photo;

  Customer get _customer => widget.customer;

  TextEditingController _c(String name) => _controllers[name]!;

  LatLng get _targetLocation =>
      LatLng(_customer.latitude, _customer.longitude);

  LatLng? get _officerLocation {
    final position = _officerPosition;
    if (position == null) return null;
    return LatLng(position.latitude, position.longitude);
  }

  @override
  void initState() {
    super.initState();

    _controllers.addAll({
      'merek_meter': TextEditingController(),
      'thn_buat_meter': TextEditingController(),
      'krn': TextEditingController(),
      'tglpasang_kwh': TextEditingController(),
      'jenis_mk': TextEditingController(),
      'jml_p2tl': TextEditingController(),
      'beli_token_akhir': TextEditingController(),
      'jml_ct': TextEditingController(),
      'titik_koordinat': TextEditingController(),
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startLocationTracking();
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _startLocationTracking() async {
    if (_isLocating) return;
    setState(() {
      _isLocating = true;
      _locationMessage = null;
    });

    await _positionSubscription?.cancel();
    _positionSubscription = null;

    try {
      final initialPosition = await _locationService.currentPosition();
      if (!mounted) return;
      _applyOfficerPosition(initialPosition);

      final stream = await _locationService.livePositionStream();
      if (!mounted) return;
      _positionSubscription = stream.listen(
        _applyOfficerPosition,
        onError: (Object error) {
          if (!mounted) return;
          setState(() {
            _locationMessage =
                'Pembaruan lokasi terhenti. Tekan "Perbarui" untuk mencoba lagi.';
          });
        },
      );
    } on LocationFailure catch (error) {
      if (!mounted) return;
      setState(() => _locationMessage = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _locationMessage =
            'Lokasi petugas belum tersedia. Periksa izin lokasi dan GPS.';
      });
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _applyOfficerPosition(Position position) {
    if (!mounted) return;
    setState(() {
      _officerPosition = position;
      _locationMessage = null;
      _c('titik_koordinat').text =
          '${position.latitude.toStringAsFixed(6)}, '
          '${position.longitude.toStringAsFixed(6)}';
    });
  }

  Future<void> _pickInstallationDate() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _installationDate ?? now,
      firstDate: DateTime(1990),
      lastDate: DateTime(now.year, now.month, now.day),
      helpText: 'Pilih tanggal pasang kWh',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (selected == null || !mounted) return;
    setState(() {
      _installationDate = selected;
      _c('tglpasang_kwh').text = _formatDate(selected);
    });
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  void _showMessage(String message, {bool error = false}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: error ? AppColors.error : AppColors.primary,
          content: Text(message),
        ),
      );
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    final formIsValid = _formKey.currentState?.validate() ?? false;
    final inspectionIsComplete =
        _hasilPeriksa != null &&
        _tindakLanjut != null &&
        _keterangan != null &&
        _photo != null &&
        _c('titik_koordinat').text.trim().isNotEmpty;

    if (!formIsValid || !inspectionIsComplete) {
      _showMessage(
        'Lengkapi semua field wajib (*) sebelum menyimpan inspeksi.',
        error: true,
      );
      return;
    }

    setState(() => _isSaving = true);

    // Integrate the field-service API here. Validation intentionally happens
    // before this block, so incomplete inspections are never submitted.
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    setState(() => _isSaving = false);
    Navigator.of(context).pop(true);
  }

  void _cancel() {
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          AppHeader(
            title: 'Form Inspeksi',
            subtitle: 'IDPEL ${_customer.idpel}',
            leading: _HeaderBackButton(onPressed: _cancel),
            onRefresh: () => _startLocationTracking(),
            isRefreshing: _isLocating,
            refreshTooltip: 'Kalibrasi GPS',
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.margin,
                  12,
                  AppSpacing.margin,
                  24,
                ),
                children: [
                  _ReportModeStrip(isGpsActive: _officerPosition != null),
                  const SizedBox(height: AppSpacing.md),
                  _FormIntroCard(customer: _customer),
                  const SizedBox(height: AppSpacing.md),
                  _buildCustomerSection(),
                  const SizedBox(height: AppSpacing.md),
                  _buildMeterSection(),
                  const SizedBox(height: AppSpacing.md),
                  _buildLocationSection(),
                  const SizedBox(height: AppSpacing.md),
                  _buildPhotoSection(),
                  const SizedBox(height: AppSpacing.md),
                  _buildInspectionSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _FormFooter(
        isSaving: _isSaving,
        onCancel: _cancel,
        onSave: _save,
      ),
    );
  }

  Widget _buildCustomerSection() {
    return FormSectionCard(
      icon: Icons.badge_outlined,
      title: 'Data Pelanggan & Meteran',
      subtitle: 'Terisi otomatis dari sistem',
      badge: const AppBadge(
        label: 'Terkunci Sistem',
        icon: Icons.lock_outline,
        background: AppColors.secondaryFixed,
        foreground: AppColors.secondary,
      ),
      children: [
        ReadOnlyValueRow(label: 'NAMA PELANGGAN', value: _customer.nama),
        const Divider(height: 20),
        ReadOnlyValueRow(
          label: 'IDPEL',
          value: _customer.idpel,
          code: true,
        ),
        const Divider(height: 20),
        ReadOnlyValueRow(
          label: 'NO. SERI METER',
          value: _customer.nomorMeter,
          code: true,
        ),
        const Divider(height: 20),
        ReadOnlyValueRow(
          label: 'TARIF / DAYA',
          value: '${_customer.tarif} / ${_customer.daya} VA',
        ),
        const Divider(height: 20),
        ReadOnlyValueRow(
          label: 'ALAMAT PELANGGAN',
          value: _customer.alamat,
        ),
        if (_showSystemDetails) ...[
          const Divider(height: 20),
          ReadOnlyValueRow(label: 'THBL', value: _customer.thbl, code: true),
          const Divider(height: 20),
          ReadOnlyValueRow(label: 'UNITUP', value: _customer.unitup),
          const Divider(height: 20),
          ReadOnlyValueRow(label: 'UNITUPI', value: _customer.unitupi),
          const Divider(height: 20),
          ReadOnlyValueRow(label: 'UNITAP', value: _customer.unitap),
          const Divider(height: 20),
          ReadOnlyValueRow(label: 'KRITERIA', value: _customer.kriteria),
          const Divider(height: 20),
          ReadOnlyValueRow(label: 'KODE GARDU', value: _customer.kodeGardu),
          const Divider(height: 20),
          ReadOnlyValueRow(label: 'NO TIANG', value: _customer.noTiang),
          const Divider(height: 20),
          ReadOnlyValueRow(label: 'KDDK', value: _customer.kddk),
        ],
        TextButton.icon(
          onPressed: () {
            setState(() => _showSystemDetails = !_showSystemDetails);
          },
          icon: Icon(
            _showSystemDetails ? Icons.expand_less : Icons.expand_more,
            size: 18,
          ),
          iconAlignment: IconAlignment.start,
          label: Text(
            _showSystemDetails
                ? 'Sembunyikan data sistem'
                : 'Lihat data sistem lainnya',
          ),
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildMeterSection() {
    return FormSectionCard(
      icon: Icons.electric_meter_outlined,
      title: 'Data Teknis Meteran',
      subtitle: 'Diisi petugas saat verifikasi kWh meter',
      children: [
        _textField(
          'merek_meter',
          label: 'MEREK METER',
          hint: 'Contoh: Itron / Hexing',
        ),
        _textField(
          'thn_buat_meter',
          label: 'TAHUN BUAT METER',
          required: true,
          keyboardType: TextInputType.number,
          numericOnly: true,
        ),
        _textField(
          'krn',
          label: 'KRN',
          required: true,
          keyboardType: TextInputType.number,
          numericOnly: true,
        ),
        _dateField(),
        _textField(
          'jenis_mk',
          label: 'JENIS MK',
          hint: 'Contoh: Prabayar',
        ),
        _textField(
          'jml_p2tl',
          label: 'JML P2TL',
          required: true,
          keyboardType: TextInputType.number,
          numericOnly: true,
        ),
        _textField(
          'beli_token_akhir',
          label: 'BELI TOKEN AKHIR',
          required: true,
          keyboardType: TextInputType.number,
          numericOnly: true,
        ),
        _textField(
          'jml_ct',
          label: 'JML CT',
          required: true,
          keyboardType: TextInputType.number,
          numericOnly: true,
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    final officerLocation = _officerLocation;
    final accuracy = _officerPosition?.accuracy;

    return FormSectionCard(
      icon: Icons.my_location,
      title: 'Titik Koordinat Petugas',
      subtitle: 'GPS real-time perangkat',
      badge: const AppBadge(
        label: 'Real-time GPS',
        icon: Icons.gps_fixed,
        background: AppColors.secondaryFixed,
        foreground: AppColors.secondary,
      ),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _CoordinateBlock(
                label: 'KOORDINAT GEOGRAFIS',
                value:
                    '${_customer.latitude.toStringAsFixed(6)}, '
                    '${_customer.longitude.toStringAsFixed(6)}',
                caption: 'Lokasi target pelanggan',
                code: true,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _CoordinateBlock(
                label: 'AKURASI GPS',
                value: accuracy == null
                    ? '—'
                    : '±${accuracy.toStringAsFixed(0)} m',
                caption: accuracy == null ? 'Menunggu GPS' : 'GPS petugas',
              ),
            ),
          ],
        ),
        Stack(
          children: [
            GestureDetector(
              onTap: _isLocating ? null : _startLocationTracking,
              child: FieldMap(
                center: officerLocation ?? _targetLocation,
                height: 180,
                pins: [
                  MapPin(
                    id: 'target',
                    position: _targetLocation,
                    title: _customer.nama,
                    snippet: _customer.alamat,
                  ),
                  if (officerLocation != null)
                    MapPin(
                      id: 'petugas',
                      position: officerLocation,
                      title: 'Posisi petugas',
                      snippet: accuracy == null
                          ? null
                          : 'Akurasi ±${accuracy.toStringAsFixed(0)} m',
                      color: AppColors.tertiary,
                    ),
                ],
              ),
            ),
            Positioned(
              left: 8,
              bottom: 8,
              right: 100,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest.withValues(
                    alpha: 0.95,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  'Pratinjau & ketuk peta untuk perbarui',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: OutlinedButton.icon(
                onPressed: _isLocating ? null : _startLocationTracking,
                icon: const Icon(Icons.gps_fixed, size: 16),
                label: Text(_isLocating ? 'Mencari...' : 'Kalibrasi'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  backgroundColor: AppColors.surfaceContainerLowest,
                ),
              ),
            ),
          ],
        ),
        if (_isLocating)
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: LinearProgressIndicator(minHeight: 2),
          ),
        if (_locationMessage != null)
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppColors.tertiaryFixed,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 17,
                  color: AppColors.onTertiaryContainer,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    _locationMessage!,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onTertiaryContainer,
                      height: 1.4,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _isLocating ? null : _startLocationTracking,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 34),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text('Perbarui'),
                ),
              ],
            ),
          ),
        _textField(
          'titik_koordinat',
          label: 'TITIK KOORDINAT',
          required: true,
          readOnly: true,
          hint: _isLocating
              ? 'Mengambil lokasi GPS...'
              : 'Otomatis terisi dari GPS perangkat',
          helper: 'Titik aktual petugas saat inspeksi dilakukan.',
        ),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return FormSectionCard(
      icon: Icons.photo_camera_outlined,
      title: 'Bukti Foto Lapangan',
      subtitle: 'Dokumentasi fisik kWh meter',
      badge: const AppBadge(
        label: 'Wajib Kamera',
        icon: Icons.photo_camera_outlined,
        background: AppColors.errorContainer,
        foreground: AppColors.onErrorContainer,
      ),
      children: [
        PhotoFormField(
          onChanged: (photo) => _photo = photo,
          validator: (value) {
            if (value == null) return 'Foto wajib diambil dari kamera.';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildInspectionSection() {
    return FormSectionCard(
      icon: Icons.fact_check_outlined,
      title: 'Hasil Inspeksi Lapangan',
      subtitle: 'Diisi petugas saat pemeriksaan',
      children: [
        _dropdownField<String>(
          label: 'DLPD',
          value: _dlpd,
          hint: 'Pilih kode DLPD',
          items: _dlpdOptions,
          onChanged: (value) => setState(() => _dlpd = value),
        ),
        _choiceField(
          fieldKey: 'hasil_periksa_field',
          label: 'HASIL PERIKSA',
          options: const ['Normal', 'P2TL'],
          value: _hasilPeriksa,
          onChanged: (value) => setState(() => _hasilPeriksa = value),
        ),
        _choiceField(
          fieldKey: 'tindak_lanjut_field',
          label: 'TINDAK LANJUT',
          options: const ['Penyegelan Ulang', 'Pemutusan Sementara'],
          value: _tindakLanjut,
          onChanged: (value) => setState(() => _tindakLanjut = value),
        ),
        _dropdownField<String>(
          label: 'KETERANGAN',
          value: _keterangan,
          hint: 'Pilih status keterangan',
          items: _keteranganOptions,
          required: true,
          validator: (value) =>
              value == null ? 'Keterangan wajib dipilih.' : null,
          onChanged: (value) => setState(() => _keterangan = value),
        ),
      ],
    );
  }

  Widget _dateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RequiredFieldLabel(
          label: 'TGL PASANG KWH',
          required: true,
          helper: 'Tanggal pemasangan meter pelanggan.',
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _c('tglpasang_kwh'),
          readOnly: true,
          keyboardType: TextInputType.datetime,
          onTap: _pickInstallationDate,
          validator: _requiredValidator,
          style: _inputStyle(readOnly: true),
          decoration: _decoration(
            hint: 'Pilih tanggal',
            fillColor: AppColors.surfaceContainerLowest,
            suffixIcon: IconButton(
              tooltip: 'Pilih tanggal',
              onPressed: _pickInstallationDate,
              icon: const Icon(
                Icons.calendar_today,
                size: 19,
                color: AppColors.secondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _textField(
    String name, {
    required String label,
    bool required = false,
    bool readOnly = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool numericOnly = false,
    String? hint,
    String? helper,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RequiredFieldLabel(
          label: label,
          required: required,
          helper: helper,
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _c(name),
          readOnly: readOnly,
          maxLines: maxLines,
          minLines: 1,
          keyboardType: keyboardType,
          inputFormatters: numericOnly
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
          validator: required ? _requiredValidator : null,
          style: _inputStyle(readOnly: readOnly),
          decoration: _decoration(
            hint: hint,
            fillColor: readOnly
                ? AppColors.surfaceContainerLow
                : AppColors.surfaceContainerLowest,
          ),
        ),
      ],
    );
  }

  Widget _dropdownField<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String hint,
    required ValueChanged<T?> onChanged,
    bool required = false,
    FormFieldValidator<T>? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RequiredFieldLabel(label: label, required: required),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          validator: validator,
          decoration: _decoration(hint: hint),
          items: [
            for (final item in items)
              DropdownMenuItem<T>(
                value: item,
                child: Text(item.toString()),
              ),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _choiceField({
    required String fieldKey,
    required String label,
    required List<String> options,
    required String? value,
    required ValueChanged<String> onChanged,
  }) {
    return FormField<String>(
      key: ValueKey(fieldKey),
      initialValue: value,
      validator: (selected) => selected == null ? 'Wajib dipilih.' : null,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RequiredFieldLabel(label: label, required: true),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                for (var index = 0; index < options.length; index++) ...[
                  if (index > 0) const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _ChoiceButton(
                      label: options[index],
                      selected: value == options[index],
                      onTap: () {
                        onChanged(options[index]);
                        field.didChange(options[index]);
                      },
                    ),
                  ),
                ],
              ],
            ),
            if (field.errorText != null) ...[
              const SizedBox(height: 7),
              Text(
                field.errorText!,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  TextStyle _inputStyle({required bool readOnly}) {
    return AppTypography.bodyMd.copyWith(
      color: AppColors.onSurface,
      fontWeight: readOnly ? FontWeight.w500 : FontWeight.w600,
      fontVariations: [FontVariation('wght', readOnly ? 500 : 600)],
    );
  }

  InputDecoration _decoration({
    String? hint,
    Color fillColor = AppColors.surfaceContainerLowest,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: fillColor,
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Wajib diisi.';
    return null;
  }
}

class _HeaderBackButton extends StatelessWidget {
  const _HeaderBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: IconButton(
        tooltip: 'Kembali',
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.08),
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        icon: const Icon(Icons.arrow_back, size: 20),
      ),
    );
  }
}

class _ReportModeStrip extends StatelessWidget {
  const _ReportModeStrip({required this.isGpsActive});

  final bool isGpsActive;

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
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 18,
            color: AppColors.secondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Mode Laporan: ',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSecondaryFixed,
                    ),
                  ),
                  TextSpan(
                    text: 'Buka Rekaman Offline',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSecondaryFixed,
                      fontWeight: FontWeight.w700,
                      fontVariations: const [FontVariation('wght', 700)],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: isGpsActive
                  ? AppColors.secondary
                  : AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isGpsActive
                        ? AppColors.onSecondary
                        : AppColors.onTertiaryContainer,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  isGpsActive ? 'GPS AKTIF' : 'GPS MENUNGGU',
                  style: AppTypography.labelSm.copyWith(
                    color: isGpsActive
                        ? AppColors.onSecondary
                        : AppColors.onTertiaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormIntroCard extends StatelessWidget {
  const _FormIntroCard({required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.margin),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  'FORM LAPANGAN',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.secondary,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: AppBadge(
                  label: 'IDPEL ${customer.idpel}',
                  background: AppColors.secondaryFixed,
                  foreground: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Formulir Inspeksi Lapangan',
            style: AppTypography.headlineMd.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Lengkapi parameter teknis dan dokumentasi verifikasi fisik '
            'kWh meter.',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoordinateBlock extends StatelessWidget {
  const _CoordinateBlock({
    required this.label,
    required this.value,
    required this.caption,
    this.code = false,
  });

  final String label;
  final String value;
  final String caption;
  final bool code;

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
            style: code
                ? AppTypography.codeData.copyWith(
                    color: AppColors.onSurface,
                    fontSize: 12,
                  )
                : AppTypography.labelLg.copyWith(
                    color: AppColors.onSurface,
                  ),
          ),
          const SizedBox(height: 1),
          Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.secondaryFixed
          : AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: selected
                  ? AppColors.secondary
                  : AppColors.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTypography.labelMd.copyWith(
              color: selected
                  ? AppColors.secondary
                  : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _FormFooter extends StatelessWidget {
  const _FormFooter({
    required this.isSaving,
    required this.onCancel,
    required this.onSave,
  });

  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.margin,
            AppSpacing.md,
            AppSpacing.margin,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isSaving ? null : onCancel,
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton(
                  onPressed: isSaving ? null : onSave,
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : const Text('Simpan Inspeksi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
