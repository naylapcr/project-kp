import 'dart:async';

import 'package:geolocator/geolocator.dart';

class LocationFailure implements Exception {
  const LocationFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Thin wrapper around geolocator so the UI does not depend on plugin errors.
class LocationService {
  Future<Position> currentPosition() async {
    await _ensurePermission();
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 25),
        ),
      );
    } on TimeoutException {
      throw const LocationFailure(
        'GPS belum mendapatkan titik lokasi. Coba lagi di area terbuka.',
      );
    } on LocationServiceDisabledException {
      throw const LocationFailure(
        'Layanan lokasi perangkat tidak aktif. Aktifkan GPS terlebih dahulu.',
      );
    }
  }

  Future<Stream<Position>> livePositionStream() async {
    await _ensurePermission();
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    );
  }

  Future<void> _ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationFailure(
        'Layanan lokasi perangkat tidak aktif. Aktifkan GPS terlebih dahulu.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationFailure(
        'Izin lokasi ditolak permanen. Aktifkan izin lokasi melalui pengaturan aplikasi.',
      );
    }

    if (permission == LocationPermission.denied) {
      throw const LocationFailure(
        'Izin lokasi diperlukan untuk mengisi titik koordinat petugas.',
      );
    }
  }
}
