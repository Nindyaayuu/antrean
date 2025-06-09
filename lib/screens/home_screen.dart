import 'package:flutter/material.dart';
import '../models/antrean.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final List<Antrean> antreanList = [
    Antrean(
      nama: 'Budi',
      layanan: 'Cetak Kartu Nama',
      pickupTime: DateTime.now(),
      fileName: 'kartu_nama.pdf',
      nomorAntrean: 1,
    ),
    Antrean(
      nama: 'Sari',
      layanan: 'Cetak Spanduk',
      pickupTime: DateTime.now(),
      fileName: 'spanduk.cdr',
      nomorAntrean: 2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daftar Antrean')),
      body: ListView.builder(
        itemCount: antreanList.length,
        itemBuilder: (context, index) {
          final antrean = antreanList[index];
          return ListTile(
            title: Text('${antrean.nama} (${antrean.layanan})'),
            subtitle: Text(
              'Antrean #${antrean.nomorAntrean} - File: ${antrean.fileName}',
            ),
          );
        },
      ),
    );
  }
}
