import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/antrean.dart';

class FormDialog extends StatefulWidget {
  final Antrean? initialData;
  final int? nextNomorAntrean;
  final Function(Antrean, PlatformFile)? onSave;

  const FormDialog({
    super.key,
    this.initialData,
    this.nextNomorAntrean,
    this.onSave,
  });

  @override
  State<FormDialog> createState() => _FormDialogState();
}

class _FormDialogState extends State<FormDialog> {
  final _formKey = GlobalKey<FormState>();
  String nama = '';
  String layanan = '';
  DateTime? pickupTime;
  PlatformFile? pickedFile;

  final List<String> layananList = [
    'PL PLOTTER',
    'BROSUR',
    'STIKER DTV UV',
    'PHOTOPAPAER',
    'CETAK POSTER BESAR',
    'INDOOR UV',
    'KALENDER',
    'KAIN',
    'KUPON / VOUCHER',
    'LANYARD',
    'STICKER CUTTING',
    'FOTO BESAR DAN FRAME',
    'FRONTLITE OUTDOOR',
    'JERSEY',
    'FOTO STUDIO',
    'SABLON DTF',
    'CETAK FOTO',
    'STEMPEL DLASH',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final antrean = widget.initialData!;
      nama = antrean.nama;
      layanan = antrean.layanan;
      pickupTime = antrean.pickupTime;
    }
  }

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        pickedFile = result.files.first;
      });
    }
  }

  void _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: pickupTime ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (result != null) {
      setState(() {
        pickupTime = result;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() && pickupTime != null) {
      _formKey.currentState!.save();

      final PlatformFile fileToSave =
          pickedFile ??
          PlatformFile(
            name: widget.initialData?.fileName ?? 'unknown.pdf',
            size: 0,
            bytes: null,
          );

      final antrean = Antrean(
        id: widget.initialData?.id ?? '',
        nama: nama,
        layanan: layanan,
        pickupTime: pickupTime!,
        fileName: fileToSave.name,
        nomorAntrean:
            widget.initialData?.nomorAntrean ?? widget.nextNomorAntrean!,
      );

      widget.onSave?.call(antrean, fileToSave);
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data dan tanggal')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialData == null ? 'Tambah Antrean' : 'Edit Antrean',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: nama,
                decoration: const InputDecoration(labelText: 'Nama'),
                onSaved: (value) => nama = value ?? '',
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: layanan.isNotEmpty ? layanan : null,
                decoration: const InputDecoration(labelText: 'Layanan'),
                items:
                    layananList
                        .map(
                          (item) =>
                              DropdownMenuItem(value: item, child: Text(item)),
                        )
                        .toList(),
                onChanged: (value) => setState(() => layanan = value ?? ''),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Pilih layanan' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      pickupTime == null
                          ? 'Belum pilih tanggal'
                          : 'Tanggal: ${pickupTime!.toLocal().toIso8601String().split("T")[0]}',
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Pilih Tanggal'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      pickedFile != null
                          ? 'File: ${pickedFile!.name}'
                          : (widget.initialData?.fileName != null
                              ? 'File lama: ${widget.initialData!.fileName}'
                              : 'Belum pilih file'),
                    ),
                  ),
                  TextButton(
                    onPressed: _pickFile,
                    child: const Text('Pilih File'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Simpan')),
      ],
    );
  }
}
