class Antrean {
  int? id;
  String nama;
  String layanan;
  DateTime pickupTime;
  String fileName;
  int nomorAntrean;
  String status;

  Antrean({
    this.id,
    required this.nama,
    required this.layanan,
    required this.pickupTime,
    required this.fileName,
    required this.nomorAntrean,
    this.status = 'Menunggu',
  });
}
