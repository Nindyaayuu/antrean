import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/antrean.dart';
import 'package:file_picker/file_picker.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  Future<bool> tambahAntrean(Antrean antrean, PlatformFile file) async {
    try {
      // Upload file ke Supabase Storage
      final fileBytes = file.bytes!;
      final fileName = '${const Uuid().v4()}_${file.name}';

      await supabase.storage
          .from('antrean-files')
          .uploadBinary(fileName, fileBytes);

      // Simpan data antrean ke Supabase Database
      await supabase.from('antrean').insert({
        'nama': antrean.nama,
        'layanan': antrean.layanan,
        'pickup_time': antrean.pickupTime.toIso8601String(),
        'file_name': fileName,
        'nomor_antrean': antrean.nomorAntrean,
      });

      return true;
    } catch (e) {
      debugPrint('Error tambahAntrean: $e');
      return false;
    }
  }

  Future<List<Antrean>> fetchAntrean() async {
    try {
      final response = await supabase
          .from('antrean')
          .select()
          .order('pickup_time', ascending: true);

      debugPrint("RESPON MURNI: $response");

      return (response as List).map((data) => Antrean.fromMap(data)).toList();
    } catch (e) {
      debugPrint('Error fetchAntrean: $e');
      return [];
    }
  }

  //Future<List<Antrean>> fetchAntrean() async {
  //final response = await supabase.from('antrean').select();

  //return (response as List).map((data) => Antrean.fromMap(data)).toList();
  //}

  Future<bool> hapusAntrean(int nomorAntrean) async {
    try {
      await supabase.from('antrean').delete().eq('nomor_antrean', nomorAntrean);
      return true;
    } catch (e) {
      debugPrint('Error hapusAntrean: $e');
      return false;
    }
  }

  Future<bool> editAntreanWithFile(Antrean antrean, PlatformFile file) async {
    try {
      final fileBytes = file.bytes!;
      final fileName = '${const Uuid().v4()}_${file.name}';

      await supabase.storage
          .from('antrean-files')
          .uploadBinary(fileName, fileBytes);

      await supabase
          .from('antrean')
          .update({
            'nama': antrean.nama,
            'layanan': antrean.layanan,
            'pickup_time': antrean.pickupTime.toIso8601String(),
            'file_name': fileName,
          })
          .eq('nomor_antrean', antrean.nomorAntrean);

      return true;
    } catch (e) {
      debugPrint('Error editAntreanWithFile: $e');
      return false;
    }
  }
}

final supabaseService = SupabaseService();
