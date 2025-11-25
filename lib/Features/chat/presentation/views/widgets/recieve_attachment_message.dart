// ReceivedAttachmentMessage.dart

import 'package:chatbox/Core/helper%20functions/build_images_files_ui_render.dart';
import 'package:chatbox/Core/utils/app_text_styles.dart';
import 'package:chatbox/Features/chat/data/models/message.dart';
import 'package:chatbox/Features/chat/presentation/manager/chat%20cubit/chat_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReceivedAttachmentMessage extends StatelessWidget {
  final String fileUrl;
  final String time;
  final MessageType messageType;
  final String? fileName;
  final MessageModel message;

  const ReceivedAttachmentMessage({
    super.key,
    required this.fileUrl,
    required this.time,
    required this.messageType,
    this.fileName,
    required this.message, // مطلوب
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: GestureDetector(
          onLongPress: () {
            // Long press على الصور لعرض dialog التحميل
            if (messageType == MessageType.image &&
                message.downloadStatus != DownloadStatus.downloaded) {
              _showDownloadDialog(context, message);
            }
          },
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
                  ImageMethods.buildReceivedImageContent(
                    context,
                    fileUrl: fileUrl,
                    message: message, // تمرير الـ message
                  )
                else
                  ImageMethods.buildReceivedFileContent(
                    context,
                    fileUrl: fileUrl,
                    fileName: fileName,
                    message: message,
                  ),

                SizedBox(height: 8.h),

                // الوقت
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: AppTextStyles.regular12.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    // إضافة مؤشر التحميل بجانب الوقت
                    if (message.downloadStatus ==
                        DownloadStatus.downloading) ...[
                      SizedBox(width: 8.w),
                      SizedBox(
                        width: 12.r,
                        height: 12.r,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Downloading...',
                        style: AppTextStyles.semiBold16.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDownloadDialog(BuildContext context, MessageModel message) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Download Image'),
            content: const Text(
              'Do you want to download this image to your gallery?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  context.read<ChatCubit>().downloadImage(message);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          SizedBox(
                            width: 20.r,
                            height: 20.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          const Text('Downloading image...'),
                        ],
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text('Download'),
              ),
            ],
          ),
    );
  }
}
