import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/antrean.dart';

class FormScreen extends StatefulWidget {
  final Antrean? antrean;
  final int? nextNomorAntrean;
  final Function(Antrean, PlatformFile)? onSave;

  const FormScreen({
    super.key,
    this.antrean,
    this.nextNomorAntrean,
    this.onSave,
  });

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  String nama = '';
  String layanan = '';
  DateTime? pickupTime;
  PlatformFile? pickedFile;

  @override
  void initState() {
    super.initState();
    if (widget.antrean != null) {
      final antrean = widget.antrean!;
      nama = antrean.nama;
      layanan = antrean.layanan;
      pickupTime = antrean.pickupTime;
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate() &&
        pickupTime != null &&
        pickedFile != null) {
      _formKey.currentState!.save();

      final antrean = Antrean(
        id: widget.antrean?.id ?? '',
        nama: nama,
        layanan: layanan,
        pickupTime: pickupTime!,
        fileName: pickedFile!.name,
        nomorAntrean:
            widget.nextNomorAntrean ?? DateTime.now().millisecondsSinceEpoch,
      );

      final onSave = widget.onSave;
      if (onSave != null) {
        onSave(antrean, pickedFile!);
      }

      if (!mounted) return;
      Navigator.pop(context);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data dan pilih file')),
      );
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Antrean')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: nama,
                decoration: const InputDecoration(labelText: 'Nama'),
                onSaved: (value) => nama = value ?? '',
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                initialValue: layanan,
                decoration: const InputDecoration(labelText: 'Layanan'),
                onSaved: (value) => layanan = value ?? '',
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              Text(
                pickupTime == null
                    ? 'Pilih tanggal'
                    : 'Tanggal: ${pickupTime!.toLocal()}'.split(' ')[0],
              ),
              ElevatedButton(
                onPressed: _pickDate,
                child: const Text('Pilih Tanggal'),
              ),
              const SizedBox(height: 16),
              Text(
                pickedFile == null
                    ? 'Belum ada file'
                    : 'File: ${pickedFile!.name}',
              ),
              ElevatedButton(
                onPressed: _pickFile,
                child: const Text('Pilih File'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _submit, child: const Text('Simpan')),
            ],
          ),
        ),
      ),
    );
  }
}
