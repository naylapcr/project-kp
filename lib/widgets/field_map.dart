import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../theme/app_theme.dart';

/// Google Maps is currently rendered natively on Android and iOS.
///
/// Other targets (including widget tests and desktop) receive a lightweight
/// visual fallback so the rest of the form remains usable.
bool get isNativeMapSupported =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

class MapPin {
  const MapPin({
    required this.id,
    required this.position,
    required this.title,
    this.snippet,
    this.color = AppColors.secondary,
  });

  final String id;
  final LatLng position;
  final String title;
  final String? snippet;
  final Color color;
}

/// A small, reusable Google Map frame with a non-native fallback.
class FieldMap extends StatefulWidget {
  const FieldMap({
    super.key,
    required this.center,
    this.height = 170,
    this.zoom = 16,
    this.pins = const [],
    this.interactive = false,
    this.onMapCreated,
    this.onPinTap,
  });

  final LatLng center;
  final double height;
  final double zoom;
  final List<MapPin> pins;
  final bool interactive;
  final ValueChanged<GoogleMapController>? onMapCreated;
  final ValueChanged<MapPin>? onPinTap;

  @override
  State<FieldMap> createState() => _FieldMapState();
}

class _FieldMapState extends State<FieldMap> {
  GoogleMapController? _controller;

  @override
  void didUpdateWidget(covariant FieldMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final centerChanged =
        widget.center.latitude != oldWidget.center.latitude ||
        widget.center.longitude != oldWidget.center.longitude;
    if (centerChanged && _controller != null) {
      _controller!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: widget.center, zoom: widget.zoom),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isNativeMapSupported) {
      return MapFallback(
        pins: widget.pins,
        height: widget.height,
        center: widget.center,
      );
    }

    final markers = <Marker>{
      for (final pin in widget.pins)
        Marker(
          markerId: MarkerId(pin.id),
          position: pin.position,
          infoWindow: InfoWindow(title: pin.title, snippet: pin.snippet),
          icon: BitmapDescriptor.defaultMarkerWithHue(_hueFor(pin.color)),
          onTap: widget.onPinTap == null ? null : () => widget.onPinTap!(pin),
        ),
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: widget.center,
            zoom: widget.zoom,
          ),
          markers: markers,
          onMapCreated: (controller) {
            _controller = controller;
            widget.onMapCreated?.call(controller);
          },
          liteModeEnabled: !widget.interactive,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          myLocationButtonEnabled: false,
          compassEnabled: false,
          scrollGesturesEnabled: widget.interactive,
          zoomGesturesEnabled: widget.interactive,
          rotateGesturesEnabled: false,
          tiltGesturesEnabled: false,
        ),
      ),
    );
  }

  double _hueFor(Color color) {
    if (color == AppColors.tertiary) return BitmapDescriptor.hueOrange;
    if (color == AppColors.error) return BitmapDescriptor.hueRed;
    if (color == AppColors.primary) return BitmapDescriptor.hueViolet;
    return BitmapDescriptor.hueAzure;
  }
}

/// A stylised map placeholder used when the native map SDK is unavailable.
class MapFallback extends StatelessWidget {
  const MapFallback({
    super.key,
    required this.pins,
    required this.height,
    required this.center,
  });

  final List<MapPin> pins;
  final double height;
  final LatLng center;

  @override
  Widget build(BuildContext context) {
    final primaryPin = pins.isEmpty ? null : pins.first;

    return Container(
      height: height,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.secondaryFixed, AppColors.surfaceContainer],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: CustomPaint(painter: _MapPatternPainter()),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.card,
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: AppColors.secondary,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 8),
                if (primaryPin != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest.withValues(
                        alpha: 0.94,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Text(
                      primaryPin.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            left: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                '${center.latitude.toStringAsFixed(5)}, '
                '${center.longitude.toStringAsFixed(5)}',
                style: AppTypography.codeData.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          Positioned(
            right: 10,
            top: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                'PETA',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.onPrimary,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPatternPainter extends CustomPainter {
  const _MapPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    const gap = 34.0;

    for (var x = -size.height; x < size.width + size.height; x += gap) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        gridPaint,
      );
    }

    for (var y = 0.0; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.72)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final road = Path()
      ..moveTo(-20, size.height * 0.7)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.58,
        size.width * 0.58,
        size.height * 0.88,
        size.width + 20,
        size.height * 0.58,
      );
    canvas.drawPath(road, roadPaint);

    final secondaryRoadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    final secondaryRoad = Path()
      ..moveTo(size.width * 0.3, -20)
      ..lineTo(size.width * 0.45, size.height + 20);
    canvas.drawPath(secondaryRoad, secondaryRoadPaint);
  }

  @override
  bool shouldRepaint(covariant _MapPatternPainter oldDelegate) => false;
}
