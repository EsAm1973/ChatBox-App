import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit/zego_uikit.dart';

ZegoSendCallInvitationButton acctionButton(
  bool isVideo,
  String reciverId,
  String reciverName,
) => ZegoSendCallInvitationButton(
  iconSize: Size(40.w, 40.h),
  buttonSize: Size(50.w, 50.h),
  resourceID: 'chatbox-zego',
  invitees: [ZegoUIKitUser(id: reciverId, name: reciverName)],
  isVideoCall: isVideo,
);
