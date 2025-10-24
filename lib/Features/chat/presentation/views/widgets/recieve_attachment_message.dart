// ReceivedAttachmentMessage.dart

import 'package:chatbox/Core/helper%20functions/sent_attachment_methods.dart';
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
                ImageMethods.buildReceivedImageContent(
                  context,
                  fileUrl: fileUrl,
                )
              else
                ImageMethods.buildReceivedFileContent(
                  context,
                  fileUrl: fileUrl,
                  fileName: fileName,
                ),

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
}
