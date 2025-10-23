import 'dart:io';

abstract class StorageService {
  Future<String> uploadFile(File file, String path, String userId);
  Future<String> uploadVoiceRecord(File file, String userId);
  Future<void> deleteFile(String filePath);
}
