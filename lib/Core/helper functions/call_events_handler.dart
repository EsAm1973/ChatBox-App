import 'package:chatbox/Core/helper%20functions/zego_types_helper.dart';
import 'package:chatbox/Core/service/firestore_call_service.dart';
import 'package:chatbox/Features/calling/data/models/call_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'dart:async';

/// Class to handle all ZegoCloud call events and sync with Firestore
class CallEventsHandler {
  final FirestoreCallService _callService;

  // Track active calls
  final Map<String, DateTime> _activeCallsStartTime = {};
  Timer? _cleanupTimer;

  CallEventsHandler(this._callService) {
    _startCleanupTimer();
  }

  /// Start periodic cleanup timer (runs every 5 seconds)
  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkAndCompleteActiveCalls();
    });
  }

  /// Check for calls that should be completed
  Future<void> _checkAndCompleteActiveCalls() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Get all in-progress calls for current user
      final snapshot =
          await FirebaseFirestore.instance
              .collection('calls')
              .where('status', isEqualTo: CallStatus.in_progress.name)
              .get();

      for (var doc in snapshot.docs) {
        final call = CallModel.fromMap(doc.data());

        // Check if call involves current user
        if (call.callerId == currentUser.uid ||
            call.receiverId == currentUser.uid) {
          // If call has been active for more than 3 hours, auto-complete it
          final duration = DateTime.now().difference(call.startedAt).inSeconds;
          if (duration > 10800) {
            await _completeCall(call.callId, duration);
          }
        }
      }
    } catch (e) {
      print('❌ Error in cleanup timer: $e');
    }
  }

  /// Get ZegoUIKitPrebuiltCallInvitationEvents
  ZegoUIKitPrebuiltCallInvitationEvents getInvitationEvents() {
    return ZegoUIKitPrebuiltCallInvitationEvents(
      onOutgoingCallSent: onOutgoingCallSent,
      onIncomingCallReceived: onIncomingCallReceived,
      onOutgoingCallAccepted: onOutgoingCallAccepted,
      onOutgoingCallDeclined: onOutgoingCallDeclined,
      onOutgoingCallRejectedCauseBusy: onOutgoingCallRejectedCauseBusy,
      onIncomingCallCanceled: onIncomingCallCanceled,
      onOutgoingCallTimeout: onOutgoingCallTimeout,
      onIncomingCallTimeout: onIncomingCallTimeout,
    );
  }

  void onOutgoingCallSent(
    String callID,
    ZegoCallUser invitee,
    ZegoCallInvitationType callType,
    List<ZegoCallUser> invitees,
    String customData,
  ) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Prevent calling yourself
      if (currentUser.uid == invitee.id) {
        print('❌ Cannot call yourself');
        return;
      }

      final receiverDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(invitee.id)
              .get();

      if (!receiverDoc.exists) {
        print('❌ Receiver user not found');
        return;
      }

      final receiverEmail = receiverDoc.data()?['email'] ?? '';
      final receiverName = receiverDoc.data()?['name'] ?? '';
      final receiverProfilePic = receiverDoc.data()?['profilePic'] ?? '';
      final modelCallType = ZegoCallHelper.getCallType(callType);

      await _callService.createCall(
        callId: callID,
        callerId: currentUser.uid,
        callerEmail: currentUser.email ?? '',
        callerName: currentUser.displayName ?? '',
        callerProfilePic: currentUser.photoURL ?? '',
        receiverId: invitee.id,
        receiverEmail: receiverEmail,
        receiverName: receiverName,
        receiverProfilePic: receiverProfilePic,
        callType: modelCallType,
      );
    } catch (e) {
      print('❌ Error storing outgoing call: $e');
    }
  }

  void onIncomingCallReceived(
    String callID,
    ZegoCallUser caller,
    ZegoCallInvitationType callType,
    List<ZegoCallUser> invitees,
    String customData,
  ) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Get caller information
      final callerDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(caller.id)
              .get();

      final callerEmail = callerDoc.data()?['email'] ?? '';
      final callerProfilePic = callerDoc.data()?['profilePic'] ?? '';
      final modelCallType = ZegoCallHelper.getCallType(callType);

      final existingCall = await _callService.getCall(callID);

      if (existingCall == null) {
        await _callService.createCall(
          callId: callID,
          callerId: caller.id, // The person who initiated the call
          callerEmail: callerEmail, // The caller's email
          callerName: caller.name,
          callerProfilePic: callerProfilePic,
          receiverId: currentUser.uid, // The current user (receiver)
          receiverEmail: currentUser.email ?? '',
          receiverName: currentUser.displayName ?? '', // Current user's email
          receiverProfilePic: currentUser.photoURL ?? '',
          callType: modelCallType,
        );
      }

      await _callService.updateCallStatus(
        callId: callID,
        status: CallStatus.ringing,
      );
    } catch (e) {
      print('❌ Error handling incoming call: $e');
    }
  }

  void onOutgoingCallAccepted(String callID, ZegoCallUser invitee) {
    _updateCallStatus(callID, CallStatus.in_progress);
    _activeCallsStartTime[callID] = DateTime.now();
  }

  void onOutgoingCallDeclined(
    String callID,
    ZegoCallUser invitee,
    String data,
  ) {
    _updateCallStatus(callID, CallStatus.rejected);
    _activeCallsStartTime.remove(callID);
  }

  void onOutgoingCallRejectedCauseBusy(
    String callID,
    ZegoCallUser invitee,
    String data,
  ) {
    _updateCallStatus(callID, CallStatus.rejected);
    _activeCallsStartTime.remove(callID);
  }

  void onIncomingCallCanceled(String callID, ZegoCallUser caller, String data) {
    _updateCallStatus(callID, CallStatus.cancelled);
    _activeCallsStartTime.remove(callID);
  }

  void onOutgoingCallTimeout(
    String callID,
    List<ZegoCallUser> invitees,
    bool timeout,
  ) {
    _updateCallStatus(callID, CallStatus.missed);
    _activeCallsStartTime.remove(callID);
  }

  void onIncomingCallTimeout(String callID, ZegoCallUser caller) {
    _updateCallStatus(callID, CallStatus.missed);
    _activeCallsStartTime.remove(callID);
  }

  Future<void> _updateCallStatus(String callID, CallStatus status) async {
    try {
      await _callService.updateCallStatus(callId: callID, status: status);
    } catch (e) {
      print('❌ Error updating call status: $e');
    }
  }

  Future<void> _completeCall(String callID, int duration) async {
    try {
      await _callService.updateCallStatus(
        callId: callID,
        status: CallStatus.completed,
        duration: duration,
      );
      _activeCallsStartTime.remove(callID);
    } catch (e) {
      print('❌ Error completing call: $e');
    }
  }

  /// Manually complete a call (call when user returns from call)
  Future<void> completeActiveCall(String callID) async {
    try {
      final call = await _callService.getCall(callID);

      if (call != null && call.status == CallStatus.in_progress) {
        final duration = DateTime.now().difference(call.startedAt).inSeconds;
        await _completeCall(callID, duration);
      }
    } catch (e) {
      print('❌ Error completing active call: $e');
    }
  }

  /// Complete all active calls for current user
  Future<void> completeAllActiveCalls() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final snapshot =
          await FirebaseFirestore.instance
              .collection('calls')
              .where('status', isEqualTo: CallStatus.in_progress.name)
              .get();

      for (var doc in snapshot.docs) {
        final call = CallModel.fromMap(doc.data());

        if (call.callerId == currentUser.uid ||
            call.receiverId == currentUser.uid) {
          final duration = DateTime.now().difference(call.startedAt).inSeconds;
          await _completeCall(call.callId, duration);
        }
      }
    } catch (e) {
      print('❌ Error completing active calls: $e');
    }
  }

  /// Dispose - stop cleanup timer
  void dispose() {
    _cleanupTimer?.cancel();
    _activeCallsStartTime.clear();
  }
}
