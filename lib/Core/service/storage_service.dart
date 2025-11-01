import 'dart:io';

import 'package:chatbox/Features/chat/data/models/message.dart';

abstract class StorageService {
  Future<String> uploadFile(File file, String path, String userId);
  Future<String> uploadVoiceRecord(File file, String userId);
  Future<String> uploadChatAttachment(
    File file,
    String userId,
    MessageType fileType,
  );
  Future<void> deleteFile(String filePath);

  // New download methods
  Future<String> downloadImage(
    String url,
    String messageId,
    Function(double)? onProgress,
  );
  Future<String> downloadFile(
    String url,
    String fileName,
    String messageId,
    Function(double)? onProgress,
  );
  Future<bool> isFileDownloaded(String messageId);
  Future<String?> getLocalFilePath(String messageId);
}
