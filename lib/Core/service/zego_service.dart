import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatbox/Core/helper%20functions/call_events_handler.dart';
import 'package:chatbox/Core/service/firestore_call_service.dart';
import 'package:chatbox/Core/service/getit_service.dart';
import 'package:chatbox/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class ZegoService {
  final GlobalKey<NavigatorState> navigatorKey;
  late final CallEventsHandler _callEventsHandler;

  ZegoService({required this.navigatorKey}) {
    _callEventsHandler = CallEventsHandler(getIt<FirestoreCallService>());
    ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);
  }

  Future<void> initForUser(User user) async {
    // It's good practice to uninit before initializing, to handle re-logins without app restart.
    await ZegoUIKitPrebuiltCallInvitationService().uninit();
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final userName = userDoc.data()?['name'] ?? user.displayName ?? user.email ?? user.uid;
    await ZegoUIKitPrebuiltCallInvitationService()
        .init(
          appID: appIdZegoCloud,
          appSign: appSignZegoCloud,
          userID: user.uid,
          userName: userName,
          plugins: [ZegoUIKitSignalingPlugin()],
          invitationEvents: _callEventsHandler.getInvitationEvents(),
          requireConfig: (ZegoCallInvitationData data) {
            final callConfig =
                (data.invitees.length > 1)
                    ? ZegoCallType.videoCall == data.type
                        ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
                        : ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
                    : ZegoCallType.videoCall == data.type
                    ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
                    : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

            callConfig.duration.isVisible = true;

            return callConfig;
          },
        )
        .catchError((error) {
          debugPrint('❌ ZegoCloud init error: $error');
        });
  }

  Future<void> uninit() async {
    await ZegoUIKitPrebuiltCallInvitationService().uninit();
  }

  CallEventsHandler get callEventsHandler => _callEventsHandler;

  void dispose() {
    _callEventsHandler.dispose();
  }
}
