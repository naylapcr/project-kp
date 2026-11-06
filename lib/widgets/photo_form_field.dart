import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_theme.dart';

/// Camera-only photo capture required by the field inspection SOP.
class PhotoFormField extends StatefulWidget {
  const PhotoFormField({super.key, this.onChanged, this.validator});

  final ValueChanged<XFile?>? onChanged;
  final FormFieldValidator<XFile?>? validator;

  @override
  State<PhotoFormField> createState() => _PhotoFormFieldState();
}

class _PhotoFormFieldState extends State<PhotoFormField> {
  final GlobalKey<FormFieldState<XFile?>> _fieldKey =
      GlobalKey<FormFieldState<XFile?>>();
  final ImagePicker _picker = ImagePicker();

  XFile? _photo;
  Uint8List? _photoBytes;
  bool _isPicking = false;

  Future<void> _takePhoto() async {
    if (_isPicking) return;
    setState(() => _isPicking = true);

    try {
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1600,
        imageQuality: 82,
        requestFullMetadata: false,
      );

      if (photo == null) return;
      final bytes = await photo.readAsBytes();
      if (!mounted) return;

      setState(() {
        _photo = photo;
        _photoBytes = bytes;
      });
      _fieldKey.currentState?.didChange(photo);
      widget.onChanged?.call(photo);
    } on PlatformException catch (error) {
      if (!mounted) return;
      final isDenied =
          error.code.toLowerCase().contains('denied') ||
          error.code.toLowerCase().contains('permission');
      _showMessage(
        isDenied
            ? 'Akses kamera ditolak. Aktifkan izin kamera dari pengaturan aplikasi.'
            : 'Kamera tidak dapat dibuka. Silakan coba lagi.',
      );
    } catch (_) {
      if (!mounted) return;
      _showMessage('Kamera tidak tersedia pada perangkat ini.');
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  void _removePhoto() {
    setState(() {
      _photo = null;
      _photoBytes = null;
    });
    _fieldKey.currentState?.didChange(null);
    widget.onChanged?.call(null);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return FormField<XFile?>(
      key: _fieldKey,
      validator:
          widget.validator ??
          (value) {
            if (value == null) return 'Foto wajib diambil dari kamera.';
            return null;
          },
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Foto wajib diambil langsung melalui kamera aplikasi. '
              'Akses galeri dinonaktifkan demi integritas & keaslian data '
              'audit lapangan.',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 10),
            Material(
              color: _photo == null
                  ? AppColors.surfaceContainerLow
                  : AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.md),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                key: const ValueKey('photo-camera-field'),
                onTap: _isPicking ? null : _takePhoto,
                child: _photo == null
                    ? _CameraPrompt(isLoading: _isPicking)
                    : _PhotoPreview(
                        bytes: _photoBytes,
                        isLoading: _isPicking,
                        onRemove: _removePhoto,
                      ),
              ),
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
}

class _CameraPrompt extends StatelessWidget {
  const _CameraPrompt({required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      width: double.infinity,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              shape: BoxShape.circle,
            ),
            child: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(15),
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                : const Icon(
                    Icons.photo_camera_outlined,
                    color: AppColors.secondary,
                    size: 25,
                  ),
          ),
          const SizedBox(height: 10),
          Text(
            isLoading ? 'Membuka kamera...' : 'Ambil Foto',
            style: AppTypography.labelLg.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Kamera aktif • galeri dinonaktifkan',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({
    required this.bytes,
    required this.isLoading,
    required this.onRemove,
  });

  final Uint8List? bytes;
  final bool isLoading;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (bytes != null)
            Image.memory(
              bytes!,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) => const ColoredBox(
                color: AppColors.surfaceContainerLow,
                child: Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            const ColoredBox(
              color: AppColors.surfaceContainerLow,
              child: Center(child: CircularProgressIndicator()),
            ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54],
                stops: [0.55, 1],
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 10,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.photo_camera,
                        size: 13,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Ganti foto',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: IconButton(
              tooltip: 'Hapus foto',
              onPressed: onRemove,
              icon: const Icon(Icons.close, size: 19),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.72),
                foregroundColor: AppColors.onPrimary,
                minimumSize: const Size(36, 36),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          if (isLoading)
            ColoredBox(
              color: Colors.black.withValues(alpha: 0.45),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
