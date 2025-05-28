import 'package:flutter/material.dart';
import '../models/antrean.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

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
  late DateTime selectedPickupTime;
  String selectedFileName = '';

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.antrean?.nama ?? '');
    layananController = TextEditingController(
      text: widget.antrean?.layanan ?? '',
    );
    selectedPickupTime = widget.antrean?.pickupTime ?? DateTime.now();
    selectedFileName = widget.antrean?.fileName ?? '';
  }

  void simpanAntrean() {
    final antrean = Antrean(
      nama: namaController.text,
      layanan: layananController.text,
      pickupTime: selectedPickupTime,
      fileName: selectedFileName,
      nomorAntrean: widget.nextNomorAntrean,
    );

    widget.onSave(antrean);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    namaController.dispose();
    layananController.dispose();
    super.dispose();
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
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Tanggal Ambil: ${DateFormat('yyyy-MM-dd').format(selectedPickupTime)}",
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedPickupTime,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => selectedPickupTime = picked);
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.attach_file),
              label: Text('Pilih File'),
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles();
                if (result != null) {
                  setState(() {
                    selectedFileName = result.files.single.name;
                  });
                }
              },
            ),
            if (selectedFileName.isNotEmpty) Text('File: $selectedFileName'),
            Spacer(),
            ElevatedButton(onPressed: simpanAntrean, child: Text('Simpan')),
          ],
        ),
      ),
    );
  }
}
