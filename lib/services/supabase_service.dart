import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/antrean.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  Future<bool> tambahAntrean(Antrean antrean, PlatformFile file) async {
    try {
      final fileBytes = file.bytes;
      if (fileBytes == null) {
        debugPrint('❌ Gagal: File kosong atau tidak dipilih');
        return false;
      }

      final fileName = '${const Uuid().v4()}_${file.name}';

      await supabase.storage
          .from('antrean-files')
          .uploadBinary(fileName, fileBytes);

      await supabase.from('antrean').insert({
        'nama': antrean.nama,
        'layanan': antrean.layanan,
        'pickup_time': antrean.pickupTime.toIso8601String(),
        'file_name': fileName,
        'nomor_antrean': antrean.nomorAntrean,
      });

      return true;
    } catch (e) {
      debugPrint('❌ Error tambahAntrean: $e');
      return false;
    }
  }

  Future<List<Antrean>> fetchAntrean() async {
    try {
      final response = await supabase
          .from('antrean')
          .select()
          .order('pickup_time', ascending: true);

      return (response as List).map((item) => Antrean.fromMap(item)).toList();
    } catch (e) {
      debugPrint('❌ Error fetchAntrean: $e');
      return [];
    }
  }

  Future<bool> editAntreanWithFile(Antrean antrean, PlatformFile file) async {
    try {
      String fileName = antrean.fileName;

      if (file.bytes != null && file.size > 0) {
        fileName = '${const Uuid().v4()}_${file.name}';
        await supabase.storage
            .from('antrean-files')
            .uploadBinary(fileName, file.bytes!);
      }

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
      debugPrint('❌ Error editAntreanWithFile: $e');
      return false;
    }
  }

  Future<bool> hapusAntrean(int nomorAntrean) async {
    try {
      await supabase.from('antrean').delete().eq('nomor_antrean', nomorAntrean);
      return true;
    } catch (e) {
      debugPrint('❌ Error hapusAntrean: $e');
      return false;
    }
  }
}

final supabaseService = SupabaseService();
