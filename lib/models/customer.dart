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
}
