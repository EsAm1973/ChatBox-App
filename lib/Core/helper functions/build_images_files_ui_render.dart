import 'dart:io';

import 'package:chatbox/Core/utils/app_text_styles.dart';
import 'package:chatbox/Features/chat/data/models/message.dart';
import 'package:chatbox/Features/chat/presentation/manager/chat%20cubit/chat_cubit.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ImageMethods {
  // Build image content widget (للرسائل المرسلة)
  static Widget buildImageContent(
    BuildContext context, {
    required String fileUrl,
    required MessageStatus status,
  }) {
    if (status == MessageStatus.pending) {
      return Container(
        width: 200.r,
        height: 150.r,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Sending Image...',
              style: AppTextStyles.regular12.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        showFullScreenImage(context, fileUrl);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          constraints: BoxConstraints(maxWidth: 200.r, maxHeight: 200.r),
          child: CachedNetworkImage(
            imageUrl: fileUrl,
            fit: BoxFit.cover,
            placeholder:
                (context, url) => Container(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            errorWidget:
                (context, url, error) => Container(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Failed to load image',
                        style: AppTextStyles.regular12,
                      ),
                    ],
                  ),
                ),
          ),
        ),
      ),
    );
  }

  // Build file content widget (للرسائل المرسلة)
  static Widget buildFileContent(
    BuildContext context, {
    required String fileUrl,
    required MessageStatus status,
    String? fileName,
  }) {
    final file = File(fileUrl);
    final actualFileName = fileName ?? file.uri.pathSegments.last;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _getFileIcon(actualFileName),
          size: 32.r,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                actualFileName,
                style: AppTextStyles.regular14.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (status == MessageStatus.pending)
                Text(
                  'Sending File...',
                  style: AppTextStyles.regular12.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimary.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Build status icon widget
  static Widget buildStatusIcon(
    BuildContext context, {
    required MessageStatus status,
    required bool isSeen,
  }) {
    if (status == MessageStatus.pending) {
      return Icon(
        Icons.watch_later_outlined,
        size: 14.r,
        color: Theme.of(context).colorScheme.onPrimary,
      );
    } else if (status == MessageStatus.failed) {
      return Icon(
        Icons.error_outline,
        size: 14.r,
        color: Theme.of(context).colorScheme.onPrimary,
      );
    } else if (status == MessageStatus.sent && !isSeen) {
      return Icon(
        Icons.done,
        size: 14.r,
        color: Theme.of(context).colorScheme.onPrimary,
      );
    } else if (status == MessageStatus.delivered ||
        (status == MessageStatus.sent && isSeen)) {
      return Icon(
        Icons.done_all,
        size: 14.r,
        color: Theme.of(context).colorScheme.onPrimary,
      );
    }

    return const SizedBox.shrink();
  }

  // Show full screen image
  static void showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black87,
                    child: InteractiveViewer(
                      child: Center(
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40.h,
                  right: 20.w,
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 30.r,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // 🔥 FIXED: Build received image content with download support
  static Widget buildReceivedImageContent(
    BuildContext context, {
    required String fileUrl,
    required MessageModel message,
  }) {
    final chatCubit = context.read<ChatCubit>();

    return GestureDetector(
      onTap: () {
        // إذا تم التحميل، فتح الصورة بشاشة كاملة
        if (message.downloadStatus == DownloadStatus.downloaded) {
          showFullScreenImage(context, fileUrl);
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          constraints: BoxConstraints(maxWidth: 200.r, maxHeight: 200.r),
          child: Stack(
            children: [
              // Show local image if downloaded
              if (message.downloadStatus == DownloadStatus.downloaded &&
                  message.localFilePath != null)
                Image.file(
                  File(message.localFilePath!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                )
              else
                CachedNetworkImage(
                  imageUrl: fileUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder:
                      (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, color: Colors.red, size: 40.r),
                            Text(
                              'Failed to load',
                              style: AppTextStyles.regular12,
                            ),
                          ],
                        ),
                      ),
                ),

              // Download overlay
              if (message.downloadStatus != DownloadStatus.downloaded)
                Positioned.fill(
                  child: Container(
                    color: Colors.black45,
                    child: Center(
                      child: _buildDownloadButton(message, chatCubit),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Download button for images
  static Widget _buildDownloadButton(MessageModel message, ChatCubit cubit) {
    switch (message.downloadStatus) {
      case DownloadStatus.notDownloaded:
        return IconButton(
          icon: Icon(Icons.download, size: 40.r, color: Colors.white),
          onPressed: () => cubit.downloadImage(message),
        );

      case DownloadStatus.downloading:
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60.r,
              height: 60.r,
              child: CircularProgressIndicator(
                value: message.downloadProgress,
                backgroundColor: Colors.white30,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 4,
              ),
            ),
            Text(
              '${((message.downloadProgress ?? 0) * 100).toInt()}%',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );

      case DownloadStatus.failed:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.refresh, size: 40.r, color: Colors.red),
              onPressed: () => cubit.downloadImage(message),
            ),
            Text(
              'Retry',
              style: TextStyle(color: Colors.white, fontSize: 12.sp),
            ),
          ],
        );

      case DownloadStatus.downloaded:
        return const SizedBox.shrink();
    }
  }

  // 🔥 FIXED: Build received file content with download support
  static Widget buildReceivedFileContent(
    BuildContext context, {
    required String fileUrl,
    String? fileName,
    required MessageModel message,
  }) {
    final chatCubit = context.read<ChatCubit>();
    final file = File(fileUrl);
    final actualFileName = fileName ?? file.uri.pathSegments.last;

    return InkWell(
      onTap: () {
        // Download and open file
        chatCubit.downloadAndOpenFile(message, actualFileName);
      },
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(
                _getFileIcon(actualFileName),
                size: 32.r,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    actualFileName,
                    style: AppTextStyles.regular14.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _getFileStatusText(message.downloadStatus),
                    style: AppTextStyles.regular12.copyWith(
                      color: _getFileStatusColor(
                        message.downloadStatus,
                        context,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            _buildFileActionButton(message, chatCubit, actualFileName, context),
          ],
        ),
      ),
    );
  }

  // File action button (download/open)
  static Widget _buildFileActionButton(
    MessageModel message,
    ChatCubit cubit,
    String fileName,
    BuildContext context,
  ) {
    switch (message.downloadStatus) {
      case DownloadStatus.notDownloaded:
        return IconButton(
          icon: Icon(
            Icons.download,
            size: 24.r,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => cubit.downloadAndOpenFile(message, fileName),
        );

      case DownloadStatus.downloading:
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 32.r,
              height: 32.r,
              child: CircularProgressIndicator(
                value: message.downloadProgress,
                strokeWidth: 2.5,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              '${((message.downloadProgress ?? 0) * 100).toInt()}%',
              style: TextStyle(
                fontSize: 8.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        );

      case DownloadStatus.downloaded:
        return IconButton(
          icon: Icon(Icons.open_in_new, size: 24.r, color: Colors.green),
          onPressed: () => cubit.downloadAndOpenFile(message, fileName),
        );

      case DownloadStatus.failed:
        return IconButton(
          icon: Icon(Icons.refresh, size: 24.r, color: Colors.red),
          onPressed: () => cubit.downloadAndOpenFile(message, fileName),
        );
    }
  }

  // Get file status text
  static String _getFileStatusText(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.notDownloaded:
        return 'Tap to download';
      case DownloadStatus.downloading:
        return 'Downloading...';
      case DownloadStatus.downloaded:
        return 'Downloaded • Tap to open';
      case DownloadStatus.failed:
        return 'Failed • Tap to retry';
    }
  }

  // Get file status color
  static Color _getFileStatusColor(
    DownloadStatus status,
    BuildContext context,
  ) {
    switch (status) {
      case DownloadStatus.notDownloaded:
        return Colors.grey[600]!;
      case DownloadStatus.downloading:
        return Theme.of(context).colorScheme.primary;
      case DownloadStatus.downloaded:
        return Colors.green;
      case DownloadStatus.failed:
        return Colors.red;
    }
  }

  // Get file icon based on extension
  static IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'zip':
      case 'rar':
        return Icons.folder_zip;
      case 'txt':
        return Icons.text_snippet;
      case 'apk':
        return Icons.android;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }
}
