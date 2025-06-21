import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/antrean.dart';
import '../services/supabase_service.dart';
import '../widgets/form_dialog.dart';
import 'login_screen.dart';

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
      await loadAntrean();
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
      await loadAntrean();
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
            title: const Text('Tandai Selesai'),
            content: const Text('Apakah antrean ini sudah selesai?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  hapusAntrean(index);
                },
                child: const Text('Selesai'),
              ),
            ],
          ),
    );
  }

  void _showFormDialog({Antrean? data, int? nomor}) {
    showDialog(
      context: context,
      builder:
          (_) => FormDialog(
            initialData: data,
            nextNomorAntrean: nomor,
            onSave: (antrean, file) async {
              if (data == null) {
                await tambahAntreanBaru(antrean, file);
              } else {
                final index = antreanList.indexWhere((a) => a.id == data.id);
                if (index != -1) {
                  await updateAntrean(antrean, file, index);
                }
              }
            },
          ),
    );
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Antrean'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: antreanList.length,
        itemBuilder: (context, index) {
          final antrean = antreanList[index];
          return ListTile(
            title: Text('${antrean.nama} (${antrean.layanan})'),
            subtitle: Text(
              'Antrean #${antrean.nomorAntrean} • File: ${antrean.fileName}\nTanggal: ${antrean.pickupTime.toLocal().toIso8601String().split("T")[0]}',
            ),
            isThreeLine: true,
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showFormDialog(data: antrean);
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
          _showFormDialog(nomor: antreanList.length + 1);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
