import 'package:chatbox/Core/cubit/user%20cubit/user_cubit.dart';
import 'package:chatbox/Core/utils/app_router.dart';
import 'package:chatbox/Core/utils/app_text_styles.dart';
import 'package:chatbox/Core/widgets/build_avatat.dart';
import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:chatbox/Features/calling/data/models/call_model.dart';
import 'package:chatbox/Features/calling/presentation/manager/call/call_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:svg_flutter/svg_flutter.dart';

class ChatAppBar extends StatelessWidget {
  const ChatAppBar({super.key, required this.otherUser});
  final UserModel otherUser;
  @override
  Widget build(BuildContext context) {
    final voiceCallCubit = context.read<CallCubit>();
    final currentUser = context.read<UserCubit>().getCurrentUser();
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
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: () async {
              // Fire cubit's initiate flow. Cubit should emit CallInvitationSent with currentCall.
              await voiceCallCubit.initiateCall(
                callerId: currentUser!.uid,
                callerEmail: currentUser.email,
                receiverId: otherUser.uid,
                receiverEmail: otherUser.email,
                callType: CallType.voice,
              );

              // After initiate, the cubit in your real project will emit a state containing the created CallModel.
              // Here we assume cubit.state has that call (CallInvitationSent). Adapt this part to your state model.
              final state = voiceCallCubit.state;
              // Replace this conditional with your actual state check in production
              if (state.currentCall != null) {
                final createdCall = state.currentCall as CallModel;

                // Navigate to Zego UI
                await GoRouter.of(context).push(
                  AppRouter.kVoiceCallViewRoute,
                  extra: {
                    'call': createdCall,
                    'localUserId': currentUser.uid,
                    'localUserName': currentUser.name,
                  },
                );

                // After returning, notify cubit to end call
                await voiceCallCubit.endCall(createdCall);
              } else {
                // handle failure case (show snackbar)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to create call')),
                );
              }
            },
            icon: SvgPicture.asset(
              _getCallIconPath(context),
              height: 28.h,
              width: 28.w,
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {},
            icon: SvgPicture.asset(
              _getVideoIconPath(context),
              height: 28.h,
              width: 28.w,
            ),
          ),
        ],
      ),
    );
  }

  String _getCallIconPath(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? 'assets/call_light.svg'
        : 'assets/call_dark.svg';
  }

  String _getVideoIconPath(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? 'assets/video_light.svg'
        : 'assets/video_dark.svg';
  }
}
