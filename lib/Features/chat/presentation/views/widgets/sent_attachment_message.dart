// SentAttachmentMessage.dart
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatbox/Core/utils/app_text_styles.dart';
import 'package:chatbox/Features/chat/data/models/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SentAttachmentMessage extends StatelessWidget {
  final String fileUrl;
  final String time;
  final bool isSeen;
  final MessageStatus status;
  final MessageType messageType;
  final String? fileName;
  final VoidCallback? onRetry;

  const SentAttachmentMessage({
    super.key,
    required this.fileUrl,
    required this.time,
    required this.isSeen,
    required this.status,
    required this.messageType,
    this.fileName,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: Radius.circular(16.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // محتوى الرسالة حسب النوع
                  if (messageType == MessageType.image)
                    _buildImageContent(context)
                  else
                    _buildFileContent(context),

                  SizedBox(height: 8.h),

                  // حالة الرسالة والوقت
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        time,
                        style: AppTextStyles.regular12.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimary.withOpacity(0.7),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      _buildStatusIcon(context),
                    ],
                  ),
                ],
              ),
            ),

            // رسالة الخطأ وإعادة المحاولة
            if (status == MessageStatus.failed)
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Failed to send',
                      style: AppTextStyles.regular12.copyWith(
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: onRetry,
                      child: Text(
                        'Try again',
                        style: AppTextStyles.regular12.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContent(BuildContext context) {
    if (status == MessageStatus.pending) {
      return Container(
        width: 200.r,
        height: 150.r,
        decoration: BoxDecoration(
          color: Colors.grey[300],
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
        // عرض الصورة في وضع full screen
        _showFullScreenImage(context, fileUrl);
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
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
            errorWidget:
                (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.grey),
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

  Widget _buildFileContent(BuildContext context) {
    final file = File(fileUrl);
    final fileName = this.fileName ?? file.uri.pathSegments.last;

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
                fileName,
                style: AppTextStyles.regular14.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (status == MessageStatus.pending)
                Text(
                  'جاري رفع الملف...',
                  style: AppTextStyles.regular12.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimary.withOpacity(0.7),
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
              _downloadFile(context, fileUrl, fileName);
            },
          ),
      ],
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
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

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
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
                    icon: Icon(Icons.close, color: Colors.white, size: 30.r),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _downloadFile(
    BuildContext context,
    String fileUrl,
    String fileName,
  ) async {
    // TODO: Implement file download logic
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('جاري تحميل الملف: $fileName')));
  }
}
