class Antrean {
  final String id;
  final String nama;
  final String layanan;
  final DateTime pickupTime;
  final String fileName;
  final int nomorAntrean;

  Antrean({
    required this.id,
    required this.nama,
    required this.layanan,
    required this.pickupTime,
    required this.fileName,
    required this.nomorAntrean,
  });

  factory Antrean.fromMap(Map<String, dynamic> map) {
    return Antrean(
      id:
          map['id']
              .toString(), // id bisa berupa int (dari Supabase auto-increment)
      nama: map['nama'] ?? '',
      layanan: map['layanan'] ?? '',
      pickupTime: DateTime.parse(map['pickup_time']),
      fileName: map['file_name'] ?? '',
      nomorAntrean:
          map['nomor_antrean'] is int
              ? map['nomor_antrean']
              : int.tryParse(map['nomor_antrean'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'layanan': layanan,
      'pickup_time': pickupTime.toIso8601String(),
      'file_name': fileName,
      'nomor_antrean': nomorAntrean,
    };
  }
}
