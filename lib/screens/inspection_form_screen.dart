import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../models/customer.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
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

  String? _dlpd;
  String? _hasilPeriksa;
  String? _tindakLanjut;
  String? _keterangan;
  DateTime? _installationDate;
  XFile? _photo;

  TextEditingController _c(String name) => _controllers[name]!;

  LatLng get _targetLocation =>
      LatLng(widget.customer.latitude, widget.customer.longitude);

  LatLng? get _officerLocation {
    final position = _officerPosition;
    if (position == null) return null;
    return LatLng(position.latitude, position.longitude);
  }

  @override
  void initState() {
    super.initState();

    final customer = widget.customer;
    _controllers.addAll({
      'idpel': TextEditingController(text: customer.idpel),
      'thbl': TextEditingController(text: customer.thbl),
      'nama': TextEditingController(text: customer.nama),
      'alamat': TextEditingController(text: customer.alamat),
      'unitup': TextEditingController(text: customer.unitup),
      'unitupi': TextEditingController(text: customer.unitupi),
      'unitap': TextEditingController(text: customer.unitap),
      'daya': TextEditingController(text: customer.daya),
      'tarif': TextEditingController(text: customer.tarif),
      'kriteria': TextEditingController(text: customer.kriteria),
      'kode_gardu': TextEditingController(text: customer.kodeGardu),
      'no_tiang': TextEditingController(text: customer.noTiang),
      'kddk': TextEditingController(text: customer.kddk),
      'nomor_meter': TextEditingController(text: customer.nomorMeter),
      'merek_meter': TextEditingController(),
      'thn_buat_meter': TextEditingController(),
      'krn': TextEditingController(),
      'tglpasang_kwh': TextEditingController(),
      'jenis_mk': TextEditingController(),
      'jml_p2tl': TextEditingController(),
      'beli_token_akhir': TextEditingController(),
      'jml_ct': TextEditingController(),
      'koordinat_x': TextEditingController(
        text: customer.latitude.toStringAsFixed(6),
      ),
      'koordinat_y': TextEditingController(
        text: customer.longitude.toStringAsFixed(6),
      ),
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
            _locationMessage = 'Pembaruan lokasi terhenti. Tekan "Perbarui" untuk mencoba lagi.';
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
          backgroundColor: error ? AppColors.danger : AppColors.ink,
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
      appBar: AppBar(
        leading: BackButton(onPressed: _cancel),
        titleSpacing: 0,
        title: const Text(
          'Belum Dikerjakan Form',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Tooltip(
            message: 'Logo instansi',
            child: Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                color: AppColors.toskaTint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.bolt,
                color: AppColors.toskaDark,
                size: 23,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            const _FormNotice(),
            const SizedBox(height: 14),
            _buildCustomerSection(),
            const SizedBox(height: 14),
            _buildMeterSection(),
            const SizedBox(height: 14),
            _buildInspectionSection(),
            const SizedBox(height: 14),
            _buildLocationSection(),
          ],
        ),
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
      title: 'Data Pelanggan',
      subtitle: 'Terisi otomatis dari sistem • tidak dapat diubah',
      children: [
        _textField('idpel', label: 'IDPEL', required: true, readOnly: true),
        _textField('thbl', label: 'THBL', required: true, readOnly: true),
        _textField('nama', label: 'NAMA', required: true, readOnly: true),
        _textField(
          'alamat',
          label: 'ALAMAT',
          required: true,
          readOnly: true,
          maxLines: 2,
        ),
        _textField('unitup', label: 'UNITUP', required: true, readOnly: true),
        _textField('unitupi', label: 'UNITUPI', required: true, readOnly: true),
        _textField('unitap', label: 'UNITAP', required: false, readOnly: true),
        _textField(
          'daya',
          label: 'DAYA',
          required: true,
          readOnly: true,
          keyboardType: TextInputType.number,
        ),
        _textField('tarif', label: 'TARIF', required: false, readOnly: true),
        _textField(
          'kriteria',
          label: 'KRITERIA',
          required: false,
          readOnly: true,
        ),
        _textField(
          'kode_gardu',
          label: 'KODE GARDU',
          required: false,
          readOnly: true,
        ),
        _textField(
          'no_tiang',
          label: 'NO TIANG',
          required: false,
          readOnly: true,
        ),
        _textField('kddk', label: 'KDDK', required: false, readOnly: true),
      ],
    );
  }

  Widget _buildMeterSection() {
    return FormSectionCard(
      icon: Icons.electric_meter_outlined,
      title: 'Data Teknis Meteran',
      subtitle: 'Data meter dan kWh prasambung',
      children: [
        _textField(
          'nomor_meter',
          label: 'NOMOR METER',
          required: true,
          readOnly: true,
        ),
        _textField(
          'merek_meter',
          label: 'MEREK METER',
          hint: 'Contoh: Itron / Hexing',
        ),
        _textField(
          'thn_buat_meter',
          label: 'THN BUAT METER',
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
        TextFormField(
          controller: _c('tglpasang_kwh'),
          readOnly: true,
          keyboardType: TextInputType.datetime,
          onTap: _pickInstallationDate,
          validator: _requiredValidator,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          decoration: _decoration(
            label: 'TGL PASANG KWH',
            required: true,
            hint: 'Pilih tanggal',
            fillColor: AppColors.surface,
            suffixIcon: IconButton(
              tooltip: 'Pilih tanggal',
              onPressed: _pickInstallationDate,
              icon: const Icon(
                Icons.calendar_today,
                size: 19,
                color: AppColors.toskaDark,
              ),
            ),
          ),
        ),
        _textField('jenis_mk', label: 'JENIS MK', hint: 'Contoh: Prabayar'),
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

  Widget _buildInspectionSection() {
    return FormSectionCard(
      icon: Icons.fact_check_outlined,
      title: 'Hasil Inspeksi Lapangan',
      subtitle: 'Diisi oleh petugas saat pemeriksaan',
      children: [
        DropdownButtonFormField<String>(
          initialValue: _dlpd,
          isExpanded: true,
          decoration: _decoration(label: 'DLPD', hint: 'Pilih kode DLPD'),
          items: [
            for (final code in _dlpdOptions)
              DropdownMenuItem(value: code, child: Text(code)),
          ],
          onChanged: (value) => setState(() => _dlpd = value),
        ),
        _segmentedField(
          fieldKey: 'hasil_periksa_field',
          label: 'HASIL PERIKSA',
          options: const ['Normal', 'P2TL'],
          value: _hasilPeriksa,
          onChanged: (value) => setState(() => _hasilPeriksa = value),
        ),
        _segmentedField(
          fieldKey: 'tindak_lanjut_field',
          label: 'TINDAK LANJUT',
          options: const ['Penyegelan Ulang', 'Pemutusan Sementara'],
          value: _tindakLanjut,
          onChanged: (value) => setState(() => _tindakLanjut = value),
          compactLabels: true,
        ),
        PhotoFormField(
          onChanged: (photo) => _photo = photo,
          validator: (value) {
            if (value == null) return 'Foto wajib diambil dari kamera.';
            return null;
          },
        ),
        DropdownButtonFormField<String>(
          initialValue: _keterangan,
          isExpanded: true,
          validator: (value) =>
              value == null ? 'Keterangan wajib dipilih.' : null,
          decoration: _decoration(
            label: 'KETERANGAN',
            required: true,
            hint: 'Pilih status keterangan',
          ),
          items: [
            for (final status in _keteranganOptions)
              DropdownMenuItem(value: status, child: Text(status)),
          ],
          onChanged: (value) => setState(() => _keterangan = value),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    final officerLocation = _officerLocation;

    return FormSectionCard(
      icon: Icons.location_searching,
      title: 'Pelacakan Lokasi',
      subtitle: 'Koordinat target dan posisi GPS petugas',
      children: [
        _textField(
          'koordinat_x',
          label: 'KOORDINAT X',
          required: true,
          readOnly: true,
          keyboardType: TextInputType.number,
          hint: 'Latitude awal',
        ),
        _textField(
          'koordinat_y',
          label: 'KOORDINAT Y',
          required: true,
          readOnly: true,
          keyboardType: TextInputType.number,
          hint: 'Longitude awal',
        ),
        const RequiredFieldLabel(
          label: 'LOKASI PETA',
          helper: 'Pratinjau lokasi target pelanggan',
        ),
        const SizedBox(height: 8),
        FieldMap(
          center: _targetLocation,
          pins: [
            MapPin(
              id: 'target',
              position: _targetLocation,
              title: widget.customer.nama,
              snippet: widget.customer.alamat,
            ),
          ],
        ),
        Row(
          children: [
            const Expanded(
              child: RequiredFieldLabel(
                label: 'LOKASI PETUGAS',
                helper: 'Dipusatkan dari GPS perangkat secara real-time',
              ),
            ),
            if (_officerPosition != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.toskaTint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LiveDot(),
                    SizedBox(width: 5),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        color: AppColors.toskaDark,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        FieldMap(
          center: officerLocation ?? _targetLocation,
          pins: [
            if (officerLocation != null)
              MapPin(
                id: 'petugas',
                position: officerLocation,
                title: 'Posisi petugas',
                snippet:
                    'Akurasi ±${_officerPosition!.accuracy.toStringAsFixed(0)} m',
                color: Colors.blue,
              ),
          ],
        ),
        if (_isLocating)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(minHeight: 2),
          ),
        if (_locationMessage != null)
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5E6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF0D7AB)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 17,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    _locationMessage!,
                    style: const TextStyle(
                      color: AppColors.warning,
                      fontSize: 11.5,
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
          keyboardType: TextInputType.number,
          hint: _isLocating
              ? 'Mengambil lokasi GPS...'
              : 'Otomatis terisi dari GPS perangkat',
          helper: 'Titik aktual petugas saat inspeksi dilakukan.',
        ),
        if (_officerPosition != null)
          Text(
            'Akurasi GPS ±${_officerPosition!.accuracy.toStringAsFixed(0)} meter',
            style: const TextStyle(color: AppColors.muted, fontSize: 11),
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
    return TextFormField(
      controller: _c(name),
      readOnly: readOnly,
      maxLines: maxLines,
      minLines: 1,
      keyboardType: keyboardType,
      inputFormatters: numericOnly
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      validator: required ? _requiredValidator : null,
      style: TextStyle(
        color: AppColors.ink,
        fontSize: 14,
        fontWeight: readOnly ? FontWeight.w500 : FontWeight.w600,
        height: 1.35,
      ),
      decoration: _decoration(
        label: label,
        required: required,
        hint: hint,
        helper: helper,
        fillColor: readOnly ? AppColors.readOnlyFill : AppColors.surface,
      ),
    );
  }

  Widget _segmentedField({
    required String fieldKey,
    required String label,
    required List<String> options,
    required String? value,
    required ValueChanged<String> onChanged,
    bool compactLabels = false,
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
            const SizedBox(height: 9),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                segments: [
                  for (final option in options)
                    ButtonSegment<String>(
                      value: option,
                      label: Text(
                        option,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: compactLabels ? 11.2 : 12.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
                selected: value == null ? const <String>{} : {value},
                emptySelectionAllowed: true,
                showSelectedIcon: false,
                expandedInsets: EdgeInsets.zero,
                onSelectionChanged: (selection) {
                  if (selection.isEmpty) return;
                  onChanged(selection.first);
                  field.didChange(selection.first);
                },
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                  ),
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.toskaDark;
                    }
                    return AppColors.muted;
                  }),
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.toskaTint;
                    }
                    return AppColors.surface;
                  }),
                  side: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return const BorderSide(color: AppColors.toska);
                    }
                    return const BorderSide(color: AppColors.border);
                  }),
                ),
              ),
            ),
            if (field.errorText != null) ...[
              const SizedBox(height: 7),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  field.errorText!,
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  InputDecoration _decoration({
    required String label,
    bool required = false,
    String? hint,
    String? helper,
    Color fillColor = AppColors.surface,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      label: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: label),
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ),
      ),
      hintText: hint,
      helperText: helper,
      helperMaxLines: 2,
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

class _FormNotice extends StatelessWidget {
  const _FormNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.toskaTint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.toska.withValues(alpha: 0.15)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.toskaDark, size: 19),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Lengkapi seluruh field bertanda (*). Data pelanggan dan meteran '
              'diisi otomatis oleh sistem.',
              style: TextStyle(
                color: AppColors.toskaDark,
                fontSize: 12,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
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
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isSaving ? null : onCancel,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: isSaving ? null : onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.toska,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.toska.withValues(
                      alpha: 0.5,
                    ),
                    elevation: 0,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveDot extends StatelessWidget {
  const _LiveDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: AppColors.toska,
        shape: BoxShape.circle,
      ),
    );
  }
}
