import 'package:flutter/material.dart';
import '../models/antrean.dart';
import 'form_screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Antrean> antreanList = [
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

  void tambahAntreanBaru(Antrean antrean) {
    setState(() {
      antreanList.add(antrean);
    });
  }

  void editAntrean(int index, Antrean antreanBaru) {
    setState(() {
      antreanList[index] = antreanBaru;
    });
  }

  void hapusAntrean(int index) {
    setState(() {
      antreanList.removeAt(index);
    });
  }

  void tandaiSelesai(int index) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Tandai Selesai'),
            content: Text('Apakah antrean ini sudah selesai?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  hapusAntrean(index);
                },
                child: Text('Selesai'),
              ),
            ],
          ),
    );
  }

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
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => FormScreen(
                            antrean: antrean,
                            onSave: (updated) => editAntrean(index, updated),
                            nextNomorAntrean: antrean.nomorAntrean,
                          ),
                    ),
                  );
                } else if (value == 'selesai') {
                  tandaiSelesai(index);
                } else if (value == 'hapus') {
                  hapusAntrean(index);
                }
              },
              itemBuilder:
                  (_) => [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'selesai', child: Text('Selesai')),
                    PopupMenuItem(value: 'hapus', child: Text('Hapus')),
                  ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => FormScreen(
                    onSave: tambahAntreanBaru,
                    nextNomorAntrean: antreanList.length + 1,
                  ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
