import 'dart:io';
import 'package:flutter/foundation.dart';
import 'supabase_service.dart';

class StorageService {
  final SupabaseService _supabase = SupabaseService();

  Future<String?> uploadReceipt(File file, String familyId) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final path = '$familyId/$fileName';

    if (_supabase.isDemoMode) {
      debugPrint('[StorageService] Demo Mode active. Simulating receipt upload to receipts/$path...');
      await Future.delayed(const Duration(milliseconds: 1500));
      // Return a premium dummy receipt link
      return 'https://via.placeholder.com/800x600.png?text=Demo+Receipt';
    }

    try {
      await _supabase.client.storage
          .from('receipts')
          .upload(path, file);

      final publicUrl = _supabase.client.storage
          .from('receipts')
          .getPublicUrl(path);

      debugPrint('[StorageService] Receipt uploaded successfully. Public URL: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('[StorageService] Failed to upload receipt: $e');
      return null;
    }
  }
}
