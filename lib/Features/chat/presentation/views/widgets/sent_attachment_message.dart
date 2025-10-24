// SentAttachmentMessage.dart

import 'package:chatbox/Core/helper%20functions/sent_attachment_methods.dart';
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
                  if (messageType == MessageType.image)
                    ImageMethods.buildImageContent(
                      context,
                      fileUrl: fileUrl,
                      status: status,
                    )
                  else
                    ImageMethods.buildFileContent(
                      context,
                      fileUrl: fileUrl,
                      status: status,
                      fileName: fileName,
                    ),

                  SizedBox(height: 8.h),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        time,
                        style: AppTextStyles.regular12.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimary.withValues(alpha: 0.7),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      ImageMethods.buildStatusIcon(
                        context,
                        status: status,
                        isSeen: isSeen,
                      ),
                    ],
                  ),
                ],
              ),
            ),

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
}
