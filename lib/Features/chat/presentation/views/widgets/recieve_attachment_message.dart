// ReceivedAttachmentMessage.dart
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatbox/Core/utils/app_text_styles.dart';
import 'package:chatbox/Features/chat/data/models/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReceivedAttachmentMessage extends StatelessWidget {
  final String fileUrl;
  final String time;
  final MessageType messageType;
  final String? fileName;

  const ReceivedAttachmentMessage({
    super.key,
    required this.fileUrl,
    required this.time,
    required this.messageType,
    this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
              bottomRight: Radius.circular(16.r),
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

              // الوقت
              Text(
                time,
                style: AppTextStyles.regular12.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageContent(BuildContext context) {
    return GestureDetector(
      onTap: () {
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

  Widget _buildFileContent(BuildContext context) {
    final file = File(fileUrl);
    final fileName = this.fileName ?? file.uri.pathSegments.last;

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
                fileName,
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
            _downloadFile(context, fileUrl, fileName);
          },
        ),
      ],
    );
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
    ).showSnackBar(SnackBar(content: Text('Downloading file: $fileName')));
  }
}
