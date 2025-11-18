import 'package:chatbox/Core/utils/app_text_styles.dart';
import 'package:chatbox/Core/widgets/build_avatat.dart';
import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:chatbox/Features/chat/presentation/views/widgets/zego_send_call_invite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatAppBar extends StatelessWidget {
  const ChatAppBar({super.key, required this.otherUser});
  final UserModel otherUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          BackButton(color: Theme.of(context).iconTheme.color),
          SizedBox(width: 12.w),
          buildAvatar(
            context,
            otherUser.profilePic,
            50.w,
            50.h,
            30.r,
            30.r,
            BoxFit.cover,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(otherUser.name, style: AppTextStyles.semiBold16),
                SizedBox(height: 6.h),
                Text(
                  otherUser.isOnline ? 'Active now' : 'Offline',
                  style: AppTextStyles.regular12.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          acctionButton(false, otherUser.uid, otherUser.name),
          acctionButton(true, otherUser.uid, otherUser.name),
        ],
      ),
    );
  }
}
