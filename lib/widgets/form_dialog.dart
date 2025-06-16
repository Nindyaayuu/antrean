import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/antrean.dart';

class FormDialog extends StatefulWidget {
  final int? nextNomorAntrean;
  final Function(Antrean, PlatformFile)? onSave;

  const FormDialog({super.key, this.nextNomorAntrean, this.onSave});

  @override
  State<FormDialog> createState() => _FormDialogState();
}

class _FormDialogState extends State<FormDialog> {
  final _formKey = GlobalKey<FormState>();
  String nama = '';
  String layanan = '';
  DateTime? pickupTime;
  PlatformFile? pickedFile;

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        pickedFile = result.files.first;
      });
    }
  }

  void _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
    if (_formKey.currentState!.validate() &&
        pickupTime != null &&
        pickedFile != null) {
      _formKey.currentState!.save();

      final antrean = Antrean(
        id: '',
        nama: nama,
        layanan: layanan,
        pickupTime: pickupTime!,
        fileName: pickedFile!.name,
        nomorAntrean:
            widget.nextNomorAntrean ?? DateTime.now().millisecondsSinceEpoch,
      );

      widget.onSave?.call(antrean, pickedFile!);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data dan pilih file')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Form Antrean'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nama'),
                onSaved: (value) => nama = value ?? '',
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Layanan'),
                onSaved: (value) => layanan = value ?? '',
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _pickDate,
                child: Text(
                  pickupTime == null
                      ? 'Pilih Tanggal'
                      : 'Tanggal: ${pickupTime!.toLocal()}'.split(' ')[0],
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _pickFile,
                child: Text(
                  pickedFile == null
                      ? 'Pilih File'
                      : 'File: ${pickedFile!.name}',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Simpan')),
      ],
    );
  }
}
