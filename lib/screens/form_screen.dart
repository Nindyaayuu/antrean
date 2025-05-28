import 'package:flutter/material.dart';
import '../models/antrean.dart';

class FormScreen extends StatefulWidget {
  final Antrean? antrean;
  final void Function(Antrean) onSave;
  final int nextNomorAntrean;

  const FormScreen({
    super.key,
    this.antrean,
    required this.onSave,
    required this.nextNomorAntrean,
  });

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  late TextEditingController namaController;
  late TextEditingController layananController;

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.antrean?.nama ?? '');
    layananController = TextEditingController(
      text: widget.antrean?.layanan ?? '',
    );
  }

  void simpanAntrean() {
    final antrean = Antrean(
      nama: namaController.text,
      layanan: layananController.text,
      pickupTime: DateTime.now(),
      fileName: '',
      nomorAntrean: widget.nextNomorAntrean,
    );

    widget.onSave(antrean);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Form Antrean')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: namaController,
              decoration: InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: layananController,
              decoration: InputDecoration(labelText: 'Layanan'),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: simpanAntrean, child: Text('Simpan')),
          ],
        ),
      ),
    );
  }
}
