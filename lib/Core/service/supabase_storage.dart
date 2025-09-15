import 'dart:io';

import 'package:chatbox/Core/service/storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as b;

class SupabaseStorageService implements StorageService {
  static late Supabase _supabase;
  static Future<void> initSupabaseStorage() async {
    _supabase = await Supabase.initialize(
      url: 'https://umhtbpnmknxwpdmmtqhu.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVtaHRicG5ta254d3BkbW10cWh1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MzQwMzksImV4cCI6MjA3MzUxMDAzOX0.o5CCLtSnOwq_lhbVY3p5__YucZ-kghl1HH-2pLZT7FY',
    );
  }

  @override
  Future<String> uploadFile(File file, String path) async {
    try {
      String fileName = b.basenameWithoutExtension(file.path);
      String extensionName = b.extension(file.path);
      String filePath = '$path/$fileName$extensionName';

      // Upload the file
      await _supabase.client.storage
          .from('user-image')
          .upload(filePath, file);

      // Get the public URL
      String publicUrl = _supabase.client.storage
          .from('user-image')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload User Image: $e');
    }
  }
}
