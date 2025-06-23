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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal menghapus antrean')));
    }
  }

  void tandaiSelesai(int index) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Colors.pink.shade50,
            title: const Text('Tandai Selesai'),
            content: const Text('Apakah antrean ini sudah selesai?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade300,
                ),
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
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        backgroundColor: Colors.pink.shade100,
        title: const Text('Daftar Antrean'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // 🖨️ Ikon printer lucu
          Icon(Icons.print, size: 64, color: Colors.pink.shade300),
          const SizedBox(height: 8),
          Text(
            'Selamat datang di Antrean Cetak!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.pink.shade300,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: antreanList.length,
              itemBuilder: (context, index) {
                final antrean = antreanList[index];
                return Card(
                  color: Colors.pink.shade100,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
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
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'selesai',
                              child: Text('Selesai'),
                            ),
                            const PopupMenuItem(
                              value: 'hapus',
                              child: Text('Hapus'),
                            ),
                          ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink.shade300,
        onPressed: () {
          _showFormDialog(nomor: antreanList.length + 1);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
