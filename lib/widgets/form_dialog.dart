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
  String? layanan;
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

  void _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: pickupTime ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.pink.shade300,
              onPrimary: Colors.white,
              onSurface: Colors.pink.shade800,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.pink),
            ),
          ),
          child: child!,
        );
      },
    );
    if (result != null) {
      setState(() {
        pickupTime = result;
      });
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

  void _submit() {
    if (_formKey.currentState!.validate() && pickupTime != null) {
      _formKey.currentState!.save();

      final PlatformFile fileToSave =
          pickedFile ??
          PlatformFile(
            name: widget.initialData?.fileName ?? 'unknown',
            size: 0,
            bytes: null,
          );

      final antrean = Antrean(
        id: widget.initialData?.id ?? '',
        nama: nama,
        layanan: layanan!,
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
      backgroundColor: Colors.pink.shade50,
      title: Text(
        widget.initialData == null ? 'Tambah Antrean' : 'Edit Antrean',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // NAMA
              TextFormField(
                initialValue: nama,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  filled: true,
                  fillColor: Colors.pink.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSaved: (value) => nama = value ?? '',
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              // LAYANAN DROPDOWN
              DropdownButtonFormField<String>(
                value: layanan,
                items:
                    layananList
                        .map(
                          (item) =>
                              DropdownMenuItem(value: item, child: Text(item)),
                        )
                        .toList(),
                onChanged: (value) => setState(() => layanan = value),
                decoration: InputDecoration(
                  labelText: 'Layanan',
                  filled: true,
                  fillColor: Colors.pink.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Wajib dipilih' : null,
              ),
              const SizedBox(height: 12),

              // TANGGAL
              Row(
                children: [
                  Expanded(
                    child: Text(
                      pickupTime == null
                          ? 'Belum pilih tanggal'
                          : 'Tanggal: ${pickupTime!.toLocal().toIso8601String().split("T")[0]}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.pink.shade100,
                    ),
                    onPressed: _pickDate,
                    child: const Text('Pilih Tanggal'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // FILE PICKER
              Row(
                children: [
                  Expanded(
                    child: Text(
                      pickedFile != null
                          ? 'File: ${pickedFile!.name}'
                          : (widget.initialData?.fileName != null
                              ? 'File lama: ${widget.initialData!.fileName}'
                              : 'Belum pilih file'),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.pink.shade100,
                    ),
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
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink.shade300,
          ),
          onPressed: _submit,
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
