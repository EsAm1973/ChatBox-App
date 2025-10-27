import 'package:chatbox/Core/utils/app_text_styles.dart';
import 'package:chatbox/Core/widgets/build_avatat.dart';
import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:chatbox/Features/chat/data/models/chat_room.dart';
import 'package:chatbox/Features/chat/data/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatListItem extends StatelessWidget {
  final ChatRoomModel chat;
  final UserModel otherUser;
  final VoidCallback onTap;

  const ChatListItem({
    super.key,
    required this.chat,
    required this.otherUser,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lastMessage = chat.lastMessage;
    final lastMessageTime = _formatLastMessageTime(chat.lastMessageTime);
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final unreadCount = chat.unreadCounts[currentUserId] ?? 0;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildAvatar(
              context,
              otherUser.profilePic,
              60.w,
              60.h,
              30.r,
              30.r,
              BoxFit.cover,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherUser.name,
                    style: AppTextStyles.semiBold20,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  if (lastMessage.type == MessageType.text)
                    Text(
                      lastMessage.content,
                      style: AppTextStyles.regular12.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (lastMessage.type == MessageType.voice)
                    Text(
                      'Voice message',
                      style: AppTextStyles.regular12.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (lastMessage.type == MessageType.image)
                    Row(
                      children: [
                        Icon(Icons.image, size: 16.r),
                        SizedBox(width: 5.w),
                        Text(
                          'Image',
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
                  if (lastMessage.type == MessageType.file)
                    Row(
                      children: [
                        Icon(Icons.insert_drive_file, size: 16.r),
                        SizedBox(width: 5.w),
                        Text(
                          'File',
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
                ],
              ),
            ),
            SizedBox(width: 15.w),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 2.0.h),
                  child: Text(
                    lastMessageTime,
                    style: AppTextStyles.regular12.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                SizedBox(height: 7.h),
                if (unreadCount > 0) _buildUnreadBadge(context, unreadCount),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnreadBadge(BuildContext context, int unreadCount) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: const BoxDecoration(
        color: Color(0xFFF04A4C),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Text(
        unreadCount > 99 ? '99+' : unreadCount.toString(),
        style: AppTextStyles.regular12.copyWith(color: Colors.white),
      ),
    );
  }

  String _formatLastMessageTime(DateTime messageTime) {
    final now = DateTime.now();
    final difference = now.difference(messageTime);

    if (difference.inMinutes < 1) {
      return 'Now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${messageTime.day}/${messageTime.month}';
    }
  }
}
