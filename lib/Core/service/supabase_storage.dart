import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:chatbox/Core/service/shared_prefrences_sengelton.dart';
import 'package:chatbox/Core/service/storage_service.dart';
import 'package:chatbox/Features/chat/data/models/message.dart';
import 'package:dio/dio.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as b;

class SupabaseStorageService implements StorageService {
  static late Supabase _supabase;
  final Dio _dio = Dio();

  // Map to track downloaded files: messageId -> localPath
  static final Map<String, String> _downloadedFiles = {};
  static const String _downloadedFilesKey = 'downloaded_files';

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

      await _supabase.client.storage
          .from('user-image')
          .upload(filePath, file, fileOptions: const FileOptions(upsert: true));

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

  @override
  Future<String> downloadImage(
    String url,
    String messageId,
    Function(double)? onProgress,
  ) async {
    try {
      // Check if already downloaded - تحميل البيانات المحفوظة أولاً
      await _loadDownloadedFiles();
      if (_downloadedFiles.containsKey(messageId)) {
        final localPath = _downloadedFiles[messageId]!;
        if (await File(localPath).exists()) {
          return localPath;
        } else {
          // إذا كان الملف غير موجود، نزيله من القائمة
          _downloadedFiles.remove(messageId);
          await _saveDownloadedFiles();
        }
      }

      // Get app directory
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/chat_images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Extract file extension from URL
      final uri = Uri.parse(url);
      final extension = b.extension(uri.path);
      final fileName = '$messageId$extension';
      final filePath = '${imagesDir.path}/$fileName';

      // Download the file with progress tracking
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            final progress = received / total;
            onProgress(progress);
          }
        },
      );

      // حفظ الصورة في المعرض
      File imageFile = File(filePath);
      Uint8List imageBytes = await imageFile.readAsBytes();

      await ImageGallerySaverPlus.saveImage(
        imageBytes,
        name: 'ChatApp_${DateTime.now().millisecondsSinceEpoch}',
        quality: 100,
      );

      // Store in map and save permanently
      _downloadedFiles[messageId] = filePath;
      await _saveDownloadedFiles();

      return filePath;
    } catch (e) {
      throw Exception('Failed to download image: $e');
    }
  }

  @override
  Future<String> downloadFile(
    String url,
    String fileName,
    String messageId,
    Function(double)? onProgress,
  ) async {
    try {
      // Check if already downloaded - تحميل البيانات المحفوظة أولاً
      await _loadDownloadedFiles();
      if (_downloadedFiles.containsKey(messageId)) {
        final localPath = _downloadedFiles[messageId]!;
        if (await File(localPath).exists()) {
          return localPath;
        } else {
          // إذا كان الملف غير موجود، نزيله من القائمة
          _downloadedFiles.remove(messageId);
          await _saveDownloadedFiles();
        }
      }

      // Get downloads directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final downloadsDir = Directory('${directory!.path}/Downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      // Create unique file name if needed
      final filePath = '${downloadsDir.path}/$fileName';

      // Download the file with progress tracking
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            final progress = received / total;
            onProgress(progress);
          }
        },
      );

      // Store in map and save permanently
      _downloadedFiles[messageId] = filePath;
      await _saveDownloadedFiles();

      return filePath;
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }

  // دالة لحفظ حالة التحميل باستخدام Prefs
  Future<void> _saveDownloadedFiles() async {
    try {
      final String encodedData = json.encode(_downloadedFiles);
      await Prefs.setString(_downloadedFilesKey, encodedData);
    } catch (e) {
      print('Failed to save downloaded files: $e');
    }
  }

  // دالة لتحميل حالة التحميل باستخدام Prefs
  Future<void> _loadDownloadedFiles() async {
    try {
      final String downloadedFilesJson = Prefs.getString(_downloadedFilesKey);

      if (downloadedFilesJson.isNotEmpty) {
        final Map<String, dynamic> decodedData = json.decode(
          downloadedFilesJson,
        );
        _downloadedFiles.clear();
        decodedData.forEach((key, value) {
          _downloadedFiles[key] = value as String;
        });

        // تنظيف الملفات التي لم تعد موجودة
        await _cleanupMissingFiles();
      }
    } catch (e) {
      print('Failed to load downloaded files: $e');
    }
  }

  // تنظيف الملفات التي تم حفظها في القائمة ولكنها غير موجودة فعلياً
  Future<void> _cleanupMissingFiles() async {
    final missingFiles = <String>[];

    for (final entry in _downloadedFiles.entries) {
      final file = File(entry.value);
      if (!await file.exists()) {
        missingFiles.add(entry.key);
      }
    }

    for (final messageId in missingFiles) {
      _downloadedFiles.remove(messageId);
    }

    if (missingFiles.isNotEmpty) {
      await _saveDownloadedFiles();
    }
  }

  @override
  Future<bool> isFileDownloaded(String messageId) async {
    // تحميل البيانات المحفوظة أولاً
    await _loadDownloadedFiles();

    if (!_downloadedFiles.containsKey(messageId)) {
      return false;
    }

    final localPath = _downloadedFiles[messageId]!;
    return await File(localPath).exists();
  }

  @override
  Future<String?> getLocalFilePath(String messageId) async {
    // تحميل البيانات المحفوظة أولاً
    await _loadDownloadedFiles();

    if (await isFileDownloaded(messageId)) {
      return _downloadedFiles[messageId];
    }
    return null;
  }

  // دالة جديدة لحذف ملف من القائمة
  Future<void> removeDownloadedFile(String messageId) async {
    _downloadedFiles.remove(messageId);
    await _saveDownloadedFiles();
  }

  // دالة لتحميل جميع الملفات المحملة مسبقاً عند بدء التطبيق
  static Future<void> initializeDownloadedFiles() async {
    final instance = SupabaseStorageService();
    await instance._loadDownloadedFiles();
  }
}
