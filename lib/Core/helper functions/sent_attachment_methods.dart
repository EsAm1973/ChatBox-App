import 'dart:io';

import 'package:chatbox/Core/utils/app_text_styles.dart';
import 'package:chatbox/Features/chat/data/models/message.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ImageMethods {
  // Build image content widget
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

  // Build file content widget
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
          Icons.insert_drive_file,
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
        if (status != MessageStatus.pending && status != MessageStatus.failed)
          IconButton(
            icon: Icon(
              Icons.download,
              size: 20.r,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: () {
              downloadFile(context, fileUrl, actualFileName);
            },
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

  static Widget buildReceivedImageContent(
    BuildContext context, {
    required String fileUrl,
  }) {
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
                        'Error loading image',
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

  static Widget buildReceivedFileContent(
    BuildContext context, {
    required String fileUrl,
    String? fileName,
  }) {
    final file = File(fileUrl);
    final actualFileName = fileName ?? file.uri.pathSegments.last;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.insert_drive_file,
          size: 32.r,
          color: Theme.of(context).colorScheme.onSurface,
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
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.download,
            size: 20.r,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () {
            downloadFile(context, fileUrl, actualFileName);
          },
        ),
      ],
    );
  }

  // Download file
  static void downloadFile(
    BuildContext context,
    String fileUrl,
    String fileName,
  ) async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Downloading file: $fileName')));
  }
}
