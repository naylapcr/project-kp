/// Inspection state shown on the monitoring dashboard and map sheet.
enum CustomerStatus {
  pending('Belum Dikerjakan', 'Tertunda'),
  completed('Selesai Diperiksa', 'Selesai'),
  followUp('Perlu Tindak Lanjut', 'Tindak Lanjut');

  const CustomerStatus(this.label, this.shortLabel);

  final String label;
  final String shortLabel;
}

/// A customer record shown to field officers.
///
/// Values in this model mirror the customer section of the inspection form.
/// Coordinates represent the registered meter/target location.
class Customer {
  const Customer({
    required this.idpel,
    required this.thbl,
    required this.nama,
    required this.alamat,
    required this.unitup,
    required this.unitupi,
    required this.unitap,
    required this.daya,
    required this.tarif,
    required this.kriteria,
    required this.kodeGardu,
    required this.noTiang,
    required this.kddk,
    required this.nomorMeter,
    required this.latitude,
    required this.longitude,
    this.status = CustomerStatus.pending,
  });

  final String idpel;
  final String thbl;
  final String nama;
  final String alamat;
  final String unitup;
  final String unitupi;
  final String unitap;
  final String daya;
  final String tarif;
  final String kriteria;
  final String kodeGardu;
  final String noTiang;
  final String kddk;
  final String nomorMeter;
  final double latitude;
  final double longitude;
  final CustomerStatus status;

  Customer copyWith({CustomerStatus? status}) {
    return Customer(
      idpel: idpel,
      thbl: thbl,
      nama: nama,
      alamat: alamat,
      unitup: unitup,
      unitupi: unitupi,
      unitap: unitap,
      daya: daya,
      tarif: tarif,
      kriteria: kriteria,
      kodeGardu: kodeGardu,
      noTiang: noTiang,
      kddk: kddk,
      nomorMeter: nomorMeter,
      latitude: latitude,
      longitude: longitude,
      status: status ?? this.status,
    );
  }
}
