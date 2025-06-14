import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // <-- Tambahkan ini
import '../models/antrean.dart';
import '../services/supabase_service.dart';
import 'form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Antrean> antreanList = [];

  @override
  void initState() {
    super.initState();
    loadAntrean();
  }

  Future<void> loadAntrean() async {
    final data = await supabaseService.fetchAntrean();
    debugPrint("DATA TERAMBIL: ${data.length}");
    for (var item in data) {
      debugPrint(
        "Nama: ${item.nama}, File: ${item.fileName}, Pickup: ${item.pickupTime}",
      );
    }
    setState(() {
      antreanList = data;
    });
  }

  Future<void> tambahAntreanBaru(Antrean antrean, PlatformFile file) async {
    final result = await supabaseService.tambahAntrean(antrean, file);
    if (result) {
      loadAntrean();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menambahkan antrean')),
      );
    }
  }

  Future<void> updateAntrean(
    Antrean antrean,
    PlatformFile file,
    int index,
  ) async {
    final result = await supabaseService.editAntreanWithFile(antrean, file);
    if (result) {
      loadAntrean();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal mengedit antrean')));
    }
  }

  Future<void> hapusAntrean(int index) async {
    final id = antreanList[index].nomorAntrean;

    final result = await supabaseService.hapusAntrean(id);
    if (result) {
      setState(() {
        antreanList.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus antrean dari server')),
      );
    }
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
                            onSave:
                                (updated, file) =>
                                    updateAntrean(updated, file, index),
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
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(
                      value: 'selesai',
                      child: Text('Selesai'),
                    ),
                    const PopupMenuItem(value: 'hapus', child: Text('Hapus')),
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
