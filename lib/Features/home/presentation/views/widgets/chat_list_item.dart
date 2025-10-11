import 'package:chatbox/Core/utils/app_text_styles.dart';
import 'package:chatbox/Features/home/data/models/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatListItem extends StatelessWidget {
  final ChatMessage chat;
  const ChatListItem({super.key, required this.chat});
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildAvatarWithStatusDot(context),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chat.name,
                style: AppTextStyles.semiBold20,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 6.h),
              Text(
                chat.lastMessage,
                style: AppTextStyles.regular12.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 15),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Time
            Padding(
              padding: EdgeInsets.only(top: 2.0.h),
              child: Text(
                chat.time,
                style: AppTextStyles.regular12.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            SizedBox(height: 7.h),
            if (chat.unreadCount > 0) _buildUnreadBadge(context),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatarWithStatusDot(BuildContext context) {
    double avatarRadius = 30.0.r;
    double dotSize = 15.0.r;

    return Stack(
      children: [
        CircleAvatar(
          radius: avatarRadius,
          backgroundImage: AssetImage(chat.avatarUrl),
        ),
        // Status Dot
        if (chat.isOnline)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: const Color(0xFF0FE16D),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2.0.w,
                ),
              ),
            ),
          ),
        // Design shows a grey dot, which can represent "busy" or just a visual element.
        // For demonstration, if not online (or if we want the grey dot):
        if (!chat.isOnline)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2.0.w,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUnreadBadge(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(6.0.r),
      constraints: BoxConstraints(
        minWidth: 24.0.w, // Minimum width for single digit consistency
        minHeight: 24.0.h,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF04A4C),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          // Display count, or 9+ if count is very large
          chat.unreadCount > 99 ? '99+' : chat.unreadCount.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.0.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
