import 'dart:io';

import 'package:file_picker/file_picker.dart';

class FilePickerService {
  static final FilePicker _filePicker = FilePicker.platform;

  /// Pick image files (with option for multiple selection)
  static Future<List<File>?> pickImages({bool allowMultiple = false}) async {
    final result = await _filePicker.pickFiles(
      type: FileType.image,
      allowMultiple: allowMultiple,
    );

    if (result != null && result.files.isNotEmpty) {
      return result.files
          .where((file) => file.path != null)
          .map((file) => File(file.path!))
          .toList();
    }
    return null;
  }

  /// Pick any type of files
  static Future<List<File>?> pickFiles({bool allowMultiple = false}) async {
    final result = await _filePicker.pickFiles(
      type: FileType.any,
      allowMultiple: allowMultiple,
    );

    if (result != null && result.files.isNotEmpty) {
      return result.files
          .where((file) => file.path != null)
          .map((file) => File(file.path!))
          .toList();
    }
    return null;
  }

  /// Get file size in readable format
  static String getFileSizeString(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1048576) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    }
  }
}
