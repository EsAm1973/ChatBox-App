import 'package:chatbox/Core/cubit/user%20cubit/user_cubit.dart';
import 'package:chatbox/Core/helper functions/formatted_date_and_days.dart';
import 'package:chatbox/Features/calling/data/models/call_model.dart';
import 'package:chatbox/Core/widgets/build_avatat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:svg_flutter/svg.dart';

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
    final hasError = errorMessage != null && deletedCallId == call.callId;

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
          48.w,
          48.h,
          24.r,
          24.r,
          BoxFit.cover,
        ),
        title: Text(
          (call.callerName ==
                      context.read<UserCubit>().getCurrentUser()!.name &&
                  call.callerId != call.receiverId)
              ? call.receiverName
              : call.callerName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Row(
          children: [
            Icon(
              call.status == CallStatus.missed
                  ? Icons.call_missed
                  : Icons.call_made,
              size: 16,
              color:
                  call.status == CallStatus.missed ? Colors.red : Colors.green,
            ),
            const SizedBox(width: 4),
            Text(
              formatCallTime(call.startedAt),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            if (call.duration > 0) ...[
              const SizedBox(width: 8),
              Text(
                formatDuration(call.duration),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              call.callType == CallType.video
                  ? 'assets/video_light.svg'
                  : 'assets/call_light.svg',
              width: 20,
              height: 20,
            ),
            if (isCurrentDeleting) ...[
              const SizedBox(width: 8),
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
            if (hasError) ...[
              const SizedBox(width: 8),
              const Icon(Icons.error, color: Colors.red, size: 20),
            ],
          ],
        ),
        onLongPress: () {
          // TODO: Show delete option
        },
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
