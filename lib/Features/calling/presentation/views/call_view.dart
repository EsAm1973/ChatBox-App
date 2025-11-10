import 'package:chatbox/Features/calling/data/models/call_model.dart';
import 'package:chatbox/Features/calling/presentation/manager/call/call_cubit.dart';
import 'package:chatbox/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallView extends StatefulWidget {
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
  State<CallView> createState() => _CallViewState();
}

class _CallViewState extends State<CallView> {
  @override
  void initState() {
    super.initState();
    // Update call status to in_progress when call view opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.call.status != CallStatus.in_progress) {
        context.read<CallCubit>().acceptCall(widget.call);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Configure call based on type
    final config =
        widget.call.callType == CallType.voice
            ? ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
            : ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall();

    return PopScope(
      canPop: false, // Prevent back button
      onPopInvoked: (didPop) async {
        if (!didPop) {
          // End call when trying to go back
          context.read<CallCubit>().endCall(widget.call);
          Navigator.of(context).pop();
        }
      },
      child: SafeArea(
        child: ZegoUIKitPrebuiltCall(
          appID: appIdZegoCloud,
          appSign: appSignZegoCloud,
          userID: widget.localUserId,
          userName: widget.localUserName,
          callID: widget.call.callId,
          config: config,
        ),
      ),
    );
  }
}
