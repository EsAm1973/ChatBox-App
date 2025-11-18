
import 'package:chatbox/Core/cubit/user%20cubit/user_cubit.dart';
import 'package:chatbox/Core/helper functions/formatted_date_and_days.dart';
import 'package:chatbox/Core/utils/app_text_styles.dart';
import 'package:chatbox/Features/calling/data/models/call_model.dart';
import 'package:chatbox/Core/widgets/build_avatat.dart';
import 'package:chatbox/Features/chat/presentation/views/widgets/zego_send_call_invite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CallHistoryItem extends StatelessWidget {
  final CallModel call;
  final bool isDeleting;
  final String? deletedCallId;
  final String? errorMessage;

  const CallHistoryItem({
    super.key,
    required this.call,
    this.isDeleting = false,
    this.deletedCallId,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentDeleting = isDeleting && deletedCallId == call.callId;
    final otherUserID =
        call.callerId == context.read<UserCubit>().getCurrentUser()!.uid
            ? call.receiverId
            : call.callerId;
    final otherUserName =
        call.callerId == context.read<UserCubit>().getCurrentUser()!.uid
            ? call.receiverName
            : call.callerName;

    return Opacity(
      opacity: isCurrentDeleting ? 0.5 : 1.0,
      child: ListTile(
        leading: buildAvatar(
          context,
          (call.callerName ==
                      context.read<UserCubit>().getCurrentUser()!.name &&
                  call.callerId != call.receiverId)
              ? call.receiverImage
              : call.callerImage,
          50.w,
          50.h,
          30.r,
          30.r,
          BoxFit.contain,
        ),
        title: Text(
          (call.callerName ==
                      context.read<UserCubit>().getCurrentUser()!.name &&
                  call.callerId != call.receiverId)
              ? call.receiverName
              : call.callerName,
          style: AppTextStyles.bold18,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        subtitle: Row(
          children: [
            Icon(
              call.status == CallStatus.missed
                  ? Icons.call_missed
                  : Icons.call_made,
              size: 16.r,
              color:
                  call.status == CallStatus.missed ? Colors.red : Colors.green,
            ),
            SizedBox(width: 4.w),
            Text(
              formatCallTime(call.startedAt),
              style: AppTextStyles.regular12.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            if (call.duration > 0) ...[
              SizedBox(width: 8.w),
              Text(
                formatDuration(call.duration),
                style: AppTextStyles.regular12.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            acctionButton(false, otherUserID, otherUserName),
            acctionButton(true, otherUserID, otherUserName),
          ],
        ),
        onLongPress: () {},
      ),
    );
  }

  String formatCallTime(DateTime dateTime) {
    return formatDate(dateTime);
  }

  String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
