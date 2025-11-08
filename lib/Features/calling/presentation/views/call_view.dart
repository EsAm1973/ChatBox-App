import 'package:chatbox/Features/calling/data/models/call_model.dart';
import 'package:chatbox/Features/calling/presentation/manager/call/call_cubit.dart';
import 'package:chatbox/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallView extends StatelessWidget {
  const CallView({
    super.key,
    required this.call,
    required this.localUserId,
    required this.localUserName,
  });
  final CallModel call;
  final String localUserId;
  final String localUserName;

  @override
  Widget build(BuildContext context) {
    // ZegoUIKit will handle permissions automatically
    final config = call.callType == CallType.voice
        ? ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
        : ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall();

    return Scaffold(
      body: SafeArea(
        child: ZegoUIKitPrebuiltCall(
          appID: appIdZegoCloud,
          appSign: appSignZegoCloud,
          userID: localUserId,
          userName: localUserName,
          callID: call.callId,
          config: config,
          // Handle call end - update Firestore when call is disposed
          onDispose: () {
            final cubit = context.read<CallCubit>();
            // Only end call if it's still active
            if (call.status == CallStatus.in_progress) {
              cubit.endCall(call);
            }
          },
        ),
      ),
    );
  }
}
