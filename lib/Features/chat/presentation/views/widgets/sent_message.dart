import 'package:chatbox/Core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SentMessage extends StatelessWidget {
  final String message;
  final String time;
  final bool isSeen;

  const SentMessage({
    super.key,
    required this.message,
    required this.time,
    required this.isSeen,
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
                Icon(
                  isSeen ? Icons.done_all : Icons.done,
                  size: 14.r,
                  color:
                      isSeen
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(
                            context,
                          ).colorScheme.onPrimary.withOpacity(0.7),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
