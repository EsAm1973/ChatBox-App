import 'dart:io';

import 'package:chatbox/Core/service/storage_service.dart';
import 'package:chatbox/Features/chat/data/models/message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as b;

class SupabaseStorageService implements StorageService {
  static late Supabase _supabase;
  static Future<void> initSupabaseStorage() async {
    _supabase = await Supabase.initialize(
      url: 'https://umhtbpnmknxwpdmmtqhu.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVtaHRicG5ta254d3BkbW10cWh1Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkzNDAzOSwiZXhwIjoyMDczNTEwMDM5fQ.uMvZ-lHqdA2Yp88-V07KpM8YlOfOH0R7araQFcfR3wA',
    );
  }

  @override
  Future<String> uploadFile(File file, String path, String userId) async {
    try {
      String fileName = b.basenameWithoutExtension(file.path);
      String extensionName = b.extension(file.path);
      String filePath = '$path/$userId/$fileName$extensionName';

      // Upload the file
      await _supabase.client.storage
          .from('user-image')
          .upload(filePath, file, fileOptions: const FileOptions(upsert: true));

      // Get the public URL
      String publicUrl = _supabase.client.storage
          .from('user-image')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload User Image: $e');
    }
  }

  @override
  Future<String> uploadVoiceRecord(File file, String userId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = b.extension(file.path);
      final fileName = 'voice_$timestamp$extension';
      final filePath = 'voice_records/$userId/$fileName';

      await _supabase.client.storage
          .from('voice-records')
          .upload(
            filePath,
            file,
            fileOptions: const FileOptions(
              upsert: false,
              contentType: 'audio/mpeg',
            ),
          );

      String publicUrl = _supabase.client.storage
          .from('voice-records')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload voice record: $e');
    }
  }

  @override
  @override
  Future<String> uploadChatAttachment(
    File file,
    String userId,
    MessageType fileType,
  ) async {
    try {
      String originalFileName = b.basename(file.path);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${originalFileName}_$timestamp';

      String bucketName;
      String filePath;

      switch (fileType) {
        case MessageType.image:
          bucketName = 'chat-images';
          filePath = 'images/$userId/$fileName';
          break;
        case MessageType.file:
          bucketName = 'chat-files';
          filePath = 'files/$userId/$fileName';
          break;
        default:
          throw Exception('Unsupported file type for attachment');
      }

      await _supabase.client.storage
          .from(bucketName)
          .upload(
            filePath,
            file,
            fileOptions: const FileOptions(upsert: false),
          );

      String publicUrl = _supabase.client.storage
          .from(bucketName)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload chat attachment: $e');
    }
  }

  @override
  Future<void> deleteFile(String fileUrl) async {
    try {
      final uri = Uri.parse(fileUrl);
      final pathSegments = uri.pathSegments;
      if (pathSegments.length < 3) {
        throw Exception('Invalid file URL format');
      }

      // Determine bucket based on URL
      String bucketName = 'user-image';
      if (fileUrl.contains('voice-records')) {
        bucketName = 'voice-records';
      } else if (fileUrl.contains('chat-images')) {
        bucketName = 'chat-images';
      } else if (fileUrl.contains('chat-files')) {
        bucketName = 'chat-files';
      }

      final filePath = pathSegments.sublist(2).join('/');
      await _supabase.client.storage.from(bucketName).remove([filePath]);
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }
}
