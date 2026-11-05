# Inspeksi Lapangan

Aplikasi mobile operasional petugas lapangan: monitoring pelanggan, formulir
inspeksi, kamera bukti, GPS real-time, dan peta pelanggan.

## Fitur

- **Monitoring** – daftar pelanggan, pencarian berdasarkan nama/IDPEL/alamat,
  refresh data, tombol edit inspeksi, dan akses cepat ke peta.
- **Maps** – peta pelanggan (Google Maps), fokus ke pelanggan yang dipilih,
  dan tombol lokasi petugas. Ada tampilan fallback untuk desktop/web.
- **Formulir inspeksi** "Belum Dikerjakan Form":
  - Data pelanggan dan meteran terisi otomatis (read-only).
  - Validasi wajib untuk semua field bertanda `*`.
  - Foto hanya dapat diambil melalui kamera (galeri tidak tersedia).
  - Titik koordinat petugas terisi otomatis dari GPS dan diperbarui real-time.
  - Pratinjau peta lokasi target dan posisi petugas.
  - Tombol **Save** tidak akan memproses data jika field wajib atau hasil
    inspeksi (`hasil_periksa`, `tindak_lanjut`, `foto`, `keterangan`,
    `titik_koordinat`) belum lengkap.

## Menjalankan

```bash
flutter pub get
flutter run
```

Target utama: Android dan iOS.

## Konfigurasi Google Maps (wajib untuk peta asli)

Aplikasi tidak menyertakan API key produksi. Tanpa key, tab Maps dan pratinjau
peta di perangkat mobile tidak akan menampilkan peta Google.

1. Aktifkan **Maps SDK for Android** dan **Maps SDK for iOS** di Google Cloud
   Console, lalu buat API key dengan pembatasan aplikasi.
2. **Android** – tambahkan key ke `android/local.properties` (file ini tidak
   di-commit):

   ```properties
   MAPS_API_KEY=AIza...
   ```

   Alternatif: set environment variable `MAPS_API_KEY` atau jalankan Gradle
   dengan `-PMAPS_API_KEY=AIza...`. Key dipakai oleh `AndroidManifest.xml`
   melalui manifest placeholder di `android/app/build.gradle.kts`.
3. **iOS** – ganti `YOUR_GOOGLE_MAPS_API_KEY` pada key
   `GOOGLE_MAPS_API_KEY` di `ios/Runner/Info.plist`, lalu jalankan
   `pod install` di folder `ios`.

## Izin platform

- GPS: `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION` (Android) dan
  `NSLocationWhenInUseUsageDescription` (iOS).
- Kamera: `CAMERA` (Android) dan `NSCameraUsageDescription` (iOS).
- Internet untuk Google Maps.

Izin GPS dan kamera diminta saat fitur terkait pertama kali digunakan.

## Struktur utama

```text
lib/
├── app.dart
├── main.dart
├── data/mock_customers.dart
├── models/customer.dart
├── screens/
│   ├── home_shell.dart
│   ├── monitoring_screen.dart
│   ├── customer_search_delegate.dart
│   ├── customer_map_screen.dart
│   └── inspection_form_screen.dart
├── services/location_service.dart
├── theme/app_theme.dart
└── widgets/
    ├── customer_card.dart
    ├── field_map.dart
    ├── form_section_card.dart
    └── photo_form_field.dart
```

Data pelanggan masih berasal dari `lib/data/mock_customers.dart`. Ganti sumber
tersebut dengan API layanan lapangan dan sambungkan proses simpan pada method
`_save()` di `lib/screens/inspection_form_screen.dart`.

## Pemeriksaan kualitas

```bash
flutter analyze
flutter test
```
