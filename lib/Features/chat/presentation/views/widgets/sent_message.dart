import 'package:chatbox/Core/utils/app_text_styles.dart';
import 'package:chatbox/Features/chat/data/models/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SentMessage extends StatelessWidget {
  final String message;
  final String time;
  final bool isSeen;
  final MessageStatus status;

  const SentMessage({
    super.key,
    required this.message,
    required this.time,
    required this.isSeen,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(16.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message,
              style: AppTextStyles.regular14.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            SizedBox(height: 7.h),
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
}
