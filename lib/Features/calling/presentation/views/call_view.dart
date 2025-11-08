import 'package:chatbox/Features/calling/data/models/call_model.dart';
import 'package:chatbox/Features/calling/presentation/manager/call/call_cubit.dart';
import 'package:chatbox/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
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
  bool _permissionsGranted = false;

  @override
  void initState() {
    super.initState();
    _ensurePermissions();
  }

  Future<void> _ensurePermissions() async {
    final permissions = <Permission>[];
    if (widget.call.callType == CallType.voice) {
      permissions.add(Permission.microphone);
    } else {
      permissions.addAll([Permission.microphone, Permission.camera]);
    }

    final results = await permissions.request();
    final allGranted = results.values.every((s) => s.isGranted);

    if (!allGranted) {
      // if permissions denied permanently, open app settings
      final anyPermanentlyDenied = results.values.any(
        (s) => s.isPermanentlyDenied,
      );
      if (anyPermanentlyDenied) {
        await openAppSettings();
      }
    }

    setState(() => _permissionsGranted = allGranted);
  }

  @override
  Widget build(BuildContext context) {
    final config =
        widget.call.callType == CallType.voice
            ? ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
            : ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall();
    if (!_permissionsGranted) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                const Text('Requesting permissions...'),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _ensurePermissions,
                  child: const Text('Retry permissions'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: ZegoUIKitPrebuiltCall(
          appID: appIdZegoCloud,
          appSign: appSignZegoCloud,
          userID: widget.localUserId,
          userName: widget.localUserName,
          callID: widget.call.callId,
          config: config,
          // Optional: listen to onHangUp to update call state when user presses hangup
          onDispose: () {
            final cubit = context.read<CallCubit>();
            cubit.endCall(widget.call);
          },
        ),
      ),
    );
  }
}
